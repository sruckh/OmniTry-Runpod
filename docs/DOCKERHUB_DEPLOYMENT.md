# OmniTry Docker Hub Deployment Guide 🐳

## 📦 Docker Hub Repository

**Repository**: `gemneye/omnitry-runpod`
**Latest Tag**: `:latest`

## 🚀 Deployment Methods

### 1. Docker Pull and Run

```bash
# Pull the latest image
docker pull gemneye/omnitry-runpod:latest

# Run the container
docker run -d \
    -p 7860:7860 \
    -e HF_TOKEN=your_huggingface_token \
    -e GRADIO_SHARE=false \
    -e RUNPOD_GRADIO_USERNAME=admin \
    -e RUNPOD_GRADIO_PASSWORD=your_secure_password \
    --gpus all \
    gemneye/omnitry-runpod:latest
```

### 2. Docker Compose

```yaml
version: '3.8'
services:
  omnitry:
    image: gemneye/omnitry-runpod:latest
    ports:
      - "7860:7860"
    environment:
      - HF_TOKEN=your_huggingface_token
      - GRADIO_SHARE=false
      - RUNPOD_GRADIO_USERNAME=admin
      - RUNPOD_GRADIO_PASSWORD=your_secure_password
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
```

## 🔧 Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `HF_TOKEN` | Optional | - | Hugging Face access token for model downloads |
| `GRADIO_SHARE` | Optional | `false` | Enable/disable public Gradio sharing |
| `RUNPOD_GRADIO_USERNAME` | Optional | - | Basic authentication username |
| `RUNPOD_GRADIO_PASSWORD` | Optional | - | Basic authentication password |
| `WORKSPACE_DIR` | Optional | `/workspace` | Container workspace directory |
| `GRADIO_SERVER_PORT` | Optional | `7860` | Gradio server port |
| `GRADIO_SERVER_NAME` | Optional | `0.0.0.0` | Gradio server host |

## 📊 System Requirements

- **GPU**: NVIDIA GPU with CUDA support
- **VRAM**: 28GB+ (32GB recommended)
- **Docker**: 20.10+ with NVIDIA Container Toolkit
- **Operating System**: Linux (Ubuntu 22.04+ recommended)

## 🛡️ Security Considerations

- Use strong, unique passwords
- Limit container network access
- Regularly update the Docker image
- Use environment-specific configurations

## 🔄 Image Versioning

| Tag | Description |
|-----|-------------|
| `latest` | Most recent stable release |
| `v1.0.0` | Specific version releases |
| `dev` | Development/unstable builds |

## 🚧 Troubleshooting

- Verify Docker and NVIDIA Container Toolkit installation
- Check Docker logs: `docker logs <container_id>`
- Ensure GPU drivers are correctly installed
- Validate environment variable configurations

## 📦 Building Custom Image

```bash
# Clone repository
git clone https://github.com/Kunbyte-AI/OmniTry.git
cd OmniTry

# Build Docker image
docker build -t omnitry-runpod .

# Optional: Push to your Docker Hub
docker tag omnitry-runpod:latest your_dockerhub_username/omnitry-runpod:latest
docker push your_dockerhub_username/omnitry-runpod:latest
```

## 📝 Notes

- First run may take 15-45 minutes for dependency installation
- Subsequent runs are much faster
- Monitor GPU memory usage
- Keep the image updated for latest features and security fixes

## 🆘 Support

- **Docker Hub Issues**: Report in GitHub repository
- **Deployment Help**: RunPod Discord, GitHub Discussions
- **Enterprise Support**: Contact Kunbyte AI development team

*Last Updated: 2025-09-02*