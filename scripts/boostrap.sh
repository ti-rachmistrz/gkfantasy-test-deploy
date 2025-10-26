#!/usr/bin/env bash
set -euo pipefail

REGION="${1:-us-east-1}"
ECR_REPO="${2:-my-lambda}"
LAMBDA_NAME="${3:-my-func}"
LAMBDA_ROLE_ARN="${4:-}"  # e.g. arn:aws:iam::123456789012:role/LambdaBasicExecRole

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

echo "Creating (or confirming) ECR repo: ${ECR_REPO}"
aws ecr describe-repositories --repository-names "${ECR_REPO}" --region "${REGION}" >/dev/null 2>&1 \
  || aws ecr create-repository --repository-name "${ECR_REPO}" --image-scanning-configuration scanOnPush=true --region "${REGION}"

echo "Logging in to ECR..."
aws ecr get-login-password --region "${REGION}" | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

echo "Building image..."
docker build -t "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO}:init" .

echo "Pushing image..."
docker push "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO}:init"

if [[ -n "$LAMBDA_ROLE_ARN" ]]; then
  echo "Creating Lambda (if not exists)..."
  aws lambda get-function --function-name "${LAMBDA_NAME}" --region "${REGION}" >/dev/null 2>&1 || \
  aws lambda create-function \
    --function-name "${LAMBDA_NAME}" \
    --package-type Image \
    --code ImageUri="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO}:init" \
    --role "${LAMBDA_ROLE_ARN}" \
    --timeout 15 \
    --memory-size 256 \
    --region "${REGION}"
fi

echo "Done."
