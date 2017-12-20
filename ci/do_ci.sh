#!/bin/bash

# Run a CI build/test target, e.g. docs, asan.

set -e

. "$(dirname "$0")"/build_setup.sh
echo "building using ${NUM_CPUS} CPUs"
export BUILD_DIR=/build

export MIXER_BUILD_DIR="${BUILD_DIR}"/mixer
mkdir -p "${MIXER_BUILD_DIR}"

[ -z "${MIXER_SRCDIR}" ] && export MIXER_SRCDIR=/source

export MIXER_CI_DIR="${MIXER_SRCDIR}"/ci

# This is where we copy build deliverables to.
export MIXER_DELIVERY_DIR="${MIXER_BUILD_DIR}"/source/exe
mkdir -p "${MIXER_DELIVERY_DIR}"

if [[ "$1" == "bazel.dev" ]]; then
  # This doesn't go into CI but is available for developer convenience.
  echo "bazel build with tests..."
  cd "${MIXER_CI_DIR}"
  echo "Building..."
  bazel --batch build
  # Copy the MIXER-static binary somewhere that we can access outside of the
  # container for developers.
  cp -f \
    "${MIXER_CI_DIR}"/bazel-bin/source/exe/mixer-static \
    "${MIXER_DELIVERY_DIR}"/mixer-fastbuild
  echo "Building and testing..."
  bazel --batch test ${BAZEL_TEST_OPTIONS} -c fastbuild //test/...
  exit 0
else
  echo "Invalid do_ci.sh target, see ci/README.md for valid targets."
  exit 1
fi