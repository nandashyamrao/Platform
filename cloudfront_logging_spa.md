# CloudFront Logging with a Single Page Application (SPA)

## **1️⃣ Overview**
This project sets up a **Single Page Application (SPA)** served via **Amazon CloudFront**, with logging enabled to **Amazon S3** and processed via **AWS SNS, SQS, and Dynatrace AWS S3 Log Forwarder**.

### **📌 Features**
- **CloudFront distribution** for global content delivery.
- **Static hosting** via **Amazon S3**.
- **Standard logging** stored in **Amazon S3**.
- **Real-time JavaScript logging** of client details.
- **AWS SNS & SQS integration** for log forwarding.
- **Dynatrace ingestion** for log analysis.

---

## **2️⃣ Single Page Web Application (SPA) Code**

### **🔹 `index.html`**
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CloudFront Logging Demo</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <h1>Welcome to CloudFront Logging Demo</h1>
    <p>Your request details are logged.</p>
    <pre id="log-output"></pre>
    
    <script src="app.js"></script>
</body>
</html>
```

### **🔹 `styles.css`**
```css
body {
    font-family: Arial, sans-serif;
    text-align: center;
    padding: 20px;
}
h1 {
    color: #0077cc;
}
pre {
    background-color: #f4f4f4;
    padding: 10px;
    border-radius: 5px;
    overflow-x: auto;
}
```

### **🔹 `app.js`**
```js
document.addEventListener("DOMContentLoaded", async function() {
    let logOutput = document.getElementById("log-output");

    function logMessage(message) {
        console.log(message);
        logOutput.textContent += message + "\n";
    }

    logMessage("Browser Info: " + navigator.userAgent);

    try {
        let response = await fetch("https://api64.ipify.org?format=json");
        let data = await response.json();
        logMessage("Client IP: " + data.ip);

        let geoResponse = await fetch(`https://ipapi.co/${data.ip}/json/`);
        let geoData = await geoResponse.json();
        logMessage(`Location: ${geoData.city}, ${geoData.region}, ${geoData.country_name}`);
    } catch (error) {
        logMessage("Failed to fetch IP or location: " + error.message);
    }

    window.onerror = function(message, source, lineno, colno, error) {
        logMessage(`Error: ${message} at ${source}:${lineno}:${colno}`);
    };
});
```

---

## **3️⃣ Enable CloudFront Logging to S3**

1. Go to **AWS CloudFront Console** → Select your **distribution**.
2. Under **Settings**, enable **Logging**.
3. Choose an **S3 bucket** (e.g., `my-cloudfront-logs`).

Logs are stored in **S3** under:
```
s3://my-cloudfront-logs/AWSLogs/ACCOUNT_ID/CloudFront/
```

Each log entry includes:
```
timestamp  client_ip  method  uri  status_code  user_agent  country  bytes_sent
```

Example:
```
2025-02-24T23:59:59Z  192.168.1.10  GET  /index.html  200  "Mozilla/5.0"  US  3421
```

---

## **4️⃣ SNS & SQS for CloudFront Logs**

### **🔹 Step 1: Create SNS & SQS**
```sh
aws sns create-topic --name CloudFrontLogsSNS
aws sqs create-queue --queue-name CloudFrontLogsSQS
```

### **🔹 Step 2: Subscribe SQS to SNS**
```sh
aws sns subscribe --topic-arn arn:aws:sns:REGION:ACCOUNT_ID:CloudFrontLogsSNS --protocol sqs --notification-endpoint arn:aws:sqs:REGION:ACCOUNT_ID:CloudFrontLogsSQS
```

### **🔹 Step 3: Configure S3 to send logs to SNS**
- Go to **S3 Console** → `my-cloudfront-logs` → **Event Notifications**.
- Set **Event Type**: `PUT` (Object Created).
- Choose **SNS Destination**: `CloudFrontLogsSNS`.

---

## **5️⃣ Deploy Dynatrace AWS S3 Log Forwarder**

### **🔹 Clone and Deploy**
```sh
git clone https://github.com/dynatrace-oss/dynatrace-aws-s3-log-forwarder.git
cd dynatrace-aws-s3-log-forwarder
sam build && sam deploy
```

### **🔹 Modify `template.yaml` for SQS Integration**
```yaml
  Environment:
    Variables:
      SQS_QUEUE_URL: "https://sqs.REGION.amazonaws.com/ACCOUNT_ID/CloudFrontLogsSQS"
      DYNATRACE_LOG_INGEST_URL: "https://your-dynatrace-environment/api/v2/logs/ingest"
      DYNATRACE_API_KEY: "YOUR_API_KEY"
```

### **🔹 Deploy Updated Configuration**
```sh
sam build && sam deploy
```

---

## **6️⃣ Verify Logs in Dynatrace**
1. Open **Dynatrace Console**.
2. Go to **Logs** → Filter by `log.source.aws.s3.bucket.name = "my-cloudfront-logs"`.
3. View **CloudFront logs with client details**.

---

## **7️⃣ Summary**
✅ **Single Page App (SPA) with CloudFront**  
✅ **CloudFront logs stored in S3**  
✅ **SNS & SQS forwarding logs to Dynatrace**  
✅ **Real-time JavaScript logging for additional insights**  

This setup ensures **full observability** of CloudFront logs with **Dynatrace** and **AWS logging services**! 🚀  
