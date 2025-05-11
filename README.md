# 🚀 kind + Helm + Istio on macOS

This tutorial will guide you through:

1. Installing `kind`, `kubectl`, `helm`, and `istioctl`
2. Creating a local Kubernetes cluster with `kind`
3. Installing Istio using `helm`
4. Verifying Istio in the pods

---

## 📦 Prerequisites

Make sure you have the following tools installed:

### 1. Install kind

```bash
brew install kind
```

### 2. Install kubectl

```bash
brew install kubectl
```

### 3. Install Helm

```bash
brew install helm
```

### 4. Install istioctl

```bash
brew install istioctl
```

Check versions to verify installation:

```bash
kind version
kubectl version --client
helm version
istioctl version
```

---

## 🔧 Step 1: Create a kind Cluster

Create a config file for the kind cluster with extra port mappings (optional):

```yaml
# kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30000
        hostPort: 30000
        protocol: TCP
```

Create the cluster:

```bash
kind create cluster --name istio-demo --config kind-config.yaml
```

Check the cluster:

```bash
kubectl cluster-info --context kind-istio-demo
```

---

## 🚀 Step 2: Install Istio using Helm

### 1. Add the Istio Helm repo

```bash
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
```

### 2. Create a namespace for Istio

```bash
kubectl create namespace istio-system
```

### 3. Install Istio base chart

```bash
helm install istio-base istio/base -n istio-system
```

### 4. Install Istiod (Istio control plane)

```bash
helm install istiod istio/istiod -n istio-system --wait
```

### 5. (Optional) Install Istio Ingress Gateway

```bash
helm install istio-ingress istio/gateway -n istio-system
```

---

## ✅ Step 3: Verify Istio Installation

### Check Istio components

```bash
kubectl get pods -n istio-system
```

You should see pods like:

```
istiod-xxxxxxxxxx-yyyyy
istio-ingress-xxxxx-yyyyy (if installed)
```

### Enable automatic sidecar injection for your application namespace

```bash
kubectl create namespace demo
kubectl label namespace demo istio-injection=enabled
```

---

## 🧪 Step 4: Deploy a Sample App

Deploy the sample **httpbin** app with sidecar injection:

```bash
kubectl apply -n demo -f https://raw.githubusercontent.com/istio/istio/release-1.22/samples/httpbin/httpbin.yaml
```

Check the pods:

```bash
kubectl get pods -n demo
```

You should see 2 containers per pod (the app + the Envoy sidecar).

---

## 🧼 Cleanup

To delete everything:

```bash
kind delete cluster --name istio-demo
```

---

## 📝 References

* [Kind](https://kind.sigs.k8s.io/)
* [Helm](https://helm.sh/)
* [Istio Helm Install Docs](https://istio.io/latest/docs/setup/install/helm/)
* [Istio Sample Apps](https://github.com/istio/istio/tree/release-1.22/samples)

---
