# AWS Monitoring & Observability Stack - Deployment Guide

This guide provides step-by-step instructions for deploying the AWS Monitoring & Observability Stack using Terraform.

## Prerequisites

- **AWS Account:** An active AWS account with permissions to create the necessary resources (EC2, VPC, IAM, etc.).
- **AWS CLI:** Configured with your credentials (`aws configure`).
- **Terraform:** Version 1.6.0 or later.
- **Git:** To clone the repository.
- **A VPC with public and private subnets:** This stack is designed to be deployed into an existing VPC.

## Deployment Steps

### Step 1: Clone the Repository

```bash
git clone https://github.com/mlakhoua-rgb/aws-monitoring-observability-stack.git
cd aws-monitoring-observability-stack
```

### Step 2: Configure the Terraform Environment

Navigate to the development environment directory and create a `terraform.tfvars` file.

```bash
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
```

Edit the `terraform.tfvars` file with your specific VPC and subnet information, and set a secure password for the Grafana admin user.

```hcl
# terraform.tfvars

aws_region           = "us-east-1"
environment          = "dev"
vpc_id               = "vpc-xxxxxxxxxxxxxxxxx" # Your VPC ID
private_subnet_ids   = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-yyyyyyyyyyyyyyyyy"] # Your private subnet IDs
public_subnet_ids    = ["subnet-zzzzzzzzzzzzzzzzz", "subnet-aaaaaaaaaaaaaaaaa"] # Your public subnet IDs
grafana_admin_password = "YourSecurePasswordHere"
alert_email          = "your-email@example.com"
```

### Step 3: Deploy the Infrastructure

1.  **Initialize Terraform:**

    ```bash
    terraform init
    ```

2.  **Plan the Deployment:**

    ```bash
    terraform plan
    ```

3.  **Apply the Configuration:**

    ```bash
    terraform apply
    ```

    Confirm the deployment by typing `yes`.

### Step 4: Access Grafana

Once the deployment is complete, Terraform will output the DNS name of the Grafana Application Load Balancer.

```bash
terraform output grafana_url
```

Open this URL in your web browser. You can log in with the username `admin` and the password you set in your `terraform.tfvars` file.

### Step 5: Configure Prometheus Data Source

In the Grafana UI, you may need to manually configure the Prometheus data source.

1.  Go to **Configuration (gear icon) > Data Sources**.
2.  Click **Add data source** and select **Prometheus**.
3.  For the **URL**, enter the private IP address of your Prometheus instance (you can get this from the Terraform output: `terraform output prometheus_private_ip`). The URL should be in the format `http://<prometheus-private-ip>:9090`.
4.  Click **Save & Test**.

## Destroying the Infrastructure

To remove all the resources created by this stack, run:

```bash
terraform destroy
```
