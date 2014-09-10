## Installation

```
$ sudo docker build Dockerfile
$ docker run -d -v /root/.btcd/:/root/.btcd/ -v /root/.btcctl/:/root/.btcctl/ --name btcd roasbeef/btcd
```
