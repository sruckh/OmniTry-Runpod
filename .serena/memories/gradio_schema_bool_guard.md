# Gradio Schema Bool Guard

## Context
- Runtime uses `install_runtime.sh` to launch `python gradio_demo.py` inside the container, exposing the Gradio UI directly to end users.

## Problem
- `gradio_client.utils._json_schema_to_python_type` can receive bare booleans (`True`/`False`) in schemas (e.g., `additionalProperties`), causing `TypeError: argument of type 'bool' is not iterable` during API metadata generation and crashing the ASGI app.

## Solution
- In `gradio_demo.py`, wrap `_json_schema_to_python_type` with `_safe_json_schema_to_python_type` that short-circuits boolean schemas, returning a human-readable placeholder instead of delegating to the original helper.

## Impact
- Gradio launches without ASGI crashes and retains useful schema descriptions for API consumers.
