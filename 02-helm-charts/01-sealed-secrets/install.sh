#! /bin/bash
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets

helm dep update 01-sealed-secrets/

helm upgrade --install -n kube-system sealed-secrets 01-sealed-secrets/