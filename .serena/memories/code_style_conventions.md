# OmniTry Code Style & Conventions

## General Code Style
- **Language**: Python 3.11+
- **Indentation**: 4 spaces (standard PEP 8)
- **Line Length**: Follows standard Python conventions (~88 characters)
- **Imports**: PEP 8 compliant organization
  - Standard library imports first
  - Third-party imports second
  - Local imports last
- **Naming Conventions**: 
  - Functions: snake_case lowercase
  - Classes: PascalCase
  - Variables: snake_case lowercase
  - Constants: UPPER_CASE
- **Type Hints**: Minimal type hints present (e.g., in pipeline code)
- **Docstrings**: Limited use, mostly inline comments

## Specific Patterns Found
- **Torch Device Management**: device = torch.device('cuda:0')
- **Memory Optimization**: pipeline.enable_model_cpu_offload(), vae.enable_tiling()
- **Weight Management**: torch.bfloat16 weight dtype
- **Image Processing**: PIL transforms with torchvision
- **LoRA Implementation**: Custom PeftConfig with targeted modules for diffusion models

## Architecture Patterns
- **Separation of Concerns**: Models, pipelines, and demo logic separated
- **Configuration-Driven**: Uses OmegaConf for model and generation configs
- **Memory-Efficient Design**: VRAM optimization techniques for large models
- **Modular Model Loading**: SafeTensors format with strategic weight loading

## Error Handling
- Basic try/catch blocks in demo code
- Runtime warnings suppressed (gradio demo)
- Memory management considerations for GPU usage

## Security Practices
- Secure model loading with safetensors
- Input validation for Gradio interface
- Password-free authentication (local/demo usage)
- No production security features evident (appropriate for research/demo)

## Development Guidelines
- Model-only at build time (no full inference setup)
- Post-deployment installation (PyTorch, dependencies, checkpoints)
- Container-based deployment on RunPod
- No hardcoded secrets (environment variables for API keys if needed)