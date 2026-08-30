SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
.DELETE_ON_ERROR:
.DEFAULT_GOAL := help

.PHONY: test
test:
	@echo Processed makefiles: $(MAKEFILE_LIST).

.PHONY: help
help: TARGET_DEFINITION_PATTERN := ^[a-z][a-zA-Z0-9_-]*:
help:
	@grep -hE '$(TARGET_DEFINITION_PATTERN)' $(MAKEFILE_LIST) | cut -d: -f1 | sort -u

.PHONY: check-required-tools
check-required-tools:
	@command -v docker >/dev/null || { echo "FAIL: docker not installed"; exit 1; }
	@docker info >/dev/null 2>&1 || { echo "FAIL: docker daemon not running"; exit 1; }
	@command -v minikube >/dev/null || { echo "FAIL: minikube not installed"; exit 1; }
	@command -v kubectl >/dev/null || { echo "FAIL: kubectl not installed"; exit 1; }

.PHONY: start-cluster
start-cluster: check-required-tools
	minikube start

.PHONY: install-argo
install-argo: ARGO_VERSION := stable
install-argo: ARGO_INSTALL_URL = https://raw.githubusercontent.com/argoproj/argo-cd/$(ARGO_VERSION)/manifests/install.yaml
install-argo: start-cluster
	kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
	kubectl apply -n argocd -f $(ARGO_INSTALL_URL)
	kubectl wait --for=condition=available --timeout=300s -n argocd deploy/argocd-server

.PHONY: apply-root-app
apply-root-app: install-argo
	kubectl apply -f manifests/bootstrap/root.yaml

.PHONY: forward-argo-ui
forward-argo-ui:
	@kubectl get deploy -n argocd argocd-server >/dev/null 2>&1 \
		|| { echo "FAIL: argocd not installed, run 'make dev' first"; exit 1; }
	@echo "argocd ui: https://localhost:8080"
	@echo "user: admin"
	@echo "password: make print-argo-password"
	kubectl port-forward svc/argocd-server -n argocd 8080:443

.PHONY: print-argo-password
print-argo-password:
	@kubectl get secret argocd-initial-admin-secret -n argocd \
		-o jsonpath='{.data.password}' | base64 -d
	@echo

.PHONY: dev
dev: start-cluster install-argo apply-root-app
	@echo "cluster up and bootstrapped. run 'make forward-argo-ui' for the ui"

.PHONY: delete-cluster
delete-cluster:
	minikube delete
