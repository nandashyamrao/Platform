
# Dynatrace AWS S3 Log Forwarder – Terraform IAM & EventBridge Configuration

This file contains all necessary IAM roles, policies, S3 bucket policies, and EventBridge rules required to operate the Dynatrace AWS S3 Log Forwarder for KMS-encrypted CloudTrail, CloudFront, and custom logs.

---

## 📌 IAM Role for Lambda

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
```

---

## 📌 IAM Policy for Lambda

```hcl
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
        Resource = aws_sqs_queue.log_queue.arn
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
```

---

## 📌 IAM Role-Policy Attachment

```hcl
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
```

---

## 📌 SQS Queue Policy

```hcl
resource "aws_sqs_queue_policy" "queue_policy" {
  queue_url = aws_sqs_queue.log_queue.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowEventBridgeSend",
        Effect = "Allow",
        Principal = { Service = "events.amazonaws.com" },
        Action = "sqs:SendMessage",
        Resource = aws_sqs_queue.log_queue.arn
      },
      {
        Sid = "AllowLambdaReceive",
        Effect = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = aws_sqs_queue.log_queue.arn
      }
    ]
  })
}
```

---

## 📌 S3 Bucket Policy for Lambda to Access Logs

```hcl
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.log_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "AllowLambdaToReadLogs",
        Effect: "Allow",
        Principal = {
          AWS = aws_iam_role.lambda_role.arn
        },
        Action = ["s3:GetObject"],
        Resource = "${aws_s3_bucket.log_bucket.arn}/*"
      }
    ]
  })
}
```

---

## 📌 EventBridge Rule and Target

```hcl
resource "aws_cloudwatch_event_rule" "s3_event_rule" {
  name        = "sf-ems-test-dt-s3-fwd-s3-events"
  description = "Trigger rule for S3 put events to forward logs"
  event_pattern = jsonencode({
    source = ["aws.s3"],
    "detail-type" = ["Object Created"],
    detail = {
      bucket = {
        name = [aws_s3_bucket.log_bucket.id]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "s3_event_target" {
  rule      = aws_cloudwatch_event_rule.s3_event_rule.name
  target_id = "SendToSQS"
  arn       = aws_sqs_queue.log_queue.arn
}
```

---

## 📌 Lambda Permission for EventBridge

```hcl
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynatrace_forwarder.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_event_rule.arn
}
```
