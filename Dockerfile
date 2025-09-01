# OmniTry RunPod Container
FROM nvidia/cuda:12.3.2-cudnn9-runtime-ubuntu22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    wget \
    curl \
    git \
    tzdata && \
    rm -rf /var/lib/apt/lists/*

# Configure timezone and install Python 3.11
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
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