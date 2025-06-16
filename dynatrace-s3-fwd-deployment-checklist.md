
# ✅ Dynatrace S3 Log Forwarder Deployment Checklist

This checklist is designed to guide the setup of Dynatrace AWS S3 Log Forwarder using Terraform, with full support for CloudTrail, CloudFront, and custom logs stored in an S3 bucket secured with a KMS key. All resources will follow the naming prefix: `sf-ems-test-dt-s3-fwd`.

---

## 📦 S3 Bucket Setup

- [ ] Create S3 bucket (e.g., `sf-ems-test-dt-s3-fwd-logs`)
- [ ] Enable server-side encryption using KMS
- [ ] Add bucket policy to allow:
  - EventBridge to send events
  - Lambda to read logs
- [ ] Use folder prefixes:
  - `AWSLogs/` for CloudTrail
  - `CloudFront/` for CloudFront logs
  - `custom-logs/` for generic logs

## 🔐 KMS Setup

- [ ] Create KMS key (e.g., `sf-ems-test-dt-s3-fwd-key`)
- [ ] Add permissions for:
  - Lambda execution role
  - S3 bucket access
- [ ] Enable key rotation if needed

## 🧾 SSM Parameter Store

- [ ] Store Dynatrace URL
- [ ] Store Dynatrace token
- Parameter names:
  - `/dynatrace/url`
  - `/dynatrace/token`

## 🪵 AppConfig Setup

- [ ] Create AppConfig application and environment
- [ ] Upload:
  - `log-forwarding-rules.yaml`
  - `log-processing-rules.yaml`

## 🪝 Lambda Function

- [ ] Use ECR image if applicable
- [ ] Lambda environment variables:
  - `DT_API_URL`
  - `DT_API_TOKEN`
  - `AWS_LAMBDA_EXEC_WRAPPER` (if using wrapper)
  - `APP_CONFIG_ENV`, `APP_CONFIG_APP`, `APP_CONFIG_CONFIG`
- [ ] Attach IAM execution role

## 🛡️ IAM Roles & Policies

- [ ] Lambda Role (created in Terraform)
- [ ] Lambda Policy (attach permissions for S3, SQS, KMS, SSM, AppConfig, CloudWatch Logs)

## 📥 SQS Queue

- [ ] Name: `sf-ems-test-dt-s3-fwd-queue`
- [ ] Add policy to allow:
  - EventBridge to send messages
  - Lambda to read/delete messages

## 🔔 EventBridge Rule

- [ ] Triggers on `PutObject` in S3
- [ ] Sends to SQS queue
- [ ] Use default EventBus or specify one

## 🧪 Testing & Verification

- [ ] Upload CloudTrail `.gz` log to `AWSLogs/`
- [ ] Upload CloudFront log to `CloudFront/`
- [ ] Upload a generic log to `custom-logs/`
- [ ] Check logs appearing in Dynatrace

---

## 🔄 End-to-End Flow Orchestration

1. **Log Generation**:
   - AWS services like CloudTrail and CloudFront write logs to specific prefixes in your S3 bucket.

2. **Notification**:
   - S3 emits `PutObject` event.
   - EventBridge captures this and forwards it to the SQS queue.

3. **Queue Message**:
   - SQS holds the event message.
   - Lambda function is triggered to consume it.

4. **Lambda Processing**:
   - Downloads the file from S3.
   - Uses AppConfig rules to match the log type (CloudTrail, CloudFront, generic).
   - Parses the log.
   - Forwards the log entries to Dynatrace using the URL and token from SSM.

5. **Security & Access**:
   - All sensitive resources (S3, KMS, SSM) are permissioned using IAM roles/policies.
   - KMS ensures log data encryption and secure decryption during processing.

6. **Observability**:
   - Lambda writes diagnostic and processing logs to CloudWatch for visibility.

---

Let me know if you need the `.tf` files generated next.
