# Suggested Commands for OmniTry Development

## Environment Setup
```bash
# Clone repository
git clone https://github.com/Kunbyte-AI/OmniTry.git
cd OmniTry

# Set up Python environment (Conda recommended)
conda env create -f environment.yml
conda activate omnitry

# Install dependencies
pip install -r requirements.txt

# Install Flash Attention (optional, performance boost)
pip install flash-attn==2.6.3
```

## Checkpoint Download
```bash
# Create checkpoints directory
mkdir -p checkpoints

# Download FLUX.1-Fill-dev base model
huggingface-cli download black-forest-labs/FLUX.1-Fill-dev --local-dir checkpoints/FLUX.1-Fill-dev

# Download OmniTry LoRA weights
# Unified weights (all garment types)
huggingface-cli download Kunbyte/OmniTry omnitry_v1_unified.safetensors --local-dir checkpoints/
# Cloth-specific weights
huggingface-cli download Kunbyte/OmniTry omnitry_v1_clothes.safetensors --local-dir checkpoints/
```

## Running the Project
```bash
# Basic demo launch
python gradio_demo.py

# Launch on specific port
gradio demo.py --server.port=7860

# Run without share (local only)
gradio demo.py --share=False
```

## Model Configuration
```bash
# Switch LoRA checkpoints by editing config
vim configs/omnitry_v1_unified.yaml

# Key config parameters:
# lora_path: checkpoints/omnitry_v1_unified.safetensors
# model_root: checkpoints/FLUX.1-Fill-dev
# lora_rank: 256
# lora_alpha: 256
```

## Development Commands
```bash
# Test imports
python -c "import torch; import diffusers; print('Imports OK')"

# Check CUDA available
python -c "import torch; print('CUDA available:', torch.cuda.is_available())"

# Check VRAM
python -c "import torch; print(torch.cuda.get_device_properties(0))"
```

## Benchmarking
```bash
# Run benchmark evaluation
cd omnitry_bench
python vtryon_metric.py  # Assumes evaluation data available
python vtryon_get_mask.py

# View benchmark documentation
cat README.MD
```

## Data Preprocessing
```bash
cd data_preprocess

# Ground objects inference
python infer_ground_objects.py

# List objects
python infer_list_objects.py

# Remove objects
python infer_remove_objects.py

# View preprocessing guide
cat README.MD
```

## Git Operations
```bash
# Standard Git workflow
git status
git add .
git commit -m "Update: [description]"
git push origin main

# Repository URL: https://github.com/sruckh/OmniTry-Runpod
```

## System Commands (Linux)
```bash
# Directory navigation
ls -la
pwd
cd omnitry/

# File operations
find . -name "*.py" -type f
grep -r "gradio" .
head -50 gradio_demo.py

# Network checks
ping google.com
curl -I http://localhost:7860

# Disk space (important for large models)
df -h
du -sh checkpoints/

# Memory usage
free -h
nvidia-smi

# Process monitoring
ps aux | grep python
top
htop
```

## Docker Commands (for deployment)
```bash
# Build container (in parent directory)
docker-compose up --build

# View logs
docker-compose logs -f

# Access container shell
docker exec -it omnitry_container /bin/bash

# Stop services
docker-compose down
```

## Debugging Commands
```bash
# Python debugging
python -m pdb gradio_demo.py

# Torch debugging
export CUDA_LAUNCH_BLOCKING=1
python gradio_demo.py

# Memory debugging
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

# Environment variables
export CUDA_VISIBLE_DEVICES=0
export TORCH_DEBUG=0
```

## Performance Monitoring
```bash
# GPU monitoring
watch nvidia-smi

# CPU monitoring
top -p $(pgrep python)

# Memory monitoring
python -c "import torch; print(f'GPU Memory: {torch.cuda.memory_allocated()/1e9:.2f}GB')"

# Model loading time
time python -c "from omnitry.pipelines.pipeline_flux_fill import FluxFillPipeline; print('Pipeline loaded')"
```

## Security Commands
```bash
# Scan for exposed secrets
grep -r "API_KEY\|SECRET\|TOKEN" . 2>/dev/null || echo "No obvious secrets found"

# Check file permissions
find checkpoints/ -type f -exec ls -la {} \; | head -10

# Secure file permissions
chmod 644 configs/*.yaml
chmod 755 *.sh
```