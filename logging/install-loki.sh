#!/bin/bash
# Script install logging stack (Standalone) + Promtail + Grafana

set -euo pipefail

echo "📊 מתחיל התקנת Loki logging stack..."

# 1. הוספת Helm repo של Grafana
echo "📦 מוסיף Grafana Helm repo..."
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# 2. התקנת Loki (SingleBinary) עם תצורה מתאימה
echo "🔧 מתקין Loki (single-binary)..."
helm upgrade --install loki grafana/loki \
  --namespace logging --create-namespace \
  -f values.yaml \
  --wait


# 3. התקנת Promtail לאיסוף לוגים
echo "📤 מתקין Promtail..."
helm upgrade --install promtail grafana/promtail \
  --namespace logging \
  --set loki.serviceName=loki \
  --wait

# 4. התקנת Grafana עם datasource ללוגים
echo "📈 מתקין Grafana..."
helm upgrade --install grafana grafana/grafana \
  --namespace logging \
  --set adminPassword=admin123 \
  --set service.type=LoadBalancer \
  --set datasources.datasources\.yaml.apiVersion=1 \
  --set "datasources.datasources\.yaml.datasources[0].name=Loki" \
  --set "datasources.datasources\.yaml.datasources[0].type=loki" \
  --set "datasources.datasources\.yaml.datasources[0].url=http://loki:3100" \
  --set "datasources.datasources\.yaml.datasources[0].access=proxy" \
  --wait

# 5. קונפיגורציה מותאמת ל-Promtail
echo "⚙️ מיישם קונפיגורציה ל-Promtail..."
kubectl -n logging apply -f - <<EOF
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
    - url: http://loki.logging.svc.cluster.local:3100/loki/api/v1/push
    scrape_configs:
    - job_name: kubernetes-pods
      kubernetes_sd_configs:
        - role: pod
      relabel_configs:
      - source_labels: ['__meta_kubernetes_pod_label_app']
        regex: hello-world-node
        action: keep
      - source_labels: ['__meta_kubernetes_pod_name']
        target_label: pod
      - source_labels: ['__meta_kubernetes_namespace']
        target_label: namespace
      - source_labels: ['__meta_kubernetes_pod_container_name']
        target_label: container
      - source_labels: ['__meta_kubernetes_pod_node_name']
        target_label: __host__
      pipeline_stages:
      - docker: {}
EOF

kubectl -n logging rollout restart daemonset promtail
# 6. הדפסת פרטים לסיום
LB=$(kubectl -n logging get svc grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "✅ התקנת Loki logging stack הושלמה!"
echo "📊 Grafana UI: http://${LB:-<NodePort או IP>}"
echo "🔑 משתמש: admin / סיסמה: admin123"
