SQUEAKNODE_SRC := $(shell find ./squeaknode)
VERSION := $(shell yq e ".version" manifest.yaml)

.DELETE_ON_ERROR:

all: verify

verify: squeaknode.s9pk
	embassy-sdk verify s9pk squeaknode.s9pk

install: squeaknode.s9pk
	embassy-cli package install squeaknode.s9pk

squeaknode.s9pk: manifest.yaml assets/compat/config_spec.yaml assets/compat/config_rules.yaml image.tar instructions.md
	embassy-sdk pack

image.tar: Dockerfile docker_entrypoint.sh check-web.sh
	docker build --tag start9/squeaknode/main:$(VERSION) . --load
	docker save -o image.tar start9/squeaknode/main:$(VERSION)
