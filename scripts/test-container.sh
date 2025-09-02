#!/bin/bash

# ====================================================================
# Container Test Script for OmniTry RunPod Setup
# This script tests the container setup and validates functionality
# ====================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
TEST_LOG="/tmp/omnitry_test.log"
CONTAINER_NAME="omnitry-test"
IMAGE_NAME="omnitry-runpod:test"

# Logging function
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "INFO")
            echo -e "${GREEN}[INFO]${NC} $message" | tee -a "$TEST_LOG"
            ;;
        "WARN")
            echo -e "${YELLOW}[WARN]${NC} $message" | tee -a "$TEST_LOG"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message" | tee -a "$TEST_LOG"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[SUCCESS]${NC} $message" | tee -a "$TEST_LOG"
            ;;
    esac
    echo "[$timestamp][$level] $message" >> "$TEST_LOG"
}

# Test Docker build
test_build() {
    log "INFO" "Testing Docker build..."
    
    if docker build -t "$IMAGE_NAME" .; then
        log "SUCCESS" "Docker build successful"
        return 0
    else
        log "ERROR" "Docker build failed"
        return 1
    fi
}

# Test container startup
test_container_startup() {
    log "INFO" "Testing container startup..."
    
    # Clean up any existing test container
    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
    
    # Start container in detached mode
    if docker run -d \
        --name "$CONTAINER_NAME" \
        --gpus all \
        -p 7860:7860 \
        -e "HF_TOKEN=${HF_TOKEN:-}" \
        -e "GRADIO_SHARE=false" \
        "$IMAGE_NAME"; then
        log "SUCCESS" "Container started successfully"
        return 0
    else
        log "ERROR" "Container startup failed"
        return 1
    fi
}

# Test container health
test_container_health() {
    log "INFO" "Testing container health..."
    
    local max_attempts=60
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if docker exec "$CONTAINER_NAME" curl -s -f http://localhost:7860 >/dev/null 2>&1; then
            log "SUCCESS" "Container is healthy (attempt $attempt/$max_attempts)"
            return 0
        fi
        
        if [[ $attempt -eq 1 || $((attempt % 10)) -eq 0 ]]; then
            log "INFO" "Health check attempt $attempt/$max_attempts (waiting for startup...)"
        fi
        
        sleep 10
        ((attempt++))
    done
    
    log "ERROR" "Container health check failed after $max_attempts attempts"
    return 1
}

# Test API endpoints (basic check)
test_api_endpoints() {
    log "INFO" "Testing API endpoints..."
    
    # Test root endpoint
    if docker exec "$CONTAINER_NAME" curl -s -f http://localhost:7860 >/dev/null 2>&1; then
        log "SUCCESS" "Root endpoint accessible"
    else
        log "ERROR" "Root endpoint not accessible"
        return 1
    fi
    
    # Test if Gradio interface is working
    local response=$(docker exec "$CONTAINER_NAME" curl -s http://localhost:7860 2>/dev/null || echo "")
    if echo "$response" | grep -q "gradio" || echo "$response" | grep -q "Gradio"; then
        log "SUCCESS" "Gradio interface detected"
    else
        log "WARN" "Gradio interface not clearly detected"
    fi
    
    return 0
}

# Show container logs
show_container_logs() {
    log "INFO" "Showing container logs (last 50 lines)..."
    echo -e "\n${BLUE}=== Container Logs ===${NC}"
    docker logs --tail 50 "$CONTAINER_NAME"
    echo -e "${BLUE}======================${NC}\n"
}

# Cleanup test resources
cleanup() {
    log "INFO" "Cleaning up test resources..."
    
    # Stop and remove container
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
    
    # Remove test image (optional)
    if [[ "$1" == "--remove-image" ]]; then
        docker rmi "$IMAGE_NAME" 2>/dev/null || true
        log "INFO" "Test image removed"
    fi
    
    log "INFO" "Cleanup complete"
}

# Main test function
run_tests() {
    log "INFO" "Starting OmniTry container tests..."
    log "INFO" "Test log: $TEST_LOG"
    
    local failed=0
    
    # Test 1: Build
    if ! test_build; then
        ((failed++))
    fi
    
    # Test 2: Container startup
    if ! test_container_startup; then
        ((failed++))
        return $failed
    fi
    
    # Give container time to initialize
    log "INFO" "Waiting for container initialization (this may take 20-30 minutes on first run)..."
    sleep 30
    
    # Test 3: Health check
    if ! test_container_health; then
        ((failed++))
        show_container_logs
    else
        # Test 4: API endpoints (only if health check passes)
        if ! test_api_endpoints; then
            ((failed++))
        fi
    fi
    
    # Show results
    echo ""
    if [[ $failed -eq 0 ]]; then
        log "SUCCESS" "All tests passed! 🎉"
        log "INFO" "Container is ready for RunPod deployment"
        echo -e "${GREEN}✅ Build successful${NC}"
        echo -e "${GREEN}✅ Container startup successful${NC}"
        echo -e "${GREEN}✅ Health check passed${NC}"
        echo -e "${GREEN}✅ API endpoints working${NC}"
    else
        log "ERROR" "$failed test(s) failed"
        echo -e "${RED}❌ $failed test(s) failed${NC}"
        
        echo -e "\n${YELLOW}Troubleshooting tips:${NC}"
        echo "1. Check container logs: docker logs $CONTAINER_NAME"
        echo "2. Check GPU availability: nvidia-smi"
        echo "3. Verify sufficient disk space: df -h"
        echo "4. Check system memory: free -h"
        
        show_container_logs
    fi
    
    return $failed
}

# Handle script arguments
case "${1:-test}" in
    "test")
        run_tests
        exit_code=$?
        cleanup
        exit $exit_code
        ;;
    "build")
        test_build
        exit $?
        ;;
    "cleanup")
        cleanup --remove-image
        ;;
    "logs")
        show_container_logs
        ;;
    *)
        echo "Usage: $0 [test|build|cleanup|logs]"
        echo ""
        echo "Commands:"
        echo "  test     - Run full test suite (default)"
        echo "  build    - Test Docker build only"
        echo "  cleanup  - Clean up test resources"
        echo "  logs     - Show container logs"
        exit 1
        ;;
esac