# OmniTry RunPod Container
# Base image is the ONLY thing done at build time
# Everything else happens at runtime after container starts

FROM nvidia/cuda:12.3.2-cudnn9-runtime-ubuntu22.04

# Set working directory
WORKDIR /workspace

# Copy the runtime setup script
COPY setup.sh /workspace/setup.sh

# Make setup script executable
RUN chmod +x /workspace/setup.sh

# Expose Gradio port
EXPOSE 7860

# Default command - runs setup then starts the application
CMD ["/bin/bash", "/workspace/setup.sh"]