# OmniTry RunPod Container - Deployment Guide

## 🚀 Automated Docker Hub Deployment

This project includes a complete CI/CD pipeline that automatically builds and pushes Docker containers to Docker Hub when code is pushed to the repository.

### 📋 Workflow Overview

#### Primary Build Workflow (`docker-build.yml`)
- **Triggers**: Push to main/master branch, pull requests, manual dispatch
- **Platform**: linux/amd64 (RunPod requirement)
- **Registry**: docker.io/gemneye/omnitry-runpod
- **Security**: Uses GitHub secrets DOCKER_USERNAME and DOCKER_PASSWORD
- **Features**:
  - Multi-platform tagging (latest, SHA, date-based)
  - Docker Hub description auto-update
  - Security scanning with Trivy
  - GitHub cache optimization
  - Compliance reporting

#### Security Scanning (`security-scan.yml`)
- **Triggers**: Daily at 2 AM UTC, on Dockerfile changes, manual dispatch
- **Scans**: Container vulnerabilities, Dockerfile best practices, Python dependencies
- **Reporting**: GitHub Security tab integration
- **Tools**: Trivy, Hadolint, Safety

### 🏷️ Container Tags

The automated workflow creates multiple tags for different use cases:

| Tag Pattern | Description | Use Case |
|-------------|-------------|----------|
| `latest` | Latest stable release | Production deployment |
| `main-{sha}` | Development builds | Testing and development |
| `YYYY.MM.DD` | Date-based releases | Version tracking |
| `{branch}` | Branch-specific builds | Feature testing |

### 🔐 Security Best Practices

✅ **Implemented Security Measures**:
- GitHub secrets for Docker Hub authentication
- No hardcoded credentials in any files
- Regular vulnerability scanning
- Dockerfile security linting
- Python dependency security checks
- SARIF reporting to GitHub Security tab
- Minimal attack surface with runtime installations

### 🛠️ Manual Validation

A validation script is provided to test workflows locally:

```bash
# Run complete validation
./scripts/validate-workflows.sh

# Individual checks
docker build --dry-run .  # Test Docker build
yq eval .github/workflows/*.yml  # Validate YAML syntax
shellcheck scripts/*.sh  # Validate shell scripts
```

### 📊 Deployment Workflow

1. **Code Push** → Triggers GitHub Actions
2. **Security Checks** → Validates code and dependencies
3. **Docker Build** → Creates container for linux/amd64
4. **Registry Push** → Uploads to gemneye/omnitry-runpod
5. **Documentation Update** → Updates Docker Hub description
6. **Scan Results** → Reports to GitHub Security tab

### 🔧 Environment Variables

The following GitHub secrets must be configured in repository settings:

| Secret | Description | Required |
|--------|-------------|----------|
| `DOCKER_USERNAME` | Docker Hub username | ✅ Yes |
| `DOCKER_PASSWORD` | Docker Hub password/token | ✅ Yes |

### 📈 Monitoring and Maintenance

- **Daily Security Scans**: Automated vulnerability assessment
- **Build Status**: Monitor via GitHub Actions tab
- **Docker Hub Metrics**: Track pulls and image size
- **Security Alerts**: GitHub Security tab notifications

### 🚀 RunPod Deployment

Once the container is built and pushed, deploy on RunPod:

1. **Image**: `gemneye/omnitry-runpod:latest`
2. **Platform**: GPU-enabled (RTX 4090/A6000 recommended)
3. **Port**: 7860 (Gradio interface)
4. **Storage**: 20GB+ for models and checkpoints
5. **Environment**: Configure optional variables as needed

### 🔍 Troubleshooting

#### Build Failures
- Check GitHub Actions logs for detailed error messages
- Verify Dockerfile syntax with local build test
- Ensure all required files are present

#### Push Failures
- Verify Docker Hub credentials are correctly set in GitHub secrets
- Check Docker Hub repository permissions
- Ensure image name and tags are valid

#### Security Scan Issues
- Review Trivy scan results in GitHub Security tab
- Address high/critical vulnerabilities in base images
- Update Python dependencies if security issues found

### 📚 Additional Resources

- **GitHub Repository**: [sruckh/OmniTry-RunPod](https://github.com/sruckh/OmniTry-RunPod)
- **Docker Hub**: [gemneye/omnitry-runpod](https://hub.docker.com/r/gemneye/omnitry-runpod)
- **RunPod Documentation**: [runpod.io/docs](https://docs.runpod.io)
- **Original Project**: [Kunbyte-AI/OmniTry](https://github.com/Kunbyte-AI/OmniTry)

---

## 🎯 Quick Start Summary

1. **Configure GitHub Secrets**: Add DOCKER_USERNAME and DOCKER_PASSWORD
2. **Push Code**: Workflow automatically triggers on push to main
3. **Monitor Build**: Check GitHub Actions tab for build status
4. **Deploy on RunPod**: Use `gemneye/omnitry-runpod:latest`
5. **Access Interface**: Connect to port 7860 for Gradio UI

The entire deployment pipeline is now automated and follows security best practices! 🎉