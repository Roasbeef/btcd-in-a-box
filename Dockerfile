FROM google/golang

MAINTAINER Olaoluwa Osuntokun <laolu32@gmail.com>

# Grab and install the latest version of btcd and it's dependencies.
RUN go get github.com/btcsuite/btcd/...

# Expose mainnet listening port.
EXPOSE 8333

# Expose mainnet rpc port.
EXPOSE 8334

# Expose mainnet wallet rpc port.
EXPOSE 8332

# Expose testnet listening port. 
EXPOSE 18333

# Expose testnet rpc port.
EXPOSE 18334

# Expose testnet wallet rpc port.
EXPOSE 18332

RUN mkdir /root/.btcd
RUN mkdir /root/.btcctl

CMD []
ENTRYPOINT ["/gopath/bin/btcd"]
