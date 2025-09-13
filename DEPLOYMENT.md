# OmniTry RunPod Deployment Guide

## 📋 Overview

This guide explains how to deploy the OmniTry virtual try-on application on RunPod using the containerized version.

## 🚀 RunPod Deployment Steps

### 1. Access RunPod
1. Go to [RunPod](https://runpod.io)
2. Sign up/login to your account
3. Navigate to "Pods" section

### 2. Create New Pod
1. Click "Deploy" or "Create Pod"
2. Select GPU type (recommended: RTX 3090 or better)
3. Choose container deployment option

### 3. Container Configuration
- **Container Image**: `gemneye/omnitry-runpod:latest`
- **Port**: `7860` (Gradio web interface)
- **Volume Size**: 50GB+ recommended (for model storage)

### 4. Advanced Settings (Optional)
```bash
# Environment Variables
HF_TOKEN=your_huggingface_token  # If needed for private models
GRADIO_SERVER_NAME=0.0.0.0
GRADIO_SERVER_PORT=7860
```

### 5. Deploy and Wait
1. Click "Deploy" 
2. Wait for pod to start (status: Running)
3. Monitor logs for setup progress
4. **First run takes 10-15 minutes** for model downloads

### 6. Access Application
1. Click on your running pod
2. Find the "Connect" button with port 7860
3. Click to open the Gradio web interface
4. Start using OmniTry for virtual try-on!

## 💰 Cost Optimization

### GPU Selection
| GPU | VRAM | Performance | Cost (approx) |
|-----|------|-------------|---------------|
| RTX 3090 | 24GB | Excellent | $0.34/hr |
| RTX 4090 | 24GB | Excellent | $0.44/hr |
| RTX 3080 | 10GB | Limited* | $0.24/hr |
| A100 | 40GB | Overkill | $1.89/hr |

*RTX 3080 may have VRAM limitations for larger models

### Cost Saving Tips
1. **Stop pods when not in use** - RunPod charges per minute
2. **Use Spot instances** for 50-80% cost savings
3. **Use persistent volumes** to avoid re-downloading models
4. **Monitor usage** through RunPod dashboard

## 🔧 Configuration Options

### Model Selection
The OmniTry application supports two model variants:
- `omnitry_v1_unified.safetensors` - General virtual try-on
- `omnitry_v1_clothes.safetensors` - Specialized for clothing

You can switch between models in the Gradio interface.

### Performance Tuning
For optimal performance:
1. Use RTX 3090/4090 GPUs
2. Ensure sufficient VRAM (12GB+)
3. Use SSD storage for faster model loading
4. Close unused browser tabs to free GPU memory

## 📊 Monitoring

### Pod Status
Monitor your pod through RunPod dashboard:
- **CPU Usage**: Should be moderate during inference
- **GPU Usage**: High during image generation
- **Memory Usage**: Monitor for out-of-memory errors
- **Network**: Initial high usage during model download

### Logs
Check container logs for:
- Setup progress during first run
- Error messages if issues occur
- Model download status
- Application startup confirmation

## 🔍 Troubleshooting

### Common Issues

#### Container Won't Start
```bash
# Check logs for:
- CUDA driver issues
- Insufficient VRAM
- Network connectivity problems
```

#### Models Won't Download
```bash
# Solutions:
- Check HF_TOKEN if using private models
- Verify network connectivity
- Ensure sufficient storage space
```

#### Out of Memory Errors
```bash
# Solutions:
- Use GPU with more VRAM
- Reduce batch size in application
- Close other GPU applications
- Restart pod to clear memory
```

#### Slow Performance
```bash
# Check:
- GPU utilization (should be high during generation)
- VRAM usage (shouldn't exceed available)
- Storage type (SSD preferred)
```

### Getting Help
1. Check RunPod community forums
2. Review container logs thoroughly
3. Verify system requirements are met
4. Contact RunPod support if infrastructure issues

## 🔄 Updates

The container is automatically built from the latest OmniTry code. To get updates:
1. Stop current pod
2. Create new pod with latest image
3. Models and settings will be preserved if using persistent volume

## 📝 Notes

- **First run**: Takes 10-15 minutes for complete setup
- **Model size**: ~15GB total download
- **Architecture**: AMD64 only (no ARM support)
- **CUDA**: Requires CUDA 12.3+ compatible GPU
- **Persistent storage**: Recommended for model caching

## 🔗 Additional Resources

- [RunPod Documentation](https://docs.runpod.io/)
- [OmniTry Original Repository](https://github.com/Kunbyte-AI/OmniTry)
- [Docker Hub Container](https://hub.docker.com/r/gemneye/omnitry-runpod)