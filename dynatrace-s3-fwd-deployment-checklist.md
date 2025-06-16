
# ✅ Dynatrace AWS S3 Log Forwarder – Deployment Checklist

A comprehensive, sequenced checklist for deploying the Dynatrace S3 log forwarder in a secure and modular AWS environment using Terraform/CLI.

---

## 🗂️ Parameters & Values to Prepare

| Parameter | Description |
|----------|-------------|
| `sf-ems-test-dt-s3-fwd-logs` | S3 bucket for CloudTrail, CloudFront, and generic logs |
| `dt_url` | Dynatrace log ingest endpoint (saved in SSM) |
| `dt_token` | Dynatrace API token with `logs.ingest` scope (saved in SSM) |
| `Lambda ECR Image URI` | ECR URI for the Lambda forwarder image |
| `AWS Region` | Region for all resources |
| `KMS Key ARN` | Key used for S3 bucket encryption |
| `AppConfig Configurations` | Includes forwarding and processing rules |

---

## 🔁 Deployment Sequence

### 1. ✅ Store Dynatrace Parameters in SSM
```bash
aws ssm put-parameter --name "/sf-ems-test-dt-s3-fwd/dt_token" --type SecureString --value "<DYNATRACE_TOKEN>" --overwrite
aws ssm put-parameter --name "/sf-ems-test-dt-s3-fwd/dt_url" --type SecureString --value "<DYNATRACE_URL>" --overwrite
```

---

### 2. ✅ Create S3 Bucket
- Name: `sf-ems-test-dt-s3-fwd-logs`
- Enable **KMS encryption**
- Folder layout:
  - `AWSLogs/<account-id>/CloudTrail/`
  - `CloudFront/`
  - `custom-logs/`

---

### 3. ✅ Setup KMS Key
- Create and allow usage by:
  - S3 Bucket
  - Lambda Role
- Attach policy for:
  - `s3:GetObject`
  - `kms:Decrypt`

---

### 4. ✅ Create SQS Queue
```bash
aws sqs create-queue --queue-name sf-ems-test-dt-s3-fwd-queue
```
- Attach SQS policy to allow:
  - `events.amazonaws.com`: `SendMessage`
  - `lambda.amazonaws.com`: `Receive/Delete`

---

### 5. ✅ Setup EventBridge Rule
```bash
aws events put-rule --name sf-ems-test-dt-s3-fwd-eb-rule --event-pattern file://event_pattern.json
aws events put-targets --rule sf-ems-test-dt-s3-fwd-eb-rule --targets "Id"="1","Arn"="<SQS_ARN>"
```

---

### 6. ✅ Create IAM Role and Policies for Lambda
- Allow:
  - `sqs:ReceiveMessage`, `sqs:DeleteMessage`
  - `s3:GetObject`, `kms:Decrypt`
  - `ssm:GetParameter`
  - `logs:*`, `appconfig:GetConfiguration`

---

### 7. ✅ Deploy Lambda
```bash
aws lambda create-function   --function-name sf-ems-test-dt-s3-fwd-lambda   --role <LAMBDA_EXEC_ROLE_ARN>   --package-type Image   --code ImageUri=<ECR_IMAGE_URI>
```

---

### 8. ✅ AppConfig Setup
- Create `log-forwarding-rules.yaml`
- Create `log-processing-rules.yaml`
- Deploy to AppConfig

---

### 9. ✅ Upload Logs for Testing
- Drop sample `.gz` files under each prefix
- Validate logs received in Dynatrace

---

## 📋 Final Validation
- [ ] Confirm CloudTrail logs parsed and sent
- [ ] Confirm CloudFront logs parsed and sent
- [ ] Confirm custom logs processed
- [ ] Check Dynatrace Log viewer

---

> 💬 For help with Terraform equivalents or YAML/JSON rule files, run `terraform plan` with this checklist preconfigured.
