FROM google/golang

MAINTAINER Olaoluwa Osuntokun <laolu32@gmail.com>

# Grab and install the latest, stable version of btcd and it's dependencies.
RUN go get github.com/conformal/btcd/...

# Expose mainnet listening port.
EXPOSE 8333/tcp:8333/tcp

# Expose mainnet rpc port.
EXPOSE 8334/tcp:8334/tcp

# Expose mainnet wallet rpc port.
EXPOSE 8332/tcp:8332/tcp

# Expose testnet listening port. 
EXPOSE 18333/tcp:18333/tcp

# Expose testnet rpc port.
EXPOSE 18334/tcp:18334/tcp

# Expose testnet wallet rpc port.
EXPOSE 18332/tcp:18332/tcp

RUN mkdir /root/.btcd
RUN mkdir /root/.btcctl

#ADD btcd.conf    /root/.btcd/btcd.conf
#ADD btcctl.conf  /root/.btcctl/btcctl.conf

CMD []
ENTRYPOINT ["/gopath/bin/btcd"]
