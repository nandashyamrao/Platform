# 🚀 Backstage & Dynatrace Integration Setup Guide

> **Monitor your Kubernetes workloads directly from Backstage using Dynatrace!**  
> This guide will walk you through setting up **Backstage + Dynatrace** to track **pod availability, errors, SLIs, and real-time alerts**.

---

## 📌 **Prerequisites**
Before starting, ensure you have:
- ✅ **Backstage installed** (`yarn create backstage-app` or an existing deployment).
- ✅ **Dynatrace account** with API access.
- ✅ **Kubernetes cluster with workloads**.
- ✅ **Kubernetes labels (`backstage.io/component`) assigned to services**.

---

## 🛠 **Step 1: Generate Dynatrace API Token**
1. **Login to Dynatrace** → Go to **Settings > Integration > API tokens**.
2. Click **"Generate new token"**.
3. Enable the following permissions:
   - 🔹 `metrics.read`
   - 🔹 `entities.read`
   - 🔹 `problems.read`
   - 🔹 `logs.read`
4. **Copy the generated API token** – you'll need it later.

---

## 🏗 **Step 2: Configure Dynatrace in Backstage**
1. Open **Backstage configuration file (`app-config.yaml`)**.
2. Add the following Dynatrace integration:
   ```yaml
   integrations:
     dynatrace:
       - name: "dynatrace"
         apiToken: "${DYNATRACE_API_TOKEN}"
         baseUrl: "https://YOUR_ENVIRONMENT.live.dynatrace.com"
   ```
3. **Save the file and restart Backstage**.

---

## 🔌 **Step 3: Install Dynatrace Plugin in Backstage**
1. **Navigate to your Backstage project root** and install the Dynatrace plugin:
   ```sh
   yarn add @backstage/plugin-dynatrace
   ```
2. **Register the plugin in Backstage** (`packages/app/src/plugins.ts`):
   ```tsx
   import { DynatracePlugin } from '@backstage/plugin-dynatrace';

   const routes = createRoutesFromElements(
     <Route path="/dynatrace" element={<DynatracePlugin />} />
   );
   ```
3. **Restart Backstage**:
   ```sh
   yarn dev
   ```

---

## 🏷 **Step 4: Link Backstage Components to Dynatrace**
Each service in Backstage **must map to a Dynatrace entity**.

1. Open the **`catalog-info.yaml`** for each service.
2. Add the **Dynatrace entity ID** as an annotation:
   ```yaml
   apiVersion: backstage.io/v1alpha1
   kind: Component
   metadata:
     name: payment-service
     annotations:
       dynatrace.com/entityId: "SERVICE-1234567890"
   ```
3. **Commit & push the changes**.

---

## 🚀 **Step 5: Label Kubernetes Services for Backstage & Dynatrace**
Ensure your Kubernetes services **include `backstage.io/component` labels**.

Modify your **Deployment YAML**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-service
  namespace: production
  labels:
    backstage.io/component: "default.payment-service-team01-prod"
spec:
  replicas: 10  # Desired Pods
  selector:
    matchLabels:
      app: payment-service
  template:
    metadata:
      labels:
        app: payment-service
        backstage.io/component: "default.payment-service-team01-prod"
    spec:
      containers:
      - name: payment-container
        image: myregistry.com/payment-service:v1.0
```

**Apply the changes:**
```sh
kubectl apply -f deployment.yaml
```

✅ Now, Dynatrace and Backstage can **match Kubernetes workloads to services**!

---

## 📊 **Step 6: Dynatrace Query for Pod Availability**
To track **pod availability**, use this **Dynatrace Query Language (DQL)**:
```dql
timeseries {desired = avg(dt.kubernetes.workload.pods.desired), active = avg(dt.kubernetes.pods)}, by: {dt.entity.cloud_application}
fieldsAdd component = labels['backstage.io/component']
filter component == "default.$proj_name-$owner-$stage"
fieldsAdd sli = (active||desired) * 100
summarize sli = avg(arrayAvg(sli))
```
🔹 This calculates:
```
sli = (active pods / desired pods) * 100
```
✅ Use **Dynatrace dashboards** to visualize this data inside Backstage!

---

## 📡 **Step 7: Display Dynatrace Dashboard in Backstage**
To show Dynatrace data **inside Backstage**, modify `packages/app/src/components.tsx`:

```tsx
import { DynatraceDashboard } from '@backstage/plugin-dynatrace';

export const ServiceDashboard = () => {
  return (
    <DynatraceDashboard entityId="SERVICE-1234567890" />
  );
};
```

Now, clicking a service in Backstage will **display Dynatrace metrics, alerts, and logs!**

---

## ✅ **Step 8: Testing & Validation**
1. **Check Backstage UI**: Ensure Dynatrace metrics appear in **Service Overview**.
2. **Verify Dynatrace Logs**: Look for errors or missing services.
3. **Test Alerts**: Stop a pod (`kubectl delete pod <pod-name>`) and check Dynatrace alerts.

---

## ❓ **Troubleshooting**
| Issue | Solution |
|-------|----------|
| Dynatrace data not appearing in Backstage | Check **API token permissions** and Backstage logs. |
| Services missing in Backstage | Ensure `backstage.io/component` label is set in Kubernetes. |
| Alerts not triggering | Check **Dynatrace alert rules** and thresholds. |

---

## 🎯 **Final Summary**
🎉 **Congrats! You have successfully integrated Backstage with Dynatrace!** 🚀  

🔹 **Kubernetes** assigns `backstage.io/component` labels.  
🔹 **Dynatrace monitors services and pods**.  
🔹 **Backstage pulls Dynatrace metrics** using API integration.  
🔹 **Developers & SREs can monitor services directly in Backstage!**  

---

## 💡 **Next Steps**
✅ Explore **Dynatrace Synthetic Monitoring** inside Backstage.  
✅ Use **Dynatrace Logs API** to fetch logs for services.  
✅ Automate **Dynatrace alerts into Slack/PagerDuty from Backstage**.  

📚 **Resources**:  
- [Backstage Official Docs](https://backstage.io/docs)  
- [Dynatrace API Docs](https://developer.dynatrace.com/)  
