
# 🧾 Observed Limitations and Behavior in Dynatrace Workflows

This document summarizes key observations and system behaviors related to Dynatrace workflows, especially focusing on limitations encountered while using Simple Workflows and issues with the ServiceNow integration pipeline.

---

## ⚙️ Workflow Behavior and Limitations

1. **Simple Workflows execute immediately upon problem detection.**  
   There is no built-in support for waiting and rechecking the problem status after a duration.

2. **No native 'duration' check in Simple Workflows.**  
   Users cannot specify a condition like "problem must persist for 15 minutes" before triggering an action.

3. **Wait steps do not include condition re-evaluation.**  
   The wait action only introduces a delay; it does not recheck the problem state before proceeding to the next step.

4. **Introducing a condition check after delay requires a custom query.**  
   Adding this logic converts the workflow from Simple to Standard, which incurs cost.

5. **Alerting profiles with extremely long wait times (e.g., 10,000 minutes) are used as a workaround to suppress alerts.**  
   This leads to clutter and inefficiency in alert management.

6. **Standard workflows offer improved ServiceNow integration.**  
   They allow configuration of urgency levels and configuration items which are not available through the pipeline integration.

7. **Priority mapping inconsistency between Dynatrace and ServiceNow.**  
   Dynatrace uses numeric priority (1, 2, 3), but ServiceNow treats higher numbers (e.g., 5) as high priority, leading to potential mismatches.

8. **The current ServiceNow pipeline behaves as a black box.**  
   Failures are hard to trace and often lead to dropped alerts without visibility.

9. **Alerts may be lost in the pipeline.**  
   Situations occur where problems are detected but do not result in tickets due to pipeline issues.

10. **Payload manipulation within the pipeline introduces failure risk.**  
    Any unapproved or malformed changes in payloads can cause the workflow to break silently.

11. **Workflow ownership is non-transferable by default.**  
    Only the creator can modify the workflow, which limits collaboration and governance.

12. **No search capability based on workflow owner.**  
    Effective search depends on consistent naming conventions.

13. **Multiple actions (e.g., email + incident) are only supported in standard workflows.**  
    This is not possible in Simple Workflows without conversion.

14. **Workflow validation and testing are required to confirm expected behavior.**  
    Delay and conditional logic must be verified in live scenarios before full implementation.

---

