#!/bin/bash
# Workflow validation script for OmniTry GitHub Actions

set -e

echo "=== GitHub Actions Workflow Validation ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if required tools are available
check_requirements() {
    echo "📋 Checking requirements..."
    
    local tools=("docker" "yq" "shellcheck")
    local missing=()
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing+=("$tool")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}❌ Missing required tools: ${missing[*]}${NC}"
        echo "Please install missing tools to continue."
        exit 1
    fi
    
    echo -e "${GREEN}✅ All requirements satisfied${NC}"
    echo ""
}

# Validate YAML syntax
validate_yaml() {
    echo "🔍 Validating YAML syntax..."
    
    local workflows_dir=".github/workflows"
    local errors=0
    
    for workflow in "$workflows_dir"/*.yml "$workflows_dir"/*.yaml 2>/dev/null; do
        if [ -f "$workflow" ]; then
            echo "  Checking $(basename "$workflow")..."
            if yq eval . "$workflow" > /dev/null 2>&1; then
                echo -e "    ${GREEN}✅ Valid YAML${NC}"
            else
                echo -e "    ${RED}❌ Invalid YAML${NC}"
                errors=$((errors + 1))
            fi
        fi
    done
    
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}✅ All YAML files are valid${NC}"
    else
        echo -e "${RED}❌ Found $errors YAML validation errors${NC}"
        return 1
    fi
    echo ""
}

# Check for secrets usage
validate_secrets() {
    echo "🔐 Validating secrets usage..."
    
    local workflows_dir=".github/workflows"
    local issues=0
    
    for workflow in "$workflows_dir"/*.yml "$workflows_dir"/*.yaml 2>/dev/null; do
        if [ -f "$workflow" ]; then
            echo "  Checking $(basename "$workflow") for secrets..."
            
            # Check for hardcoded credentials (basic patterns)
            if grep -i -E "(password|token|key|secret).*['\"].*['\"]" "$workflow" | grep -v "secrets\." > /dev/null; then
                echo -e "    ${RED}❌ Potential hardcoded credentials found${NC}"
                issues=$((issues + 1))
            fi
            
            # Check for proper secrets usage
            if grep -E "secrets\.(DOCKER_USERNAME|DOCKER_PASSWORD)" "$workflow" > /dev/null; then
                echo -e "    ${GREEN}✅ Using GitHub secrets properly${NC}"
            else
                echo -e "    ${YELLOW}⚠️  No Docker Hub secrets found (may be intentional)${NC}"
            fi
        fi
    done
    
    if [ $issues -eq 0 ]; then
        echo -e "${GREEN}✅ No security issues found${NC}"
    else
        echo -e "${RED}❌ Found $issues potential security issues${NC}"
        return 1
    fi
    echo ""
}

# Validate Dockerfile
validate_dockerfile() {
    echo "🐳 Validating Dockerfile..."
    
    if [ -f "Dockerfile" ]; then
        # Basic Dockerfile validation
        if docker build --dry-run . > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Dockerfile syntax is valid${NC}"
        else
            echo -e "${RED}❌ Dockerfile has syntax errors${NC}"
            return 1
        fi
        
        # Check for security best practices
        local warnings=0
        
        # Check for USER instruction
        if ! grep -q "^USER " Dockerfile; then
            echo -e "${YELLOW}⚠️  Consider adding USER instruction for security${NC}"
            warnings=$((warnings + 1))
        fi
        
        # Check for COPY vs ADD
        if grep -q "^ADD " Dockerfile && ! grep -q "^ADD.*\.tar" Dockerfile; then
            echo -e "${YELLOW}⚠️  Consider using COPY instead of ADD for files${NC}"
            warnings=$((warnings + 1))
        fi
        
        if [ $warnings -eq 0 ]; then
            echo -e "${GREEN}✅ Dockerfile follows security best practices${NC}"
        else
            echo -e "${YELLOW}⚠️  Found $warnings potential improvements${NC}"
        fi
    else
        echo -e "${RED}❌ Dockerfile not found${NC}"
        return 1
    fi
    echo ""
}

# Check shell scripts
validate_scripts() {
    echo "📜 Validating shell scripts..."
    
    local errors=0
    
    # Find all shell scripts
    while IFS= read -r -d '' script; do
        echo "  Checking $(basename "$script")..."
        if shellcheck "$script" > /dev/null 2>&1; then
            echo -e "    ${GREEN}✅ Shell script is clean${NC}"
        else
            echo -e "    ${RED}❌ Shell script has issues${NC}"
            shellcheck "$script" || true
            errors=$((errors + 1))
        fi
    done < <(find . -name "*.sh" -type f -print0)
    
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}✅ All shell scripts are clean${NC}"
    else
        echo -e "${RED}❌ Found issues in $errors shell scripts${NC}"
        return 1
    fi
    echo ""
}

# Validate required files
validate_structure() {
    echo "📁 Validating project structure..."
    
    local required_files=(
        ".github/workflows/docker-build.yml"
        "Dockerfile"
        "requirements.txt"
        "docs/DOCKERHUB.md"
    )
    
    local missing=()
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing+=("$file")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}❌ Missing required files:${NC}"
        for file in "${missing[@]}"; do
            echo "    - $file"
        done
        return 1
    else
        echo -e "${GREEN}✅ All required files present${NC}"
    fi
    echo ""
}

# Main execution
main() {
    echo "Starting workflow validation for OmniTry project..."
    echo "================================================"
    echo ""
    
    local errors=0
    
    check_requirements || errors=$((errors + 1))
    validate_structure || errors=$((errors + 1))
    validate_yaml || errors=$((errors + 1))
    validate_secrets || errors=$((errors + 1))
    validate_dockerfile || errors=$((errors + 1))
    validate_scripts || errors=$((errors + 1))
    
    echo "================================================"
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}🎉 All validations passed! Workflows are ready for deployment.${NC}"
        exit 0
    else
        echo -e "${RED}❌ Found $errors validation errors. Please fix before deploying.${NC}"
        exit 1
    fi
}

# Run main function
main "$@"