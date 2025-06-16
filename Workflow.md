# 📊 Dynatrace Workflow Comparison

This table compares three approaches to Dynatrace workflows: Simple Workflow, Standard Workflow without a re-check, and Standard Workflow with a delay + conditional re-check.

---

## 🧾 Workflow Comparison Table

| Feature / Behavior                              | 🔹 Simple Workflow                         | ⚠️ Standard Workflow (No Re-check Logic)     | ✅ Standard Workflow with Delay + Re-check    |
|--------------------------------------------------|--------------------------------------------|----------------------------------------------|------------------------------------------------|
| **Trigger Timing**                               | Immediate on problem detection              | Immediate on problem detection                | Immediate, then delayed                        |
| **Delay Supported**                              | ❌ No (not based on condition)              | ✅ Yes (wait step possible)                   | ✅ Yes (real wait + logic check)               |
| **Condition Re-check after Delay**               | ❌ Not possible                              | ❌ Not by default                              | ✅ Yes, using DQL or filter step               |
| **Execution Cost**                               | 💸 Free                                      | 💸 Charged per execution                      | 💸 Charged per execution (but optimized)       |
| **False Alert Prevention**                       | ❌ None (fires on all problems)             | ❌ Still alerts even if problem clears        | ✅ Prevents false alerts if problem resolves   |
| **Best For**                                     | Basic alerts, low-priority issues           | Multi-step tasks without timing logic         | Production-grade alerting, alert reliability  |
| **Common Use Case**                              | CPU > 90% → Email instantly                 | CPU > 90% → Wait 15m → Always alert           | CPU > 90% → Wait 15m → Alert **only if still true** |
| **Alert Fatigue Risk**                           | 🔴 High                                      | 🟠 Medium                                      | 🟢 Low                                         |
| **ServiceNow Ticket Quality**                    | ❌ May open false incidents                 | ❌ Still noisy                                | ✅ High-quality incident generation            |
| **Workflow Flexibility (Logic, Branching)**      | ❌ None                                     | ✅ Full logic support                         | ✅ Full logic support                          |
| **Labeling / Tagging Supported**                 | ❌ No                                        | ❌ No                                          | ❌ No                                           |
| **Multiple Actions (email + incident)**          | ❌ No                                        | ✅ Yes                                         | ✅ Yes                                          |

---

## 🧠 Summary Verdict

| Workflow Type                  | Verdict |
|-------------------------------|---------|
| **Simple Workflow**           | ✅ Easy to use, but too reactive for serious use |
| **Standard (no re-check)**    | ⚠️ Adds flexibility but may trigger too often |
| **Standard (with re-check)**  | ✅ Best for resilient, production-quality alerts — adds some cost but reduces alert noise dramatically |

---

## 📝 Recommendation

If you're working with critical alerting (e.g., CPU, availability, errors), prefer the **Standard Workflow with re-check** and negotiate with Dynatrace for execution cost optimization where needed.
