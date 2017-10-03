#!/usr/bin/env bash

set -e

docker build -t infolinks/k8s-ingress-networks:${TRAVIS_COMMIT} .

if [[ ${TRAVIS_TAG} =~ ^v[0-9]+$ ]]; then
    docker tag infolinks/k8s-ingress-networks:${TRAVIS_COMMIT} infolinks/k8s-ingress-networks:${TRAVIS_TAG}
    docker push infolinks/k8s-ingress-networks:${TRAVIS_TAG}
    docker tag infolinks/k8s-ingress-networks:${TRAVIS_COMMIT} infolinks/k8s-ingress-networks:latest
    docker push infolinks/k8s-ingress-networks:latest
fi
