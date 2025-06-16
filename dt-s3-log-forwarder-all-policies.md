
# 📜 Dynatrace S3 Log Forwarder – IAM, SQS, EventBridge, and S3 Policies

This markdown file includes all IAM roles, policies, and resource-based permissions (SQS, S3, EventBridge) required for a complete same-account setup.

---

## 1️⃣ Lambda Execution Role & Policy

```hcl
resource "aws_iam_role" "lambda_role" {
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

resource "aws_iam_role_policy_attachment" "lambda_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
```

---

## 2️⃣ SQS Queue Policy

```hcl
resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.queue.id
  policy    = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowEventBridge",
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action = "sqs:SendMessage",
        Resource = aws_sqs_queue.queue.arn
      },
      {
        Sid = "AllowLambda",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
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

## 3️⃣ S3 Bucket Policy

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

## 4️⃣ KMS Key Policy (Partial)

Make sure the Lambda IAM role is included in the KMS key’s policy:

```json
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
```

---

## 5️⃣ EventBridge Rule

```hcl
resource "aws_cloudwatch_event_rule" "s3_event_rule" {
  name        = "sf-ems-test-dt-s3-fwd-rule"
  description = "Triggers on CloudTrail S3 object creation"
  event_pattern = jsonencode({
    source = ["aws.s3"],
    "detail-type" = ["Object Created"],
    detail = {
      bucket = {
        name = ["sf-ems-test-dt-s3-fwd-logs"]
      },
      object = {
        key = [{ prefix = "AWSLogs/" }]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "send_to_sqs" {
  rule = aws_cloudwatch_event_rule.s3_event_rule.name
  arn  = aws_sqs_queue.queue.arn
}
```

---

🔐 Ensure:
- The Lambda role is trusted by Lambda
- The SQS queue accepts messages from EventBridge and allows Lambda to consume
- The S3 bucket allows object read by Lambda
- The KMS key allows decryption by Lambda

Let me know if you want these rendered into `.tf` files or added to your main `.md` deployment documentation!
