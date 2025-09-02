# OmniTry RunPod Deployment Guide

This guide explains how to deploy OmniTry on RunPod using the containerized setup.

## 🚀 Quick Start

### Option 1: Use Pre-built Docker Image (Recommended)

1. **Create RunPod Instance**
   - Go to [RunPod.io](https://runpod.io)
   - Click "Deploy" → "GPU Pods"
   - Select a GPU with at least 16GB VRAM (RTX 4090, A100, etc.)

2. **Configure Container**
   - **Docker Image**: `gemneye/omnitry-runpod:latest`
   - **Container Disk**: 40GB minimum (recommended: 50GB)
   - **Exposed HTTP Port**: `7860`

3. **Environment Variables (Optional)**
   ```
   HF_TOKEN=your_huggingface_token_here
   GRADIO_SHARE=false
   RUNPOD_GRADIO_USERNAME=admin
   RUNPOD_GRADIO_PASSWORD=your_password_here
   ```

4. **Deploy and Wait**
   - The container will automatically install all dependencies on first run
   - This process takes 15-30 minutes depending on your internet connection
   - Monitor logs to track installation progress

5. **Access Application**
   - Use the RunPod provided URL (port 7860)
   - Or click "Connect" → "HTTP Service [Port 7860]"

### Option 2: Build from Source

```bash
# Clone repository
git clone https://github.com/your-repo/OmniTry.git
cd OmniTry

# Build Docker image
docker build -t omnitry-runpod .

# Push to your registry (optional)
docker tag omnitry-runpod your-registry/omnitry-runpod:latest
docker push your-registry/omnitry-runpod:latest
```

## 📋 System Requirements

### Minimum Requirements
- **GPU**: 16GB VRAM (RTX 4090, A100, etc.)
- **RAM**: 16GB system RAM
- **Disk**: 40GB free space
- **Network**: Good internet connection for model downloads

### Recommended Requirements
- **GPU**: 24GB+ VRAM (A100, RTX 6000 Ada)
- **RAM**: 32GB+ system RAM
- **Disk**: 60GB+ free space
- **Network**: High-speed connection (>100 Mbps)

## 🔧 Configuration Options

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `WORKSPACE_DIR` | `/workspace` | Container workspace directory |
| `GRADIO_SERVER_PORT` | `7860` | Gradio server port |
| `GRADIO_SERVER_NAME` | `0.0.0.0` | Gradio server host |
| `GRADIO_SHARE` | `false` | Enable Gradio sharing |
| `HF_TOKEN` | - | Hugging Face access token |
| `RUNPOD_GRADIO_USERNAME` | - | Basic auth username |
| `RUNPOD_GRADIO_PASSWORD` | - | Basic auth password |

### RunPod Template Configuration

```json
{
  "name": "OmniTry Virtual Try-On",
  "imageName": "gemneye/omnitry-runpod:latest",
  "dockerArgs": "",
  "containerDiskInGb": 50,
  "volumeInGb": 0,
  "volumeMountPath": "",
  "ports": "7860/http",
  "env": [
    {
      "key": "HF_TOKEN",
      "value": "your_token_here"
    }
  ]
}
```

## 🚀 Startup Process

The container follows this startup sequence:

1. **Environment Check**: Detects RunPod environment and validates system
2. **Dependency Installation**: Runs `startup.sh` to install all dependencies
3. **Model Download**: Downloads FLUX.1-Fill-dev and LoRA models (~20GB)
4. **Application Launch**: Starts Gradio demo with proper configuration
5. **Health Check**: Verifies application is running correctly

### Installation Steps (Automated)
1. Update system packages
2. Install Python 3.11 via deadsnakes PPA
3. Install Miniconda
4. Install PyTorch 2.4.0 with CUDA 12.4
5. Clone OmniTry repository
6. Download model checkpoints
7. Install Python requirements
8. Install flash-attention
9. Launch Gradio application

## 📊 Performance Expectations

### First Run (Cold Start)
- **Installation Time**: 15-30 minutes
- **Model Download**: 10-15 minutes
- **Total Startup**: 25-45 minutes

### Subsequent Runs (Warm Start)
- **Dependency Check**: 1-2 minutes
- **Application Launch**: 2-3 minutes
- **Total Startup**: 3-5 minutes

### Inference Performance
- **Image Processing**: 10-30 seconds per image
- **Memory Usage**: 12-18GB VRAM
- **Batch Processing**: Supported with sufficient VRAM

## 🐛 Troubleshooting

### Common Issues

#### 1. Out of VRAM
```
RuntimeError: CUDA out of memory
```
**Solution**: Use a GPU with more VRAM or enable model CPU offloading

#### 2. Model Download Fails
```
ConnectionError: Failed to download model
```
**Solutions**:
- Check internet connection
- Verify HF_TOKEN if using gated models
- Increase container disk space

#### 3. Permission Errors
```
PermissionError: [Errno 13] Permission denied
```
**Solution**: Ensure proper file permissions in the container

#### 4. Port Not Accessible
**Solutions**:
- Verify port 7860 is exposed in RunPod configuration
- Check firewall settings
- Ensure Gradio is binding to 0.0.0.0

### Debug Commands

```bash
# Check container logs
docker logs <container_id>

# Access container shell
docker exec -it <container_id> /bin/bash

# Check GPU status
nvidia-smi

# Check disk space
df -h

# Check application status
curl http://localhost:7860
```

### Log Files

- **Entrypoint Log**: `/tmp/omnitry_entrypoint.log`
- **Installation Log**: `/tmp/omnitry_startup.log`
- **Application Logs**: Container stdout/stderr

## 📁 File Structure

```
/workspace/
├── OmniTry/                    # Main application
│   ├── gradio_demo.py         # Gradio interface
│   ├── requirements.txt       # Python dependencies
│   ├── configs/               # Configuration files
│   ├── omnitry/              # Core application code
│   ├── checkpoints/          # Model checkpoints
│   │   ├── FLUX.1-Fill-dev/  # Main model
│   │   ├── omnitry_v1_unified.safetensors
│   │   └── omnitry_v1_clothes.safetensors
│   └── .gradio/              # Gradio temp files

/opt/scripts/
├── entrypoint.sh             # Container entrypoint
├── startup.sh                # Installation script
└── validate-workflows.sh     # Validation script

/tmp/
├── omnitry_entrypoint.log    # Entrypoint logs
└── omnitry_startup.log       # Installation logs
```

## 🔒 Security Considerations

### Authentication
- Enable basic authentication using `RUNPOD_GRADIO_USERNAME` and `RUNPOD_GRADIO_PASSWORD`
- Use strong passwords for production deployments

### Network Security
- RunPod provides network isolation by default
- Consider using Gradio sharing only when necessary
- Monitor access logs for suspicious activity

### Data Privacy
- Uploaded images are processed locally in the container
- No data is sent to external services (except model downloads)
- Images are temporarily stored in `/workspace/OmniTry/.gradio/`

## 📈 Optimization Tips

### Performance Optimization
1. **Use Fast Storage**: SSD/NVMe storage for better I/O
2. **Sufficient RAM**: 32GB+ for optimal caching
3. **High-End GPU**: RTX 4090/A100 for faster inference
4. **Network Speed**: Fast internet for initial setup

### Cost Optimization
1. **Auto-pause**: Enable auto-pause when not in use
2. **Instance Sizing**: Choose appropriate GPU size for your workload
3. **Spot Instances**: Use spot instances for development/testing
4. **Volume Management**: Delete unnecessary files to save storage costs

## 🆘 Support

### Documentation
- [OmniTry GitHub](https://github.com/Kunbyte-AI/OmniTry)
- [RunPod Documentation](https://docs.runpod.io/)
- [Gradio Documentation](https://gradio.app/docs/)

### Community
- GitHub Issues for bug reports
- RunPod Discord for deployment help
- Gradio Community for interface questions

### Professional Support
Contact the development team for enterprise support and custom deployments.

---

## 📝 Notes

- First run requires significant time for dependency installation and model downloads
- Subsequent runs are much faster as dependencies are cached
- Monitor GPU memory usage to avoid OOM errors
- Keep the container updated for latest features and security fixes

Happy virtual try-on! 🎉