EMVER := $(shell yq e ".version" manifest.yaml)
SQUEAKNODE_SRC := $(shell find ./squeaknode)
S9PK_PATH=$(shell find . -name squeaknode.s9pk -print)

.DELETE_ON_ERROR:

all: verify

verify: squeaknode.s9pk $(S9PK_PATH)
	embassy-sdk verify s9pk $(S9PK_PATH)

install: squeaknode.s9pk
	embassy-cli package install squeaknode.s9pk

squeaknode.s9pk: manifest.yaml assets/* image.tar docs/instructions.md LICENSE icon.png
	embassy-sdk pack

image.tar: Dockerfile docker_entrypoint.sh assets/utils/* ${SQUEAKNODE_SRC}
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --tag start9/squeaknode/main:${EMVER}	--platform=linux/arm64/v8 -f Dockerfile -o type=docker,dest=image.tar .

clean:
	rm -f squeaknode.s9pk
	rm -f image.tar
