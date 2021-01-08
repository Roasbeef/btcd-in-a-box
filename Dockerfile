FROM golang:1.15.6-alpine as builder

MAINTAINER Olaoluwa Osuntokun <laolu32@gmail.com>

# Force Go to use the cgo based DNS resolver. This is required to ensure DNS
# queries required to connect to linked containers succeed.
ENV GODEBUG netdns=cgo

# Pass a tag, branch or a commit using build-arg.  This allows a docker
# image to be built from a specified Git state.  The default image
# will use the Git tip of master by default.
ARG checkout="master"

# Install dependencies and build the binaries.
RUN apk add --no-cache --update alpine-sdk \
    git

# Install supplementary Go cryptography libraries
RUN go get -u golang.org/x/crypto/...

# Build btcd
RUN  git clone https://github.com/btcsuite/btcd /go/src/github.com/btcsuite/btcd \
&&  git clone https://github.com/btcsuite/btcutil.git /go/src/github.com/btcsuite/btcutil \
&&  cd /go/src/github.com/btcsuite/btcd \
&&  git checkout $checkout \
&&  GO111MODULE=on go install -v . ./cmd/...

# Generate an automatic RPC conf.
ADD initrpc.go /root
WORKDIR /root
RUN go build -o gen-config


# Start a new, final image.
FROM alpine as final

# Define a root volume for data persistence.
VOLUME /root/.btcd
VOLUME /root/.btcctl

# Add bash, jq and ca-certs, for quality of life and SSL-related reasons.
RUN apk --no-cache add \
    bash \
    ca-certificates

# Copy the binaries from the builder image.
COPY --from=builder /go/bin/btcd /bin/
COPY --from=builder /root/gen-config /bin/

# wallet, p2p, and rpc
EXPOSE 8332 8333 8334

# testnet wallet, p2p, and rpc
EXPOSE 18332 18333 18334

WORKDIR /root
RUN gen-config
 
ENTRYPOINT ["btcd"]
