# 🚀 Observability Score Validation in SRG  

> **Ensuring all deployments are observable and meet security and monitoring requirements.**  

---

## 📌 **1. What is Observability Score Validation?**  
Observability Score Validation ensures that **Dynatrace correctly ingests logs, metrics, traces, and events** after every deployment.  

🔹 **Why is this important?**  
✔️ Ensures logs and telemetry data are being captured.  
✔️ Prevents security vulnerabilities by validating expected monitoring data.  
✔️ Confirms app accessibility post-deployment.  

🔹 **Who uses it?**  
✔️ **SREs and Platform Teams** – Ensure deployments meet monitoring standards.  
✔️ **Security Teams** – Ensure no missing logs or anomalies.  
✔️ **Central Observability Teams** – Validate system-wide monitoring completeness.  

---

## 📌 **2. Key Observability Validation Queries**  

### **✅ Validate Capturing Logs**
This query ensures **logs are being ingested for a deployed application.**  

```dql
fetch logs
filter k8s.namespace.name == "$proj_name-$owner-$stage" and k8s.container.name == "rollouts-demo"
summarize count()
```
- **`fetch logs`** → Retrieves logs from the Dynatrace log store.  
- **`filter k8s.namespace.name == "$proj_name-$owner-$stage"`** → Ensures logs are only from the **correct deployment namespace**.  
- **`filter k8s.container.name == "rollouts-demo"`** → Restricts logs to the **specific rollout container**.  
- **`summarize count()`** → Counts the number of logs ingested.  

✅ **If logs are missing, an alert can be triggered.**  

---

### **✅ Validate Capturing Requests**  
This query validates that **Dynatrace successfully captures service requests** after a deployment.  

```dql
timeseries {
    requestCount=sum(dt.service.request.count)
}, by: {dt.entity.service}, filter: {k8s.namespace.name == "$proj_name-$owner-$stage", nonempty: true}
fields maxCount = arrayMax(requestCount)
```
- **`dt.service.request.count`** → Counts the number of service requests.  
- **`by: {dt.entity.service}`** → Groups requests by **service name**.  
- **`filter: { k8s.namespace.name == "$proj_name-$owner-$stage", nonempty: true }`** → Ensures only valid namespaces are included.  
- **`fields maxCount = arrayMax(requestCount)`** → Retrieves the **maximum number of requests** to ensure traffic is being captured.  

✅ **If request counts drop to 0, this could indicate service failure or misconfigured monitoring.**  

---

### **✅ Validate Synthetic Test Execution**  
This query ensures that **synthetic tests executed successfully** for a deployed service.  

```dql
fetch dt.synthetic.events
filter dt.synthetic.batch.status == "Success"
filter event.id == batchId
summarize count()
```
- **`fetch dt.synthetic.events`** → Retrieves synthetic test execution events.  
- **`filter dt.synthetic.batch.status == "Success"`** → Ensures that **only successful synthetic tests** are counted.  
- **`filter event.id == batchId`** → Filters the results to match a **specific synthetic batch execution ID**.  
- **`summarize count()`** → Counts the number of successful synthetic test executions.  

✅ **If no synthetic test executions are found, an alert is raised.**  

---

## 📌 **3. Workflow to Trigger Synthetics and SRG Validation**  

### **Triggering Observability Checks After a Deployment**
A workflow can automatically **trigger observability validation** after a deployment completes.  

```yaml
matchesValue(event.kind,"SDLC_EVENT") and
matchesValue(event.type,"app-deployed.validated") and
isNotNull(owner) and
isNotNull(proj_name) and
isNotNull(stage)
```
- **`event.kind == "SDLC_EVENT"`** → Ensures this is a **Software Development Lifecycle (SDLC) event**.  
- **`event.type == "app-deployed.validated"`** → Ensures the validation happens **after a deployment is completed**.  
- **`isNotNull(owner), isNotNull(proj_name), isNotNull(stage)`** → Ensures all **deployment metadata exists**.  

✅ **Ensures that observability validation is only triggered after successful deployments.**  

---

### **Execute Synthetic Tests for Validation**  
After a deployment, synthetic tests are executed to validate application functionality.  

```yaml
owner: {{event().owner}}
stage: {{event().stage}}
proj_name: {{event().proj_name}}
```
- **Passes deployment metadata (Owner, Stage, Project Name) to the synthetic test execution.**  

✅ **Ensures synthetic tests match the deployed application.**  

---

### **Passing Synthetic Batch ID to SRG**  
To validate synthetic executions, we pass the **batch ID** from the synthetic test results.  

```yaml
batchId: {{ result("execute_synthetic_checks")["event.id"] }}
```
- Retrieves the **batch execution ID** from the synthetic check results.  
- **Ensures SRG validation only happens after successful synthetic execution.**  

✅ **Automates validation for synthetic checks.**  

---

## 📌 **4. Summary – Why Observability Score Validation Matters?**  

| **Validation** | **What It Ensures** | **Why It's Important?** |
|---------------|--------------------|----------------------|
| **Log Validation** | Logs are ingested into Dynatrace | Prevents missing logs for troubleshooting |
| **Service Requests Validation** | Requests are successfully captured | Ensures services are receiving traffic |
| **Synthetic Test Execution** | Services pass synthetic health checks | Confirms application functionality |
| **Automated Workflow** | Observability checks run after deployments | No manual validation needed |
| **SRG Integration** | Automates pass/fail decisions | Blocks faulty deployments from production |

🚀 **This setup ensures deployments are fully observable and meet security, reliability, and monitoring standards!** 🔥  

---

## ✅ **Next Steps**  
1️⃣ **Implement Observability Score Validation in your SRG workflows.**  
2️⃣ **Set up alerts if logs, service requests, or synthetic tests fail.**  
3️⃣ **Use automation to trigger validation only after successful deployments.**  

📚 **Resources**:  
- [Dynatrace Query Language (DQL) Docs](https://developer.dynatrace.com/)  
- [Backstage Observability Plugin](https://backstage.io/)  

