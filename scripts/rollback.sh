#!/bin/bash
# Emergency rollback script
set -euo pipefail

SERVICE="${1:?Usage: rollback.sh <service-name> [region]}"
REGION="${2:-us-east-1}"

echo "ROLLBACK: $SERVICE in $REGION"
aws eks update-kubeconfig --name "devops-platform-prod" --region "$REGION"
kubectl rollout undo deployment/"$SERVICE" -n production
kubectl rollout status deployment/"$SERVICE" -n production --timeout=5m
echo "Rollback complete for $SERVICE"
