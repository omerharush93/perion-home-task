#!/bin/bash

# Script להתקנת Loki logging stack
# עונה על Setup Requirements: "Configure log collection using EFK stack or Loki"

set -e

echo "📊 מתקין Loki logging stack..."

# הוספת Grafana Helm repository
echo "📦 מוסיף Grafana Helm repository..."
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# התקנת Loki
echo "🔧 מתקין Loki..."
helm install loki grafana/loki \
  --namespace logging \
  --create-namespace \
  --version 6.31.0 \
  --set loki.auth_enabled=false \
  --set loki.commonConfig.replication_factor=1 \
  --set loki.storage.type=filesystem \
  --wait

# התקנת Promtail
echo "📤 מתקין Promtail..."
helm install promtail grafana/promtail \
  --namespace logging \
  --version 6.31.0 \
  --set loki.serviceName=loki \
  --wait

# התקנת Grafana
echo "📈 מתקין Grafana..."
helm install grafana grafana/grafana \
  --namespace logging \
  --version 7.0.0 \
  --set adminPassword=admin123 \
  --set service.type=LoadBalancer \
  --set datasources.datasources\\.yaml.apiVersion=1 \
  --set datasources.datasources\\.yaml.datasources[0].name=Loki \
  --set datasources.datasources\\.yaml.datasources[0].type=loki \
  --set datasources.datasources\\.yaml.datasources[0].url=http://loki:3100 \
  --set datasources.datasources\\.yaml.datasources[0].access=proxy \
  --wait

# יצירת ConfigMap עבור Promtail configuration
echo "⚙️ יוצר Promtail configuration..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: promtail-config
  namespace: logging
data:
  promtail.yaml: |
    server:
      http_listen_port: 9080
      grpc_listen_port: 0
    positions:
      filename: /tmp/positions.yaml
    clients:
      - url: http://loki:3100/loki/api/v1/push
    scrape_configs:
      - job_name: kubernetes-pods-name
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels:
              - __meta_kubernetes_pod_label_app
            regex: hello-world-node
            action: keep
          - source_labels:
              - __meta_kubernetes_pod_name
            target_label: pod
          - source_labels:
              - __meta_kubernetes_namespace
            target_label: namespace
          - source_labels:
              - __meta_kubernetes_pod_container_name
            target_label: container
        pipeline_stages:
          - docker: {}
EOF

# עדכון Promtail עם הקונפיגורציה החדשה
kubectl rollout restart deployment/promtail -n logging

echo "✅ Loki logging stack הותקן בהצלחה!"
echo "📊 Grafana UI זמין ב: http://$(kubectl get svc grafana -n logging -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "🔑 משתמש: admin, סיסמה: admin123" 