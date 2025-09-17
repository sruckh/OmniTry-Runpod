# OmniTry RunPod Container
# Base image is the ONLY thing done at build time
# Everything else happens at runtime after container starts

FROM nvidia/cuda:12.3.2-cudnn9-runtime-ubuntu22.04

# Set working directory
WORKDIR /workspace

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Copy necessary files
COPY install_runtime.sh /workspace/install_runtime.sh
COPY configs /workspace/configs
COPY omnitry /workspace/omnitry
COPY gradio_demo.py /workspace/gradio_demo.py

# Make setup script executable
RUN chmod +x /workspace/install_runtime.sh

# Expose Gradio port
EXPOSE 7860

# Default command - runs setup then starts the application
CMD ["/bin/bash", "/workspace/install_runtime.sh"]
