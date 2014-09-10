## Installation

```
$ sudo docker build Dockerfile
$ docker run -p 8333:8333 -d -v /root/.btcd/:/root/.btcd/ -v /root/.btcctl/:/root/.btcctl/ --name btcd roasbeef/btcd
```
