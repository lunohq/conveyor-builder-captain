.PHONY: test build data

IMAGE=lunohq/conveyor-builder-captain
DATA_IMAGE=conveyor-builder-data
EMAIL=your_email@example.com
REPOSITORY=your_repo
BRANCH=master
SHA=some_sha

test: bootstrap
	docker run --privileged=true \
		--volumes-from=data \
		-e CACHE=on \
		-e REPOSITORY=${REPOSITORY} \
		-e BRANCH=${BRANCH} \
		-e SHA=${SHA} \
		-e DRY=true \
		${IMAGE}

bootstrap: build data

build:
	docker build -t ${IMAGE} .

data: data/.docker/config.json data/.ssh/id_rsa
	docker rm data || true
	docker create --name data \
		-v ${PWD}/data/.ssh:/var/run/conveyor/.ssh \
		-v ${PWD}/data/.docker/config.json:/var/run/conveyor/.docker/config.json \
		alpine:3.1 sh

data/.docker/config.json:
	cp ${HOME}/.docker/config.json data/.docker/config.json

data/.ssh/id_rsa:
	ssh-keygen -t rsa -b 4096 -C ${EMAIL} -f data/.ssh/id_rsa -P ""
