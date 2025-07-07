#!/bin/bash
set -e

APP_NAME=gin-demo
CHART_PATH=./gin-demo-chart

echo "🧹 Cleaning up old cluster (if any)..."
kind delete cluster --name istio-demo || true

echo "📦 Creating kind cluster with port mappings..."
kind create cluster --name istio-demo --config kind-config.yaml

echo "🚀 Installing Istio..."
istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled

echo "📦 Building Go Gin Docker image..."
docker build -t localhost/gin-demo:latest .
kind load docker-image localhost/gin-demo:latest --name istio-demo

echo "🚀 Deploying with Helm..."
helm install $APP_NAME $CHART_PATH || helm upgrade $APP_NAME $CHART_PATH

echo "🌐 Applying Istio Gateway & VirtualService..."
kubectl apply -f gin-istio.yaml

echo "📈 Installing Prometheus and Grafana..."
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.22/samples/addons/prometheus.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.22/samples/addons/grafana.yaml

echo "🔁 Forwarding istio-ingressgateway to localhost:8080 ..."
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80 > /dev/null 2>&1 &
