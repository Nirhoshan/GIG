# Compile stage
FROM golang:1.18.1 AS builder
ARG DEBIAN_FRONTEND=noninteractive

# Add required packages
RUN apt -y update && apt -y install git curl bash

# Set the working directory inside the container
WORKDIR /go/src/GIG

# Copy go.mod and go.sum to the working directory
ADD go.mod go.sum ./

# Download Go modules
RUN go mod download

# Install Revel and other dependencies
RUN go install github.com/revel/cmd/revel@latest \
    && go install github.com/lsflk/gig-sdk@latest

# Ensure the Go bin directory is in the PATH
ENV PATH=$PATH:/go/bin

# Copy the entire project to the working directory
ADD . .

# Build the application
RUN revel build . /go/src/GIG/build -m prod

# Run stage
FROM golang:1.18.1
EXPOSE 9000

# Add non-root user
ARG DEBIAN_FRONTEND=noninteractive
RUN apt -y update && useradd -m -s /bin/bash appuser

# Set the working directory
WORKDIR /app

# Switch to the non-root user
USER appuser

# Copy the build from the builder stage
COPY --from=builder /go/src/GIG/build .

# Ensure required directories exist
RUN mkdir -p app/cache

# Run the application
ENTRYPOINT ["app/run.sh"]
