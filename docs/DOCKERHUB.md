# OmniTry RunPod Container

[![Docker Pulls](https://img.shields.io/docker/pulls/gemneye/omnitry-runpod)](https://hub.docker.com/r/gemneye/omnitry-runpod)
[![Docker Image Size](https://img.shields.io/docker/image-size/gemneye/omnitry-runpod/latest)](https://hub.docker.com/r/gemneye/omnitry-runpod)

**AI-powered virtual try-on system optimized for RunPod GPU cloud platform**

## 🎯 Overview

OmniTry is an advanced AI virtual try-on system that leverages FLUX.1-Fill-dev foundation models with specialized LoRA fine-tuning for realistic garment fitting and virtual clothing try-on applications. This container is specifically optimized for RunPod deployment with GPU acceleration.

## 🚀 Features

- **Advanced Virtual Try-On**: State-of-the-art garment fitting using FLUX.1-Fill-dev base model
- **Dual LoRA Models**: Choose between unified (all garments) or clothes-specific models
- **GPU Optimized**: Built for NVIDIA CUDA 12.3.2 with cuDNN 9 acceleration  
- **RunPod Ready**: Optimized deployment workflow for RunPod cloud platform
- **Interactive Demo**: Built-in Gradio interface for easy experimentation
- **Runtime Installation**: Minimal build-time footprint with post-startup dependency installation

## 📋 Requirements

- **Platform**: RunPod GPU cloud (A6000, RTX 4090, or better recommended)
- **GPU Memory**: Minimum 16GB VRAM (24GB+ recommended for optimal performance)
- **Storage**: 20GB+ free space for models and checkpoints
- **Network**: Stable internet connection for model downloads

## 🛠️ Quick Start on RunPod

### 1. Deploy Container
```bash
Image: gemneye/omnitry-runpod:latest
Ports: 7860
GPU Type: RTX 4090 / A6000 / A6000 Ada (recommended)
```

### 2. Environment Variables (Optional)
```bash
GRADIO_SHARE=true          # Enable public sharing
HF_TOKEN=your_hf_token     # Hugging Face token for private models
```

### 3. Post-Startup Installation
The container includes a runtime installation script that sets up:
- PyTorch 2.4.0 with CUDA 12.4 support
- OmniTry codebase from GitHub  
- Model checkpoints and dependencies
- Flash Attention for performance optimization

### 4. Access Interface
Once deployed, access the Gradio interface at:
```
https://your-pod-id-7860.proxy.runpod.net
```

## 🎨 Model Selection

Two specialized LoRA models are available:

- **`omnitry_v1_unified.safetensors`**: General-purpose model for all garment types
- **`omnitry_v1_clothes.safetensors`**: Specialized model for clothing-specific applications

Configure model selection in `configs/omnitry_v1_unified.yaml` within the container.

## 🏗️ Architecture

- **Base Image**: `nvidia/cuda:12.3.2-cudnn9-runtime-ubuntu22.04`
- **Python**: 3.11 via deadsnakes PPA
- **Framework**: PyTorch 2.4.0 with CUDA 12.4
- **UI**: Gradio web interface
- **Models**: FLUX.1-Fill-dev + OmniTry LoRA fine-tuning

## 📚 Documentation

- **GitHub Repository**: [sruckh/OmniTry-RunPod](https://github.com/sruckh/OmniTry-RunPod)
- **Original Project**: [Kunbyte-AI/OmniTry](https://github.com/Kunbyte-AI/OmniTry)
- **RunPod Platform**: [runpod.io](https://runpod.io)

## 🔧 Advanced Usage

### Custom Model Configuration
```bash
# Access container shell
docker exec -it container_name bash

# Edit configuration
nano /app/omnitry/configs/omnitry_v1_unified.yaml

# Restart demo with new settings
cd /app/omnitry && python gradio_demo.py
```

### Performance Optimization
- Enable Flash Attention for faster inference
- Use mixed precision training for memory efficiency  
- Configure batch processing for multiple try-ons
- Monitor GPU utilization and adjust settings accordingly

## 🛡️ Security & Compliance

- Regular security scans with Trivy
- No hardcoded credentials or secrets
- Minimal attack surface with runtime-only installations
- CUDA-optimized for performance without compromising security

## 📞 Support

For issues related to:
- **Container Deployment**: Check RunPod documentation and container logs
- **Model Performance**: Ensure adequate GPU memory and CUDA compatibility
- **Feature Requests**: Submit issues to the GitHub repository

## 📊 Version Tags

- `latest`: Latest stable release (recommended for production)
- `main-{sha}`: Development builds from main branch
- `YYYY.MM.DD`: Date-based releases for version tracking

---

**Built with ❤️ for the AI community | Optimized for RunPod GPU Cloud**