# OmniTry Codebase Structure

## Main Directories
```
/opt/docker/OmniTry/
├── omnitry/                    # Core AI/ML package
│   ├── __init__.py           # Package initialization
│   ├── models/               # Transformer models and components
│   │   ├── transformer_flux.py    # FLUX transformer implementation
│   │   └── attn_processors.py     # Attention processors
│   └── pipelines/             # Diffusion pipelines
│       ├── pipeline_flux_fill.py   # Main pipeline
│       └── pipeline_flux.py        # FLUX flux pipeline
├── configs/                  # Configuration files
│   └── omnitry_v1_unified.yaml    # Model and LoRA configuration
├── data_preprocess/         # Data preprocessing scripts
│   ├── infer_ground_objects.py     # Ground object inference
│   ├── infer_list_objects.py       # Object listing inference
│   ├── infer_remove_objects.py     # Object removal inference
│   └── README.MD                    # Preprocessing README
├── omnitry_bench/          # Benchmarking suite
│   ├── vtryon_metric.py           # Try-on quality metrics
│   ├── vtryon_get_mask.py         # Mask generation
│   └── README.MD                   # Benchmark documentation
├── checkpoints/             # Model weights (gitignored)
│   ├── FLUX.1-Fill-dev/          # Base FLUX model
│   ├── omnitry_v1_unified.safetensors    # LoRA weights
│   └── omnitry_v1_clothes.safetensors    # Cloth-specific weights
├── demo_example/           # Example images for demo
│   ├── person_*.jpg             # Person images
│   └── object_*.jpg             # Object images
└── *root files*
    ├── gradio_demo.py           # Web interface entry point
    ├── environment.yml          # Conda environment spec
    ├── requirements.txt         # Python dependencies
    ├── README.MD               # Project documentation
    └── data_preprocess/README.MD # Internal docs
```

## Key Entry Points
- **Main Demo**: gradio_demo.py (web interface)
- **Benchmark**: omnitry_bench/ scripts
- **Preprocessing**: data_preprocess/ scripts
- **Model Usage**: Pipeline classes in omnitry/pipelines/

## Dependencies Relationship
```
gradio_demo.py
├── omnitry.pipelines.pipeline_flux_fill
├── omnitry.models.transformer_flux
├── configs/omnitry_v1_unified.yaml
├── checkpoints/FLUX.1-Fill-dev/
└── checkpoints/omnitry_v1_unified.safetensors

omnitry_bench/
└── wrap various evaluation pipelines
```

## Configuration Flow
1. Load config from configs/ directory
2. Initialize pipeline with FLUX base model
3. Load and merge LoRA weights from checkpoints/
4. Apply memory optimizations (CPU offload, tiling)
5. Launch Gradio interface

## Data Flow
- **Input**: Person image + object image + object class
- **Processing**: Pipeline generates try-on result
- **Output**: Combined image via Gradio interface

## Development Workflow Directories
- **Source**: omnitry/ directory for model code
- **Config**: configs/ for hyperparameters
- **Demo**: gradio_demo.py for interface development
- **Bench**: omnitry_bench/ for testing and evaluation