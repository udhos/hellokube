FROM alpine:latest
COPY hello-app .
ENV PORT 8080
CMD ["/hello-app"]
