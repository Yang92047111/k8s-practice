# 🛠️ 自建 Helm Chart 教學（for macOS）

* 📦 Gin 應用打包成 Docker Image
* 🛠 使用 Helm Chart 部署
* ☸️ 部署到本機 kind
* 🧭 整合 Istio
* 📊 整合 Prometheus & Grafana
* 🧪 一鍵部署腳本 `deploy.sh`

---

# 🔁 Golang Gin + Helm + Istio + Prometheus + Grafana @ kind 教學（for macOS）

---

## 🛠 Golang Gin App 程式碼（`main.go`）

```go
package main

import (
    "github.com/gin-gonic/gin"
    "net/http"
)

func main() {
    r := gin.Default()

    r.GET("/", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{
            "message": "Hello from Gin + Istio 🚀",
        })
    })

    r.Run(":8080") // listen and serve on port 8080
}
```

---

## 🐳 Dockerfile

```Dockerfile
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY . .
RUN go mod init gin-demo && go get -u github.com/gin-gonic/gin && go build -o server .

FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/server .
EXPOSE 8080
CMD ["./server"]
```

---

## 📁 Helm Chart：`gin-demo-chart/`

### `Chart.yaml`

```yaml
apiVersion: v2
name: gin-demo
description: A simple Golang Gin app
type: application
version: 0.1.0
appVersion: "1.0"
```

### `values.yaml`

```yaml
replicaCount: 1

image:
  repository: gin-demo
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 8080

resources: {}
```

### `templates/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
        - name: gin
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: 8080
```

### `templates/service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}
spec:
  selector:
    app: {{ .Release.Name }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: 8080
      protocol: TCP
      name: http
  type: {{ .Values.service.type }}
```

---

## 🌐 `gin-istio.yaml`（Istio Gateway + VirtualService）

```yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: gin-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
    - port:
        number: 80
        name: http
        protocol: HTTP
      hosts:
        - "*"

---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: gin-vs
spec:
  hosts:
    - "*"
  gateways:
    - gin-gateway
  http:
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: gin-demo
            port:
              number: 8080
```

---

## 🧪 `deploy.sh` 一鍵部署腳本

```bash
#!/bin/bash
set -e

APP_NAME=gin-demo
CHART_PATH=./gin-demo-chart

echo "🧹 Cleaning up old cluster (if any)..."
kind delete cluster --name istio-demo || true

echo "📦 Creating kind cluster..."
kind create cluster --name istio-demo

echo "🚀 Installing Istio..."
istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled

echo "📦 Building Go Gin Docker image..."
docker build -t gin-demo:latest .
kind load docker-image gin-demo:latest --name istio-demo

echo "🚀 Deploying with Helm..."
helm install $APP_NAME $CHART_PATH

echo "🌐 Applying Istio Gateway & VirtualService..."
kubectl apply -f gin-istio.yaml

echo "📈 Installing Prometheus and Grafana..."
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.22/samples/addons/prometheus.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.22/samples/addons/grafana.yaml

echo "✅ Deployment complete!"
echo "Visit your app at: http://localhost:$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.spec.ports[0].nodePort}')"
```

---

## ✅ 使用方式

```bash
go mod tidy         # 初始化 go module
chmod +x deploy.sh  # 賦予腳本執行權限
./deploy.sh
```

### 預期結果

* 瀏覽 `http://localhost:<PORT>` 應回傳：

```json
{"message":"Hello from Gin + Istio 🚀"}
```

* 瀏覽 Grafana：`http://localhost:3001`
* 瀏覽 Prometheus：`http://localhost:3002`

---
