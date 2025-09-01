#!/bin/bash
# Runtime installation script for OmniTry on RunPod
# This script runs INSIDE the container after startup

echo "=== OmniTry Runtime Installation ==="
echo "Installing PyTorch and dependencies..."
echo ""

# Install PyTorch with CUDA
pip install torch==2.4.0 torchvision==0.19.0 torchaudio==2.4.0 --index-url https://download.pytorch.org/whl/cu124

# Clone OmniTry codebase
echo ""
echo "Cloning OmniTry repository..."
git clone https://github.com/Kunbyte-AI/OmniTry.git /app/omnitry

cd /app/omnitry

# Create checkpoints directory
echo ""
echo "Setting up checkpoints directory..."
mkdir -p checkpoints
cd checkpoints

# Download FLUX.1-Fill-dev model
echo "Downloading FLUX.1-Fill-dev base model..."
# This will be handled via RunPod volume mount or download at runtime
# huggingface-cli download black-forest-labs/FLUX.1-Fill-dev --local-dir FLUX.1-Fill-dev

# Download LoRA weights
echo "Downloading OmniTry LoRA weights..."
# huggingface-cli download Kunbyte/OmniTry omnitry_v1_unified.safetensors --local-dir .
# huggingface-cli download Kunbyte/OmniTry omnitry_v1_clothes.safetensors --local-dir .

echo ""
echo "Install Python dependencies..."
cd /app/omnitry
pip install -r requirements.txt

echo ""
echo "Install Flash Attention (optional performance boost)..."
pip install https://github.com/Dao-AILab/flash-attention/releases/download/v2.6.3/flash_attn-2.6.3+cu123torch2.4cxx11abiFALSE-cp311-cp311-linux_x86_64.whl

echo ""
echo "=== Installation Complete ==="
echo "RunPod container is ready for OmniTry!"
echo ""
echo "To start the demo:"
echo "  python gradio_demo.py"
echo ""
echo "Available LoRA models:"
echo "  - omnitry_v1_unified.safetensors (all garments)"
echo "  - omnitry_v1_clothes.safetensors (clothes only)"
echo ""
echo "Configure model selection in configs/omnitry_v1_unified.yaml"