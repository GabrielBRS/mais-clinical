UV ?= uv
CONTEXT := kind-orzyon
IMAGE ?= orzyon/platform:0.1.0
.PHONY: bootstrap cluster-up cluster-down deploy test lint status logs clean serve image
bootstrap:
	$(UV) sync --frozen
serve:
	$(UV) run uvicorn orzyon.api:create_app --factory --host 127.0.0.1 --port 8000 --no-access-log
cluster-up:
	kind create cluster --name orzyon --config kubernetes/kind.yaml
image:
	docker build -t $(IMAGE) .
deploy: image
	kind load docker-image $(IMAGE) --name orzyon
	kubectl --context $(CONTEXT) apply -f kubernetes/namespace.yaml
	helm upgrade --install orzyon helm/platform --kube-context $(CONTEXT) -n orzyon --wait --atomic --timeout 3m
test:
	$(UV) run pytest -q
lint:
	$(UV) run ruff check .
	$(UV) run ruff format --check .
	$(UV) run mypy src
	helm lint helm/platform
	helm template orzyon helm/platform -n orzyon
status:
	kubectl --context $(CONTEXT) -n orzyon get pods,deploy,svc
logs:
	kubectl --context $(CONTEXT) -n orzyon logs deployment/orzyon-platform --tail=100
cluster-down:
	@test "$(CONFIRM)" = "delete-orzyon" || (echo "Requires human approval: make cluster-down CONFIRM=delete-orzyon"; exit 1)
	kind delete cluster --name orzyon
clean:
	@test "$(CONFIRM)" = "uninstall-orzyon" || (echo "Requires human approval: make clean CONFIRM=uninstall-orzyon"; exit 1)
	helm uninstall orzyon --kube-context $(CONTEXT) -n orzyon
