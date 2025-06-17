# 🧩 Terraform: Lambda Function for Dynatrace S3 Log Forwarder

This file defines the AWS Lambda function that processes CloudTrail, CloudFront, and generic logs from an S3 bucket and sends them to Dynatrace. It includes:

- Lambda function configuration using an ECR container image
- Environment variables with SSM-based secrets
- IAM role and permissions
- SQS trigger event mapping

---

## 📁 Lambda Function Terraform Resource

```hcl
resource "aws_lambda_function" "dt_s3_log_forwarder" {
  function_name = "sf-ems-test-dt-s3-fwd-lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  package_type  = "Image"
  image_uri     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/dt-log-fwd:latest"
  timeout       = 300
  memory_size   = 512
  publish       = true

  environment {
    variables = {
      APP_CONFIG_APPLICATION_NAME      = "dt-s3-log-fwd-app"
      APP_CONFIG_ENVIRONMENT_NAME      = "dt-s3-log-fwd-env"
      APP_CONFIG_CONFIGURATION_PROFILE = "dt-s3-log-fwd-profile"
      DT_URL                           = "ssm:/sf-ems-test-dt-url"
      DT_API_TOKEN                     = "ssm:/sf-ems-test-dt-token"
      LOG_LEVEL                        = "INFO"
    }
  }
}
```

---

## 🛡 IAM Role & Policy

```hcl
resource "aws_iam_role" "lambda_exec_role" {
  name = "sf-ems-test-dt-s3-fwd-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_exec_policy" {
  name = "sf-ems-test-dt-s3-fwd-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::sf-ems-test-dt-s3-fwd-logs/*"
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = ["kms:Decrypt"],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = ["appconfig:GetConfiguration"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_exec_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}
```

---

## 🔁 Event Source Mapping from SQS

```hcl
resource "aws_lambda_event_source_mapping" "from_sqs" {
  event_source_arn = aws_sqs_queue.logs_queue.arn
  function_name    = aws_lambda_function.dt_s3_log_forwarder.arn
  batch_size       = 10
  enabled          = true
}
```
