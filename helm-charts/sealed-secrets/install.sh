#! /bin/bash
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets

helm dep update sealed-secrets/

helm upgrade --install -n kube-system sealed-secrets sealed-secrets/