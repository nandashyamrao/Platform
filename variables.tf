variable "lambda_name" {
  description = "The name of the Dynatrace log forwarder Lambda function"
  type        = string
}

variable "sqs_name" {
  description = "The SQS queue name receiving notifications"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}