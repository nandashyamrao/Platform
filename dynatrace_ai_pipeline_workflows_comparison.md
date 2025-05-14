
# **Dynatrace: Davis AI vs. OpenPipeline vs. Workflows**

Let’s compare and contrast how **Davis AI**, **Dynatrace OpenPipeline**, and **Dynatrace Workflows** operate within the platform.

---

## 1. **Davis AI with Streaming & Grail Data for Alerting Profiles** 🔍

- **Purpose**: Core AI mechanism for automatic problem detection and intelligent alerting.
- **Data Handling**:
  - **Real-time Analysis**: Processes observability data like metrics, traces, events, etc.
  - **Grail Integration**: Stores and analyzes historical data for context.
  - **Root-Cause Intelligence**: Uses Grail for smart baselining, complex correlation.
- **Output**: Generates **“problems”**—contextualized issues with impact assessment.
- **Alerting Profiles**: Filters Davis-detected problems by severity, zone, tags, etc.
- **Focus**: Automated identification and qualification of issues.

---

## 2. **Dynatrace OpenPipeline** 🔄

- **Purpose**: Seamless ingestion and transformation of data into Dynatrace (Grail).
- **Data Handling**:
  - **Ingestion**: Logs, metrics (StatsD, Telegraf, Prometheus), business events.
  - **Processing**: Parse, transform, and enrich data before storage.
  - **Routing**: Store structured data in Grail for analysis and dashboards.
- **Relationship to Davis AI & Alerting**:
  - Feeds rich data to **Davis AI**.
  - Enables **custom anomaly detection**.
- **Focus**: Effective onboarding and contextualization of all observability data.

---

## 3. **Dynatrace Workflows** ⚙️

- **Purpose**: Automate actions and orchestrate IT processes.
- **Triggers**:
  - Davis AI problems (filtered by alerting profiles)
  - Metric thresholds
  - Scheduled jobs or manual triggers
- **Contextual Inputs**:
  - Use problem/event details or query Grail/APIs for extra context.
- **Actions**:
  - Send alerts (Slack, Jira, ServiceNow, Email)
  - Run remediation scripts or scale infra
  - Create/update ITSM tickets
  - Execute multi-step orchestration flows
- **Focus**: Automated and consistent IT response workflows.

---

## **Comparison Table** 📊

| **Feature**              | **Davis AI (Alerting Profiles)** 🔍 | **OpenPipeline** 🔄 | **Workflows** ⚙️ |
|--------------------------|--------------------------------------|---------------------|------------------|
| **Primary Goal**         | Auto-detect problems & alert         | Ingest & prepare data | Automate responses |
| **Data Flow**            | Analyze streams & Grail              | Feed data into Grail  | Triggered by Dynatrace events |
| **Main Function**        | Find issues & context                | Contextualize data    | Take action based on events |
| **Automation Type**      | AI-based detection                   | Data pipeline automation | Process orchestration |
| **Alerting Connection**  | Source of problems for alerting      | Provides data for detection | Responds to alert-triggered problems |
| **Key Output**           | “Problems” for alert filtering       | Structured data in Grail | Notifications, scripts, tickets |
| **Analogy**              | 🕵️ The Detective                     | 📚 The Librarian      | 🚨 The First Responder |

---

## **In Summary**

- **OpenPipeline**: Brings in and prepares the data.
- **Davis AI**: Analyzes data to detect and understand issues.
- **Alerting Profiles**: Filter the right notifications from Davis AI findings.
- **Workflows**: Automate what happens **after** alerts or at defined schedules.

These 3 features **work hand-in-hand** to deliver **end-to-end observability, intelligent alerting, and automated remediation** in the Dynatrace ecosystem.

---
