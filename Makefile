.PHONY: sealed-secrets-gen-cert
SEALED_SECRET_KEY_FILE := ./assets/sealed-secrets.key
SEALED_SECRET_CERT_FILE := ./assets/sealed-secrets.crt
SEALED_SECRET_TLS_FILE := ./assets/sealed-secrets-key.secrets.yaml
SEALED_SECRET_SOPS_TLS_FILE := ./assets/sealed-secrets-key.secrets.enc.yaml
KMS_KEY := arn:aws:kms:ap-southeast-1:429702212725:alias/eks/strimq/sops
sealed-secrets-gen-cert: ## Generate self-signed certificate for Sealed Secrets
	@echo "Generating self-signed certificate for Sealed Secrets..."
	@openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout $(SEALED_SECRET_KEY_FILE) -out $(SEALED_SECRET_CERT_FILE) -subj "/CN=sealed-secrets/O=sealed-secrets"
	@yq eval -n '.tls.crt |= load_str("$(SEALED_SECRET_CERT_FILE)") | .tls.key |= load_str("$(SEALED_SECRET_KEY_FILE)")' > $(SEALED_SECRET_TLS_FILE)

.PHONY: sealed-secrets-encrypt-tls
sealed-secrets-encrypt-tls: ## Encrypt Sealed Secrets TLS certificate with SOPS
	@echo "Encrypting Sealed Secrets TLS certificate with SOPS..."
	@sops --encrypt --kms "$(KMS_KEY)" $(SEALED_SECRET_TLS_FILE) > $(SEALED_SECRET_SOPS_TLS_FILE)
