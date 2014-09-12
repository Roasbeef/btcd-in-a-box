# [btcd](https://github.com/conformal/btcd)-in-a-[box](https://www.docker.com/)

## Installing The Image
* Installation instructions assume you already have ```docker``` installed. If this is not the case, then check out the [official installation docs](https://docs.docker.com/installation/) so you can get ```docker``` up and running on your machine. 

### Via The Docker Hub Registry
This repo is also hosted as an automated build repository which can be found [here](https://registry.hub.docker.com/u/roasbeef/btcd/).

To grab the lastest build of this image straight from the registry, run:
  ```
  $ sudo docker pull roasbeef/btcd
  ```
You can check that the image has been installed successfully by running:
  ```
  $ sudo docker images
  ```
You should see something like:
  ```
  REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
  *snip*
  roasbeef/btcd       latest              1b6af1fcbeef        1 second ago        651.4 MB
  ```

### Building Manually
Alternatively, if you'd like to make some additions or modifications to the ```Dockerfile```, you can build the image manually directly on your machine:
  ```
  $ sudo docker build -t="<your_user_name>/btcd:<optional_tag>" .
  ```

## Starting your btcd full-node. 
Creating and running the initial container is very simple.
Run this command to boot up your node:
  ```
  $ docker run -p 8333:8333 -d -v /root/.btcd/:/root/.btcd/ -v /root/.btcctl/:/root/.btcctl/ --name btcd roasbeef/btcd --externalip <your_external_ip_address> 
  ```
  
* A few notes about the command line arguments we've passed in here:
  * `-p 8333:8333`
    * Here we're mapping port `8333` from our host, into the container that our node is running in. This will allow our node to successfully accept incoming onnections. 
    * Note that this is the default `mainnet` port, if you'd like to run your node on `testnet3`, then pass in 18333 instead.
    * For programatically communicating with your node via RPC from other containers, check out the user guide to [link containers together](https://docs.docker.com/userguide/dockerlinks/), the ports are already privately exposed via the ```Dockerfile```. 
  * `-d`
    * Standard, run the `ENTRYPOINT` command as a daemon (i.e non-interactive).
  * `-v`
    * Now here's some `docker` coolness. `docker` containers are meant to be single-purpose, ephemeral, and loosely coupled. Allowing one to easily bring containers up and down without affecting your system's state. 
    * If we stored our blockchain data, logs, and configuration directly within the container then all of that information would be destroyed if we swapped out btcd container images. Causing us to have to re-sync the blockchain everytime.
    * So instead, we create a [volume](https://docs.docker.com/userguide/dockervolumes/) from our host to the docker container so all of this data is stored in a shared space, not unique to the container. 
    * With this flag and it's arguments, we map the two app data directories for `btcd` and `btcctl` to a local direcotry on our host machine. This allows us to build and run any btcd image we want, while perserving our logs and blockchain data outside the container's namespace. 
  * `--name`
    * Here we're simply giving our container a name. This can be used later in [linking containers](https://docs.docker.com/userguide/dockerlinks/), or starting and stopping our btcd container with:
      * ```docker start btcd``` or ```docker stop btcd```. 
  * `--externalip`
    * If you look at the ```Dockerfile``` for this image, you'll notice we've created an `ENTRYPOINT`, so we can simply used `docker run <image>`, without having to specify the command each time.
    * This also allows us to pass in arbitary arguments to configure out btcd node.
    * So we pass in what we think our external IP is, so btcd can advertise your listening address through ```addr``` responses. 

## Updating your btcd full-node. 
Although this is an unofficial image, I'm commited to keeping the image up to date to the latest state of the btcd [master branch](https://github.com/conformal/btcd).
So in order to update your node, you can simply re-pull or re-build the image. 

## Poking your node from the main host via `btcctl`
Ideally, `docker` containers should only be running one process. So we're not running an `sshd` right off the bat, which would required us also running a `supervisord` within the containers. Also, [running `sshd` within `docker` containers is considered evil](https://jpetazzo.github.io/2014/06/23/docker-ssh-considered-evil/). 

Instead, if we'd like to fire off some rpc commands to our host we can enter the `namespace` of our container and used the `btcctl` binary that's already installed in our `btcd` container. You can install `nsenter` via [this Github repo](https://github.com/jpetazzo/nsenter), and the helper script `docker-enter`. 

Once you've installed `nsenter` and optionally, `docker-enter`, you can fire off rpc requests like so:
```
$ docker-enter btcd /gopath/bin/btcctl getinfo
```
