# Fix Gradio Object Map Schema

## Problem Identified
- The Gradio app crashed at startup with `TypeError: argument of type 'bool' is not iterable` when building API metadata.
- `object_map` remained as an OmegaConf `DictConfig`, so Gradio emitted a JSON schema containing `additionalProperties: True`, which is not JSON-serializable and led to the error inside `gradio_client.utils`.

## Solution Applied
**File Modified**:
- `gradio_demo.py`

**Changes Made**:
- Converted `args.object_map` into a plain Python dict via `OmegaConf.to_container(..., resolve=True)`.
- Updated the code to read prompts and dropdown choices from the normalized `OBJECT_MAP`.

## Impact
- Gradio now receives standard JSON-serializable data, preventing the schema conversion crash.
- The application API metadata loads correctly, allowing the UI to start without runtime exceptions.
