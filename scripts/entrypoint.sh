#!/bin/bash
set -e  # Exit on any error

# ====================================================================
# OmniTry Container Entrypoint Script for RunPod
# This script handles runtime setup and launches the Gradio demo
# ====================================================================

# Configuration
LOGFILE="/tmp/omnitry_entrypoint.log"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
APP_DIR="$WORKSPACE_DIR/OmniTry"
STARTUP_SCRIPT="$SCRIPT_DIR/startup.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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
        "SUCCESS")
            echo -e "${CYAN}[SUCCESS]${NC} $message" | tee -a "$LOGFILE"
            ;;
    esac
    echo "[$timestamp][$level] $message" >> "$LOGFILE"
}

# Error handling function
handle_error() {
    local exit_code=$?
    local line_number=$1
    log "ERROR" "Entrypoint failed at line $line_number with exit code $exit_code"
    log "ERROR" "Check $LOGFILE for detailed logs"
    
    # Show last few lines of log for debugging
    echo -e "\n${RED}=== Last 10 lines from log file ===${NC}"
    tail -n 10 "$LOGFILE" 2>/dev/null || echo "Could not read log file"
    
    exit $exit_code
}

# Set up error trap
trap 'handle_error ${LINENO}' ERR

# Signal handler for graceful shutdown
handle_shutdown() {
    log "INFO" "Received shutdown signal, cleaning up..."
    if [[ -n $GRADIO_PID ]]; then
        kill $GRADIO_PID 2>/dev/null || true
        wait $GRADIO_PID 2>/dev/null || true
    fi
    log "INFO" "Shutdown complete"
    exit 0
}

# Set up signal traps
trap handle_shutdown SIGTERM SIGINT

# Check if we're running in RunPod
check_runpod_environment() {
    if [[ -n "$RUNPOD_POD_ID" ]]; then
        log "INFO" "Running in RunPod environment (Pod ID: $RUNPOD_POD_ID)"
        export RUNPOD_DETECTED=true
    else
        log "INFO" "Not running in RunPod, using standard container mode"
        export RUNPOD_DETECTED=false
    fi
    
    # Log environment information
    log "DEBUG" "Container environment:"
    log "DEBUG" "  HOSTNAME: ${HOSTNAME:-unknown}"
    log "DEBUG" "  USER: ${USER:-unknown}"
    log "DEBUG" "  HOME: ${HOME:-unknown}"
    log "DEBUG" "  PWD: ${PWD:-unknown}"
    log "DEBUG" "  WORKSPACE_DIR: $WORKSPACE_DIR"
}

# Process RunPod-specific environment variables
process_environment_variables() {
    log "INFO" "Processing environment variables..."
    
    # Set default values for common RunPod variables
    export GRADIO_SERVER_PORT="${GRADIO_SERVER_PORT:-7860}"
    export GRADIO_SERVER_NAME="${GRADIO_SERVER_NAME:-0.0.0.0}"
    export GRADIO_SHARE="${GRADIO_SHARE:-false}"
    
    # RunPod-specific configurations
    if [[ "$RUNPOD_DETECTED" == "true" ]]; then
        # RunPod typically uses port 7860 for HTTP services
        export GRADIO_SERVER_PORT="7860"
        export GRADIO_SERVER_NAME="0.0.0.0"
        
        # Enable sharing if specified
        if [[ "${RUNPOD_GRADIO_SHARE}" == "true" ]]; then
            export GRADIO_SHARE="true"
        fi
        
        # Set up authentication if provided
        if [[ -n "$RUNPOD_GRADIO_USERNAME" && -n "$RUNPOD_GRADIO_PASSWORD" ]]; then
            export GRADIO_AUTH="$RUNPOD_GRADIO_USERNAME:$RUNPOD_GRADIO_PASSWORD"
            log "INFO" "Gradio authentication configured"
        fi
    fi
    
    # Hugging Face token for model downloads
    if [[ -n "$HF_TOKEN" ]]; then
        export HUGGING_FACE_HUB_TOKEN="$HF_TOKEN"
        log "INFO" "Hugging Face token configured"
    fi
    
    # Log final configuration
    log "INFO" "Final configuration:"
    log "INFO" "  GRADIO_SERVER_PORT: $GRADIO_SERVER_PORT"
    log "INFO" "  GRADIO_SERVER_NAME: $GRADIO_SERVER_NAME"
    log "INFO" "  GRADIO_SHARE: $GRADIO_SHARE"
    
    if [[ -n "$GRADIO_AUTH" ]]; then
        log "INFO" "  GRADIO_AUTH: configured"
    fi
}

# Validate system requirements
validate_system() {
    log "INFO" "Validating system requirements..."
    
    # Check CUDA availability
    if command -v nvidia-smi &> /dev/null; then
        log "INFO" "NVIDIA GPU detected:"
        nvidia-smi --query-gpu=name,memory.total,memory.used --format=csv,noheader,nounits | while read line; do
            log "INFO" "  GPU: $line"
        done
    else
        log "WARN" "No NVIDIA GPU detected - OmniTry may not work properly"
    fi
    
    # Check available disk space
    local available_space=$(df /workspace 2>/dev/null | tail -1 | awk '{print $4}' || echo "0")
    local available_gb=$((available_space / 1024 / 1024))
    
    if [[ $available_gb -lt 10 ]]; then
        log "WARN" "Low disk space available: ${available_gb}GB (recommended: >20GB)"
    else
        log "INFO" "Disk space available: ${available_gb}GB"
    fi
    
    # Check memory
    local total_memory=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local total_memory_gb=$((total_memory / 1024 / 1024))
    
    if [[ $total_memory_gb -lt 8 ]]; then
        log "WARN" "Low system memory: ${total_memory_gb}GB (recommended: >16GB)"
    else
        log "INFO" "System memory: ${total_memory_gb}GB"
    fi
}

# Run the startup script if OmniTry is not already installed
check_and_install() {
    log "INFO" "Checking OmniTry installation..."
    
    # Check if OmniTry is already installed
    if [[ -f "$APP_DIR/gradio_demo.py" && -d "$APP_DIR/checkpoints" && -f "$APP_DIR/checkpoints/omnitry_v1_unified.safetensors" ]]; then
        log "SUCCESS" "OmniTry appears to be already installed"
        
        # Quick validation
        cd "$APP_DIR"
        if python3 -c "import torch; import diffusers; import transformers; print('Dependencies OK')" 2>/dev/null; then
            log "SUCCESS" "Dependencies validated successfully"
            return 0
        else
            log "WARN" "Dependencies validation failed, will reinstall"
        fi
    fi
    
    log "INFO" "OmniTry not found or incomplete, running installation..."
    
    # Check if startup script exists
    if [[ ! -f "$STARTUP_SCRIPT" ]]; then
        log "ERROR" "Startup script not found at: $STARTUP_SCRIPT"
        exit 1
    fi
    
    # Make startup script executable
    chmod +x "$STARTUP_SCRIPT"
    
    # Run the startup script
    log "INFO" "Executing startup script..."
    bash "$STARTUP_SCRIPT"
    
    if [[ $? -eq 0 ]]; then
        log "SUCCESS" "Installation completed successfully"
    else
        log "ERROR" "Installation failed"
        exit 1
    fi
}

# Setup paths and environment
setup_environment() {
    log "INFO" "Setting up environment..."
    
    # Add conda to PATH if it exists
    if [[ -d "/opt/miniconda3/bin" ]]; then
        export PATH="/opt/miniconda3/bin:$PATH"
        log "INFO" "Added conda to PATH"
    fi
    
    # Change to application directory
    if [[ ! -d "$APP_DIR" ]]; then
        log "ERROR" "Application directory not found: $APP_DIR"
        exit 1
    fi
    
    cd "$APP_DIR"
    log "INFO" "Changed to application directory: $APP_DIR"
    
    # Set GRADIO_TEMP_DIR to avoid permission issues
    export GRADIO_TEMP_DIR="$APP_DIR/.gradio"
    mkdir -p "$GRADIO_TEMP_DIR"
    
    # Set Python path
    export PYTHONPATH="$APP_DIR:$PYTHONPATH"
    
    log "INFO" "Environment setup complete"
}

# Health check function
health_check() {
    local max_attempts=30
    local attempt=1
    local port="$GRADIO_SERVER_PORT"
    
    log "INFO" "Performing health check on port $port..."
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -s -f "http://localhost:$port" >/dev/null 2>&1; then
            log "SUCCESS" "Health check passed (attempt $attempt/$max_attempts)"
            return 0
        fi
        
        log "DEBUG" "Health check attempt $attempt/$max_attempts failed, retrying in 5 seconds..."
        sleep 5
        ((attempt++))
    done
    
    log "WARN" "Health check failed after $max_attempts attempts"
    return 1
}

# Launch the Gradio application
launch_gradio() {
    log "INFO" "Launching OmniTry Gradio application..."
    
    # Create a modified version of gradio_demo.py to accept environment variables
    local demo_script="gradio_demo.py"
    
    if [[ ! -f "$demo_script" ]]; then
        log "ERROR" "Gradio demo script not found: $demo_script"
        exit 1
    fi
    
    # Set up launch parameters
    local launch_args=""
    
    # Add server configuration
    launch_args="--server-name $GRADIO_SERVER_NAME --server-port $GRADIO_SERVER_PORT"
    
    # Add authentication if configured
    if [[ -n "$GRADIO_AUTH" ]]; then
        launch_args="$launch_args --auth $GRADIO_AUTH"
    fi
    
    # Add sharing if enabled
    if [[ "$GRADIO_SHARE" == "true" ]]; then
        launch_args="$launch_args --share"
    fi
    
    log "INFO" "Starting Gradio with arguments: $launch_args"
    log "INFO" "Application will be available at:"
    log "INFO" "  Local: http://localhost:$GRADIO_SERVER_PORT"
    
    if [[ "$RUNPOD_DETECTED" == "true" ]]; then
        log "INFO" "  RunPod: Use the provided RunPod URL"
    fi
    
    if [[ "$GRADIO_SHARE" == "true" ]]; then
        log "INFO" "  Public: Will be displayed after startup"
    fi
    
    # Launch the application
    export PYTHONUNBUFFERED=1
    python3 "$demo_script" &
    GRADIO_PID=$!
    
    log "INFO" "Gradio application started with PID: $GRADIO_PID"
    
    # Wait a moment for startup
    sleep 10
    
    # Perform health check
    if health_check; then
        log "SUCCESS" "🚀 OmniTry is ready!"
        log "SUCCESS" "Access the application at http://localhost:$GRADIO_SERVER_PORT"
    else
        log "WARN" "Health check failed, but application may still be starting..."
    fi
    
    # Keep the container running
    log "INFO" "Container ready. Keeping alive..."
    wait $GRADIO_PID
}

# Show startup banner
show_banner() {
    echo -e "\n${CYAN}"
    echo "██████╗ ███╗   ███╗███╗   ██╗██╗████████╗██████╗ ██╗   ██╗"
    echo "██╔═══██╗████╗ ████║████╗  ██║██║╚══██╔══╝██╔══██╗╚██╗ ██╔╝"
    echo "██║   ██║██╔████╔██║██╔██╗ ██║██║   ██║   ██████╔╝ ╚████╔╝ "
    echo "██║   ██║██║╚██╔╝██║██║╚██╗██║██║   ██║   ██╔══██╗  ╚██╔╝  "
    echo "╚██████╔╝██║ ╚═╝ ██║██║ ╚████║██║   ██║   ██║  ██║   ██║   "
    echo " ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   "
    echo -e "${NC}"
    echo -e "${GREEN}              RunPod Container Entrypoint              ${NC}"
    echo -e "${BLUE}              Virtual Try-On Technology              ${NC}"
    echo ""
}

# Main execution function
main() {
    # Show banner
    show_banner
    
    log "INFO" "Starting OmniTry container entrypoint..."
    log "INFO" "Log file: $LOGFILE"
    log "INFO" "Workspace directory: $WORKSPACE_DIR"
    
    # Execute startup sequence
    check_runpod_environment
    process_environment_variables
    validate_system
    check_and_install
    setup_environment
    launch_gradio
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi