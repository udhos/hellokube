#!/bin/bash

msg() {
        echo >&2 $0: $@
}

die() {
        msg $@
        exit 1
}

[ -n "$PORT" ] || die missing env var PORT=$PORT

[ "$#" -eq 1 ] || die usage: $0 tag
tag=$1

mkdir eraseme

cat >eraseme/Dockerfile <<__EOF__ || die could not create Dockerfile
FROM udhos/web:latest
ENV PORT 8888
ENTRYPOINT ["/gowebhello", "-addr", ":$PORT", "-banner", "tag=$tag"]
__EOF__

pushd eraseme || die could not enter dir

project_id="$(gcloud config get-value project -q)"

docker build -t gcr.io/$project_id/web:$tag .

docker push gcr.io/$project_id/web:$tag

popd

echo test with: docker run --rm -p $PORT:$PORT gcr.io/$project_id/web:$tag
