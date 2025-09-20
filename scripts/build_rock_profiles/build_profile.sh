#!/usr/bin/env bash

# Build script for custom Rock server with DataSHIELD Survival profile
# Usage: ./build_profile.sh (ensure it is executable `chmod +x build_profile.sh`)

TAG="v2.3.0"
IMAGE_NAME="rock-survival"

echo "Building Rock server with Survival profile..."
echo "Image: ${IMAGE_NAME}:${TAG}"

# Build the Docker image
docker build -f Dockerfile \
  -t "${IMAGE_NAME}:${TAG}" \
  -t "${IMAGE_NAME}:latest" \
  .

echo "Build completed successfully!"
echo "Image tags created:"
echo "  - ${IMAGE_NAME}:${TAG}"
echo "  - ${IMAGE_NAME}:latest"

# Optional: Test the built image
read -p "Do you want to test the image? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Testing the image..."
    
    # Run container in background
    docker run -d --name test-survival-rock \
      -p 8085:8085 \
      "${IMAGE_NAME}:${TAG}"
    
    # Wait a moment for container to start
    sleep 5
    
    # Test package installation
    echo "Checking dsSurvival package installation..."
    docker exec test-survival-rock \
      Rscript -e "library(dsSurvival); cat('dsSurvival version:', as.character(packageVersion('dsSurvival')), '\n')"
    
    # Clean up test container
    docker stop test-survival-rock
    docker rm test-survival-rock
    
    echo "Test completed successfully!"
fi

echo "To run the image:"
echo "  docker run -d -p 8085:8085 ${IMAGE_NAME}:${TAG}"
