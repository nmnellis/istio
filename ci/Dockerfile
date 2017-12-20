FROM ubuntu:xenial

RUN apt-get update \
    && apt-get install -y openjdk-8-jdk make libtool m4 autoconf uuid-dev cmake golang-go curl python python-pip git \
    && echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list \
    && curl https://bazel.build/bazel-release.pub.gpg | apt-key add - \
    && apt-get update \
    && apt-get -y install bazel \
    && curl -sSL https://get.docker.com/ | sh \
    && rm -rf /var/lib/apt/lists/* 

RUN mkdir -p /go/src/istio.io/istio \
    && mkdir -p /root/.kube \
    && touch /root/.kube/config

ENV GOPATH=/go

#docker run --rm -t -i -v "/usr/local/Cellar/go/1.9.2/src/istio.io/istio:/go/istio.io/istio" istio.mixer/mixer-test:0.1 /bin/bash