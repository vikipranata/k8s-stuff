#!/bin/bash
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -
mkdir -p /etc/rancher/rke2

cat <<EOF | tee /etc/rancher/rke2/config.yaml
node-ip: $(hostname -i)
server: https://kubenya-master01:9345
token: cluster-token-secret
EOF

systemctl enable --now rke2-agent.service
systemctl disable --now rke2-server.service

#chmod -x /usr/local/bin/rke2-*
