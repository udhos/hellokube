#!/bin/bash

msg() {
	echo >&2 `basename $0`: $@
}

die() {
	msg $@
	exit 1
}

# CGO_ENABLED=0 creates a statically linked binary
CGO_ENABLED=0 go build -o hello-app main.go

[ -x hello-app ] || die 

project_id="$(gcloud config get-value project -q)"

msg project_id=$project_id

docker build -t gcr.io/$project_id/hello-app:v1 .

docker images

msg pushing image

gcloud auth configure-docker

docker push gcr.io/$project_id/hello-app:v1
