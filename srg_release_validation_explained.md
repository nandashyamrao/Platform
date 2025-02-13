# 🚀 Dynatrace Query Language (DQL) Queries for SRG Release Validation

> **This document explains the DQL queries used for release validation in the Site Reliability Guardian (SRG). Each query ensures observability, performance, and service health across deployments.**  

---

## 📌 **1. Pod Availability**  
**Measures the ratio between desired and active pods in Kubernetes.**  
- ✅ **100% means all requested pods are running.**  
- ❌ **Lower values indicate that Kubernetes cannot deploy all requested pods.**  

### **🔍 Query Breakdown**
```dql
timeseries {desired = avg(dt.kubernetes.workload.pods.desired), active = avg(dt.kubernetes.pods)}, by: {dt.entity.cloud_application}
fieldsAdd labels = entityAttr(dt.entity.cloud_application,'cloudApplicationLabels')
fieldsAdd component = labels['backstage.io/component']
filter component == "default.$proj_name-$owner-$stage"
fieldsAdd sli = (active||desired) * 100
summarize sli = avg(arrayAvg(sli))
```
- **Line 1:** Computes the **average number of desired** and **active pods**.  
- **Line 2-3:** Adds metadata labels from **Backstage** to associate pod data with a service.  
- **Line 4:** Filters data to include **only the relevant service** based on `$proj_name`, `$owner`, and `$stage`.  
- **Line 5:** Calculates **Service Level Indicator (SLI)**:  
  ```math
  SLI = (Active Pods / Desired Pods) * 100
  ```
- **Line 6:** Averages **SLI** over time to ensure accurate monitoring.  

✅ **Ensures Kubernetes deploys all requested pods.**  

---

## 📌 **2. Synthetic Availability**  
**Measures the success rate of synthetic tests.**  
- ✅ **100% means all synthetic checks passed.**  
- ❌ **Lower values indicate availability issues.**  

### **🔍 Query Breakdown**
```dql
timeseries {
    total = sum(dt.synthetic.http.executions, default: 0), 
    pass = sum(dt.synthetic.http.executions, default: 0, filter: { matchesValue(http_monitor.result.status, "HEALTHY") })
}, by: { dt.entity.http_check }
fieldsAdd name = entityName(dt.entity.http_check)
filter name == "Healthcheck $proj_name-$owner-$stage"
fieldsAdd sli=(((pass||1)/total)*(100))
summarize sli = avg(arrayAvg(sli))
```
- **Line 1-2:** Computes **total synthetic checks** and **successful checks** (`"HEALTHY"` status).  
- **Line 3:** Groups results **by synthetic test name**.  
- **Line 4:** Filters **only relevant tests** for the service.  
- **Line 5:** Calculates **SLI**:  
  ```math
  SLI = (Successful Executions / Total Executions) * 100
  ```
- **Line 6:** Averages **SLI** over time.  

✅ **Validates that deployed services remain available.**  

---

## 📌 **3. Service Performance**  
**Measures the percentage of service requests completed in under 500ms.**  
- ✅ **100% means all requests are fast.**  
- ❌ **Lower values indicate performance issues.**  

### **🔍 Query Breakdown**
```dql
timeseries total=avg(dt.service.request.response_time, default: 0), by: { dt.entity.service }, filter: { k8s.namespace.name == "$proj_name-$owner-$stage" }
fieldsAdd high=collectArray(if(total> (1000 * 500), total,[]))
fieldsAdd low=collectArray(if(total<= (1000 * 500), total,[]))
fieldsAdd highRespTimes=collectArray(if(isNull(high),[],else:1))
fieldsAdd lowRespTimes=collectArray(if(isNull(low),[],else:1))
fieldsAdd sli=100*(lowRespTimes[]/(lowRespTimes[]+highRespTimes[]))
summarize sli = avg(arrayAvg(sli))
```
- **Line 1:** Computes the **average response time** per service.  
- **Line 2-3:** Categorizes requests into **"Fast" (≤500ms)** and **"Slow" (>500ms)**.  
- **Line 4-5:** Counts requests in each category.  
- **Line 6:** Calculates **SLI**:  
  ```math
  SLI = (Fast Requests / Total Requests) * 100
  ```
- **Line 7:** Averages **SLI** over time.  

✅ **Ensures the service maintains a fast response time.**  

---

## 📌 **4. Service Availability**  
**Tracks the ratio of successful service requests (excluding HTTP 5xx errors).**  
- ✅ **100% means no failures.**  
- ❌ **Lower values indicate failures.**  

### **🔍 Query Breakdown**
```dql
timeseries { total=sum(dt.service.request.count, default: 0), failures=sum(dt.service.request.failure.count, default: 0) }, by: { dt.entity.service }
filter: { k8s.namespace.name == "$proj_name-$owner-$stage" }
fieldsAdd sli=(((total-failures)/total)*(100))
summarize sli = avg(arrayAvg(sli))
```
- **Line 1:** Computes **total requests** and **failed requests**.  
- **Line 2:** Filters **only relevant services**.  
- **Line 3:** Calculates **SLI**:  
  ```math
  SLI = ((Total Requests - Failed Requests) / Total Requests) * 100
  ```
- **Line 4:** Averages **SLI** over time.  

✅ **Ensures no critical service failures.**  

---

## 📌 **5. Container Logs**  
**Tracks the ratio of logs containing WARN/ERROR messages.**  
- ✅ **100% means no errors.**  
- ❌ **Lower values indicate potential issues.**  

### **🔍 Query Breakdown**
```dql
fetch logs
filter k8s.namespace.name == "$proj_name-$owner-$stage" and k8s.container.name == "rollouts-demo"
fields total = count()
fieldsAdd info=total - count(filter(status, ("ERROR", "WARN"), default:0))
fieldsAdd sli = ((info/total) * 100)
summarize sli = avg(arrayAvg(sli))
```
- **Line 1-2:** Fetches logs **only from the relevant namespace/container**.  
- **Line 3:** Counts **total logs**.  
- **Line 4:** Counts **logs without WARN/ERROR messages**.  
- **Line 5:** Calculates **SLI**:  
  ```math
  SLI = (Non-Error Logs / Total Logs) * 100
  ```
- **Line 6:** Averages **SLI** over time.  

✅ **Detects application errors after deployment.**  

---

## 📌 **6. Service Throughput**  
**Ensures the service is consistently handling active requests.**  
- ✅ **100% means constant traffic.**  
- ❌ **Lower values indicate a drop in traffic.**  

### **🔍 Query Breakdown**
```dql
timeseries { count = sum(dt.service.request.count, default: 0) }, by: { dt.entity.service }
filter: { k8s.namespace.name == "$proj_name-$owner-$stage" }
fieldsAdd traffic = if(count[] > 0, 1, else: 1)
fieldsAdd sli = (traffic[] * 100)
summarize sli = avg(arrayAvg(sli))
```
- **Line 1:** Counts total requests per service.  
- **Line 2:** Filters **only relevant services**.  
- **Line 3:** Sets `traffic = 1` if there are active requests.  
- **Line 4:** Converts `traffic` into an **SLI (100% = constant traffic)**.  
- **Line 5:** Averages **SLI** over time.  

✅ **Ensures traffic flow remains constant.**  

---

🚀 **With these queries, SRG ensures service reliability, availability, and performance during deployments!** 🔥  

