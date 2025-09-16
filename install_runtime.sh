#!/bin/bash

# A robust runtime installation script for OmniTry on RunPod.
# This script is designed to be clean, efficient, and to follow a logical order of operations.

set -e
echo "🚀 Starting OmniTry installation..."

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to retry commands
retry_command() {
    local max_attempts=3
    local attempt=1
    local cmd="$@"

    while [ $attempt -le $max_attempts ]; do
        log_info "Attempt $attempt/$max_attempts: $cmd"
        if eval $cmd; then
            log_info "Command succeeded"
            return 0
        else
            log_error "Command failed (attempt $attempt/$max_attempts)"
            if [ $attempt -eq $max_attempts ]; then
                log_error "Max attempts reached. Exiting."
                return 1
            fi
            log_info "Waiting 10 seconds before retry..."
            sleep 10
            ((attempt++))
        fi
    done
}

log_info "Step 1: Installing essential system dependencies..."
apt-get update && apt-get install -y git wget curl

log_info "Step 2: Installing and setting up Miniconda..."
if [ ! -d "$HOME/miniconda3" ]; then
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
    bash miniconda.sh -b -p $HOME/miniconda3
    rm miniconda.sh
fi
source $HOME/miniconda3/bin/activate
conda init

log_info "Step 3: Accepting conda Terms of Service..."
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

log_info "Step 4: Cloning the OmniTry repository..."
REPO_URL="https://github.com/Kunbyte-AI/OmniTry.git"
REPO_DIR="OmniTry"
if [ ! -d "$REPO_DIR" ]; then
    retry_command "git clone $REPO_URL $REPO_DIR"
fi
cd $REPO_DIR

log_info "Step 5: Creating and activating the conda environment..."
conda create -n omnitry python=3.10 -y
source activate omnitry

log_info "Step 6: Installing all Python dependencies..."
retry_command "conda install pytorch==2.4.0 torchvision==0.19.0 torchaudio==2.4.0 pytorch-cuda=12.4 -c pytorch -c nvidia -y"
retry_command "pip install huggingface-hub hf_transfer[cli]"
retry_command "pip install -r requirements.txt"
retry_command "pip install protobuf"
FLASH_ATTENTION_URL="https://github.com/Dao-AILab/flash-attention/releases/download/v2.6.3/flash_attn-2.6.3+cu123torch2.4cxx11abiFALSE-cp310-cp310-linux_x86_64.whl"
if ! retry_command "pip install --no-cache-dir $FLASH_ATTENTION_URL"; then
    log_warn "Flash Attention installation failed, continuing without it..."
fi

log_info "Step 7: Copying local configs..."
cp -r /workspace/configs/* ./configs/

log_info "Step 8: Downloading models..."
export HF_HUB_ENABLE_HF_TRANSFER=1
download_model() {
    local model_id="$1"
    local local_path="$2"

    if [ -d "$local_path" ]; then
        log_info "Model already exists at $local_path, skipping download"
        return 0
    fi

    log_info "Downloading model: $model_id to $local_path"

    # Try using hf cli first
    if retry_command "hf download $model_id --local-dir $local_path"; then
        log_info "Successfully downloaded $model_id"
        return 0
    fi

    # Fallback to python
    log_warn "hf download failed, trying with python..."
    if retry_command "python -c \"from huggingface_hub import snapshot_download; snapshot_download(repo_id='$model_id', local_dir='$local_path', allow_patterns=['*.safetensors', '*.json', '*.txt'])\""
    then
        log_info "Successfully downloaded $model_id"
        return 0
    fi

    # Fallback to git lfs if available
    log_warn "huggingface-hub failed, trying git lfs..."
    if command -v git-lfs &> /dev/null; then
        if retry_command "git lfs clone $model_id $local_path"; then
            log_info "Successfully downloaded $model_id using git lfs"
            return 0
        fi
    fi

    log_error "Failed to download $model_id"
    return 1
}

download_model "black-forest-labs/FLUX.1-Fill-dev" "checkpoints/FLUX.1-Fill-dev"
download_model "Kunbyte/OmniTry" "checkpoints/omnitry_v1_unified"
download_model "Kunbyte/OmniTry" "checkpoints/omnitry_v1_clothes"


log_info "✅ Installation complete! Starting Gradio app..."
exec python gradio_demo.py