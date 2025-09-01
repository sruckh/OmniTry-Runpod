# OmniTry Project Overview

## Project Purpose
OmniTry is an advanced AI system for virtual try-on of clothing and accessories without requiring image masks. It uses diffusion models (FLUX.1-Fill-dev) with LoRA fine-tuning to generate realistic try-on results for various garment types including tops, bottoms, dresses, shoes, jewelry, hats, bags, and accessories.

## Tech Stack
- **Programming Language**: Python 3.11+
- **Core Framework**: PyTorch 2.4.0 with CUDA 12.4
- **Diffusion Model**: FLUX.1-Fill-dev from Hugging Face
- **Fine-tuning**: LoRA (Low-Rank Adaptation)
- **Web Interface**: Gradio 5.6.0
- **Additional Libraries**: 
  - transformers 4.45.0
  - diffusers 0.33.1
  - peft 0.13.2 (for LoRA)
  - safetensors for model loading
  - omegaconf for configuration

## Key Features
- Supports 12+ garment types (tops, bottoms, dresses, shoes, jewelry, etc.)
- Real-time generation through Gradio web interface
- Configurable checkpoints (omnitry_v1_unified.safetensors or omnitry_v1_clothes.safetensors)
- CPU offloading and memory optimization for 28GB VRAM requirement
- Integration with Hugging Face datasets for benchmarking

## Hardware Requirements
- Minimum VRAM: 28GB
- Recommended GPU: NVIDIA with CUDA 12.4+
- Base image: nvidia/cuda:12.3.2-cudnn9-runtime-ubuntu22.04

## Deployment Target
- RunPod platform as containerized service
- Entry point: python gradio_demo.py
- Port: 7860 (default Gradio port)