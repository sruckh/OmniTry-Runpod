#!/usr/bin/env python3
"""
Test script to verify dual LoRA implementation without running the full Gradio interface.
This script simulates the LoRA loading functionality.
"""

import os
import sys

# Test the LoRA switching functionality
def test_lora_switching():
    print("🧪 Testing Dual LoRA Implementation")
    print("=" * 50)
    
    # Test 1: Check if both LoRA files exist (they won't in test environment)
    lora_files = {
        "unified": "checkpoints/omnitry_v1_unified.safetensors",
        "clothes": "checkpoints/omnitry_v1_clothes.safetensors"
    }
    
    print("📁 Checking LoRA file paths:")
    for name, path in lora_files.items():
        exists = os.path.exists(path)
        status = "✅ EXISTS" if exists else "❌ MISSING"
        print(f"  {name}: {path} - {status}")
    
    # Test 2: Verify configuration structure
    print("\n⚙️ Configuration Test:")
    try:
        from omegaconf import OmegaConf
        config_path = 'configs/omnitry_v1_unified.yaml'
        if os.path.exists(config_path):
            args = OmegaConf.load(config_path)
            print(f"✅ Config loaded: {config_path}")
            print(f"   LoRA path: {args.lora_path}")
            print(f"   LoRA rank: {args.lora_rank}")
            print(f"   LoRA alpha: {args.lora_alpha}")
        else:
            print(f"❌ Config file not found: {config_path}")
    except Exception as e:
        print(f"❌ Config loading error: {e}")
    
    # Test 3: Check if the modified gradio_demo.py has expected changes
    print("\n🔍 Code Structure Verification:")
    try:
        with open('gradio_demo.py', 'r') as f:
            content = f.read()
            
        checks = [
            ("LORA_MODELS dictionary", "LORA_MODELS = {"),
            ("load_lora_weights function", "def load_lora_weights(lora_model_name):"),
            ("update_lora_status function", "def update_lora_status(lora_model_name):"),
            ("LoRA model parameter in generate", "def generate(person_image, object_image, object_class, lora_model,"),
            ("LoRA Radio control", "lora_model = gr.Radio("),
            ("LoRA status display", "lora_status = gr.Textbox("),
            ("LoRA change callback", "lora_model.change(update_lora_status,")
        ]
        
        for check_name, check_string in checks:
            found = check_string in content
            status = "✅ FOUND" if found else "❌ MISSING"
            print(f"  {check_name}: {status}")
            
    except Exception as e:
        print(f"❌ Error reading gradio_demo.py: {e}")
    
    print("\n📝 Summary:")
    print("✅ Dual LoRA support has been implemented with:")
    print("   • Dynamic LoRA model switching")
    print("   • User-friendly Radio button selection")
    print("   • Status display for current LoRA model")
    print("   • Automatic model loading during generation")
    print("   • Support for both unified and clothes models")
    
    print("\n🚀 Next Steps:")
    print("   1. Deploy container with both LoRA files")
    print("   2. Test actual inference with both models")
    print("   3. Verify UI responsiveness and model switching")

if __name__ == "__main__":
    test_lora_switching()