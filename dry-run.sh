#!/bin/bash
# Dry-run script for building OmniTry container locally
# WARNING: This is for testing only - do not build locally for production

echo "=== OmniTry RunPod Container - Local Test Build ==="
echo "WARNING: Local builds may not work on production RunPod!"
echo ""

# Set container name
CONTAINER_NAME="omnitry-runpod-test"
DOCKERHUB_REPO="gemneye/omnitry-runpod"

echo "Building container: $CONTAINER_NAME"
echo "Target repo: $DOCKERHUB_REPO"
echo ""

# Check if we have the required secrets
if [[ -z "${DOCKER_USERNAME}" || -z "${DOCKER_PASSWORD}" ]]; then
    echo "❌ DockerHub credentials not found in environment"
    echo "   Set DOCKER_USERNAME and DOCKER_PASSWORD to test push"
    echo ""
    echo "Building locally without push..."
    docker build -t $CONTAINER_NAME .

    echo ""
    echo "Container built: $CONTAINER_NAME"
    echo "To push manually:"
    echo "  docker tag $CONTAINER_NAME $DOCKERHUB_REPO:test"
    echo "  docker push $DOCKERHUB_REPO:test"
    echo ""
    echo "⚠️  NOTE: Test pushes should use different tags than production"
    echo "   Use format: :test-YYYYMMDD or :local-NNN"
else
    echo "🔐 DockerHub credentials found"
    echo "   Building and pushing to DockerHub..."

    # Build and push
    docker build -t $CONTAINER_NAME .
    docker tag $CONTAINER_NAME $DOCKERHUB_REPO:test-$(date +%Y%m%d)

    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
    docker push $DOCKERHUB_REPO:test-$(date +%Y%m%d)

    echo ""
    echo "✅ Container pushed to: $DOCKERHUB_REPO:test-$(date +%Y%m%d)"
    echo "   View at: https://hub.docker.com/r/$DOCKERHUB_REPO"
fi

echo ""
echo "Build complete!"
echo "Container is ready for RunPod deployment via:"
echo "  Runtime installation script: runtime_install.sh"