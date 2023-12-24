#!/bin/bash
# This script runninig only in temng01ranch01 as root user
for cluster in $(ls -1 ~/.kube/*kube01 | sed 's/\/root\/.kube\///');
    do echo $cluster; KUBECONFIG=~/.kube/$cluster kubectl -n monitoring create ingress prometheus --rule $cluster.tworty.id/*=prometheus:9090;
done