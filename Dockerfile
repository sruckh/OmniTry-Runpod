# OmniTry RunPod Container - Minimal build-time setup
FROM nvidia/cuda:12.3.2-cudnn9-runtime-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV WORKSPACE_DIR=/workspace
ENV PYTHONUNBUFFERED=1

# Create workspace directory
RUN mkdir -p /workspace

# Install minimal runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy scripts into the container
COPY scripts/ /opt/scripts/
RUN chmod +x /opt/scripts/*.sh

# Set working directory
WORKDIR /workspace

# Expose Gradio port
EXPOSE 7860

# Set the entrypoint
ENTRYPOINT ["/opt/scripts/entrypoint.sh"]