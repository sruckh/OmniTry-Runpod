# OmniTry RunPod Container Goals

## Project Goal
The primary goal of this project is to create a containerized version of the [OmniTry](https://github.com/Kunbyte-AI/OmniTry) project that can be reliably run on the RunPod platform.

## Container Strategy
- **Base Image**: We use `nvidia/cuda:12.3.2-cudnn9-runtime-ubuntu22.04` as the base image for the container, for AMD64 architecture.
- **Build vs. Runtime**: The container image is kept minimal. The `Dockerfile` only copies essential scripts and configuration files. All other dependencies are installed at runtime when the container starts on RunPod.

## Runtime Installation
- The runtime installation is handled by the `install_runtime.sh` script, which is the entrypoint of the container.
- This script performs the following steps:
  1.  Installs system dependencies.
  2.  Installs Miniconda and PyTorch.
  3.  Clones the upstream OmniTry repository (`https://github.com/Kunbyte-AI/OmniTry.git`).
  4.  Overwrites the upstream `configs/omnitry_v1_unified.yaml` with the version from the local repository.
  5.  Downloads the required models from Hugging Face using `hf_transfer`.
  6.  Installs Python dependencies from `requirements.txt`.
  7.  Installs Flash Attention.
  8.  Starts the Gradio application.

## Development Workflow
- **Local Repository**: Development and script modifications are done in the `https://github.com/sruckh/OmniTry-Runpod` repository.
- **Upstream Repository**: The core application code is cloned from `https://github.com/Kunbyte-AI/OmniTry.git` at runtime.
- **Commits**: All changes to the deployment scripts and configurations should be committed to the `sruckh/OmniTry-Runpod` repository.

## Important Rules
- **RunPod Only**: This container is designed specifically for RunPod and should not be built or run on a local machine.
- **No Local Dependencies**: All software and dependencies should be installed inside the container at runtime.
- **Security**: Never expose secrets or API keys in the GitHub repository.

## Future Work
- The `gradio_demo.py` currently only supports one LoRA file at a time. A desired feature is to allow users to easily switch between the `omnitry_v1_unified.safetensors` and `omnitry_v1_clothes.safetensors` files in the Gradio web interface.