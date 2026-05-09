#!/bin/bash
# Multi-region deployment script
set -euo pipefail

REGIONS=("us-east-1" "us-west-2" "eu-west-1")
IMAGE_TAG="${1:-latest}"
SERVICE="${2:-all}"

echo "Deploying $SERVICE:$IMAGE_TAG to ${#REGIONS[@]} regions..."

for REGION in "${REGIONS[@]}"; do
  echo "--- Deploying to $REGION ---"
  aws eks update-kubeconfig --name "devops-platform-prod" --region "$REGION"

  if [ "$SERVICE" == "all" ]; then
    kubectl apply -f kubernetes/ --recursive
    kubectl rollout status deployment -n production --timeout=5m
  else
    kubectl set image deployment/"$SERVICE" "$SERVICE"="$ECR_REGISTRY/$SERVICE:$IMAGE_TAG" -n production
    kubectl rollout status deployment/"$SERVICE" -n production --timeout=5m
  fi

  echo "Region $REGION: Deployment successful"
done

echo "All regions deployed successfully!"
