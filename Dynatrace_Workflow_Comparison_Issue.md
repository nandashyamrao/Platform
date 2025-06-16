
# 📝 Issue: Evaluation of Dynatrace Workflow Types for Alerting

## 📌 Summary
We are reviewing Dynatrace’s **workflow options** to improve the reliability and accuracy of alerts — especially for situations where we want to **wait and verify** an issue (e.g., high CPU) before sending emails or opening ServiceNow incidents.

---

## 📚 Background
Dynatrace supports two main types of workflows for automation:

- ✅ **Simple Workflow** – Easy to use, free to run, but limited.
- ⚠️ **Standard Workflow** – Flexible and powerful, but incurs cost per execution.

The goal is to use the **best option** for balancing alert quality, cost, and maintainability.

---

## 🔍 Use Case
> _“Only alert me if CPU usage stays high for 15 minutes — don’t notify for short spikes.”_

This is **not possible** with Simple Workflows. We need to use **Standard Workflows with conditional logic** to achieve it.

---

## 🔄 Comparison of Options

| Behavior / Feature                       | 🔹 Simple Workflow       | ⚠️ Standard Workflow (No Logic) | ✅ Standard Workflow (With Delay + Re-check) |
|------------------------------------------|--------------------------|----------------------------------|----------------------------------------------|
| **When it triggers**                     | Immediately              | Immediately                      | Waits, then checks again                      |
| **Can wait & re-check issue?**           | ❌ No                    | ❌ Waits but doesn’t re-check    | ✅ Yes, with a query step                     |
| **False alert prevention**               | ❌ No                    | ❌ Limited                       | ✅ Strong (alerts only if still an issue)     |
| **Can send to ServiceNow + Email**       | ❌ Only one              | ✅ Yes                           | ✅ Yes                                        |
| **Cost to run**                          | Free                     | Charged per run                  | Charged (but can be scoped to reduce cost)   |
| **Best for...**                          | Low-priority alerts      | Multi-step sequences             | Production-grade, reliable alerting          |

---

## ✅ Recommendation
We recommend using **Standard Workflows with a re-check condition** when:
- You need **alerts only if a problem persists**
- You're integrating with **ServiceNow**
- You want to reduce **false positives and noise**

To manage cost, we will:
- Use **tight filters** so workflows only run for specific, high-impact issues
- Work with Dynatrace on **cost waivers or optimizations**

---

## 📅 Next Steps
- [ ] Build a test workflow for CPU alerting with delay + query check  
- [ ] Evaluate cost based on real-world runs  
- [ ] Finalize decision and update alerting playbook  

---

## 🧠 Why This Matters (for Non-Technical Reviewers)
Without this improvement, we risk:
- Alerting teams for issues that resolve in seconds
- Creating unnecessary ServiceNow tickets
- Losing trust in the alert system

By making alerts **smarter**, we reduce noise and ensure action is taken only when necessary.
