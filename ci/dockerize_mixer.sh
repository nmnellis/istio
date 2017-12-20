#!/bin/bash

bazel --output_base=$BAZEL_OUTBASE run //mixer/docker:mixer
