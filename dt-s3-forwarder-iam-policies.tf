
# -----------------------------------------
# Lambda Execution Role
# -----------------------------------------
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

# Lambda IAM Policy
resource "aws_iam_policy" "lambda_policy" {
  name   = "sf-ems-test-dt-s3-fwd-lambda-policy"
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

# Attach Policy to Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# -----------------------------------------
# SQS Policy
# -----------------------------------------
resource "aws_sqs_queue_policy" "queue_policy" {
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

# -----------------------------------------
# S3 Bucket Policy
# -----------------------------------------
resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = aws_s3_bucket.log_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowLambdaGetObject",
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.lambda_role.arn
        },
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.log_bucket.arn}/*"
      }
    ]
  })
}

# -----------------------------------------
# EventBridge Rule
# -----------------------------------------
resource "aws_cloudwatch_event_rule" "s3_event_rule" {
  name        = "sf-ems-test-dt-s3-fwd-event-rule"
  description = "Triggered on S3 Object Created events"
  event_pattern = jsonencode({
    source = ["aws.s3"],
    "detail-type" = ["Object Created"],
    detail = {
      bucket = {
        name = [aws_s3_bucket.log_bucket.bucket]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "s3_event_target" {
  rule      = aws_cloudwatch_event_rule.s3_event_rule.name
  arn       = aws_sqs_queue.queue.arn
  target_id = "sendToSQS"
}
