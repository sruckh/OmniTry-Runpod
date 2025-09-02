#!/usr/bin/env python3
"""
Demo usage script for the enhanced OmniTry Gradio interface.
This script shows how to programmatically interact with the model selection feature.
"""

import os
import sys
from pathlib import Path

# Add the project root to Python path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

def simulate_model_usage():
    """Simulate how the enhanced model selection works"""
    
    print("=== OmniTry Enhanced Demo Usage ===\n")
    
    # Import the enhanced demo functions (this would work if all dependencies were installed)
    print("1. Model Selection Options:")
    model_configs = {
        "Unified Model": "configs/omnitry_v1_unified.yaml",
        "Clothes Model": "configs/omnitry_v1_clothes.yaml"
    }
    
    for name, path in model_configs.items():
        status = "✅ Available" if Path(path).exists() else "❌ Missing"
        print(f"   - {name}: {path} - {status}")
    
    print("\n2. Configuration Files:")
    for name, path in model_configs.items():
        if Path(path).exists():
            print(f"   - {name} config exists: {path}")
        else:
            print(f"   - {name} config missing: {path}")
    
    print("\n3. Expected LoRA Files:")
    lora_files = [
        "checkpoints/omnitry_v1_unified.safetensors",
        "checkpoints/omnitry_v1_clothes.safetensors"
    ]
    
    for lora_file in lora_files:
        status = "✅ Ready" if Path(lora_file).exists() else "❌ Need to download"
        print(f"   - {lora_file}: {status}")
    
    print("\n4. Usage Workflow:")
    print("   a. Launch: python src/gradio_demo.py")
    print("   b. Select model from dropdown")
    print("   c. Upload person image")
    print("   d. Upload object/garment image")
    print("   e. Choose object class")
    print("   f. Click 'Generate Try-On'")
    
    print("\n5. Key Features:")
    print("   - Runtime model switching")
    print("   - Dynamic object class updates")
    print("   - Memory efficient loading")
    print("   - Status feedback")
    print("   - Error handling")
    
    print("\n=== Demo Ready! ===")

if __name__ == "__main__":
    # Change to project directory
    os.chdir(project_root)
    simulate_model_usage()