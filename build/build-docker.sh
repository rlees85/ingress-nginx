#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

BASE="$(git rev-parse --show-toplevel)"

sudo docker pull golang

ARCH="amd64"
PKG="k8s.io/ingress-nginx"
REPO_INFO="$(git config --get remote.origin.url)"
GIT_COMMIT="git-$(git rev-parse --short HEAD)"

declare -a mandatory
mandatory=(
  PKG
  ARCH
  GIT_COMMIT
  REPO_INFO
  TAG
)

missing=false
for var in "${mandatory[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Environment variable $var must be set"
    missing=true
  fi
done

if [ "$missing" = true ]; then
  exit 1
fi

sudo docker run --env "CGO_ENABLED=0"            \
                --env "GOPATH=/go"               \
                --env "ARCH=${ARCH}"             \
                --env "TAG=${TAG}"               \
                --env "PKG=${PKG}"               \
                --env "REPO_INFO=${REPO_INFO}"   \
                --env "GIT_COMMIT=${GIT_COMMIT}" \
                -v "${BASE}:/go/k8s.io/ingress-nginx"  \
                -w "/go/k8s.io/ingress-nginx"    \
                --rm -t -i golang make build

export ARCH

make container
