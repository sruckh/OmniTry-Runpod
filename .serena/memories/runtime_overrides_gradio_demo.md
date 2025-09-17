# Ensure Patched Gradio Demo Overrides Clone

## Context
- `install_runtime.sh` clones the upstream OmniTry repo into the container at runtime, then launches `python gradio_demo.py`.

## Problem
- Our local fixes to `gradio_demo.py` were lost because the clone overwrote the file before launch.

## Solution
- Copy `/workspace/gradio_demo.py` (baked into the image) into the cloned repo during Step 7 of `install_runtime.sh`.
- Added `COPY gradio_demo.py /workspace/gradio_demo.py` to the Dockerfile so the patched entry point is available for the copy.

## Impact
- The runtime now uses the patched Gradio app, preventing the schema bool crash from resurfacing after container rebuilds.
