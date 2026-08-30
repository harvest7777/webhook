SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
.DELETE_ON_ERROR:
.DEFAULT_GOAL := help

ARGO_VERSION := stable
ARGO_INSTALL_URL := https://raw.githubusercontent.com/argoproj/argo-cd/$(ARGO_VERSION)/manifests/install.yaml

.PHONY: help
help: ## list all targets
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

.PHONY: preflight
preflight: ## verify required tools are installed and running
	@command -v docker >/dev/null || { echo "FAIL: docker not installed"; exit 1; }
	@docker info >/dev/null 2>&1 || { echo "FAIL: docker daemon not running"; exit 1; }
	@command -v minikube >/dev/null || { echo "FAIL: minikube not installed"; exit 1; }
	@command -v kubectl >/dev/null || { echo "FAIL: kubectl not installed"; exit 1; }

.PHONY: cluster
cluster: preflight ## start the minikube cluster
	minikube start

.PHONY: argo-install
argo-install: cluster ## install argocd into the cluster
	kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
	kubectl apply -n argocd -f $(ARGO_INSTALL_URL)
	kubectl wait --for=condition=available --timeout=300s -n argocd deploy/argocd-server

.PHONY: argo-bootstrap
argo-bootstrap: argo-install ## apply the root app-of-apps
	kubectl apply -f manifests/bootstrap/root.yaml

.PHONY: argo-forward
argo-forward: ## port-forward the argocd ui to localhost:8080
	@kubectl get deploy -n argocd argocd-server >/dev/null 2>&1 \
		|| { echo "FAIL: argocd not installed, run 'make dev' first"; exit 1; }
	@echo "argocd ui: https://localhost:8080"
	@echo "user: admin"
	@echo "password: make argo-password"
	kubectl port-forward svc/argocd-server -n argocd 8080:443

.PHONY: argo-password
argo-password: ## print the argocd admin password
	@kubectl get secret argocd-initial-admin-secret -n argocd \
		-o jsonpath='{.data.password}' | base64 -d
	@echo

.PHONY: dev
dev: cluster argo-install argo-bootstrap ## bring up the full local environment
	@echo "cluster up and bootstrapped. run 'make argo-forward' for the ui"

.PHONY: down
down: ## destroy the cluster
	minikube delete
