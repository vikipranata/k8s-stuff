#!/bin/bash
mkdir -p /etc/rancher/rke2/

curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="server" sh -

cat <<EOF | tee /etc/rancher/rke2/config.yaml
#Fist Master RKE2 Server
node-ip: 172.16.66.11
token: cluster-token-secret
write-kubeconfig-mode: "0600"
tls-san:
  - "localhost"
  - "127.0.0.1"
  - "kube-api.lab-sysops.net"
  - "116.206.198.212"
  - "172.16.66.254"
# Make a etcd snapshot every 6 hours
etcd-snapshot-schedule-cron: " */6 * * *"
# Keep 56 etcd snapshorts (equals to 2 weeks with 6 a day)
etcd-snapshot-retention: 56
disable-kube-proxy: true
disable:
  - rke2-ingress-nginx
cni: calico
EOF

systemctl enable --now rke2-server.service
systemctl disable --now rke2-agent.service

sleep 60s

kubectl apply -f - <<EOF
kind: ConfigMap
apiVersion: v1
metadata:
  name: kubernetes-services-endpoint
  namespace: tigera-operator
data:
  KUBERNETES_SERVICE_HOST: "172.16.66.11"
  KUBERNETES_SERVICE_PORT: "6443"
EOF

export CALICO_DATASTORE_TYPE=kubernetes
export CALICO_KUBECONFIG=~/.kube/config

kubectl patch installation.operator.tigera.io default --type merge -p '{"spec":{"calicoNetwork":{"linuxDataplane":"BPF", "hostPorts":null}}}'
calicoctl patch felixconfiguration default --patch='{"spec": {"bpfKubeProxyIptablesCleanupEnabled": false}}'
calicoctl patch felixconfiguration default --patch='{"spec": {"bpfEnabled": true}}'
calicoctl patch felixconfiguration default --patch='{"spec": {"bpfExternalServiceMode": "DSR"}}'

#kubectl apply -f - <<EOF
#apiVersion: helm.cattle.io/v1
#kind: HelmChartConfig
#metadata:
#  name: rke2-coredns
#  namespace: kube-system
#spec:
#  valuesContent: |-
#    nodelocal:
#      enabled: true
#EOF

chmod -x /usr/local/bin/rke2-*
