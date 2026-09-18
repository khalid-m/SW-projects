#!/bin/bash

pushd ../..
source install.sh
popd
pushd ..
source mkdmp.sh
popd
echo "Installing SCSQ-PLR"
source mkdmp.sh
