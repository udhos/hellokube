#!/bin/bash

msg() {
	echo >&2 $0: $@
}

die() {
	msg $@
	exit 1
}

env_var() {
	die missing env var USER=$USER PASS=$PASS PORT=$PORT
}

[ -n "$USER" ] || env_var
[ -n "$PASS" ] || env_var
[ -n "$PORT" ] || env_var

go get github.com/philpearl/scratchbuild
go get github.com/udhos/gowebhello

go install github.com/philpearl/scratchbuild/cmd/scratch || die install scratch failed
CGO_ENABLED=0 go install github.com/udhos/gowebhello || die install gowebhello failed

mkdir -p tmp || die mkdir failed
cp ~/go/bin/gowebhello tmp || die cp failed

scratch -dir ./tmp -entrypoint "/gowebhello -addr :$PORT" -name $USER/web -regurl https://index.docker.io -user $USER -password $PASS -tag latest

docker pull $USER/web

docker run --rm -p $PORT:$PORT $USER/web
