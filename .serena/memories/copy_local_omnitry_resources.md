# Copy Local OmniTry Resources into Image

## Problem Identified
- `install_runtime.sh` copies custom pipeline files from `/workspace/omnitry`, but the Docker image only included `install_runtime.sh` and `configs`.
- At runtime, the script failed with `cp: cannot stat '/workspace/omnitry/pipelines/pipeline_flux_fill.py'` because the `omnitry` directory was missing inside the container image.

## Solution Applied
**File Modified**:
- `Dockerfile`

**Changes Made**:
- Added `COPY omnitry /workspace/omnitry` so the container bundles the customized `omnitry` directory alongside the runtime script and configs.

## Impact
- The runtime installation script can now find and copy the pipeline overrides without errors.
- RunPod containers will complete Step 7 of `install_runtime.sh` successfully, preventing startup failures due to missing files.
