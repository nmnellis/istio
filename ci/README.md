# Building Istio dockers from macOS

## Get istio src.

* Download istio source
```
git clone https://github.com/istio/istio
```

## Build the Dockerfile

* Copy the Dockerfile into the istio dir, and build it
```
docker build -t istio-builder:latest -f Dockerfile .
```


## Build docker images

* Enter the istio dir:
```
cd istio-dir
```

* Use the previous docker and build the docker images:
```
docker run --rm -ti --workdir=/go/istio.io/istio \
                     -v /var/run/docker.sock:/var/run/docker.sock \
                     -v "$(pwd)/:/go/istio.io/istio/" \
                     istio-builder:latest \
                     make clean docker
```

## Enjoy your new docker images

* Check docker images:
```
docker images

REPOSITORY                                 TAG                                        IMAGE ID            CREATED             SIZE

istio/mixer/example/servicegraph/docker    servicegraph                               557f9e0dce0a        47 years ago        138MB
servicegraph                               latest                                     557f9e0dce0a        47 years ago        138MB
istio/mixer/docker                         mixer                                      f98b234d49d4        47 years ago        171MB
mixer                                      latest                                     f98b234d49d4        47 years ago        171MB
istio/mixer/docker                         mixer_debug                                c53d9c9cfa04        47 years ago        276MB
mixer_debug                                latest                                     c53d9c9cfa04        47 years ago        276MB
```