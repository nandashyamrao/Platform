# 🚀 Service Performance DQL Query Explanation

> **Understand how this Dynatrace Query Language (DQL) query calculates service performance and why it matters!**  

---

## 📌 **What Does This Query Do?**
This **Dynatrace Query Language (DQL)** query calculates **Service Performance**, measuring the ratio of service requests that complete **faster than 500ms**.

📌 **Goal**: Ensure that **most service requests respond within an acceptable time threshold**.  
- ✅ **100% means all requests completed in under 500ms.**  
- ❌ **Less than 100% indicates slow-performing requests.**  
- ⚙️ **The threshold (500ms) can be adjusted in the query.**  

---

## **1️⃣ Breakdown of the Query**
```dql
timeseries total=avg(dt.service.request.response_time, default: 0), by: { dt.entity.service }, filter: { k8s.namespace.name == "$proj_name-$owner-$stage" }
```
📌 **What This Does:**
- **`dt.service.request.response_time`** → Tracks response times for all service requests.
- **`avg(dt.service.request.response_time, default: 0)`** → Calculates the **average response time**.
- **`by: { dt.entity.service }`** → Groups response times by each **service**.
- **`filter: { k8s.namespace.name == "$proj_name-$owner-$stage" }`** → Filters **only relevant services**.

✅ **Example Service Performance Data:**
| **Service** | **Avg Response Time (ms)** |
|------------|-------------------------|
| `payment-service` | 450 ✅ |
| `cart-service` | 520 ❌ |

---

### **2️⃣ Categorizing Response Times**
```dql
fieldsAdd high=collectArray(if(total> (1000 * 500), total,[]))
fieldsAdd low=collectArray(if(total<= (1000 * 500), total,[]))
```
📌 **What This Does:**
- **Categorizes service requests into "High" and "Low" response time buckets**:
  - **`high`** → Requests that took **longer than 500ms**.
  - **`low`** → Requests that completed **within 500ms**.

✅ **Example Categorization:**
| **Service** | **Total Requests** | **Slow Requests (>500ms)** | **Fast Requests (≤500ms)** |
|------------|----------------|----------------------|----------------------|
| `payment-service` | 100 | 10 ❌ | 90 ✅ |
| `cart-service` | 200 | 40 ❌ | 160 ✅ |

---

### **3️⃣ Identifying Response Time Distributions**
```dql
fieldsAdd highRespTimes=collectArray(if(isNull(high),[],else:1))
fieldsAdd lowRespTimes=collectArray(if(isNull(low),[],else:1))
```
📌 **What This Does:**
- **Extracts the actual response times for both slow and fast requests**.
- **Handles null values** to prevent errors in calculations.

---

### **4️⃣ Compute the Service Level Indicator (SLI)**
```dql
fieldsAdd sli=100*(lowRespTimes[]/(lowRespTimes[]+highRespTimes[]))
```
📌 **Formula Explanation:**
```
SLI = (Fast Requests / Total Requests) * 100
```
✅ **Example Calculation:**
| **Service** | **Total Requests** | **Fast Requests (≤500ms)** | **SLI (%)** |
|------------|----------------|----------------------|---------|
| payment-service | 100 | 90 | (90/100) * 100 = **90%** |
| cart-service | 200 | 160 | (160/200) * 100 = **80%** |

---

### **5️⃣ Final Aggregation**
```dql
summarize sli = avg(arrayAvg(sli))
```
📌 **What This Does:**
- **Averages the Service Level Indicator (SLI) over time** to track long-term performance trends.

✅ **Example SLI Over Time:**
| **Time** | **SLI (%)** |
|---------|----------|
| 10:00 AM | 95% ✅ |
| 10:10 AM | 98% ✅ |
| 10:20 AM | 85% ⚠️ |
| 10:30 AM | 70% ❌ |

---

## **📌 Example of Final Output in Dynatrace**
| Service | Total Requests | Fast Requests (≤500ms) | SLI (%) | Status |
|---------|--------------|------------------|---------|--------|
| `payment-service` | 100 | 90 | **90%** ✅ | Healthy |
| `cart-service` | 200 | 160 | **80%** ⚠️ | Needs Attention |

✅ **High performance (>95%)** = Service is fast and efficient.  
⚠️ **Moderate performance (85-95%)** = Some requests are slow.  
❌ **Low performance (<85%)** = Performance issues; alerts may trigger.  

---

## **2️⃣ Why Is This Important?**
✅ **Detects Performance Bottlenecks** – Helps identify slow services.  
✅ **Improves User Experience** – Ensures services respond quickly.  
✅ **Tracks Deployment Performance** – Compares service speed before/after a release.  
✅ **Triggers Alerts in Dynatrace** – If response times increase beyond acceptable thresholds.  

---

## **🎯 Summary**
| **Step** | **What It Does** |
|---------|----------------|
| 1️⃣ Calculate total request response times | Tracks overall service performance |
| 2️⃣ Categorize requests into **fast** and **slow** | Helps identify slow-performing requests |
| 3️⃣ Collect response time distributions | Extracts actual values for trend analysis |
| 4️⃣ Compute SLI (%) | Performance = (Fast Requests / Total Requests) * 100 |
| 5️⃣ Summarize over time | Monitors service trends over time |

🚀 **This query helps ensure services are responding quickly and optimally!** 🔥

---

## ✅ **Next Steps**
1️⃣ **Fine-tune DQL queries for different response time thresholds (e.g., 300ms, 1000ms).**  
2️⃣ **Enable Dynatrace alerts if performance drops below a set threshold.**  
3️⃣ **Analyze performance trends over weeks/months for deeper insights.**  

📚 **Resources**:  
- [Dynatrace Query Language (DQL) Docs](https://developer.dynatrace.com/)  
