#!/bin/bash

set -e

IMAGE_NAME="ecs-demo-app"
TAG="latest"
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID=""

echo "Building and pushing Docker image..."

if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install AWS CLI first."
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "Could not get AWS account ID. Please check your AWS credentials."
    exit 1
fi

echo "AWS Account ID: $AWS_ACCOUNT_ID"

echo "Creating ECR repository..."
aws ecr create-repository --repository-name $IMAGE_NAME --region $AWS_REGION 2>/dev/null || echo "Repository already exists"

echo "Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

echo "Building Docker image..."
docker build -f Dockerfile.simple -t $IMAGE_NAME:$TAG .

ECR_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME:$TAG"
docker tag $IMAGE_NAME:$TAG $ECR_URI

echo "Pushing image to ECR..."
docker push $ECR_URI

echo "Image successfully pushed to ECR!"
echo "ECR Image URI: $ECR_URI"

echo "Updating terraform.tfvars with ECR image URI..."
sed -i.bak "s|container_image = \".*\"|container_image = \"$ECR_URI\"|" terraform/terraform.tfvars

echo ""
echo "Docker image build and push completed!"
echo "Next steps:"
echo "  1. Run: cd terraform && ./deploy.sh"
echo "  2. Or manually: terraform init && terraform plan && terraform apply"
echo ""
echo "Your application will be available at the ALB DNS name after deployment." 