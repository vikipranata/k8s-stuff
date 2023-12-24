#!/bin/bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm -n monitoring install blackbox prometheus-community/prometheus-blackbox-exporter --values prometheus-blackbox-values.yaml --create-namespace