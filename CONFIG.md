# CONFIG.md

## Runtime Configuration

### Environment Variables

#### Required Variables
```bash
# GPU and Hardware Configuration
CUDA_VISIBLE_DEVICES=0                          # GPU device selection
PYTORCH_CUDA_ALLOC_CONF=expandable_segments    # Memory allocation

# Model Directories
FLUX_MODEL_ROOT=/path/to/checkpoints/FLUX.1-Fill-dev
LORA_CHECKPOINT=/path/to/checkpoints/omnitry_v1_unified.safetensors

# Gradio Configuration
GRADIO_SHARE=False                              # Local-only mode
GRADIO_PORT=7860                               # Default Gradio port
GRADIO_MAX_FILE_SIZE=50MB                      # Upload size limit
```

#### Optional Variables
```bash
# Performance Tuning
TORCH_DEBUG=0                                  # Disable torch debug logging
PYTORCH_ENABLE_MPS_FALLBACK=1                  # Mac MPS fallback
FLASH_ATTENTION_FORCE_BUILD=False              # Use wheel instead of compiling

# Hugging Face Configuration
HF_HUB_CACHE=/tmp/huggingface_cache             # Model cache location
HF_HOME=/opt/docker/models                     # HuggingFace home directory
HF_TOKEN=your_huggingface_token               # For private models

# Development Settings
CUDA_LAUNCH_BLOCKING=0                         # Async GPU operations
OMNITRY_LOG_LEVEL=INFO                         # Application logging
OMNITRY_MODEL_PRECISION=bfloat16               # Model precision
```

## Configuration Files

### Main Model Configuration
```yaml
# configs/omnitry_v1_unified.yaml - Primary configuration file
model_root: checkpoints/FLUX.1-Fill-dev          # Base FLUX model path
lora_path: checkpoints/omnitry_v1_unified.safetensors  # LoRA weights path
lora_rank: 256                                   # LoRA adapter rank
lora_alpha: 256                                  # LoRA scaling factor
weight_dtype: bfloat16                           # Model precision

# Generation Parameters
guidance_scale: 30                               # CLIP guidance strength
num_inference_steps: 20                          # Diffusion steps
denoising_strength: 1.0                         # Image-to-image strength

# Object Classes (12+ supported garments)
object_map:
  "top clothes": "A person wearing top clothing, photorealistic"
  "bottom clothes": "A person wearing bottom clothing, photorealistic"
  "dress": "A person wearing a dress, photorealistic"
  "shoe": "A person wearing shoes, photorealistic"
  "earrings": "A person wearing earrings, photorealistic"
  "bracelet": "A person wearing bracelets, photorealistic"
  "necklace": "A person wearing necklaces, photorealistic"
  "ring": "A person wearing rings, photorealistic"
  "sunglasses": "A person wearing sunglasses, photorealistic"
  "glasses": "A person wearing glasses, photorealistic"
  "belt": "A person wearing belts, photorealistic"
  "bag": "A person wearing bags, photorealistic"
  "hat": "A person wearing hats, photorealistic"
  "tie": "A person wearing ties, photorealistic"
  "bow tie": "A person wearing bow ties, photorealistic"
```

### Performance Configuration
```yaml
# Performance optimization settings
memory_optimization:
  enable_cpu_offload: true                        # Offload models to CPU
  enable_vae_tiling: true                         # Process VAE in tiles
  vram_efficient_unet: true                       # Memory optimization
  torch_compile: false                           # Experimental compilation
  flash_attention_available: true                 # Use flash attention if available

# GPU Resource Management
gpu_settings:
  device: cuda:0                                 # Primary GPU device
  torch_dtype: torch.bfloat16                   # Model precision
device_map:                                     # Model distribution
  transformer: cuda:0                           # Transformer on GPU
  vae: cpu                                       # VAE on CPU
  text_encoder: cuda:0                          # Text encoder on GPU
```

### Interface Configuration
```yaml
# Gradio interface settings
gradio_config:
  title: "OmniTry: Virtual Try-On Demo"
  description: "Upload person and object images for virtual try-on generation"
  examples_per_page: 100
  height: 800                                  # Image display height
  concurrency_limit: 1                         # Single concurrent request
  css: |
    .gradio-container {
      max-width: 1200px;
    }
```
## Feature Configuration

### Active Features
| Feature | Status | Description |
|---------|--------|-------------|
| `UNIFIED_LORA` | enabled | Single LoRA model for all garments |
| `CLOTH_SPECIFIC_LORA` | available | Targeted LoRA for cloth categories |
| `FLASH_ATTENTION` | optional | Memory-efficient attention computation |
| `CPU_OFFLOAD` | enabled | GPU memory optimization technique |
| `VAE_TILING` | enabled | High-resolution image processing |
| `GRADIO_INTERFACE` | enabled | Web-based interactive demo |

### Feature Management
```python
# Feature detection and configuration
def get_available_features():
    """Check system capabilities and feature availability"""
    features = {}
    
    # Check CUDA availability
    features['cuda_available'] = torch.cuda.is_available()
    features['gpu_count'] = torch.cuda.device_count() if features['cuda_available'] else 0
    
    # Check VRAM capacity
    if features['cuda_available']:
        total_vram = torch.cuda.get_device_properties(0).total_memory / (1024**3)
        features['sufficient_vram'] = total_vram >= 28  # GB
    
    # Check Flash Attention
    try:
        import flash_attn
        features['flash_attention'] = True
    except ImportError:
        features['flash_attention'] = False
    
    # Check LoRA checkpoints
    unified_path = 'checkpoints/omnitry_v1_unified.safetensors'
    cloth_path = 'checkpoints/omnitry_v1_clothes.safetensors'
    features['unified_lora_available'] = os.path.exists(unified_path)
    features['cloth_lora_available'] = os.path.exists(cloth_path)
    
    return features

active_features = get_available_features()
print(f"Available features: {active_features}")
```
## Security & Validation

### GPU Resource Protection
```python
# GPU memory validation and protection
def validate_gpu_memory():
    """Ensure sufficient GPU resources before model loading"""
    if not torch.cuda.is_available():
        raise RuntimeError("CUDA not available. GPU required for OmniTry.")
    
    gpu_props = torch.cuda.get_device_properties(0)
    total_memory = gpu_props.total_memory / (1024**3)  # GB
    
    if total_memory < 28:
        raise MemoryError(f"Insufficient VRAM: {total_memory:.1f}GB. Minimum 28GB required.")
    
    # Check memory utilization
    current_memory = torch.cuda.memory_allocated(0) / (1024**3)
    available_memory = total_memory - current_memory
    
    if available_memory < 20:  # Reserve ~8GB for system
        raise MemoryError(f"Low GPU memory: {available_memory:.1f}GB available")
    
    return True

# Model path security
class SecureModelLoader:
    """Secure model loading with path validation"""
    def __init__(self, allowed_paths=None):
        self.allowed_paths = allowed_paths or [
            'checkpoints/', '/tmp/', '/tmp/models/'
        ]
    
    def validate_path(self, path):
        """Validate model path against allowed directories"""
        abs_path = os.path.abspath(path)
        for allowed in self.allowed_paths:
            if abs_path.startswith(allowed) or allowed in abs_path:
                return True
        raise ValueError(f"Unauthorized model path: {abs_path}")
```
## Performance Configuration

### VRAM Optimization Settings
```yaml
# Memory management configuration
memory_config:
  gradient_checkpointing: false                # Savings vs speed trade-off
  attention_slicing: "auto"                   # Memory efficiency
  sequential_cpu_offload: true                 # Redistribute components
  vae_slicing: true                            # Process VAE in slices
  torch_dtype: ""bfloat16""                   # Mixed precision training
  revision: null                              # Model revision
  text_encoder_ldmq: true                      # Text encoder optimization

# Generation performance settings
generation_config:
  batch_size: 1                               # Fixed batch size for inference
  num_workers: 0                              # CPU workers for data loading
  pin_memory: false                           # GPU memory pinning
  torch_compile: false                         # Experimental performance
  enable_flash_attn: true                     # Flash attention acceleration

  # Diffusion parameters
  scheduler_save_steps: 500                   # Checkpoint frequency
  warmup_steps: 0                             # Warmup period
  num_cycles: 1                               # Learning rate cycles
```

### Model Loading Optimization
```python
# Optimized model loading with memory management
import torch

class OptimizedPipelineLoader:
    """Memory-optimized pipeline loading"""
    def __init__(self):
        self.device = torch.device('cuda:0')
        self.weight_dtype = torch.bfloat16
    
    def load_optimized_pipeline(self, config_path):
        """Load pipeline with memory optimizations"""
        args = OmegaConf.load(config_path)
        
        # Load transformer with memory efficiency
        transformer = FluxTransformer2DModel.from_pretrained(
            f'{args.model_root}/transformer',
            torch_dtype=self.weight_dtype
        ).requires_grad_(False).to(dtype=self.weight_dtype)
        
        # Create pipeline with optimizations
        pipeline = FluxFillPipeline.from_pretrained(
            args.model_root,
            transformer=transformer.eval(),
            torch_dtype=self.weight_dtype,
            revision="refs/pr/18"  # Optimized branch
        )
        
        # Apply memory optimizations
        pipeline.enable_model_cpu_offload()
        pipeline.vae.enable_tiling()
        
        return pipeline
```
## Common Configuration Patterns

### OmegaConf Configuration Pattern
```python
# YAML-based configuration with validation
from omegaconf import OmegaConf
from omegaconf import DictConfig

import os

def load_omnitry_config(config_path: str = 'configs/omnitry_v1_unified.yaml') -> DictConfig:
    """Load and validate OmniTry configuration"""
    
    # Validate config file exists
    if not os.path.exists(config_path):
        raise FileNotFoundError(f"Configuration file not found: {config_path}")
    
    # Load configuration
    cfg = OmegaConf.load(config_path)
    
    # Validate required fields
    required_fields = ['model_root', 'lora_path', 'object_map']
    missing = [field for field in required_fields if field not in cfg]
    if missing:
        raise ValueError(f"Missing required config fields: {missing}")
    
    # Validate model paths exist
    if not os.path.exists(cfg.model_root):
        raise ValueError(f"Model root not found: {cfg.model_root}")
    
    if not os.path.exists(cfg.lora_path):
        # Try alternative cloth-specific path
        alt_path = cfg.lora_path.replace('unified', 'clothes')
        if os.path.exists(alt_path):
            cfg.lora_path = alt_path
            print(f"Switched to cloth-specific LoRA: {alt_path}")
        else:
            raise ValueError(f"LoRA checkpoint not found: {cfg.lora_path} or {alt_path}")
    
    # Set default values with validation
    cfg.setdefault('guidance_scale', 30.0)
    cfg.setdefault('num_inference_steps', 20)
    cfg.setdefault('weight_dtype', 'bfloat16')
    cfg.setdefault('lora_rank', 256)
    
    # Environment-specific overrides
    if os.getenv('CUDA_VISIBLE_DEVICES'):
        cfg.device = f"cuda:{os.getenv('CUDA_VISIBLE_DEVICES')}"
    
    print(f"Configuration loaded from {config_path}")
    print(f"Model: {cfg.model_root}")
    print(f"LoRA: {cfg.lora_path}")
    
    return cfg

# Usage:
# config = load_omnitry_config()
# pipeline = create_pipeline(config)
```

### Environment-Based Configuration Selection
```python
# Environment-based config selection
import os

def get_config_for_environment():
    """Select optimal configuration based on hardware capabilities"""
    
    config_files = {
        'development': 'configs/omnitry_v1_unified.yaml',
        'production': 'configs/omnitry_production.yaml',
        'high_mem': 'configs/omnitry_high_mem.yaml',
        'minimal': 'configs/omnitry_minimal.yaml'
    }
    
    # Auto-detect based on VRAM
    if torch.cuda.is_available():
        vram_gb = torch.cuda.get_device_properties(0).total_memory / (1024**3)
        
        if vram_gb >= 48:
            return config_files['high_mem']
        elif vram_gb >= 32:
            return config_files['production']
        elif vram_gb >= 24:
            return config_files['development']
        else:
            return config_files['minimal']
    else:
        return config_files['minimal']  # CPU fallback

# Usage:
# config_path = get_config_for_environment()
# config = load_omnitry_config(config_path)
```

### Runtime Feature Detection
```python
# Dynamic feature detection and conditional configuration
def configure_system_features():
    """Automatically configure features based on available system resources"""
    features = {}
    
    # Hardware detection
    features['gpu_available'] = torch.cuda.is_available()
    features['cpu_cores'] = os.cpu_count()
    features['ram_gb'] = psutil.virtual_memory().total / (1024**3) if 'psutil' in globals() else 16
    
    if features['gpu_available']:
        features['gpu_ram'] = torch.cuda.get_device_properties(0).total_memory / (1024**3)
        features['flash_attention_supported'] = features['gpu_ram'] >= 8  # Minimum VRAM for flash attention
    
    # Model capability detection
    base_model_path = 'checkpoints/FLUX.1-Fill-dev'
    features['base_model_available'] = os.path.exists(base_model_path)
    
    unified_lora = 'checkpoints/omnitry_v1_unified.safetensors'
    cloth_lora = 'checkpoints/omnitry_v1_clothes.safetensors'
    features['unified_lora'] = os.path.exists(unified_lora)
    features['cloth_lora'] = os.path.exists(cloth_lora)
    
    return features
```
## Keywords <!-- #keywords -->
- configuration
- environment variables
- settings
- feature flags
- security
- omnitry
- virtual try-on
- pytorch
- cuda
- gradio
- flash attention
- vram optimization
- lora fine-tuning
- diffusion models
- омegaconf
- hugging face
- model configuration
- gpu memory
- deployment