Because we need persistent volume, first step we create directory with `mkdir /opt/prometheus-pod` command in each master node and change onwership with command `chown nobody:nogroup /opt/prometheus-pod` then create resources with the manifest

```bash
kubectl apply -f prometheus-namespace.yaml
kubectl apply -f prometheus-rbac.yaml
kubectl apply -f prometheus-pv-pvc.yaml
kubectl apply -f prometheus-configmap.yaml
kubectl apply -f prometheus-statefulset.yaml
kubectl apply -f prometheus-svc-ingress.yaml
```