# Compile stage
FROM golang:1.18.1 AS builder
ARG DEBIAN_FRONTEND=noninteractive

# Add required packages
RUN apt -y update && apt -y install git curl bash

WORKDIR /go/src/GIG

ADD go.mod go.sum ./
RUN go mod download

RUN go get -u github.com/revel/revel
RUN go get -u github.com/revel/cmd/revel
RUN go install github.com/revel/cmd/revel@latest
RUN go get -u github.com/lsflk/gig-sdk

ENV CGO_ENABLED 0 \
    GOOS=linux \
    GOARCH=amd64
ADD . .
RUN revel build "" build -m dev

# Run stage
FROM golang:1.18.1
EXPOSE 9000
ARG DEBIAN_FRONTEND=noninteractive
RUN apt -y update && useradd -m -s /bin/bash 10001


WORKDIR /app
COPY --from=builder /go/src/GIG/build .
RUN mkdir -p app && mkdir -p app/cache
# COPY config-loader.sh /app/config-loader.sh
# RUN chmod +x /app/config-loader.sh
RUN chmod +x /app/run.sh

RUN chown -R 10001:10001 /app

# Switch to the non-root user
USER 10001

ENTRYPOINT ["/app/run.sh"]
