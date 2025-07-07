# ECS Terraform Infrastructure with Docker

Complete AWS ECS infrastructure deployment using Terraform with Docker containerization.

## Project Structure

```
terraform-learn/
├── Dockerfile              # Node.js application Dockerfile
├── Dockerfile.simple       # Nginx-based Dockerfile (recommended)
├── nginx.conf             # Nginx configuration
├── public/
│   └── index.html         # Web application
├── terraform/
│   ├── main.tf           # Main Terraform configuration
│   ├── variables.tf      # Variable definitions
│   ├── terraform.tfvars  # Variable values
│   ├── deploy.sh         # Deployment script
│   └── README.md         # Terraform documentation
├── build-and-push.sh     # Docker build and push script
└── .dockerignore         # Docker ignore file
```

## Quick Start

### Prerequisites

- AWS CLI configured
- Terraform installed
- Docker installed
- AWS credentials with ECR permissions

### Step 1: Build and Push Docker Image

```bash
./build-and-push.sh
```

### Step 2: Deploy Infrastructure

```bash
cd terraform
./deploy.sh
```

### Step 3: Access Your Application

After deployment, access your application using the ALB DNS name:

```bash
terraform output alb_dns_name
```

## Docker Setup

### Option 1: Simple Nginx Application (Recommended)

```bash
# Build using simple Dockerfile
docker build -f Dockerfile.simple -t ecs-demo-app .

# Run locally to test
docker run -p 8080:80 ecs-demo-app
```

### Option 2: Node.js Application

```bash
# Build using Node.js Dockerfile
docker build -f Dockerfile -t ecs-demo-app .

# Run locally to test
docker run -p 3000:3000 ecs-demo-app
```

## Infrastructure Components

### Created Resources:

- **VPC** with public/private subnets
- **Application Load Balancer** (ALB)
- **ECS Cluster** with Fargate
- **ECS Task Definition** and **Service**
- **Security Groups** and **IAM Roles**
- **CloudWatch Log Group**
- **ECR Repository** (created automatically)

### Architecture:

```
Internet → ALB → ECS Service → ECS Tasks (Fargate)
```

## Customization

### Docker Image

Edit `Dockerfile.simple` to customize your application:

```dockerfile
# Change base image
FROM nginx:alpine

# Add custom files
COPY your-app/ /usr/share/nginx/html/
```

### Terraform Configuration

Modify `terraform/terraform.tfvars`:

```hcl
# Change region
aws_region = "us-west-2"

# Adjust resources
task_cpu = 512
task_memory = 1024
service_desired_count = 3
```

## Monitoring

### CloudWatch Logs

```bash
# View container logs
aws logs describe-log-groups --log-group-name-prefix "/ecs/ecs-app"
```

### ECS Service Status

```bash
# Check service status
aws ecs describe-services --cluster ecs-app-cluster --services ecs-app-service
```

### ALB Health

```bash
# Check target health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

## Development Workflow

### 1. Local Development

```bash
# Build and test locally
docker build -f Dockerfile.simple -t my-app .
docker run -p 8080:80 my-app
```

### 2. Push to ECR

```bash
# Build and push to ECR
./build-and-push.sh
```

### 3. Deploy Infrastructure

```bash
# Deploy with Terraform
cd terraform
terraform apply
```

### 4. Update Application

```bash
# After code changes
./build-and-push.sh
# Terraform will use the new image automatically
```

## Cost Optimization

- **Fargate**: Pay only for what you use
- **Minimal Resources**: 256 CPU, 512MB RAM by default
- **Auto Scaling**: Scale based on demand
- **Spot Instances**: Use for non-critical workloads

## Security Features

- **Private Subnets**: ECS tasks run in private subnets
- **Security Groups**: Restrict traffic to HTTP/HTTPS
- **IAM Roles**: Least privilege access
- **Container Logging**: All logs sent to CloudWatch

## Cleanup

### Destroy Infrastructure

```bash
cd terraform
terraform destroy
```

### Remove ECR Repository

```bash
aws ecr delete-repository --repository-name ecs-demo-app --force
```

## Troubleshooting

### Common Issues:

1. **Docker Build Fails**

   ```bash
   # Check Docker is running
   docker --version
   docker ps
   ```

2. **ECR Login Issues**

   ```bash
   # Re-login to ECR
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
   ```

3. **Terraform Apply Fails**

   ```bash
   # Check AWS credentials
   aws sts get-caller-identity

   # Check Terraform state
   terraform plan
   ```

4. **ECS Service Not Starting**
   ```bash
   # Check service events
   aws ecs describe-services --cluster ecs-app-cluster --services ecs-app-service --query 'services[0].events'
   ```

## Next Steps

Consider adding:

- HTTPS/SSL certificates
- Custom domain names
- Auto scaling policies
- CI/CD pipeline integration
- Monitoring and alerting
- Blue-green deployments

## Success!

After deployment, you'll have:

- **Production-ready ECS cluster**
- **Scalable containerized application**
- **Load balancer for traffic distribution**
- **CloudWatch monitoring**
- **Infrastructure as Code**

Your application will be available at the ALB DNS name!
