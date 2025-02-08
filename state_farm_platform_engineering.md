# **State Farm Platform Engineering: GitOps, Deployment, and Infrastructure**

## **1️⃣ Overview**  
This document provides a **detailed breakdown of how State Farm's platform engineering works**, covering:  
- **GitOps (GitLab, JFrog, ArgoCD, Kubernetes, Terraform, Backstage).**
- **Deployment mechanisms (VMware, OpenShift, TP2, AWS, ROSA, Cloud Foundry).**
- **SRE, SLIs, SLOs, CI/CD, and monitoring.**

---

## **2️⃣ GitOps: Managing Infrastructure & Deployments with Git**  
### **What is GitOps?**  
✅ **GitOps = Managing infrastructure and applications declaratively using Git.**  
✅ **Git is the single source of truth for configurations and deployments.**  

### **GitOps Workflow:**  
1️⃣ **Developers push changes to GitLab (source repo or config repo).**  
2️⃣ **GitOps tools (ArgoCD, FluxCD) detect and apply changes automatically.**  
3️⃣ **Applications & infrastructure are updated seamlessly.**  

### **Key GitOps Components:**  
| **Component** | **Stored In** | **Example** |
|--------------|-------------|-------------|
| **Application Source Code** | **GitLab Source Code Repo** | `git@gitlab.com:my-app.git` |
| **Built Artifacts (JAR, Docker Images)** | **JFrog Artifactory** | `https://artifactory.company.com/repo/my-app.jar` |
| **Deployment Configs (YAML, Terraform)** | **GitLab Config Project** | `git@gitlab.com:my-app-config.git` |
| **Deployment Execution** | **ArgoCD (pull) or Terraform (push)** | `kubectl apply -f deployment.yaml` |

✅ **This structure ensures security, efficiency, and compliance with GitOps best practices.**  

---

## **3️⃣ Deployment Mechanisms & Infrastructure**  

### **Deployment Mechanisms at State Farm**  
| **Platform** | **Deployment Type** | **Deployment Tool** |
|-------------|----------------|----------------|
| **VMware (TP2, vSphere)** | Push-based | CLI (Provisioning scripts) |
| **VMware Tanzu Kubernetes Grid (TKG)** | Pull-based | ArgoCD |
| **Cloud Foundry (TAS on VMware)** | Push-based | `cf push` |
| **AWS (Terraform-based Infra)** | Push-based | Terraform |
| **ROSA (OpenShift on AWS)** | Pull-based | ArgoCD |

✅ **Pull-based GitOps (ArgoCD, FluxCD) ensures automatic deployment updates.**  
✅ **Push-based deployment (Terraform, CLI) requires manual execution.**  

---

## **4️⃣ SRE, SLIs, and SLOs**  

### **What is SRE?**  
✅ **Site Reliability Engineering (SRE) ensures reliable, scalable, and resilient systems.**  
✅ **It introduces SLIs, SLOs, error budgets, and automation for high availability.**  

### **SLI (Service Level Indicators) Explained**  
| **SLI Type** | **What It Measures** | **Example** |
|-------------|------------------|----------------------|
| **Availability** | How often the service is up | `Website uptime 99.99%` |
| **Latency** | How fast responses are | `API responds in <200ms` |
| **Error Rate** | How many requests fail | `<0.5% of transactions fail` |
| **Throughput** | How many requests can be handled | `10,000 requests/sec` |

✅ **SLIs define system performance; SLOs set performance targets.**  

### **SLO (Service Level Objective) Explained**  
| **SLO Type** | **Objective (Goal)** | **Example** |
|-------------|------------------|----------------------|
| **Availability** | 99.95% uptime | `Ensure 99.95% service uptime` |
| **Latency** | 95% of requests in <200ms | `Maintain API speed under 200ms` |
| **Error Rate** | <1% failures | `Keep checkout errors below 1%` |

✅ **If an SLO is violated, teams investigate and optimize system performance.**  

---

## **5️⃣ Backstage for Developer Experience & Visibility**  

### **How Backstage Integrates GitLab & JFrog**  
| **Information Needed** | **Best Source** | **Backstage Plugin** |
|-----------------|-----------------|----------------|
| **Code & Version History** | GitLab | ✅ GitLab Plugin |
| **Built JARs, Docker Images** | JFrog Artifactory | ✅ JFrog Plugin |
| **Running Deployments** | Kubernetes, ArgoCD | ✅ Kubernetes / ArgoCD Plugin |
| **CI/CD Pipeline Status** | GitLab CI/CD | ✅ GitLab Plugin |

✅ **GitLab tracks code history; JFrog tracks built artifacts; ArgoCD/Kubernetes tracks running versions.**  

### **Example Backstage Configuration for GitLab & JFrog**  
```yaml
metadata:
  name: my-app
spec:
  type: service
  owner: team-xyz
  lifecycle: production
  links:
    - url: "https://gitlab.com/my-org/my-app"
      title: "GitLab Repository"
      icon: "gitlab"
    - url: "https://artifactory.company.com/repo/my-app"
      title: "JFrog Artifacts"
      icon: "package"
    - url: "https://argocd.company.com/applications/my-app"
      title: "ArgoCD Deployment"
      icon: "deploy"
```

✅ **Backstage gives a single pane of glass for tracking code, artifacts, and deployments.**  

---

## **6️⃣ Summary: Key Takeaways**  
| **Concept** | **Explanation** |
|------------|---------------|
| **Where is the code stored?** | GitLab Source Code Repo |
| **Where are JARs stored?** | JFrog Artifactory (not Git) |
| **Where are deployment configs stored?** | GitLab Config Repo |
| **What handles deployments?** | ArgoCD (Pull-based) or Terraform (Push-based) |
| **What does Backstage show?** | Code (GitLab), Artifacts (JFrog), Deployments (ArgoCD) |

✅ **GitOps enables automated, secure, and efficient deployments.**  
✅ **Backstage provides visibility into the full software lifecycle.**  
✅ **SRE practices (SLIs, SLOs) ensure system reliability.**  

---

## **7️⃣ Next Steps**  
🚀 **Would you like a step-by-step guide for setting up GitOps with Backstage?** 🚀  
