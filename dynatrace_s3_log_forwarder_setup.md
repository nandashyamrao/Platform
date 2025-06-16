
# 📦 Dynatrace AWS S3 Log Forwarder Setup (Terraform + AppConfig)

To fully align with the Dynatrace AWS S3 Log Forwarder repository instructions (especially `docs/log_forwarding.md` and `docs/log_processing.md`), here are the customized and complete AppConfig JSON/YAML rules and Terraform roles/policies tailored to your multi-log-source bucket setup.

---

## ✅ 1. Log Forwarding Rules (`log-forwarding-rules.yaml`)

```yaml
log_forwarding_rules:
  - rule_name: cloudtrail-logs
    match:
      bucket_name: sf-ems-test-dt-s3-fwd-logs
      key_prefix: AWSLogs/
      log.source: aws.cloudtrail
    actions:
      - action: forward
        target: dynatrace

  - rule_name: cloudfront-logs
    match:
      bucket_name: sf-ems-test-dt-s3-fwd-logs
      key_prefix: CloudFront/
      log.source: aws.cloudfront
    actions:
      - action: forward
        target: dynatrace

  - rule_name: generic-logs
    match:
      bucket_name: sf-ems-test-dt-s3-fwd-logs
      key_prefix: custom-logs/
    actions:
      - action: forward
        target: dynatrace
```

---

## ✅ 2. Log Processing Rules (`log-processing-rules.yaml`)

```yaml
log_processing_rules:
  - rule_name: parse-cloudtrail
    match:
      log.source: aws.cloudtrail
    actions:
      - action: parse
        parser: cloudtrail

  - rule_name: parse-cloudfront
    match:
      log.source: aws.cloudfront
    actions:
      - action: parse
        parser: cloudfront

  - rule_name: parse-generic
    match:
      key_prefix: custom-logs/
    actions:
      - action: parse
        parser: text
```

---

## ✅ Compatibility Notes

These rule sets match the repository’s guidelines and ensure:

- Correct routing for each log category
- Appropriate parsing leveraging built-in Dynatrace parsers
- Fallback handling for generic log files

---

## ✅ 3. Terraform IAM Roles & Policies

```hcl
resource "aws_iam_role" "lambda_role" {
  name = "sf-ems-test-dt-s3-fwd-lambda-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }],
    Version = "2012-10-17"
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
        Action = ["ssm:GetParameter","ssm:GetParameters"],
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

## ✅ 4. SQS Policy Snippet

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

## 📥 What’s Next

1. Save the YAML rule files to your environment
2. Deploy using AWS AppConfig or Terraform
3. Upload sample CloudTrail, CloudFront, and custom logs to the bucket
4. Confirm data reaches Dynatrace via log viewer and dashboards
