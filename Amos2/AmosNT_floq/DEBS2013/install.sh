#!/bin/bash

cd ../validate
./install.sh
cd ../DEBS2013
make clean
make
./mkdmp.sh