#!/bin/bash
set -e  # Exit on any error

# ====================================================================
# OmniTry Runtime Installation Script for RunPod
# This script handles ALL runtime installation steps for OmniTry
# ====================================================================

# Configuration
LOGFILE="/tmp/omnitry_startup.log"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/workspace"
OMNITRY_REPO="https://github.com/Kunbyte-AI/OmniTry.git"
FLUX_MODEL_REPO="https://huggingface.co/black-forest-labs/FLUX.1-Fill-dev"
LORA_REPO="https://huggingface.co/Kunbyte/OmniTry"
FLASH_ATTN_WHEEL="https://github.com/Dao-AILab/flash-attention/releases/download/v2.6.3/flash_attn-2.6.3+cu123torch2.4cxx11abiFALSE-cp310-cp310-linux_x86_64.whl"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "INFO")
            echo -e "${GREEN}[INFO]${NC} $message" | tee -a "$LOGFILE"
            ;;
        "WARN")
            echo -e "${YELLOW}[WARN]${NC} $message" | tee -a "$LOGFILE"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message" | tee -a "$LOGFILE"
            ;;
        "DEBUG")
            echo -e "${BLUE}[DEBUG]${NC} $message" | tee -a "$LOGFILE"
            ;;
    esac
    echo "[$timestamp][$level] $message" >> "$LOGFILE"
}

# Error handling function
handle_error() {
    local exit_code=$?
    local line_number=$1
    log "ERROR" "Script failed at line $line_number with exit code $exit_code"
    log "ERROR" "Check $LOGFILE for detailed logs"
    exit $exit_code
}

# Set up error trap
trap 'handle_error ${LINENO}' ERR

# Progress indicator
show_progress() {
    local current=$1
    local total=$2
    local description=$3
    local percentage=$((current * 100 / total))
    log "INFO" "[$current/$total] ($percentage%) $description"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log "INFO" "Running as root user"
    else
        log "WARN" "Not running as root - some operations may fail"
    fi
}

# Check what's already available in the base image
check_base_image() {
    log "INFO" "=== NVIDIA Base Image Analysis ==="
    
    # Check Python installations
    log "INFO" "--- Python Analysis ---"
    if command -v python3 &> /dev/null; then
        log "INFO" "Python3 available: $(python3 --version)"
        log "INFO" "Python3 location: $(which python3)"
    else
        log "INFO" "Python3 not found"
    fi
    
    if command -v python &> /dev/null; then
        log "INFO" "Python available: $(python --version)"
        log "INFO" "Python location: $(which python)"
    else
        log "INFO" "Python not found"
    fi
    
    # Check pip
    if command -v pip3 &> /dev/null; then
        log "INFO" "pip3 available: $(pip3 --version)"
    else
        log "INFO" "pip3 not found"
    fi
    
    # Check conda
    log "INFO" "--- Conda Analysis ---"
    if command -v conda &> /dev/null; then
        log "INFO" "Conda available: $(conda --version)"
        log "INFO" "Conda location: $(which conda)"
        log "INFO" "Conda environments:"
        conda env list 2>/dev/null || log "INFO" "Could not list conda environments"
    else
        log "INFO" "Conda not found"
    fi
    
    # Check CUDA
    log "INFO" "--- CUDA Analysis ---"
    if command -v nvidia-smi &> /dev/null; then
        log "INFO" "NVIDIA SMI available:"
        nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader,nounits 2>/dev/null || log "WARN" "Could not query GPU info"
    else
        log "INFO" "nvidia-smi not found"
    fi
    
    if command -v nvcc &> /dev/null; then
        log "INFO" "NVCC available: $(nvcc --version | grep release)"
    else
        log "INFO" "nvcc not found"
    fi
    
    # Check PyTorch
    log "INFO" "--- PyTorch Analysis ---"
    if python3 -c "import torch; print(f'PyTorch {torch.__version__} (CUDA: {torch.cuda.is_available()})')" 2>/dev/null; then
        log "INFO" "PyTorch is already installed and working"
        python3 -c "import torch; print(f'CUDA devices: {torch.cuda.device_count()}')" 2>/dev/null || true
    else
        log "INFO" "PyTorch not found or not working"
    fi
    
    # Check other ML libraries
    log "INFO" "--- ML Libraries Analysis ---"
    for lib in numpy scipy sklearn transformers; do
        if python3 -c "import $lib; print(f'$lib available')" 2>/dev/null; then
            log "INFO" "$lib is available"
        else
            log "INFO" "$lib not found"
        fi
    done
    
    # Check system info
    log "INFO" "--- System Info ---"
    log "INFO" "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"')"
    log "INFO" "Architecture: $(uname -m)"
    log "INFO" "Available memory: $(free -h | grep '^Mem:' | awk '{print $2}')"
    log "INFO" "Available disk space: $(df -h / | tail -1 | awk '{print $4}')"
    
    log "INFO" "=== End Base Image Analysis ==="
}

# System update and preparation
prepare_system() {
    show_progress 1 9 "Updating system packages"
    
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y -qq \
        software-properties-common \
        wget \
        curl \
        git \
        build-essential \
        ca-certificates \
        gnupg \
        lsb-release \
        unzip \
        git-lfs \
        htop \
        vim \
        tmux
    
    log "INFO" "System packages updated successfully"
}

# Setup Python environment (use existing Python 3.10.12 from NVIDIA base image)
setup_python() {
    show_progress 2 9 "Setting up Python environment"
    
    # Based on NVIDIA base image analysis: Python 3.10.12 is available, but pip3 is missing
    log "INFO" "Using existing Python 3.10.12 from NVIDIA base image"
    
    # Install pip3 which is missing from base image
    log "INFO" "Installing pip3 (missing from base image)..."
    apt-get update -qq
    apt-get install -y -qq python3-pip python3-dev python3-venv
    
    # Verify Python and pip installation
    python3 --version || { log "ERROR" "Python verification failed"; exit 1; }
    pip3 --version || { log "ERROR" "pip3 installation failed"; exit 1; }
    
    log "INFO" "Python environment ready: $(python3 --version) with pip3 $(pip3 --version)"
}

# Install and setup conda
install_conda() {
    show_progress 3 9 "Installing Miniconda"
    
    if command -v conda &> /dev/null; then
        log "INFO" "Conda already installed: $(conda --version)"
        return 0
    fi
    
    # Download and install Miniconda
    local conda_installer="/tmp/Miniconda3-latest-Linux-x86_64.sh"
    wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O "$conda_installer"
    
    # Install Miniconda silently
    bash "$conda_installer" -b -p /opt/miniconda3
    rm "$conda_installer"
    
    # Add conda to PATH
    export PATH="/opt/miniconda3/bin:$PATH"
    echo 'export PATH="/opt/miniconda3/bin:$PATH"' >> ~/.bashrc
    
    # Initialize conda
    /opt/miniconda3/bin/conda init bash
    source ~/.bashrc
    
    # Verify installation
    conda --version || { log "ERROR" "Conda installation failed"; exit 1; }
    
    log "INFO" "Miniconda installed successfully: $(conda --version)"
}

# Install PyTorch with CUDA support using pip (no conda needed)
install_pytorch() {
    show_progress 3 9 "Installing PyTorch with CUDA support"
    
    # Install PyTorch with the exact specified versions using pip
    # Based on GOALS.md: pytorch==2.4.0 torchvision==0.19.0 torchaudio==2.4.0 pytorch-cuda=12.4
    log "INFO" "Installing PyTorch 2.4.0 with CUDA 12.4 support via pip..."
    
    pip3 install torch==2.4.0 torchvision==0.19.0 torchaudio==2.4.0 --index-url https://download.pytorch.org/whl/cu124
    
    # Verify PyTorch installation
    python3 -c "import torch; print(f'PyTorch version: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}')" || {
        log "ERROR" "PyTorch installation failed"
        exit 1
    }
    
    log "INFO" "PyTorch installed successfully with CUDA support"
}

# Clone OmniTry repository
clone_repository() {
    show_progress 4 8 "Cloning OmniTry repository"
    
    cd "$INSTALL_DIR"
    
    if [[ -d "OmniTry" ]]; then
        log "INFO" "OmniTry directory exists, pulling latest changes"
        cd OmniTry
        git pull origin main
    else
        log "INFO" "Cloning OmniTry repository from $OMNITRY_REPO"
        git clone "$OMNITRY_REPO" OmniTry
        cd OmniTry
    fi
    
    # Enable Git LFS if needed
    git lfs install
    
    log "INFO" "OmniTry repository cloned/updated successfully"
}

# Download models and create checkpoints
setup_models() {
    show_progress 5 8 "Setting up model checkpoints"
    
    cd "$INSTALL_DIR/OmniTry"
    
    # Create checkpoints directory
    mkdir -p checkpoints/FLUX.1-Fill-dev
    
    log "INFO" "Downloading FLUX.1-Fill-dev model (this may take a while...)"
    
    # Download FLUX.1-Fill-dev model using git with LFS
    if [[ ! -d "checkpoints/FLUX.1-Fill-dev/.git" ]]; then
        cd checkpoints
        git clone "$FLUX_MODEL_REPO" FLUX.1-Fill-dev
        cd FLUX.1-Fill-dev
        git lfs pull
        cd ../..
    else
        log "INFO" "FLUX.1-Fill-dev already exists, updating..."
        cd checkpoints/FLUX.1-Fill-dev
        git pull origin main
        git lfs pull
        cd ../..
    fi
    
    log "INFO" "Downloading OmniTry LoRA models"
    
    # Download OmniTry LoRA models
    if [[ ! -f "checkpoints/omnitry_v1_unified.safetensors" ]]; then
        wget -q "$LORA_REPO/resolve/main/omnitry_v1_unified.safetensors" -O checkpoints/omnitry_v1_unified.safetensors
    else
        log "INFO" "omnitry_v1_unified.safetensors already exists"
    fi
    
    if [[ ! -f "checkpoints/omnitry_v1_clothes.safetensors" ]]; then
        wget -q "$LORA_REPO/resolve/main/omnitry_v1_clothes.safetensors" -O checkpoints/omnitry_v1_clothes.safetensors
    else
        log "INFO" "omnitry_v1_clothes.safetensors already exists"
    fi
    
    log "INFO" "Model checkpoints setup completed"
}

# Install Python requirements
install_requirements() {
    show_progress 6 8 "Installing Python requirements"
    
    cd "$INSTALL_DIR/OmniTry"
    
    # Upgrade pip first
    python3 -m pip install --upgrade pip
    
    # Install requirements
    if [[ -f "requirements.txt" ]]; then
        pip3 install -r requirements.txt
        log "INFO" "Python requirements installed successfully"
    else
        log "ERROR" "requirements.txt not found"
        exit 1
    fi
}

# Install flash-attention
install_flash_attention() {
    show_progress 7 8 "Installing flash-attention wheel"
    
    # Download and install flash-attention wheel
    local wheel_file="/tmp/flash_attn-2.6.3+cu123torch2.4cxx11abiFALSE-cp310-cp310-linux_x86_64.whl"
    
    log "INFO" "Downloading flash-attention wheel..."
    wget -q "$FLASH_ATTN_WHEEL" -O "$wheel_file"
    
    log "INFO" "Installing flash-attention..."
    pip3 install "$wheel_file"
    
    # Clean up
    rm -f "$wheel_file"
    
    # Verify installation
    python3 -c "import flash_attn; print('Flash-attention installed successfully')" || {
        log "ERROR" "Flash-attention installation failed"
        exit 1
    }
    
    log "INFO" "Flash-attention installed successfully"
}

# Final setup and validation
finalize_setup() {
    show_progress 8 8 "Finalizing setup and validation"
    
    cd "$INSTALL_DIR/OmniTry"
    
    # Validate all components
    log "INFO" "Validating installation..."
    
    # Check Python
    python3 --version || { log "ERROR" "Python validation failed"; exit 1; }
    
    # Check PyTorch
    python3 -c "import torch; print(f'PyTorch {torch.__version__} with CUDA: {torch.cuda.is_available()}')" || {
        log "ERROR" "PyTorch validation failed"; exit 1
    }
    
    # Check flash-attention
    python3 -c "import flash_attn; print('Flash-attention: OK')" || {
        log "ERROR" "Flash-attention validation failed"; exit 1
    }
    
    # Check required files
    local required_files=(
        "gradio_demo.py"
        "requirements.txt"
        "checkpoints/omnitry_v1_unified.safetensors"
        "checkpoints/omnitry_v1_clothes.safetensors"
        "checkpoints/FLUX.1-Fill-dev"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -e "$file" ]]; then
            log "ERROR" "Required file/directory missing: $file"
            exit 1
        fi
    done
    
    # Set executable permissions
    chmod +x gradio_demo.py 2>/dev/null || true
    
    # Create startup script for the application
    cat > start_omnitry.sh << 'EOF'
#!/bin/bash
cd /workspace/OmniTry
export PATH="/opt/miniconda3/bin:$PATH"
python3 gradio_demo.py
EOF
    chmod +x start_omnitry.sh
    
    log "INFO" "Installation completed successfully!"
    log "INFO" "To start OmniTry, run: cd $INSTALL_DIR/OmniTry && python3 gradio_demo.py"
    log "INFO" "Or use the convenience script: $INSTALL_DIR/OmniTry/start_omnitry.sh"
}

# Main execution function
main() {
    log "INFO" "Starting OmniTry runtime installation for RunPod"
    log "INFO" "Log file: $LOGFILE"
    log "INFO" "Installation directory: $INSTALL_DIR"
    
    # Create workspace directory
    mkdir -p "$INSTALL_DIR"
    
    # Check prerequisites
    check_root
    
    # Analyze base image capabilities
    check_base_image
    
    # Execute installation steps (optimized for NVIDIA base image)
    prepare_system
    setup_python
    install_pytorch
    clone_repository
    setup_models
    install_requirements
    install_flash_attention
    finalize_setup
    
    log "INFO" "=== Installation Summary ==="
    log "INFO" "✅ Python 3.10.12 (from NVIDIA base image) + pip3 installed"
    log "INFO" "✅ PyTorch 2.4.0 with CUDA 12.4 installed (via pip)"
    log "INFO" "✅ OmniTry repository cloned"
    log "INFO" "✅ FLUX.1-Fill-dev model downloaded"
    log "INFO" "✅ LoRA models downloaded"
    log "INFO" "✅ Python requirements installed"
    log "INFO" "✅ Flash-attention installed (Python 3.10 wheel)"
    log "INFO" "=== Ready to run OmniTry! ==="
    
    # Show final instructions
    echo ""
    echo -e "${GREEN}🚀 Installation completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}To start OmniTry:${NC}"
    echo -e "  cd $INSTALL_DIR/OmniTry"
    echo -e "  python3 gradio_demo.py"
    echo ""
    echo -e "${BLUE}Or use the convenience script:${NC}"
    echo -e "  $INSTALL_DIR/OmniTry/start_omnitry.sh"
    echo ""
    echo -e "${YELLOW}Application will be available at: http://localhost:7860${NC}"
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi