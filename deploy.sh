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
