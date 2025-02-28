# AWS CloudFront Logs to Dynatrace Using Terraform

This guide provides a **Terraform setup** to forward **AWS CloudFront logs** to **Dynatrace** using an **ECR-based AWS S3 Lambda forwarder**. No CloudFormation is used.

---

## **📂 Folder & File Structure**
```
terraform/
│── modules/
│   ├── s3/                 # S3 bucket for CloudFront logs
│   ├── cloudfront/         # CloudFront distribution setup
│   ├── sns/                # SNS topic and subscriptions
│   ├── iam/                # IAM roles and policies
│   ├── ecr/                # ECR repository setup
│   ├── lambda/             # Lambda function (ECR-based)
│   ├── secrets/            # AWS Secrets Manager & SSM Parameter Store
│── main.tf                 # Root Terraform configuration
│── variables.tf            # Variables for configuration
│── outputs.tf              # Outputs after deployment
│── terraform.tfvars        # User-defined values
```

---

## **🔹 Phase 1: ECR Repository for Storing Lambda Image**
```hcl
resource "aws_ecr_repository" "lambda_ecr" {
  name = "dt-s3-log-forwarder"

  image_scanning_configuration {
    scan_on_push = true
  }
}
```

After creating the repo, **push the Lambda image**:
```sh
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
docker tag dt-s3-log-forwarder:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/dt-s3-log-forwarder:latest
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/dt-s3-log-forwarder:latest
```

---

## **🔹 Phase 2: Create S3 Bucket for CloudFront Logs**
```hcl
resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = var.cloudfront_logs_bucket_name
}
```

---

## **🔹 Phase 3: Configure CloudFront to Send Logs to S3**
```hcl
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = "your-origin.example.com"
    origin_id   = "origin-1"
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
    prefix          = "cloudfront-logs/"
  }

  enabled = true
}
```

---

## **🔹 Phase 4: SNS Topic for Log Notifications**
```hcl
resource "aws_sns_topic" "cloudfront_log_notifications" {
  name = "cloudfront-log-notifications"
}
```

---

## **🔹 Phase 5: IAM Role for Lambda**
```hcl
resource "aws_iam_role" "lambda_role" {
  name = "dt-s3-log-forwarder-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}
```

---

## **🔹 Phase 6: AWS Secrets & Parameter Store for Dynatrace API Key**
```hcl
resource "aws_secretsmanager_secret" "dynatrace_api_key" {
  name = "dynatrace_api_key"
}
```

---

## **🔹 Phase 7: Deploy Lambda Function (ECR-based)**
```hcl
resource "aws_lambda_function" "dt_s3_log_forwarder" {
  function_name = "dt-s3-log-forwarder"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.lambda_ecr.repository_url}:latest"
  timeout       = 60
  memory_size   = 512

  environment {
    variables = {
      DYNATRACE_LOG_INGEST_URL = "https://<your_dynatrace_env>/api/v2/logs/ingest"
      DYNATRACE_API_KEY        = aws_secretsmanager_secret.dynatrace_api_key.name
    }
  }
}
```

---

## **📌 Phase 8: Define Terraform Variables**
```hcl
variable "cloudfront_logs_bucket_name" {
  description = "S3 bucket for CloudFront logs"
  type        = string
}

variable "dynatrace_api_key" {
  description = "API key for Dynatrace Log Monitoring"
  type        = string
}
```

---

## **📌 Phase 9: Deploying the Infrastructure**
1. **Initialize Terraform**
   ```sh
   terraform init
   ```
2. **Preview the Plan**
   ```sh
   terraform plan
   ```
3. **Deploy the Infrastructure**
   ```sh
   terraform apply -auto-approve
   ```

---

## **🎯 Summary**
✅ **No CloudFormation, 100% Terraform**  
✅ **CloudFront logs → S3 → SNS → Lambda (ECR) → Dynatrace**  
✅ **Uses AWS Secrets Manager & SSM for secure API key storage**  
✅ **Complete automation for CloudFront log ingestion**  

🚀 **Now, you have a complete Terraform setup to send AWS CloudFront logs to Dynatrace!** 🎉
