# OmniTry RunPod Container

A containerized version of [OmniTry](https://github.com/Kunbyte-AI/OmniTry) optimized for RunPod deployment. OmniTry is an AI-powered virtual try-on application that allows users to try on clothes virtually using advanced diffusion models.

## 🚀 Quick Start on RunPod

1. **Create a new pod** on RunPod
2. **Select this container**: `gemneye/omnitry-runpod:latest`
3. **Configure settings**:
   - **Port**: 7860 (Gradio web interface)
   - **GPU**: Recommended RTX 3090 or better
   - **VRAM**: Minimum 12GB
4. **Start the pod** and wait for setup to complete (first run takes 10-15 minutes)
5. **Access the interface** via the provided RunPod URL

## 🛠 Container Architecture

This container uses a **runtime setup approach** optimized for RunPod:

- **Base Image**: `nvidia/cuda:12.3.2-cudnn9-runtime-ubuntu22.04`
- **Build Time**: Only base image installation
- **Runtime**: All dependencies installed when container starts

### Runtime Installation Process

When the container starts, it automatically:

1. ✅ Installs Miniconda and Python 3.11
2. ✅ Installs PyTorch 2.4.0 with CUDA 12.4 support
3. ✅ Clones the OmniTry repository
4. ✅ Downloads required models:
   - FLUX.1-Fill-dev (~12GB)
   - OmniTry unified model
   - OmniTry clothes model
5. ✅ Installs Python dependencies
6. ✅ Installs Flash Attention for performance
7. ✅ Starts Gradio web interface on port 7860

## 📋 System Requirements

- **GPU**: NVIDIA GPU with 12GB+ VRAM (RTX 3090/4090 recommended)
- **RAM**: 16GB+ system RAM
- **Storage**: 25GB+ free space for models and cache
- **Architecture**: AMD64 only

## 🔧 Environment Variables

Optional environment variables you can set in RunPod:

```bash
HF_TOKEN=your_huggingface_token  # If needed for private models
GRADIO_SERVER_NAME=0.0.0.0       # Server bind address (default)
GRADIO_SERVER_PORT=7860          # Server port (default)
```

## 📊 Model Information

This container automatically downloads:

- **FLUX.1-Fill-dev**: Base diffusion model (~12GB)
- **OmniTry Unified**: Main virtual try-on model
- **OmniTry Clothes**: Specialized clothing model

Models are cached between runs when using persistent storage.

## 🔍 Troubleshooting

### Container Won't Start
- Ensure sufficient VRAM (12GB+ required)
- Check RunPod logs for setup progress
- First run requires 10-15 minutes for model downloads

### Out of Memory Errors
- Use GPU with more VRAM
- Close other GPU applications
- Restart the pod

### Slow Performance
- Ensure CUDA drivers are properly installed
- Use recommended RTX 3090 or better
- Check GPU utilization in RunPod

## 🔗 Links

- **Original Project**: [Kunbyte-AI/OmniTry](https://github.com/Kunbyte-AI/OmniTry)
- **RunPod Container**: [sruckh/OmniTry-Runpod](https://github.com/sruckh/OmniTry-Runpod)
- **Docker Hub**: [gemneye/omnitry-runpod](https://hub.docker.com/r/gemneye/omnitry-runpod)

## 📝 License

This container follows the same license as the original OmniTry project. Please refer to the [original repository](https://github.com/Kunbyte-AI/OmniTry) for licensing information.

---

**Built for RunPod** • **AMD64 Architecture** • **CUDA 12.3 Ready**