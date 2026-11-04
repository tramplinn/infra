.PHONY: validate

validate:
	kubectl kustomize k8s/ > /dev/null
