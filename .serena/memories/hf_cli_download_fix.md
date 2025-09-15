# HF CLI Download and Bug Fix

This memory documents the changes made to the model download process and a bug fix in the startup scripts.

## Changes

1.  **Updated Model Download Method**: The `setup.sh` and `install_runtime.sh` scripts were modified to use the `hf download` command from the `huggingface-hub` CLI. This is the modern and preferred way to download models from the Hugging Face Hub.

2.  **Enabled Fast Downloads**: The `HF_HUB_ENABLE_HF_TRANSFER` environment variable has been set to `1` in both scripts to enable the `hf-transfer` library, which significantly speeds up model downloads.

3.  **Fallback Mechanism**: The previous download methods (using `hf_hub_download` and `snapshot_download` in Python, and `git lfs`) have been retained as fallbacks to ensure robustness in case the `hf` CLI fails.

4.  **Bug Fix**: A bug was fixed in both `setup.sh` and `install_runtime.sh` where a redundant `cd` command caused an error if the repository already existed. This has been corrected to ensure the scripts run smoothly.

## Affected Files

- `setup.sh`
- `install_runtime.sh`
