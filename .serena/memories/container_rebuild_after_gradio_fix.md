# Rebuild Image After Gradio Override Update

## Context
- Dockerfile now copies the patched `gradio_demo.py` into `/workspace` and the runtime script copies it into the cloned repo before launch.

## Reminder
- Whenever these files change, rebuild and redeploy the container image so the patched entry point is picked up.

## Impact
- Prevents future runs from falling back to the upstream `gradio_demo.py`, avoiding the JSON schema bool crash.
