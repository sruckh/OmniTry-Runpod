# Task Completion Commands for OmniTry

## Code Quality & Formatting
(No specific lints/formatters configured - codebase follows standard Python practices)

## Testing Commands
- **Unit Testing**: No dedicated test framework configured
- **Integration Testing**: Manual testing via gradio_demo.py interface
- **Benchmark Testing**: omnitry_bench/ directory for evaluation scripts
- **Visual Testing**: Gradio interface provides real-time result validation

## Build & Packaging Commands
- **Container Build**: Assume Docker build in parent directory
- **Python Dependencies**: pip install -r requirements.txt
- **Conda Environment**: conda env create -f environment.yml && conda activate omnitry

## Pre-deployment Validation
- **Model Loading**: Verify FLUX.1-Fill-dev checkpoint loading
- **LoRA Loading**: Test safetensors checkpoint integration
- **VRAM Check**: Ensure sufficient GPU memory (28GB minimum)
- **CUDA Compatibility**: Validate PyTorch CUDA version compatibility

## Documentation Updates
- **README Updates**: Update model versions and checkpoint references
- **Config Documentation**: Modify configs/omnitry_v1_unified.yaml as needed
- **Environment Notes**: Document any new dependency requirements

## Common Development Workflows
1. **Model Development**: 
   - Update LoRA checkpoint paths
   - Modify target modules in PeftConfig
   - Test different guidance scales/steps

2. **Interface Updates**:
   - Modify gradio_demo.py for new features
   - Update examples/ directory
   - Add new object classes to config

3. **Performance Optimization**:
   - Adjust batch sizes and memory settings
   - Test different precision levels (bfloat16 vs float32)
   - Evaluate Flash Attention impact

## Quality Gates
- **Functional Testing**: All garment types work correctly
- **Performance Testing**: Generation time <30 seconds typical
- **Visual Quality**: Realistic try-on results across test cases
- **Memory Usage**: Stable VRAM consumption without leaks