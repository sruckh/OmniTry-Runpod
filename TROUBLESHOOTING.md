# OmniTry Troubleshooting Guide 🛠️

## 🚨 Common Issues and Solutions

### 1. Container Startup Issues

#### Symptom: apt_pkg ModuleNotFoundError
```
ModuleNotFoundError: No module named 'apt_pkg'
Traceback (most recent call last):
  File "/usr/bin/add-apt-repository", line 5, in <module>
    import apt_pkg
```

**Cause**: Missing software-properties-common package in minimal CUDA base image

**Solution**: ✅ **Fixed in startup script v1.2.0** 
- Comprehensive fix with fallback to manual PPA addition
- Installs complete apt_pkg dependency chain including python3-apt
- Automatic fallback to manual repository addition if add-apt-repository fails
- No user action required - fix includes multiple approaches

**Technical Fix Details**:
1. Installs complete dependency chain: `python3-apt`, `python3-apt-dev`, etc.
2. Sets PYTHONPATH to include Python dist-packages
3. Attempts `add-apt-repository` first
4. Falls back to manual PPA addition with GPG key if needed
5. Ensures robust Python 3.11 installation

**If still experiencing issues** (should not occur):
```bash
# Nuclear option - completely reset apt
apt-get update
apt-get install -y --reinstall python3-apt software-properties-common
export PYTHONPATH="/usr/lib/python3/dist-packages:$PYTHONPATH"
```

### 2. CUDA/GPU Related Problems

#### Symptom: Out of VRAM Error
```
RuntimeError: CUDA out of memory
```

**Solutions**:
- Use a GPU with more VRAM (32GB+ recommended)
- Enable model CPU offloading
- Reduce batch size in `configs/omnitry_v1_unified.yaml`
- Close other GPU-intensive applications

#### Symptom: No CUDA Devices Found
```
No CUDA-capable device detected
```

**Solutions**:
- Verify NVIDIA drivers are installed
- Check CUDA version compatibility
- Ensure GPU is recognized: `nvidia-smi`
- Reinstall PyTorch with CUDA support

### 2. Model Download Issues

#### Symptom: Connection Errors
```
ConnectionError: Failed to download model
```

**Solutions**:
- Check internet connection
- Verify Hugging Face token (`HF_TOKEN`)
- Increase container/system disk space
- Use direct model download from Hugging Face
- Check proxy/firewall settings

### 3. Permission and Access Problems

#### Symptom: Permission Denied
```
PermissionError: [Errno 13] Permission denied
```

**Solutions**:
- Run Docker container with appropriate permissions
- Use `chmod` to modify file permissions
- Check user and group IDs in container
- Verify volume mount configurations

### 4. Port and Networking Issues

#### Symptom: Port Not Accessible
- Gradio demo not reachable
- Connection timeout

**Solutions**:
- Verify port 7860 is exposed
- Check firewall settings
- Ensure Gradio binds to `0.0.0.0`
- Use `-p` flag correctly in Docker run command

### 5. LoRA Model Switching Problems

#### Symptom: Model Loading Failure
```
ValueError: Unable to load model checkpoint
```

**Solutions**:
- Verify checkpoint file path
- Check file integrity of `.safetensors`
- Ensure correct model format
- Validate YAML configuration

### 6. Performance and Resource Constraints

#### Symptom: Slow Inference
- Long processing times
- High resource consumption

**Solutions**:
- Use recommended GPU (RTX 4090, A100)
- Install `flash-attn` for acceleration
- Optimize model configuration
- Reduce image resolution
- Use batch processing

## 🔍 Diagnostic Commands

```bash
# Check GPU status
nvidia-smi

# Verify CUDA installation
python -c "import torch; print(torch.cuda.is_available())"

# Check disk space
df -h

# Container logs
docker logs <container_id>

# Check Python environment
python --version
pip list | grep torch
pip list | grep diffusers

# Validate Gradio connectivity
curl http://localhost:7860
```

## 📝 Logging and Debug Information

### Log File Locations
- Container Entrypoint: `/tmp/omnitry_entrypoint.log`
- Startup Process: `/tmp/omnitry_startup.log`
- Application Logs: Container stdout/stderr

### Recommended Debugging Steps
1. Check log files for specific error messages
2. Verify system and environment requirements
3. Ensure all dependencies are correctly installed
4. Test with minimal configuration
5. Update to latest version of OmniTry

## 🆘 Getting Help

- **GitHub Issues**: Detailed bug reports
- **RunPod Discord**: Deployment assistance
- **Hugging Face Community**: Model and inference support
- **Enterprise Support**: Contact Kunbyte AI development team

## 💡 Best Practices

- Keep software and dependencies updated
- Use recommended system configurations
- Monitor GPU and system resources
- Maintain clean and organized environment
- Use virtual environments for isolation

---

*Last Updated: 2025-09-02*