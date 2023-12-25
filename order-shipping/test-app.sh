#!/bin/bash
HOST=$(kubectl get ingress order-service -o jsonpath='{.spec.rules[0].host}')

while true;
    do curl -X POST http://$HOST:3000/order -H "Content-Type: application/json" -d '{
        "order": {
            "book_name": "Managing your Kubernetes clusters for dummies",
            "author": "Lawrence C. Miller",
            "buyer": "Viki Pranata",
            "shipping_address": "Jakarta, Indonesia"
        }
    }';
sleep 3s; done