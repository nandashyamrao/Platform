# 🚀 Platform Engineering Workshop

## 📖 Overview

The lab goal was to **assess impact on system performance and reliability** before rolling out an application to users.  
**Dynatrace** was used for **observability, automated analysis, and decision-making** based on real-time data.  

📄 **Refer to the PDF document** that was provided in the workshop for more details.  

By following a **structured workflow**, we were able to:

✅ **Enable feature flags** to introduce new functionality.  
✅ **Run load tests** to simulate real-world usage.  
✅ **Automate impact assessment** using Dynatrace **workflows** and **Site Reliability Guardian (SRG)**.  
✅ **Use quantitative evidence** to make a **Go/No-Go decision**.  

This approach ensures **safe and reliable feature releases while mitigating risks**.  

---

## 📚 **Workshop Notebook and Query Explanation**  

🔗 [**Link to the DT SRG Query Explanation in the Notebook**]  
🔗 [**Link to the DT Site Care Explanation in the Notebook**]  

---

## 🔍 Key Challenges & Solutions

| **Challenges** | **Solutions** |
|--------------|-------------|
| ❓ **Uncertainty about feature impact** on service behavior | ✅ **Feature flag gradual rollouts** with Dynatrace monitoring ensure controlled experimentation |
| ⚠️ **Risk of degraded performance or failures** after enabling the feature | 🤖 **Automated baselines & error detection** using **Site Reliability Guardian** |
| 🕵️ **Lack of real-time visibility** into changes | 🔎 **Dynatrace event tracking** captures feature flag modifications with metadata (**who, what, when**) |
| 🚀 **Need for automated decision-making** on feature readiness | ⚙️ **Dynatrace workflows trigger SRG**, which evaluates **key performance indicators (KPIs)** |
| 🏗️ **Manual effort in performance validation** | 🤖 **AI-driven auto-adaptive baselines** dynamically learn expected behavior, reducing manual intervention |

---

## 🔧 Key Components Used

### 1️⃣ **Site Reliability Guardian (SRG)**
- 📊 **Tracks golden signals** (Latency, Errors, Traffic)  
- 🎯 **Uses state thresholds** for latency & **auto-adaptive thresholds** for errors/traffic  
- 📉 **Evaluates feature impact before production rollout**  

### 2️⃣ **Dynatrace Workflow Automation**
- 🎯 **Listens for “Load Test Finished” events**  
- 🔄 **Triggers Site Reliability Guardian for impact analysis**  

### 3️⃣ **Observability with OpenTelemetry & Dynatrace**
- 📡 **Collects traces, logs, and metrics** from microservices  
- 🧠 **Provides evidence-based insights** for decision-making  

---

## 🏗️ Step-by-Step Process  

### 1️⃣ **Set Up Site Reliability Guardian (SRG)**
   - 🛠️ **Used a built-in template** to track key **quality indicators (KPIs)**.  
   - 📊 **Ran baseline tests** to train **SRG's adaptive thresholds**.  

### 2️⃣ **Trigger Load Testing**
   - 📡 **Ran a synthetic load test** simulating user traffic.  
   - 🎯 **Ran a completion event** to trigger Dynatrace workflow.  

### 3️⃣ **Analyze Feature Impact**
   - 📊 **Monitored latency, error rates, and traffic patterns**.  
   - ❌ **Found an increase in error rates → Guardian failed the evaluation**.  

### 4️⃣ **Gather Evidence & Decide**
   - 🛠️ **Dynatrace provided traces, logs, and stack traces** pinpointing the issue.  
   - 📉 **Decision: Rollback the feature flag.**  

### 5️⃣ **Rollback & Communicate**
   - 🔴 **Disabled the feature flag**.  
   - 📡 **Sent a rollback event** to Dynatrace for visibility.  
   - 🚀 **Application behavior returned to normal**.  
   - 📊 **Provided evidence (graphs, logs, errors) to stakeholders** for fixing the issue.  

---

## 🎯 Final Takeaways  

✅ **Automated Impact Analysis**  
   - SRG and **workflows eliminate guesswork** in performance validation.  

✅ **Real-time Observability**  
   - Dynatrace **provides deep visibility** into **code behavior** with **traceability to errors**.  

✅ **Data-Driven Decisions**  
   - **Go/No-Go choices** are based on **quantifiable metrics** rather than assumptions.  

✅ **Faster Incident Response**  
   - **Immediate rollback & clear impact analysis** reduce **downtime risks**.  

✅ **Production Readiness Validation**  
   - Ensures that **only fully tested and proven features** reach end users.  

---

## 🚀 Future Enhancements  

🔹 **Automate feature flag progressive rollouts** (canary releases, percentage-based rollouts).  
🔹 **Expand Site Reliability Guardian to include business KPIs** (e.g., conversion rates).  
🔹 **Integrate Dynatrace Davis AI for anomaly detection** during feature rollout.  

---

🚀 **This structured approach enhances reliability, observability, and automated decision-making, ensuring successful feature rollouts!** 🚀  
