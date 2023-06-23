SHELL := /bin/bash

ifndef VERBOSE
.SILENT:
endif

CODE_DIR := chirpstack-v3-to-v4
GIT_REPO_URL := https://github.com/chirpstack/chirpstack-v3-to-v4.git
GIT_TAG := v4.0.4
GOLANG_VERSION := 1.16

IMAGE_TAG_BASE := chirpstack-v3-to-v4
IMG := ${IMAGE_TAG_BASE}:${GIT_TAG}

.PHONY: docker-build docker-push render deploy undeploy clean

docker-build:
	echo "Fetch code for build."
	if [ ! -d "${CODE_DIR}" ]; then \
		git clone ${GIT_REPO_URL}; \
	else \
		echo "${CODE_DIR} does already exist."; \
	fi

	echo "Checkout Git Tag."
	cd ${CODE_DIR} && git checkout ${GIT_TAG} && cd ..

	echo "Set Golang Version in Dockerfile."
	sed -e "s/GOLANG_VERSION/${GOLANG_VERSION}/g" Dockerfile.template > Dockerfile

	echo "Actually, build the container image."
	docker build -t ${IMG} .

docker-push:
	echo "Push the container image"
	docker push ${IMG}

render:
	cp -R configurations deployment/charts/chirpstack-v3-to-v4/
	
	sed \
	-e "s/IMAGE_TAG_BASE/${IMAGE_TAG_BASE}/g" \
	-e "s/GIT_TAG/${GIT_TAG}/g" \
	deployment/kustomization.yaml.template > deployment/kustomization.yaml

	kustomize build deployment --enable-helm > rendered.yaml

deploy:
	kubectl apply -f rendered.yaml

undeploy:
	kubectl delete -f rendered.yaml

clean:
	if [[ -d "${CODE_DIR}" ]]; then rm -rf ${CODE_DIR};fi
	if [[ -f "Dockerfile" ]]; then rm Dockerfile;fi 
	if [[ -f "deployment/kustomization.yaml" ]]; then rm deployment/kustomization.yaml;fi
	if [[ -d "deployment/charts/chirpstack-v3-to-v4/configurations" ]]; then rm -rf deployment/charts/chirpstack-v3-to-v4/configurations;fi
	if [[ -f "rendered.yaml" ]]; then rm rendered.yaml;fi 
