#!/bin/bash

go get github.com/philpearl/scratchbuild

gofmt -w -s ./appdir
go tool fix ./appdir
go tool vet ./appdir
go test ./appdir
go build -o ./appdir/app ./appdir

gofmt -w -s .
go tool fix .
go tool vet .
go test
go install -v .

