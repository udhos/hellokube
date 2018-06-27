package main

import (
	"bytes"
	"log"
	"os"

	"github.com/philpearl/scratchbuild"
)

func main() {

	user := os.Getenv("USER")
	pass := os.Getenv("PASS")

	dir := "./appdir"

	log.Printf("USER=[%s] PASS=[%s] dir=[%s]", user, pass, dir)

	name := user + "/test"
	registry := "https://index.docker.io"

	log.Printf("will create image %s on %s", name, registry)

	o := scratchbuild.Options{
		Dir:      dir,
		Name:     name,
		BaseURL:  registry,
		Tag:      "latest",
		User:     user,
		Password: pass,
	}

	b := &bytes.Buffer{}
	if err := scratchbuild.TarDirectory(dir, b); err != nil {
		log.Fatalf("failed to tar layer. %s", err)
	}

	c := scratchbuild.New(&o)

	token, err := c.Auth()
	if err != nil {
		log.Fatalf("failed to authorize. %s", err)
	}
	c.Token = token

	log.Printf("authorized as USER=%s on %s", user, registry)

	if err := c.BuildImage(&scratchbuild.ImageConfig{
		Entrypoint: []string{"/app"},
	}, b.Bytes()); err != nil {
		log.Fatalf("failed to build and send image. %s", err)
	}

	log.Printf("uploaded image %s to %s", name, registry)
}
