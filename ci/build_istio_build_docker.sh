#!/bin/bash

docker build -t "istio/istio-build-ubuntu:latest" -f ci/Dockerfile .

#bazel --output_base=/tmp/istio-docker-build run //mixer/docker:mixer