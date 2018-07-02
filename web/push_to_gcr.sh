#!/bin/bash

msg() {
        echo >&2 $0: $@
}

die() {
        msg $@
        exit 1
}

mkdir eraseme

cat >eraseme/Dockerfile <<__EOF__ || die could not create Dockerfile
FROM udhos/web:latest
ENV PORT 8888
CMD ["/gowebhello -addr 8888"]
__EOF__

pushd eraseme || die could not enter dir

project_id="$(gcloud config get-value project -q)"

docker build -t gcr.io/$project_id/web:v1 .

docker push gcr.io/$project_id/web:v1

popd

echo test with: docker run --rm -p 8888:8888 gcr.io/$project_id/web:v1
