
# 📜 Dynatrace AWS S3 Log Forwarder – IAM Roles and Policies

This file contains all IAM roles and policies needed for the **end-to-end setup** of Dynatrace S3 Log Forwarder with CloudTrail, CloudFront, and generic logs.

---

## 1. Lambda Execution Role and Policy

```hcl
resource "aws_iam_role" "lambda_role" {
  name = "sf-ems-test-dt-s3-fwd-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "sf-ems-test-dt-s3-fwd-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = aws_sqs_queue.queue.arn
      },
      {
        Effect = "Allow",
        Action = ["s3:GetObject"],
        Resource = "${aws_s3_bucket.log_bucket.arn}/*"
      },
      {
        Effect = "Allow",
        Action = ["kms:Decrypt"],
        Resource = aws_kms_key.log_key.arn
      },
      {
        Effect = "Allow",
        Action = ["ssm:GetParameter", "ssm:GetParameters"],
        Resource = [
          aws_ssm_parameter.dt_token.arn,
          aws_ssm_parameter.dt_url.arn
        ]
      },
      {
        Effect = "Allow",
        Action = ["appconfig:GetConfiguration"],
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
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
```

---

## 2. SQS Queue Access Policy

```hcl
resource "aws_sqs_queue_policy" "queue_policy" {
  queue_url = aws_sqs_queue.queue.id
  policy    = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowEventBridge",
        Effect = "Allow",
        Principal = { Service = "events.amazonaws.com" },
        Action = "sqs:SendMessage",
        Resource = aws_sqs_queue.queue.arn
      },
      {
        Sid = "AllowLambda",
        Effect = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = aws_sqs_queue.queue.arn
      }
    ]
  })
}
```

---

## 3. S3 Bucket Policy for Access (Lambda Read with KMS Encryption)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowLambdaReadAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<your-account-id>:role/sf-ems-test-dt-s3-fwd-lambda-role"
      },
      "Action": ["s3:GetObject"],
      "Resource": "arn:aws:s3:::sf-ems-test-dt-s3-fwd-logs/*"
    }
  ]
}
```

---

## 4. KMS Key Policy Snippet

```json
{
  "Version": "2012-10-17",
  "Id": "key-policy",
  "Statement": [
    {
      "Sid": "AllowLambdaDecrypt",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<your-account-id>:role/sf-ems-test-dt-s3-fwd-lambda-role"
      },
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "*"
    }
  ]
}
```

---

Let me know if you need the policies broken into standalone `.tf` files or consolidated for CloudFormation.
