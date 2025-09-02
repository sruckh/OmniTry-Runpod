# OmniTry Enhanced Gradio Demo

This enhanced version of `gradio_demo.py` adds support for switching between multiple LoRA models at runtime through the Gradio interface.

## Key Features

### Model Selection
- **Dropdown Interface**: Users can select between different LoRA models:
  - **Unified Model** (`omnitry_v1_unified.safetensors`) - Supports all object types
  - **Clothes Model** (`omnitry_v1_clothes.safetensors`) - Specialized for clothing items

### Dynamic Model Loading
- Models are loaded on-demand when selected
- Status feedback shows loading progress and success/error messages
- Object class dropdown automatically updates based on the selected model

### Improved UI
- Better organized layout with clear model selection section
- Status indicator for current model
- Enhanced error handling and user feedback
- Responsive design with improved spacing

## Usage

### Running the Enhanced Demo
```bash
# From the OmniTry project root directory
python src/gradio_demo.py
```

### Model Selection Workflow
1. **Select Model**: Choose from the dropdown menu
2. **Wait for Loading**: Status will show "Successfully loaded [Model Name]!"
3. **Upload Images**: Person image and object/garment image
4. **Select Object Class**: Choose appropriate category from updated dropdown
5. **Generate**: Click "Generate Try-On" button

## Technical Implementation

### Configuration Files
- `configs/omnitry_v1_unified.yaml` - Configuration for unified model
- `configs/omnitry_v1_clothes.yaml` - Configuration for clothes-specific model

### Key Changes from Original
1. **Global Model Management**: Models are loaded/unloaded dynamically
2. **Configuration Loading**: Supports multiple YAML configurations
3. **Event Handlers**: Model selection triggers reloading and UI updates
4. **Error Handling**: Comprehensive error messages for missing files or loading issues
5. **Memory Management**: Previous models are properly cleaned up when switching

### Memory Considerations
- Only one model is loaded at a time to optimize GPU memory usage
- VRAM optimizations (CPU offloading and VAE tiling) are preserved
- Models are properly disposed when switching to prevent memory leaks

## File Structure
```
configs/
├── omnitry_v1_unified.yaml      # Unified model config
└── omnitry_v1_clothes.yaml      # Clothes model config

src/
├── gradio_demo.py               # Enhanced demo with model selection
└── README.md                    # This documentation

checkpoints/
├── FLUX.1-Fill-dev/            # Base FLUX model
├── omnitry_v1_unified.safetensors  # Unified LoRA weights
└── omnitry_v1_clothes.safetensors  # Clothes-specific LoRA weights
```

## Requirements
- Both LoRA safetensor files must be present in the `checkpoints/` directory
- Configuration files must exist in the `configs/` directory
- All original dependencies from the base OmniTry project

## Backward Compatibility
This enhanced version maintains full compatibility with the original demo functionality while adding new model selection capabilities. The default behavior loads the "Unified Model" on startup, matching the original implementation.