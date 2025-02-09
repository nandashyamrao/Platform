# **Integrating Dynatrace Launcher Apps with Backstage**

## **🔹 Overview**
Dynatrace **Launcher Apps** provide a **centralized interface within Dynatrace** for observability, monitoring, and troubleshooting. Backstage, on the other hand, is **a developer portal for self-service access to CI/CD, documentation, APIs, and observability tools**.

### **Why Integrate Them?**
✅ **Developers want a single view of services, deployments, logs, and CI/CD status.**  
✅ **Dynatrace provides deep observability, while Backstage serves as a self-service developer hub.**  
✅ **Integration eliminates tool-switching and provides end-to-end visibility.**  

---

## **🔹 Dynatrace Launcher Apps vs. Backstage – A Comparison**
| Feature | Dynatrace Launcher Apps | Backstage |
|---------|-------------------------|-----------|
| **Centralized UI** | ✅ Yes, within Dynatrace | ✅ Yes, across multiple developer tools |
| **Customizable Dashboards** | ✅ Yes, within Dynatrace Apps | ✅ Yes, with Backstage plugins |
| **Self-Service Access** | ✅ Yes, for monitoring & observability | ✅ Yes, for CI/CD, service catalogs, and logs |
| **Extensible Plugins** | ✅ Yes, via Dynatrace AppEngine | ✅ Yes, via Backstage plugins |
| **Observability & Monitoring** | ✅ Built-in with Dynatrace | 🔌 Integrates with Dynatrace, Prometheus, etc. |

✅ **Both aim to streamline workflows but serve different purposes.**  
✅ **Dynatrace = Observability & AI-driven insights.**  
✅ **Backstage = Developer Self-Service for CI/CD, APIs, and documentation.**  

---

## **🔹 How to Integrate Dynatrace into Backstage**

### **1️⃣ Install the Dynatrace Plugin for Backstage**
The **Dynatrace Backstage Plugin** allows teams to **display dashboards, logs, traces, and AI-powered insights** inside Backstage.

📌 **Install the Dynatrace Plugin in Backstage:**
```sh
yarn add @dynatrace/plugin-backstage
```

📌 **Configure `app-config.yaml` to connect Backstage to Dynatrace:**
```yaml
integrations:
  dynatrace:
    - host: your-dynatrace-environment-url
      apiToken: ${DYNATRACE_API_TOKEN}
```

📌 **Example Backstage YAML to Link a Service to Dynatrace:**
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-app
spec:
  type: service
  owner: team-dev
  lifecycle: production
  links:
    - url: "https://your-dynatrace-env.live.dynatrace.com/ui/apps/services/my-app"
      title: "Dynatrace Service Insights"
      icon: "monitor"
```

✅ **Developers can now see Dynatrace observability data inside Backstage.**  

---

### **2️⃣ Embed Dynatrace Launcher Apps in Backstage**
Dynatrace **Launcher Apps** like Logs, Tracing, and AI-powered Incident Detection can be embedded into Backstage.

📌 **Example Backstage YAML to Embed Dynatrace Apps:**  
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-app
spec:
  type: service
  owner: team-dev
  lifecycle: production
  links:
    - url: "https://your-dynatrace-env.live.dynatrace.com/ui/apps/logs/my-app"
      title: "Dynatrace Logs"
      icon: "logs"
    - url: "https://your-dynatrace-env.live.dynatrace.com/ui/apps/tracing/my-app"
      title: "Dynatrace Tracing"
      icon: "trace"
    - url: "https://your-dynatrace-env.live.dynatrace.com/ui/apps/problems"
      title: "Dynatrace AI Problems"
      icon: "alert"
```

✅ **Developers can now access logs, traces, and AI insights directly from Backstage.**  

---

### **3️⃣ Display Dynatrace CI/CD Insights in Backstage**
Dynatrace **tracks deployments and CI/CD events** from GitLab, Jenkins, or GitHub Actions. These can be surfaced in Backstage.

📌 **Modify `.gitlab-ci.yml` to Send Deployment Info to Dynatrace:**
```yaml
deploy:
  stage: deploy
  script:
    - curl -X POST "https://your-dynatrace-env/api/v2/events/ingest"       -H "Authorization: Api-Token $DYNATRACE_API_TOKEN"       -H "Content-Type: application/json"       -d '{
            "eventType": "CUSTOM_DEPLOYMENT",
            "title": "Deployment: $CI_COMMIT_REF_NAME",
            "properties": {
              "gitlab_project": "$CI_PROJECT_NAME",
              "gitlab_branch": "$CI_COMMIT_REF_NAME",
              "gitlab_pipeline_id": "$CI_PIPELINE_ID"
            }
          }'
```

📌 **Backstage YAML to Show Deployment Status:**  
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-app
spec:
  type: service
  owner: team-dev
  lifecycle: production
  links:
    - url: "https://dynatrace.company.com/deployments/my-app"
      title: "Dynatrace Deployment Events"
      icon: "monitor"
```

✅ **Backstage now shows deployment status alongside GitLab pipelines.**  

---

## **🔹 Benefits of Integration**

| **Feature** | **What It Does** | **Developer Benefit** |
|------------|----------------|----------------|
| 🚀 **CI/CD Insights** | Tracks GitLab/Jenkins deployments in Dynatrace | Developers can **see performance impact of deployments** |
| 🔍 **Logs & Traces** | Access logs & traces inside Backstage | No need to switch tools to debug |
| 🤖 **Davis AI Incident Detection** | Shows AI-detected problems inside Backstage | Faster mean-time-to-repair (MTTR) |
| 📊 **Custom Dashboards** | Embed Dynatrace dashboards in Backstage | Self-service observability |
| 🛠️ **Self-Service Monitoring** | No need for SRE involvement | Developers gain independence |

✅ **Dynatrace brings deep observability, while Backstage acts as a unified interface for developers.**  

---

## **🔹 Summary**
🚀 **Why Integrate Dynatrace & Backstage?**
- **Developers get a single view for deployments, logs, traces, and incidents.**
- **Eliminates tool-switching between Dynatrace & Backstage.**
- **Provides full observability without needing SRE intervention.**
- **AI-powered insights help prevent outages and speed up debugging.**

✅ **Best of both worlds: Dynatrace’s powerful observability + Backstage’s developer-first self-service approach.**  

---

## **🔹 Next Steps**
Would you like:
1. 📜 **A Terraform script to automate the Dynatrace & Backstage integration?**
2. 🔧 **A guide on adding Dynatrace plugin components in Backstage UI?**
3. 🚀 **More insights into Backstage service ownership using Dynatrace metadata?**

