# Containerized Lambda (Auto-deploy on develop)

This repo ships a containerized AWS Lambda. On **push/merge to `develop`**, GitHub Actions:

1) Builds a Docker image from `Dockerfile`
2) Pushes it to ECR
3) Updates the Lambda to the new image

## Prereqs

- An AWS account + admin access to set up:
  - An **ECR repo** (or run `scripts/bootstrap.sh`)
  - A **Lambda function** using `PackageType=Image` (or run `scripts/bootstrap.sh`)
  - A **Lambda execution role** (basic CloudWatch logs policy is fine)
- A **GitHub OIDC IAM role** your workflow can assume:
  - Trust policy for `token.actions.githubusercontent.com`
  - Permission policy allowing:
    - `ecr:*` (or minimally: GetAuthorizationToken, BatchCheckLayerAvailability, CompleteLayerUpload, InitiateLayerUpload, PutImage, UploadLayerPart, DescribeRepositories, CreateRepository)
    - `lambda:UpdateFunctionCode`, `lambda:GetFunction`
- GitHub repository **secrets**:
  - `AWS_ACCOUNT_ID`
  - `AWS_ROLE_TO_ASSUME` (ARN of your OIDC deploy role)
  - `ECR_REPO` (e.g., `my-lambda`)
  - `LAMBDA_FUNCTION_NAME` (e.g., `my-func`)

## One-time bootstrap (optional)

```bash
bash scripts/bootstrap.sh us-east-1 my-lambda my-func arn:aws:iam::<acct>:role/LambdaBasicExecRole
