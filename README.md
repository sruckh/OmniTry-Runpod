# OmniTry: Virtual Try-On Anything without Masks 👗🌐

A cutting-edge AI solution for virtual clothing try-on using advanced machine learning techniques.

## 🌈 Project Overview

OmniTry is an advanced AI-powered virtual clothing try-on platform developed by Kunbyte AI in collaboration with Zhejiang University. Our innovative approach allows users to virtually try on clothing without traditional masking techniques.

[![Paper](https://img.shields.io/badge/arXiv-OmniTry-red)](http://arxiv.org/abs/2508.13632)
[![Project Page](https://img.shields.io/badge/project%20page-OmniTry-green)](https://omnitry.github.io/)
[![Hugging Face Model](https://img.shields.io/badge/%F0%9F%A4%97%20Hugging%20Face-Model-yellow)](https://huggingface.co/Kunbyte/OmniTry)
[![Hugging Face Spaces](https://img.shields.io/badge/%F0%9F%A4%97%20Hugging%20Face-Spaces-blue)](https://huggingface.co/spaces/Kunbyte/OmniTry)

## 🚀 Quick Start

### System Requirements

- **Minimum**: 28GB VRAM, GPU with CUDA support
- **Recommended**: RTX 4090, A100 with 32GB+ VRAM
- **Operating System**: Linux (Ubuntu 22.04+)

### Installation Options

#### 1. Docker Deployment (Recommended)

```bash
# Pull pre-built Docker image
docker pull gemneye/omnitry-runpod:latest

# Run container
docker run -p 7860:7860 \
    -e HF_TOKEN=your_huggingface_token \
    -e GRADIO_SHARE=false \
    gemneye/omnitry-runpod:latest
```

#### 2. Local Development Setup

##### Download Checkpoints
1. Create checkpoint directory: 
   ```bash
   mkdir -p checkpoints/FLUX.1-Fill-dev
   ```

2. Download model checkpoints:
   - [FLUX.1-Fill-dev](https://huggingface.co/black-forest-labs/FLUX.1-Fill-dev)
   - [OmniTry LoRA](https://huggingface.co/Kunbyte/OmniTry)

##### Environment Setup

###### Using Conda
```bash
conda env create -f environment.yml
conda activate omnitry
```

###### Using pip
```bash
pip install -r requirements.txt
pip install flash-attn==2.6.3  # Optional, for acceleration
```

### 🖼️ Usage

```bash
# Launch Gradio Demo
python gradio_demo.py

# Switch LoRA model
# Edit: configs/omnitry_v1_unified.yaml
# Change lora_path to desired model checkpoint
```

### 🔀 LoRA Model Switching

OmniTry supports multiple LoRA models:
- `omnitry_v1_unified.safetensors`: General-purpose model
- `omnitry_v1_clothes.safetensors`: Clothing-specific fine-tuned model

To switch models, modify `configs/omnitry_v1_unified.yaml` and update the `lora_path`.

## 📦 RunPod Deployment

For detailed RunPod deployment instructions, refer to [RUNPOD_DEPLOYMENT.md](RUNPOD_DEPLOYMENT.md).

### Environment Variables

- `HF_TOKEN`: Hugging Face access token
- `GRADIO_SHARE`: Enable/disable Gradio public sharing
- `RUNPOD_GRADIO_USERNAME`: Optional basic authentication username
- `RUNPOD_GRADIO_PASSWORD`: Optional basic authentication password

## 🛠️ Troubleshooting

Common issues and solutions:
- **VRAM Limitations**: Use a GPU with 32GB+ VRAM or enable CPU offloading
- **Model Download Failures**: 
  - Check internet connection
  - Verify Hugging Face token
  - Ensure sufficient disk space
- **Permission Errors**: Check container file permissions
- **Port Accessibility**: Verify port 7860 is exposed and accessible

## 📊 Performance Expectations

- **First Run**: 25-45 minutes (dependency and model installation)
- **Subsequent Runs**: 3-5 minutes
- **Image Processing**: 10-30 seconds per image
- **VRAM Usage**: 12-18GB

## 🔒 Security Considerations

- Basic authentication available via environment variables
- Local image processing with no external data transmission
- Network isolation provided by container environment

## 🤝 Acknowledgements

Developed using:
- [Diffusers](https://github.com/huggingface/diffusers)
- [FLUX](https://github.com/black-forest-labs/flux)

## 📝 Citation

If you use OmniTry in your research, please cite:

```bibtex
@article{feng2025omnitry,
  title={OmniTry: Virtual Try-On Anything without Masks},
  author={Feng, Yutong and Zhang, Linlin and Cao, Hengyuan and Chen, Yiming and Feng, Xiaoduan and Cao, Jian and Wu, Yuxiong and Wang, Bin},
  journal={arXiv preprint arXiv:2508.13632},
  year={2025}
}
```

## 🌐 Support

- **Documentation**: [OmniTry GitHub](https://github.com/Kunbyte-AI/OmniTry)
- **Community**: GitHub Issues, RunPod Discord
- **Enterprise Support**: Contact development team for custom deployments