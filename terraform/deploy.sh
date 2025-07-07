#!/bin/bash

set -e

echo "Starting ECS Infrastructure Deployment..."

if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it first."
    exit 1
fi

if ! command -v terraform &> /dev/null; then
    echo "Terraform is not installed. Please install it first."
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    echo "AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

echo "Prerequisites check passed"

echo "Initializing Terraform..."
terraform init

echo "Planning deployment..."
terraform plan

read -p "Do you want to apply this configuration? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Applying Terraform configuration..."
    terraform apply -auto-approve
    
    echo "Deployment completed successfully!"
    echo ""
    echo "Deployment Summary:"
    echo "ALB DNS Name: $(terraform output -raw alb_dns_name)"
    echo "ECS Cluster: $(terraform output -raw ecs_cluster_name)"
    echo "ECS Service: $(terraform output -raw ecs_service_name)"
    echo ""
    echo "You can access your application at: http://$(terraform output -raw alb_dns_name)"
    echo ""
    echo "Useful commands:"
    echo "  - View logs: aws logs describe-log-groups --log-group-name-prefix '/ecs/ecs-app'"
    echo "  - Check service status: aws ecs describe-services --cluster ecs-app-cluster --services ecs-app-service"
    echo "  - Destroy infrastructure: terraform destroy"
else
    echo "Deployment cancelled"
    exit 1
fi 