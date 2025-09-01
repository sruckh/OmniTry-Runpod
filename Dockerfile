# OmniTry RunPod Container
FROM nvidia/cuda:12.3.2-cudnn9-runtime-ubuntu22.04

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    wget \
    curl \
    git && \
    rm -rf /var/lib/apt/lists/*

# Install Python 3.11
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.11 python3-pip && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    rm -rf /var/lib/apt/lists/*

# Set Python path
ENV PYTHONPATH=/app:$PYTHONPATH

# Create non-root user
RUN useradd -m -u 1000 omnitry && \
    chown -R omnitry:omnitry /app

USER omnitry

# Default command will be set at runtime by RunPod
CMD ["echo", "Container ready for RunPod deployment"]

# Labels for DockerHub
LABEL org.opencontainers.image.title="OmniTry RunPod"
LABEL org.opencontainers.image.description="Virtual clothing try-on AI system for RunPod deployment"
LABEL org.opencontainers.image.source="https://github.com/sruckh/OmniTry-Runpod"
LABEL org.opencontainers.image.licenses="MIT"