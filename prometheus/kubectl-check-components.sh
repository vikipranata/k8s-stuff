#!/bin/bash
for cluster in $(ls -1 ~/.kube/*kube01 | sed 's/\/root\/.kube\///');
    do echo $cluster; KUBECONFIG=~/.kube/$cluster kubectl -n monitoring $1 $2 $3;
done