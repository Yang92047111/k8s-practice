# 🛠️ 自建 Helm Chart 教學（for macOS）

本教學將教你如何：

1. 建立一個自訂的 Helm Chart
2. 修改模板內容
3. 使用 `helm install` 部署到 Kubernetes（例如 kind）
4. 驗證部署結果

---

## 📦 前置工具安裝

請確保已安裝以下工具：

```bash
brew install helm
brew install kubectl
brew install kind # 若你想在本機使用 kind 建立叢集
```

---

## 🧱 Step 1：建立 Helm Chart

```bash
helm create my-nginx
```

這會產生以下目錄結構：

```
my-nginx/
├── charts/              # 子 Chart 目錄
├── templates/           # Kubernetes YAML 模板
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ...
├── values.yaml          # 預設變數設定
├── Chart.yaml           # Chart 的基本描述檔
└── README.md
```

---

## ✍️ Step 2：修改 Chart 設定

### 1. 修改 `values.yaml`

```yaml
replicaCount: 1

image:
  repository: nginx
  tag: "1.25"
  pullPolicy: IfNotPresent

service:
  type: NodePort
  port: 80
```

### 2. 檢查 `deployment.yaml` 和 `service.yaml` 模板

Helm 已自動使用上述變數建好 YAML 模板，不需大改，只要確認 `image`, `replicaCount`, 和 `service` 設定與你預期一致即可。

---

## 🚀 Step 3：部署 Chart 到本地叢集

### 1. 建立 kind 叢集（如果尚未有）

```bash
kind create cluster --name helm-demo
```

### 2. 安裝 Chart

```bash
helm install my-nginx ./my-nginx
```

或指定 namespace：

```bash
kubectl create namespace web
helm install my-nginx ./my-nginx -n web
```

### 3. 查看部署結果

```bash
kubectl get all -n web
```

你應該可以看到 `Deployment`, `Pod`, `Service` 等資源。

---

## 🌐 Step 4：測試 Nginx 服務

取得 NodePort：

```bash
kubectl get svc -n web
```

例如：

```
my-nginx   NodePort   10.96.0.1   <none>   80:30999/TCP
```

然後開啟瀏覽器或用 curl 測試：

```bash
curl http://localhost:30999
```

你應該會看到 Nginx 的歡迎頁面。

---

## 🔄 更新 Chart

修改 `values.yaml` 或 templates 後，執行：

```bash
helm upgrade my-nginx ./my-nginx -n web
```

---

## 🧹 移除 Chart 與叢集

```bash
helm uninstall my-nginx -n web
kind delete cluster --name helm-demo
```

---

## 📘 補充：Chart.yaml 範例

```yaml
apiVersion: v2
name: my-nginx
description: A simple Nginx Helm chart example
type: application
version: 0.1.0
appVersion: "1.25"
```

---

## 📝 延伸閱讀

* [Helm 官方文件](https://helm.sh/docs/)
* [Helm Chart Best Practices](https://helm.sh/docs/chart_best_practices/)
* [Helm Template 語法](https://helm.sh/docs/chart_template_guide/)

---
