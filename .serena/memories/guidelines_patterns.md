# OmniTry Development Guidelines & Patterns

## Architectural Principles
- **Research-Focused Design**: Optimized for academic/research usage with minimal production hardening
- **Model-Centric Architecture**: Core logic revolves around diffusion pipeline with LoRA modifications
- **Memory-Constrained Design**: VRAM optimization techniques prioritized (28GB minimum requirement)
- **Tooling Integration**: Gradio-based interface for interactive evaluation and demonstration

## Design Patterns Used

### 1. Pipeline Pattern
```python
# Core pipeline structure in omnitry/pipelines/
class FluxFillPipeline:
    def __init__(self, model_root, transformer):
        # Initialize pipeline components
        self.transformer = transformer
        self.vae = AutoencoderKL.from_pretrained(...)
        self.text_encoder = T5EncoderModel.from_pretrained(...)
        
    def __call__(self, prompt, image, mask, **kwargs):
        # Execute pipeline steps
        latents = self.prepare_latents(...)
        noise = self.prepare_noise(...)
        
        for step in range(num_inference_steps):
            # Denoising step
            latents = self.scheduler.step(...)
            
        return self.decode_latents(latents)
```

### 2. Configuration-Driven Model Loading
```python
# Config-based initialization
args = OmegaConf.load('configs/omnitry_v1_unified.yaml')
# Use args.model_root, args.lora_path, args.lora_rank, etc.
```

### 3. LoRA Weight Injection
```python
# Dynamic LoRA adapter creation and injection
lora_config = LoraConfig(
    r=args.lora_rank,
    lora_alpha=args.lora_alpha,
    target_modules=['x_embedder', 'attn.to_k', ...]
)
transformer.add_adapter(lora_config, 'vtryon_lora')
transformer.add_adapter(lora_config, 'garment_lora')
```

### 4. Memory Optimization Pattern
```python
# CPU offloading techniques
pipeline.enable_model_cpu_offload()  # Offload models to CPU
pipeline.vae.enable_tiling()          # Process VAE in tiles

# BFloat16 precision for memory savings
weight_dtype = torch.bfloat16
transformer = transformer.to(dtype=weight_dtype)
```

## Development Guidelines

### Code Organization
- **Package Structure**: `__init__.py`, models/, pipelines/ subdirectories
- **Separation**: Models, pipelines, and demo logic clearly separated
- **Config Externalization**: All hyperparameters in YAML/JSON configs
- **Resource Management**: Explicit device management and memory cleanup

### Error Handling & Recovery
- **Graceful Failures**: Model loading errors handled silently or with warnings
- **Resource Cleanup**: Explicit CUDA memory clearing if needed
- **Validation**: Basic input validation in Gradio interface
- **Logging**: Minimal logging, focused on critical path

### Performance Considerations
- **GPU Utilization**: Explicit CUDA device targeting (`cuda:0`)
- **Batch Processing**: Support for batch generation (not fully utilized)
- **Cache Strategy**: No caching implemented (opportunity for optimization)
- **Async Patterns**: Synchronous execution in demo (potential bottleneck)

### Security Practices
- **Input Sanitization**: Gradio handles basic input validation
- **Credential Management**: No credentials in codebase (appropriate for research)
- **File Access**: Local file system access for checkpoints and configs
- **Network Isolation**: Demo runs locally, no external API calls in core logic

## Testing Patterns

### Unit Testing Strategy
- **Focus Areas**: Model loading, pipeline execution, LoRA integration
- **Challenge**: Large model sizes require significant computational resources
- **Approach**: Lightweight tests for configuration and basic pipeline flow

### Integration Testing
- **UI Testing**: Gradio interface interaction testing
- **Model Integration**: End-to-end pipeline execution verification
- **Performance Testing**: Generation time and memory usage benchmarks

### Benchmarking Strategy
- **Standard Benchmarks**: HuggingFace OmniTry-Bench dataset
- **Custom Metrics**: Try-on quality, realism, object preservation
- **Comparative Analysis**: Against baseline diffusion models

## Deployment Patterns

### Containerization Strategy
- **Base Image**: nvidia/cuda for GPU support
- **Multi-Stage Build**: Model download separated from runtime
- **Dependency Chain**: PyTorch installation at runtime for compatibility
- **Port Exposure**: Gradio default port 7860

### Configuration Management
- **Environment Variables**: Conda/virtualenv for dependency isolation
- **Model Paths**: Relative paths for checkpoint directories
- **Hyperparameters**: YAML/JSON configs for reproducible results
- **Flexibility**: Easy switching between LoRA checkpoints

## Future Considerations

### Scalability Improvement
- **Distributed Inference**: Potential for multi-GPU setups
- **Memory Optimization**: Further VRAM reduction techniques
- **Batching**: Better utilization of CUDA cores through batching
- **Compression**: Model compression for faster inference

### Production Readiness
- **Security Hardening**: Input validation, authentication if needed
- **Monitoring**: Performance metrics, error tracking
- **Documentation**: API endpoints, configuration options
- **Testing**: Comprehensive test coverage, CI/CD pipeline

### Research Directions
- **Model Architecture**: Alternative diffusion backbones (SDXL, SD3)
- **Fine-tuning Methods**: Beyond LoRA (QLoRA, Full fine-tuning)
- **Data Augmentation**: Synthetic data generation techniques
- **Evaluation Metrics**: Improved quantitative evaluation methods