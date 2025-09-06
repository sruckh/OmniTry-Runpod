#!/bin/bash
# Test script to verify Hugging Face CLI installation and usage

echo "=== Testing Hugging Face CLI Installation ==="

# Test 1: Check if hf command is available
echo "1. Testing hf command availability..."
if command -v hf &> /dev/null; then
    echo "✅ hf command is available"
else
    echo "❌ hf command not found"
    exit 1
fi

# Test 2: Check hf help
echo "2. Testing hf help..."
if hf --help >/dev/null 2>&1; then
    echo "✅ hf --help works"
else
    echo "❌ hf --help failed"
    exit 1
fi

# Test 3: Check hf env (version info)
echo "3. Testing hf env..."
if hf env >/dev/null 2>&1; then
    echo "✅ hf env works"
    echo "   Version info:"
    hf env | grep "huggingface_hub version" || true
else
    echo "❌ hf env failed"
    exit 1
fi

# Test 4: Check download command help
echo "4. Testing hf download help..."
if hf download --help >/dev/null 2>&1; then
    echo "✅ hf download --help works"
else
    echo "❌ hf download --help failed"
    exit 1
fi

echo ""
echo "=== All tests passed! Hugging Face CLI is working correctly ==="
echo ""
echo "Available commands:"
hf --help | head -20