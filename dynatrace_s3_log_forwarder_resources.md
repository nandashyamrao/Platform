
# Dynatrace S3 Log Forwarder – Terraform Resource Guide

This document outlines all the AWS resources to be provisioned using Terraform for deploying the Dynatrace AWS S3 Log Forwarder. The setup supports CloudTrail, CloudFront, and generic log files stored in a KMS-encrypted S3 bucket, and leverages EventBridge, SQS, and a Lambda deployed from an ECR image. Parameters are securely stored in AWS SSM Parameter Store.

---

## 🗂 Resource: S3 Bucket – Log Storage

**Purpose**: Stores log files from CloudTrail, CloudFront, and other services.

**Terraform Resource Type**: `aws_s3_bucket`

### Key Configurations
- `bucket`: Name should include prefix `sf-ems-test-dt-s3-fwd`
- `kms_master_key_id`: KMS key used for encryption
- `server_side_encryption_configuration`: AES256 or KMS encryption

---

## 🔐 Resource: KMS Key

**Purpose**: Encrypts the S3 bucket and secures Lambda access to objects.

**Terraform Resource Type**: `aws_kms_key`

### IAM Policy Consideration
Attach permissions to allow:
- S3 to encrypt objects
- Lambda IAM role to decrypt objects

---

## 📦 Resource: SSM Parameter Store

**Purpose**: Stores secure parameters (Dynatrace URL, token).

**Terraform Resource Type**: `aws_ssm_parameter`

### Parameters to Set
- `/dynatrace/api/url`
- `/dynatrace/api/token`

---

## 🧠 Resource: IAM Roles and Policies

### Lambda Execution Role
**Terraform Resource Type**: `aws_iam_role`

**Purpose**: Grants Lambda permission to access S3, SQS, KMS, SSM.

**Policies to Attach**:
- Read from SQS (`sqs:ReceiveMessage`, `sqs:DeleteMessage`)
- Read SSM Parameters (`ssm:GetParameter`)
- Read/Decrypt KMS-encrypted objects (`kms:Decrypt`)
- GetObject from S3
- PutMetricData to CloudWatch
- Send logs to Dynatrace endpoint (via NAT/internet)

---

## 🎯 Resource: EventBridge Rule

**Purpose**: Triggers on `PutObject` events from S3 for new log files.

**Terraform Resource Type**: `aws_cloudwatch_event_rule`

### Configuration
- Pattern: Match `PutObject` events
- Target: SQS queue

---

## 📬 Resource: SQS Queue

**Purpose**: Acts as a buffer for S3-to-Lambda messages.

**Terraform Resource Type**: `aws_sqs_queue`

### Notes
- Must allow EventBridge to send messages
- Must allow Lambda to poll messages

---

## 🧪 Resource: Lambda Function (ECR Image)

**Purpose**: Reads from SQS, downloads S3 objects, decompresses, parses logs, sends to Dynatrace.

**Terraform Resource Type**: `aws_lambda_function`

### Configuration
- `image_uri`: URI of the ECR image with the forwarder code
- `environment_variables`:
  - `DT_API_URL`
  - `DT_API_TOKEN`
  - `LOG_FORWARDING_RULES_PATH`
  - `LOG_PROCESSING_RULES_PATH`
  - `S3_EVENT_SOURCE` (set to `eventbridge`)

---

## 🧰 Supporting Files and Configs

### 1. `log_forwarding_rules.json`
Defines routing rules based on S3 key patterns, e.g., `"CloudTrail"` or `"CloudFront"` in path.

### 2. `log_processing_rules.json`
Handles JSON parsing or transformation rules for known log formats.

### 3. `app-config.json`
Used to define which SSM parameters and file paths the Lambda should refer to.

---

## 📝 Naming & Prefix Guidance

- Prefix all resource names with: `sf-ems-test-dt-s3-fwd`
- Ensure environment variables align with config file paths in S3 or Lambda layers
- Store config JSONs in S3 or embed in image depending on packaging

---

## ✅ Checklist Before Deployment

- [ ] Create KMS key and grant access to Lambda
- [ ] Create and encrypt S3 bucket
- [ ] Upload at least one test CloudTrail/CloudFront log to S3
- [ ] Ensure log matches forwarding/processing rules
- [ ] Create SSM params for Dynatrace URL/token
- [ ] Deploy Lambda from ECR
- [ ] Ensure correct EventBridge rule pattern
- [ ] Set appropriate IAM policies for each role
