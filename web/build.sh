#!/bin/bash

msg() {
	echo >&2 $0: $@
}

die() {
	msg $@
	exit 1
}

env_var() {
	die missing env var PORT=$PORT
}

[ -n "$PORT" ] || env_var

go get github.com/philpearl/scratchbuild
go get github.com/udhos/gowebhello

go install github.com/philpearl/scratchbuild/cmd/scratch || die install scratch failed
CGO_ENABLED=0 go install github.com/udhos/gowebhello || die install gowebhello failed

mkdir -p tmp || die mkdir failed
cp ~/go/bin/gowebhello tmp || die cp failed

url=https://index.docker.io
if [ -n "$URL" ]; then
	url="$URL"
fi

msg registry URL=$url

if [ -n "$TOKEN" ]; then
	auth="-token $TOKEN"
else 
	[ -n "$USER" ] || die missing env var USER=$USER
	[ -n "$PASS" ] || die missing env var PASS=$PASS
	auth="-user $USER -password $PASS"
fi

msg auth: $auth

scratch -dir ./tmp -entrypoint "/gowebhello -addr :$PORT" -name $USER/web -regurl $url -tag latest $auth

docker pull $USER/web

docker run --rm -p $PORT:$PORT $USER/web


