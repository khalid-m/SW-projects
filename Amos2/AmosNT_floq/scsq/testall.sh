#!/bin/bash

./test.sh
pushd css
./test.sh
popd
pushd generator
./test.sh
popd
pushd lr
. ./test.sh
popd
