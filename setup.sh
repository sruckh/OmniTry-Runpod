#!/bin/bash

# OmniTry Runtime Setup Script
# This script runs AFTER the container starts on RunPod
# All installation happens at runtime, not build time

set -e  # Exit on any error

echo "🚀 Starting OmniTry Runtime Setup..."

# Update system packages
echo "📦 Updating system packages..."
apt-get update && apt-get install -y \
    wget \
    git \
    software-properties-common \
    curl \
    ca-certificates

# Install OS vendor Python packages
echo "🐍 Installing Python and pip..."
apt-get install -y python python3-pip

# Install miniconda
echo "🐍 Installing Miniconda..."
cd /workspace
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh -b -p /workspace/miniconda
rm miniconda.sh

# Add conda to PATH
export PATH="/workspace/miniconda/bin:$PATH"
echo 'export PATH="/workspace/miniconda/bin:$PATH"' >> ~/.bashrc

# Initialize conda
/workspace/miniconda/bin/conda init bash
source ~/.bashrc

# Install PyTorch with specific versions
echo "🔥 Installing PyTorch..."
/workspace/miniconda/bin/conda install -y pytorch==2.4.0 torchvision==0.19.0 torchaudio==2.4.0 pytorch-cuda=12.4 -c pytorch -c nvidia

# Clone OmniTry repository
echo "📥 Cloning OmniTry repository..."
cd /workspace
git clone https://github.com/Kunbyte-AI/OmniTry.git
cd OmniTry

# Create checkpoints directory
echo "📁 Creating checkpoints directory..."
mkdir -p checkpoints

# Install huggingface_hub for downloading models
echo "🤗 Installing HuggingFace Hub..."
python -m pip install huggingface_hub[cli]

# Download models using new hf CLI
echo "📦 Downloading FLUX.1-Fill-dev model..."
hf download black-forest-labs/FLUX.1-Fill-dev --local-dir checkpoints/FLUX.1-Fill-dev

echo "📦 Downloading OmniTry unified model..."
hf download Kunbyte/OmniTry omnitry_v1_unified.safetensors --local-dir checkpoints/

echo "📦 Downloading OmniTry clothes model..."
hf download Kunbyte/OmniTry omnitry_v1_clothes.safetensors --local-dir checkpoints/

# Install requirements
echo "📦 Installing Python requirements..."
python -m pip install -r requirements.txt

# Install flash-attention wheel
echo "⚡ Installing Flash Attention..."
# Note: If Python version mismatch occurs, check available wheels at:
# https://github.com/Dao-AILab/flash-attention/releases/tag/v2.6.3
python -m pip install https://github.com/Dao-AILab/flash-attention/releases/download/v2.6.3/flash_attn-2.6.3+cu123torch2.4cxx11abiFALSE-cp311-cp311-linux_x86_64.whl

# Set environment variables for Gradio
export GRADIO_SERVER_NAME="0.0.0.0"
export GRADIO_SERVER_PORT="7860"

echo "✅ Setup complete! Starting OmniTry Gradio interface..."

# Start the application
python gradio_demo.py