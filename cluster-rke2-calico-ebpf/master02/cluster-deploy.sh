#!/bin/bash
mkdir -p /etc/rancher/rke2/

curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="server" sh -

cat <<EOF | tee /etc/rancher/rke2/config.yaml
server: https://kubenya-master01:9345
node-ip: 172.16.66.12
token: cluster-token-secret
write-kubeconfig-mode: "0600"
tls-san:
  - "localhost"
  - "127.0.0.1"
  - "kubenya-master01"
  - "172.16.66.11"
  - "kubenya-master02"
  - "172.16.66.12"
  - "kubenya-master03"
  - "172.16.66.13"
  - "kubenya-worker01"
  - "172.16.66.14"
  - "kubenya-worker02"
  - "172.16.66.15"
  - "kubenya-worker03"
  - "172.16.66.16"
  - "lbnya-kube01"
  - "172.16.66.10"
  - "kube-api.natakata.my.id"
  - "116.206.198.212"
  - "172.16.66.254"
# Make a etcd snapshot every 6 hours
etcd-snapshot-schedule-cron: " */6 * * *"
# Keep 56 etcd snapshorts (equals to 2 weeks with 6 a day)
etcd-snapshot-retention: 56
disable-kube-proxy: true
disable:
  - rke2-ingress-nginx
cni: cilium
EOF

systemctl enable --now rke2-server.service
systemctl disable --now rke2-agent.service

#chmod -x /usr/local/bin/rke2-*
