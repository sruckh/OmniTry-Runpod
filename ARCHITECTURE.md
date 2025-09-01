# ARCHITECTURE.md

## Technology Stack

### Core Technologies
- **Programming Language**: Python 3.11+
- **AI/ML Framework**: PyTorch 2.4.0 with CUDA 12.4
- **Diffusion Model**: FLUX.1-Fill-dev (text-to-image generation)
- **Fine-tuning**: LoRA (Low-Rank Adaptation) for efficient training
- **Model Loading**: Safetensors format for secure weight storage
- **Configuration**: OmegaConf (YAML-based config management)
- **Web Interface**: Gradio 5.6.0 (Python-native web UI)

### Key Dependencies
- **Core AI/ML**:
  - `transformers==4.45.0` - Hugging Face transformer models
  - `diffusers==0.33.1` - Diffusion pipeline implementations
  - `peft==0.13.2` - Parameter-efficient fine-tuning (LoRA)
  - `torchmetrics` - ML metrics computation
  - `einops` - Tensor manipulation utilities
  - `omegaconf` - Hierarchical configuration
- **Data Processing**:
  - `supervision` - Computer vision utilities
  - `torchvision` - Image processing transforms
  - `safetensors` - Secure model serialization
  - `huggingface_hub` - Model distribution platform
- **Performance & Optimization**:
  - Flash Attention 2.6.3 (optional, memory efficiency)
  - CUDA runtime for GPU acceleration

### Development & Deployment
- **Environment**: Conda virtual environments
- **Containerization**: NVIDIA CUDA base images
- **Deployment**: RunPod integration
- **CI/CD**: GitHub Actions for automated builds
  

## Directory Structure

### Configuration-Driven Pipeline Architecture

The architecture follows a **model-centric, configuration-driven** approach optimized for research and deployment on GPU-accelerated platforms. The system emphasizes memory efficiency and reproducibility through explicit configuration management.

### Key Design Characteristics
- **LoRA Injection**: Dynamic adapter merging for garment-specific fine-tuning
- **Pipeline Abstraction**: Unified interface for FLUX-based diffusion generation
- **Config-First Design**: All hyperparameters and paths managed through YAML
- **GPU Optimization**: VRAM-aware techniques (CPU offload, tiling, mixed precision)
- **Research-Friendly**: Modular components for experimentation and benchmarking

### Performance Considerations
- Minimum 28GB VRAM requirement for full inference
- BFloat16 precision for memory efficiency
- CPU offload for large model components
- VAE tiling for high-resolution processing

### Scalability Approach
- Horizontal scaling through multi-GPU support
- Offline model preparation for deployment
- Flash Attention for memory-efficient attention computation

## Codebase Directory Structure
```
/opt/docker/OmniTry/
├── omnitry/                    # Core AI/ML package
│   ├── __init__.py           # Package initialization
│   ├── models/               # Transformer models and components
│   │   ├── transformer_flux.py    # FLUX transformer implementation (line 1-100+)
│   │   └── attn_processors.py     # Attention processors with LoRA (line 1-50+)
│   └── pipelines/             # Diffusion pipelines
│       ├── pipeline_flux_fill.py   # Main pipeline wrapper (line 1-150+)
│       └── pipeline_flux.py        # FLUX pipeline logic (line 1-100+)
├── configs/                  # Configuration files
│   └── omnitry_v1_unified.yaml    # Model hyperparameters and paths
├── data_preprocess/         # Data preprocessing scripts
│   ├── infer_ground_objects.py     # Ground object inference (line 1-30+)
│   ├── infer_list_objects.py       # Object listing inference (line 1-25+)
│   ├── infer_remove_objects.py     # Object removal processing (line 1-35+)
│   └── README.MD                    # Preprocessing guides
├── omnitry_bench/          # Benchmarking suite
│   ├── vtryon_metric.py           # Quality metrics computation (line 1-60+)
│   ├── vtryon_get_mask.py         # Mask generation utilities (line 1-40+)
│   └── README.MD                   # Benchmark documentation
├── checkpoints/             # Model weights (gitignored for size)
│   ├── FLUX.1-Fill-dev/          # Base FLUX model (~18GB)
│   ├── omnitry_v1_unified.safetensors    # LoRA weights (all garments)
│   └── omnitry_v1_clothes.safetensors    # Cloth-specific LoRA weights
├── demo_example/           # Demo examples (12+ examples)
│   ├── *_person.jpg             # Person input images
│   └── *_object.jpg             # Object/garment images
├── [ROOT FILES]
│   ├── gradio_demo.py           # Main web interface (252 lines)
│   ├── environment.yml          # Conda environment specification
│   ├── requirements.txt         # Python dependencies
│   ├── README.MD               # Project README with instructions
│   └── CLAUDE.md               # AI development guidance
```

## Key Architectural Decisions

### Model-Centric Architecture
**Context**: Need to integrate large diffusion models (FLUX.1-Fill-dev) with fine-tuned LoRA adapters for specific garment generation tasks
**Decision**: Adopted model-centric architecture with dynamic LoRA injection and pipeline abstraction
**Rationale**: Enables rapid experimentation with different model combinations while maintaining clean separation between base model inference and fine-tuned generations
**Consequences**: Memory-efficient but requires careful GPU resource management; optimal for research iteration but has deployment complexity

### Configuration-Driven Pipeline
**Context**: Complex hyperparameters (LoRA ranks, model paths, VRAM settings) need to be managed across development and deployment environments
**Decision**: YAML-based configuration with OmegaConf for hierarchical parameter management
**Rationale**: Enables reproducible experiments, environment-specific overrides, and easy parameter tuning without code changes
**Consequences**: Reduces code complexity but requires careful validation of configuration schemas

### LoRA Dual-Adapter Pattern
**Context**: Generate consistent garment try-on results for person and object images simultaneously
**Decision**: Implemented dual LoRA adapters (`vtryon_lora` and `garment_lora`) with hacked forward pass merging
**Rationale**: Allows separate fine-tuning for person pose/clothing and object/garment appearance while using single forward pass
**Consequences**: Improved try-on consistency but requires manual weight merging; technically complex but enables superior results

### VRAM-Aware Memory Management
**Context**: FLUX model requires minimum 28GB VRAM while maintaining real-time inference performance
**Decision**: Combined CPU offloading, VAE tiling, and BFloat16 precision with explicit CUDA memory management
**Rationale**: Enables running large models on GPU with <32GB VRAM while maintaining quality and performance
**Consequences**: Complex memory management but enables broader hardware compatibility

## Component Architecture

### GradioDemo Main Interface <!-- #gradio-demo -->
```python
gradio_demo.py:1-252
# Main web interface and pipeline orchestration
class: Main gradio.Blocks application
lines: 144-251 - UI component definitions
lines: 25-30 - Pipeline and model loading
lines: 91-141 - Core generation logic
generate() function: Main try-on pipeline execution
```

### PipelineFluxFill Core Pipeline <!-- #pipeline -->
```python
omnitry/pipelines/pipeline_flux_fill.py:1-150+
# FLUX diffusion pipeline wrapper
class: FluxFillPipeline wrapper extending Diffusers pipeline
lines: 25-80 - Initialization and model loading
lines: 81-120 - LoRA adapter configuration
__call__ method: Diffusion generation with img_cond
supports:Guidance scale, inference steps, seed control
```

### TransformerFlux LoRA Implementation <!-- #transformer -->
```python
omnitry/models/transformer_flux.py:1-100+
# FLUX transformer with LoRA adapters
class: FluxTransformer2DModel extending Transformers model
lines: 30-60 - LoRA adapter initialization
dual_adapters: vtryon_lora + garment_lora
weight_dtype: torch.bfloat16 for memory efficiency
supports: PeftConfig with target modules for diffusion layers
```

## System Flow Diagram

### Inference Pipeline Flow
```
[User Uploads] ──┐                       ▲
                 │                       │
[Person Image] ──▼─► [Image Processing] ──► [Diffusion Generation] ──► [Output Image]
[Object Image] ──┐        ├─► [Resize] ──┐          │                      ▲
[Object Class] ──┴────────┴─► [Padding] ──┘          ▼                      │
                                                  LoRA Injection            │
                       ▲                    (Person+Object Adapters)       │
                       │                                                 │
[HuggingFace Cache]────┼───── Wingspan─► [FLUX.1-Fill-dev Model] ─► [Gradio UI] ─→ [User Download]
                       │                                                 │
[Checkpoints Dir]─────┘                                                 │
                                                                          │
                                       ┌─────────────────────────────────┐
                                       │ [RAMP Slice] Performance Tracking|
                                       └─────────────────────────────────┘
                       ▲                    ▲                     ▲
                       │                    │                     │
                 [OmegaConf]       [CUDA GPU]           [Safetensors Loading]
           YAML Configuration  VRAM Management     Secure Model Weights
```

### Development Workflow
```
1. Model Download ───► 2. Environment Setup ───► 3. Config Loading
       ▼                        ▼                         ▼
   FLUX.1-Fill-dev        conda activate              OmegaConf.load()
   LoRA Weights           pip install -r               YAML validation
   HuggingFace              requirements.txt

4. Pipeline Initialization ───► 5. LoRA Adapter Setup ───► 6. Memory Optimization
       ▼                           ▼                           ▼
   create_pipeline()           add_adapter()              enable_cpu_offload()
   model_path: str            vtryon_lora                enable_tiling()
   transformer: obj           garment_lora               bfloat16_weights

7. Gradio UI Setup ───► 8. Generation Test ───► 9. Benchmark Evaluation
       ▼                        ▼                     ▼
   gr.Blocks()               generate_batch()          vtryon_metric.py
   Image inputs              steps=20,                 LPIPS quality
   object_class dropdown      guidance_scale=30          vtryon accuracy
```

### Memory Management Architecture
```
[28GB+ GPU Memory Pool]
       ▲
       │
  ┌────┼────┐  Preload Phase
  │         │
  ▼         ▼
[Base Model]───→ [LoRA Weights]
 (17GB)            (~100MB each)
       │                  │
       └───► [Merged] ─┐  │
              (17GB)   │  │
                       │  │
          ┌────────────▼──▼────────────┐
          │        Inference         │
          │    (Active ~17GB)       │
          └───┬──────────────────────┘
              │
       [Output] ◄─── Streams
        ~5MB image
```

## Common Patterns

### Configuration-Driven Pattern
**When to use**: Managing hyperparameters, model paths, and environment settings
**Implementation**: Use OmegaConf to load YAML configs and pass to components
**Example**: 
```python
# configs/omnitry_v1_unified.yaml
args = OmegaConf.load('configs/omnitry_v1_unified.yaml')
# Access: args.lora_path, args.model_root, args.lora_rank
```

### LoRA Adapter Pattern
**When to use**: Fine-tuning large models without modifying base weights
**Implementation**: Create PeftConfig with target modules, add adapter, load LoRA weights
**Example**: 
```python
# omnitry/models/transformer_flux.py:30-45
lora_config = LoraConfig(r=256, target_modules=['x_embedder', 'attn.to_k'])
transformer.add_adapter(lora_config, 'vtryon_lora')
with safe_open(args.lora_path, framework='pt') as f:
    transformer.load_state_dict(f.get_tensor('weights'), strict=False)
```

### Pipeline Abstraction Pattern
**When to use**: Wrapping complex model inference into reusable interface
**Implementation**: Create pipeline class extending diffusers base with custom logic
**Example**: 
```python
# omnitry/pipelines/pipeline_flux_fill.py:25-80
class FluxFillPipeline:
    def __init__(self, model_root, transformer):
        self.pipeline = FluxFillPipeline.from_pretrained(model_root, transformer)
        # Custom LoRA initialization
    def __call__(self, prompt, img_cond, **kwargs):
        return self.pipeline(prompt, img_cond=img_cond, **kwargs)
```

### Memory Optimization Pattern
**When to use**: Running large models on GPU with limitation VRAM
**Implementation**: Combine CPU offload, tiling, and mixed precision
**Example**: 
```python
# gradio_demo.py:29-31
pipeline.enable_model_cpu_offload()  # Move models to CPU
pipeline.vae.enable_tiling()         # Process VAER in tiles
weight_dtype = torch.bfloat16       # Reduce memory usage
```

### Image Processing Pattern
**When to use**: Preparing images for diffusion model input
**Implementation**: Resize, normalize, and batch images with torchvision
**Example**: 
```python
# gradio_demo.py:98-118
transform = T.Compose([
    T.Resize((tH, tW)),
    T.ToTensor(),
])
person_image = transform(person_image)
object_image_padded = torch.ones_like(person_image)
min_x = (tW - new_w) // 2
object_image_padded[:, min_y:min_y+new_h, min_x:min_x+new_w] = object_image
```

## Keywords <!-- #keywords -->
- architecture
- system design
- tech stack
- components
- patterns
- omnitry
- virtual try-on
- diffusion models
- FLUX FLUX
- LoRA fine-tuning
- SAFELISH
- pytorch
- CUDA
- hugging face
- gradio
- image generation
- garment try-on
- AI/ML pipelines
- model optimization
- GPU memory management