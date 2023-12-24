#!/bin/bash
kubectl create -f https://blog.syslog.my.id/assets/manifests/ingress-nginx-hostport.yaml
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.12.0 --set installCRDs=true

kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    email: notify@tworty.id
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: le-staging-issuer-account-key
    solvers:
    - http01:
        ingress:
          ingressClassName: nginx-hostport
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-production
spec:
 aacme:
    email: notify@tworty.id
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: le-production-issuer-account-key
    solvers:
    - http01:
        ingress:
          ingressClassName: nginx-hostport
EOF

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

cat <<EOF | tee ~/prometheus-blackbox-exporter-helm-values.yaml
kind: DaemonSet
tolerations:
  - key: CriticalAddonsOnly
    operator: Exists
  - effect: NoExecute
    operator: Exists
  - effect: NoSchedule
    operator: Exists
config:
  modules:
    http_2xx:
      prober: http
      timeout: 5s
      http:
        valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
        follow_redirects: true
        preferred_ip_protocol: "ip4"
    tcp_connect:
      prober: tcp
      timeout: 5s
    icmp_connect:
      prober: icmp
      timeout: 5s
      icmp:
        preferred_ip_protocol: "ip4"
        source_ip_address: "127.0.0.1"
EOF

helm install blackbox prometheus-community/prometheus-blackbox-exporter --namespace monitoring --create-namespace --values ~/prometheus-blackbox-exporter-helm-values.yaml
