#!/bin/bash
chmod +x /usr/local/bin/{rke2-killall.sh,rke2-uninstall.sh}
rke2-uninstall.sh
rm -rf /etc/rancher /opt/cni /var/lib/rancher /var/log/containers /var/log/pods
