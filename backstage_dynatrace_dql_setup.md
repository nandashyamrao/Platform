# 🚀 Backstage + Dynatrace Query Language (DQL) Integration Guide

> **Learn how Backstage is set up, how it connects to Dynatrace Query Language (DQL), and how the results are displayed!**  

---

## 📌 **What is Backstage?**
[Backstage](https://backstage.io/) is an **open-source developer portal** built by Spotify to help teams **organize, manage, and track microservices, Kubernetes workloads, and cloud infrastructure**.

🔹 It provides a **single pane of glass** where developers can see:  
- **What services exist** and who owns them.  
- **Where services run (Kubernetes, AWS, etc.).**  
- **Monitoring data (logs, metrics, events, alerts) from Dynatrace.**  

---

## 🏗 **How Backstage is Set Up in Kubernetes?**
Backstage integrates with Kubernetes by adding **labels** to workloads:

Example **Kubernetes Deployment YAML with Backstage Labels:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-service
  namespace: production
  labels:
    backstage.io/component: "default.payment-service-team01-prod"
spec:
  replicas: 10  # Desired Pods
  selector:
    matchLabels:
      app: payment-service
  template:
    metadata:
      labels:
        app: payment-service
        backstage.io/component: "default.payment-service-team01-prod"
    spec:
      containers:
      - name: payment-container
        image: myregistry.com/payment-service:v1.0
```

📌 **This label (`backstage.io/component`) allows Backstage to recognize and catalog the service.**  

---

## 🔌 **How Backstage Connects to Dynatrace & DQL**
Once **Backstage is set up**, it connects to **Dynatrace API** to fetch **metrics, logs, and monitoring data** using **Dynatrace Query Language (DQL)**.

### **📌 Step 1: Add Dynatrace API Credentials to Backstage**
Modify **Backstage’s `app-config.yaml`**:
```yaml
integrations:
  dynatrace:
    - name: "dynatrace"
      apiToken: "${DYNATRACE_API_TOKEN}"
      baseUrl: "https://YOUR_DYNATRACE_INSTANCE.live.dynatrace.com"
```

---

## 📡 **How Dynatrace Fetches Data Using DQL**
Dynatrace uses **DQL (Dynatrace Query Language)** to extract monitoring data.  

**Example DQL Query for Pod Availability in Kubernetes:**
```dql
timeseries {desired = avg(dt.kubernetes.workload.pods.desired), active = avg(dt.kubernetes.pods)}, by: {dt.entity.cloud_application}
fieldsAdd component = labels['backstage.io/component']
filter component == "default.$proj_name-$owner-$stage"
fieldsAdd sli = (active||desired) * 100
summarize sli = avg(arrayAvg(sli))
```
✅ **This query calculates pod availability**:
```
sli = (active pods / desired pods) * 100
```

📌 **This is sent to Dynatrace API, and the result is displayed in Backstage UI.**

---

## 📊 **Displaying Dynatrace Metrics in Backstage UI**
Modify **Backstage frontend component (`DynatraceScorecard.tsx`)**:
```tsx
import React from 'react';
import { useEntity } from '@backstage/plugin-catalog-react';

export const DynatraceScorecard = () => {
  const { entity } = useEntity();
  const scorecardUrl = entity.metadata.annotations?.['dynatrace.com/scorecard'];

  if (!scorecardUrl) {
    return <div>No Dynatrace Scorecard linked.</div>;
  }

  return (
    <iframe
      src={scorecardUrl}
      width="100%"
      height="600px"
      style={{ border: 'none' }}
      title="Dynatrace Scorecard"
    />
  );
};
```
✅ **Now, Backstage can display Dynatrace logs, metrics, and service health!**  

---

## 🔄 **What Happens in Backstage After Integration?**
1️⃣ **Backstage pulls Kubernetes workloads & metadata (`backstage.io/component`).**  
2️⃣ **Dynatrace API fetches monitoring data using DQL.**  
3️⃣ **Backstage UI displays Dynatrace logs, metrics, and pod availability.**  
4️⃣ **If pod availability drops below 90%, alerts are triggered inside Backstage.**  

---

## 📌 **Backstage UI – What Users See?**
| Service | Availability (%) | CPU Usage | Logs | Metrics |
|---------|-----------------|-----------|------|---------|
| Payment API | **99.8%** ✅ | **45%** 🟢 | 🔍 [View Logs](https://YOUR_DYNATRACE_INSTANCE) | 📊 [View Metrics](https://YOUR_DYNATRACE_INSTANCE) |
| Order Service | **97.5%** ⚠️ | **85%** 🔴 | 🔍 [View Logs](https://YOUR_DYNATRACE_INSTANCE) | 📊 [View Metrics](https://YOUR_DYNATRACE_INSTANCE) |

✅ **Developers can now see all service health data in one place!** 🚀  

---

## 🎯 **Final Summary – Why This Integration Matters**
| Feature | Backstage | Dynatrace | **Why It’s Powerful?** |
|---------|-----------|-----------|------------------------|
| **Service Discovery** | ✅ Yes | ❌ No | **Backstage organizes services, Dynatrace monitors them** |
| **Real-Time Monitoring** | ❌ No | ✅ Yes | **Dynatrace tracks pod availability & performance** |
| **SLI/SLO Tracking** | ❌ No | ✅ Yes | **Teams can measure service reliability** |
| **Logs & Alerts** | ✅ Yes | ✅ Yes | **Backstage UI shows Dynatrace alerts & logs** |
| **Self-Service Monitoring** | ✅ Yes | ✅ Yes | **Developers can see service health without logging into Dynatrace** |

🚀 **With this setup, Backstage becomes a full observability platform powered by Dynatrace DQL!**  

---

## ✅ **Next Steps**
1️⃣ **Deploy Backstage + Dynatrace in a test environment**.  
2️⃣ **Fine-tune DQL queries to extract useful service metrics**.  
3️⃣ **Enable alerts & auto-remediation for failing services**.  

📚 **Resources**:  
- [Backstage Official Docs](https://backstage.io/docs)  
- [Dynatrace API Docs](https://developer.dynatrace.com/)  

