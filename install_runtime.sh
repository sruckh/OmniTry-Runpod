#!/bin/bash

# Robust runtime installation script for OmniTry on RunPod
set -e  # Exit on any error

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

# Step 1: Install system dependencies if not already installed
log_info "Installing system dependencies..."
apt-get update
apt-get install -y software-properties-common
apt-get update
apt-get install -y python python3-pip git wget curl

# Step 2: Install miniconda if not already installed
if [ ! -d "$HOME/miniconda3" ]; then
    log_info "Installing Miniconda..."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
    bash miniconda.sh -b -p $HOME/miniconda3
    rm miniconda.sh
    source $HOME/miniconda3/bin/activate
    conda init
else
    log_info "Miniconda already installed, activating..."
    source $HOME/miniconda3/bin/activate
fi

# Step 3: Install PyTorch
log_info "Installing PyTorch..."
retry_command "conda install pytorch==2.4.0 torchvision==0.19.0 torchaudio==2.4.0 pytorch-cuda=12.4 -c pytorch -c nvidia -y"

# Step 4: Handle repository clone
REPO_URL="https://github.com/Kunbyte-AI/OmniTry.git"
REPO_DIR="OmniTry"

if [ -d "$REPO_DIR" ]; then
    log_warn "Repository directory $REPO_DIR already exists"

    # Check if it's a git repository
    if [ -d "$REPO_DIR/.git" ]; then
        log_info "Git repository found, checking status..."
        cd $REPO_DIR

        # Check if remote is correct
        current_remote=$(git remote get-url origin 2>/dev/null || echo "")
        if [[ "$current_remote" == *"/Kunbyte-AI/OmniTry.git" ]]; then
            log_info "Correct remote already configured"
            # Try to pull latest changes if possible
            log_info "Attempting to pull latest changes..."
            git pull origin main || log_warn "Could not pull latest changes, continuing with existing code"
        else
            log_warn "Remote URL mismatch, removing directory and recloning..."
            cd ..
            rm -rf $REPO_DIR
            log_info "Cloning repository..."
            retry_command "git clone $REPO_URL $REPO_DIR"
        fi
    else
        log_warn "Directory exists but is not a git repository, removing and recloning..."
        rm -rf $REPO_DIR
        log_info "Cloning repository..."
        retry_command "git clone $REPO_URL $REPO_DIR"
    fi
else
    log_info "Cloning repository..."
    retry_command "git clone $REPO_URL $REPO_DIR"
fi

cd $REPO_DIR
log_info "Changed to repository directory: $(pwd)"

# Step 5: Create checkpoint directory
log_info "Creating checkpoint directory..."
mkdir -p checkpoints

# Step 6: Download Hugging Face models
log_info "Setting up Hugging Face CLI..."
pip install huggingface-hub

# Function to download model with retry
download_model() {
    local model_id="$1"
    local local_path="$2"

    if [ -d "$local_path" ]; then
        log_info "Model already exists at $local_path, skipping download"
        return 0
    fi

    log_info "Downloading model: $model_id to $local_path"

    # Try using huggingface-hub first
    if retry_command "python -c \"from huggingface_hub import snapshot_download; snapshot_download(repo_id='$model_id', local_dir='$local_path', allow_patterns=['*.safetensors', '*.json', '*.txt'])\""; then
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

# Download models
download_model "black-forest-labs/FLUX.1-Fill-dev" "checkpoints/FLUX.1-Fill-dev"
download_model "Kunbyte/OmniTry" "checkpoints/omnitry_v1_unified"
download_model "Kunbyte/OmniTry" "checkpoints/omnitry_v1_clothes"

# Step 7: Install Python requirements
log_info "Installing Python requirements..."
retry_command "pip install -r requirements.txt"

# Step 8: Install Flash Attention with retry logic
log_info "Installing Flash Attention..."
FLASH_ATTENTION_URL="https://github.com/Dao-AILab/flash-attention/releases/download/v2.6.3/flash_attn-2.6.3+cu123torch2.4cxx11abiFALSE-cp310-cp310-linux_x86_64.whl"

# Try multiple installation methods
if retry_command "pip install --no-cache-dir $FLASH_ATTENTION_URL"; then
    log_info "Flash Attention installed successfully"
elif retry_command "pip install --no-cache-dir --upgrade $FLASH_ATTENTION_URL"; then
    log_info "Flash Attention installed successfully with --upgrade"
elif retry_command "pip install --no-cache-dir --timeout=600 $FLASH_ATTENTION_URL"; then
    log_info "Flash Attention installed successfully with extended timeout"
else
    log_warn "Flash Attention installation failed, continuing without it..."
    log_warn "Note: The application may run slower without Flash Attention"
fi

# Step 9: Verify installation
log_info "Verifying installation..."

# Check if gradio_demo.py exists
if [ ! -f "gradio_demo.py" ]; then
    log_error "gradio_demo.py not found!"
    exit 1
fi

# Check if checkpoint files exist
if [ ! -d "checkpoints" ]; then
    log_error "Checkpoints directory not found!"
    exit 1
fi

log_info "Installation completed successfully!"
log_info "Starting OmniTry application..."

# Start the application
exec python gradio_demo.py