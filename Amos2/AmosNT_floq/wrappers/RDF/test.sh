#!/bin/bash
source ../../system/Linux/testenv.sh
parameters=$*
error_variable "JENA_HOME"
make test
