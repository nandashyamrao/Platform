# 🚀 Synthetic Availability DQL Query Explanation

> **Understand how this Dynatrace Query Language (DQL) query calculates synthetic availability and why it matters!**  

---

## 📌 **What Does This Query Do?**
This **Dynatrace Query Language (DQL)** query calculates **Synthetic Availability** by determining the ratio of **successful synthetic checks** to **total synthetic executions**. 

📌 **Goal**: To ensure that the service remains accessible and stable by checking if synthetic tests **pass at 100%**.  
- ✅ **100% availability** means all synthetic tests were successful.  
- ❌ **<100% availability** indicates service issues or intermittent failures.  

---

## **1️⃣ Breakdown of the Query**
```dql
timeseries {
    total = sum(dt.synthetic.http.executions, default: 0), 
    pass = sum(dt.synthetic.http.executions, default: 0, filter: { matchesValue(http_monitor.result.status, "HEALTHY") })
}, by: { dt.entity.http_check }
```
📌 **What This Does:**
- `dt.synthetic.http.executions` → Counts **total synthetic executions**.
- `filter: { matchesValue(http_monitor.result.status, "HEALTHY") }` → Filters out **only successful executions**.
- Groups results **by synthetic HTTP check** (`dt.entity.http_check`).

✅ **Real-world Example:**
| **Synthetic Check** | **Total Runs** | **Successful Runs** |
|--------------------|--------------|-------------------|
| `Healthcheck-payment-service-prod` | 100 | 98 |
| `Healthcheck-cart-service-prod` | 50 | 50 |

---

### **2️⃣ Add Metadata for Better Filtering**
```dql
fieldsAdd name = entityName(dt.entity.http_check)
```
- Extracts **the name of the synthetic HTTP check** for readability.
- Example: `Healthcheck-payment-service-prod`

---

### **3️⃣ Apply Filtering Based on Service Naming Convention**
```dql
filter name == "Healthcheck $proj_name-$owner-$stage"
```
- Ensures the query **only tracks the relevant synthetic test**.
- **Real-world Example:**
  ```
  filter name == "Healthcheck payment-service-team01-prod"
  ```

---

### **4️⃣ Compute the Service Level Indicator (SLI)**
```dql
fieldsAdd sli=(((pass||1)/total)*(100))
```
📌 **Formula Explanation:**
```
SLI = (Successful Executions / Total Executions) * 100
```
✅ **Example Calculation:**
| **Service** | **Total Executions** | **Successful Executions** | **SLI (%)** |
|------------|----------------|-------------------|---------|
| payment-service | 100 | 98 | (98/100) * 100 = **98%** |
| cart-service | 50 | 50 | (50/50) * 100 = **100%** |

---

### **5️⃣ Final Aggregation**
```dql
summarize sli = avg(arrayAvg(sli))
```
- Averages the **SLI** over time to **smooth fluctuations** in availability.

---

## **📌 Example of Final Output in Dynatrace**
| Synthetic Check | Total Executions | Successful Executions | Availability (%) |
|----------------|----------------|-------------------|---------------|
| `Healthcheck-payment-service-prod` | 100 | 98 | **98%** ✅ |
| `Healthcheck-cart-service-prod` | 50 | 50 | **100%** ✅ |

✅ **High availability (>99%)** = Healthy service.  
❌ **Low availability (<99%)** = Potential service issues, triggering alerts.  

---

## **2️⃣ Why Is This Important?**
✅ **Detects Service Downtime** – Ensures that synthetic tests are passing consistently.  
✅ **Tracks Deployment Stability** – Checks if a new release causes intermittent failures.  
✅ **Provides SLO Compliance** – Ensures services meet reliability objectives.  
✅ **Triggers Alerts in Dynatrace** – If availability drops below **99%**, teams can be notified.  

---

## **🎯 Summary**
| **Step** | **What It Does** |
|---------|----------------|
| 1️⃣ Calculate total synthetic executions | Tracks all tests executed |
| 2️⃣ Count only successful executions | Filters out failed tests |
| 3️⃣ Extract synthetic test name | Improves readability |
| 4️⃣ Filter relevant services | Ensures the correct test is analyzed |
| 5️⃣ Compute SLI (%) | Availability = (Success/Total) * 100 |
| 6️⃣ Summarize over time | Averages availability for trend analysis |

🚀 **This query provides an automated way to track synthetic availability and detect issues before customers are impacted!** 🔥

---

## ✅ **Next Steps**
1️⃣ **Fine-tune DQL queries to extract useful service metrics**.  
2️⃣ **Enable alerts & auto-remediation for failing services**.  
3️⃣ **Monitor synthetic test trends over time** for deeper insights.  

📚 **Resources**:  
- [Dynatrace Query Language (DQL) Docs](https://developer.dynatrace.com/)  
