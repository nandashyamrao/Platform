# **Platform Engineering Workshop**

## **Overview**
In the workshop, we simulated a real-world scenario where a **new feature** in a microservice is controlled using a **feature flag**. The goal was to assess its **impact on system performance and reliability** before rolling it out to users. Dynatrace was used for **observability, automated analysis, and decision-making** based on real-time data.

By following a structured workflow, we were able to:
- Enable the **feature flag** to introduce new functionality.
- **Run load tests** to simulate real-world usage.
- Automate **impact assessment** using Dynatrace workflows and **Site Reliability Guardian (SRG)**.
- Use **quantitative evidence** to make a **Go/No-Go** decision.

This approach ensures **safe and reliable** feature releases while mitigating risks.

---

## **Key Challenges & Solutions**

| **Challenges** | **Solutions** |
|--------------|-------------|
| **Uncertainty about feature impact** on service behavior | Feature flag **gradual rollouts** with **Dynatrace monitoring** ensure controlled experimentation |
| **Risk of degraded performance or failures** after enabling the feature | **Automated baselines & error detection** using Site Reliability Guardian |
| **Lack of real-time visibility into changes** | **Dynatrace event tracking** captures feature flag modifications with metadata (who, what, when) |
| **Need for automated decision-making** on feature readiness | Dynatrace **workflows trigger SRG**, which evaluates key performance indicators (KPIs) |
| **Delays in rollback during failures** | **Immediate rollback capability** with Dynatrace informing all stakeholders |
| **Manual effort in performance validation** | **AI-driven auto-adaptive baselines** dynamically learn expected behavior, reducing manual intervention |

---

## **Key Components Used**
### **1. Site Reliability Guardian (SRG)**
- Tracks **golden signals** (Latency, Errors, Traffic)
- Uses **static thresholds** for latency & **auto-adaptive** thresholds for errors/traffic
- Evaluates feature impact **before production rollout**
  
### **2. Dynatrace Workflow Automation**
- Listens for **"Load Test Finished"** events
- Triggers **Site Reliability Guardian** for impact analysis

### **3. Feature Flag Management**
- Allows **runtime behavior change** without redeployments
- Sends **informational events** to Dynatrace for auditability

### **4. Observability with OpenTelemetry & Dynatrace**
- Collects **traces, logs, and metrics** from the microservice
- Provides **evidence-based insights** for decision-making

---

## **Step-by-Step Process**
1. **Set Up Site Reliability Guardian (SRG)**
   - Used a built-in **template** to track key quality indicators (KQIs).
   - Ran **five baseline tests** to train SRG’s adaptive thresholds.

2. **Enable the Feature Flag**
   - Activated the new functionality in the microservice.
   - **Dynatrace recorded the change event** (Who, What, When).

3. **Trigger Load Testing**
   - Ran a synthetic **load test** simulating user traffic.
   - Sent a **completion event** to trigger **Dynatrace workflow**.

4. **Analyze Feature Impact**
   - **SRG evaluated latency, error rates, and traffic patterns**.
   - Found an increase in **error rates** → **Guardian failed the evaluation**.

5. **Gather Evidence & Decide**
   - Dynatrace provided **traces, logs, and stack traces** pinpointing the issue.
   - Decision: **Rollback the feature (No-Go)**.

6. **Rollback & Communicate**
   - Disabled the feature flag.
   - Sent a **rollback event** to Dynatrace for visibility.
   - Application behavior **returned to normal**.
   - **Provided evidence** (graphs, logs, errors) to stakeholders for fixing the issue.

---

## **Final Takeaways**
✅ **Safe Feature Releases**  
   → Feature flags + Dynatrace ensure **controlled rollouts** without breaking production.

✅ **Automated Impact Analysis**  
   → Site Reliability Guardian and **workflows eliminate guesswork** in performance validation.

✅ **Real-time Observability**  
   → Dynatrace provides **deep visibility into code behavior** with **traceability to errors**.

✅ **Data-Driven Decisions**  
   → Go/No-Go choices are based on **quantifiable metrics** rather than assumptions.

✅ **Faster Incident Response**  
   → Immediate rollback & clear impact analysis **reduce downtime risks**.

✅ **Production Readiness Validation**  
   → Ensures that only **fully tested and proven features** reach end users.

---

## **Future Enhancements**
- Automate feature flag **progressive rollouts** (canary releases, % based rollouts).
- Expand Site Reliability Guardian to include **business KPIs** (e.g., conversion rates).
- Integrate **Dynatrace Davis AI** for anomaly detection during feature rollout.

By leveraging **Dynatrace's observability and automation**, we enable **faster, safer, and more reliable feature deployments** with minimal risk to users.
