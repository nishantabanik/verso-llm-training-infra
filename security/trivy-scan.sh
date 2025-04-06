#!/bin/bash

# Script to scan container images for vulnerabilities using Trivy

set -e

# Check if image name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <image-name> [severity-level]"
  echo "Example: $0 our-registry/llm-training:latest CRITICAL,HIGH"
  exit 1
fi

IMAGE_NAME=$1
SEVERITY=${2:-"CRITICAL,HIGH"}

# Make sure Trivy is installed
if ! command -v trivy &> /dev/null; then
  echo "Trivy not found. Installing..."
  curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
fi

echo "Scanning image: $IMAGE_NAME for vulnerabilities with severity: $SEVERITY"
trivy image --severity $SEVERITY --no-progress $IMAGE_NAME

# Check exit code
SCAN_EXIT_CODE=$?
if [ $SCAN_EXIT_CODE -eq 0 ]; then
  echo "No vulnerabilities found with severity level: $SEVERITY"
elif [ $SCAN_EXIT_CODE -eq 1 ]; then
  echo "Vulnerabilities found with severity level: $SEVERITY"
  exit 1
else
  echo "Trivy scan failed with exit code: $SCAN_EXIT_CODE"
  exit $SCAN_EXIT_CODE
fi