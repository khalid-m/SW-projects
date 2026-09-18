#!/bin/bash
source ../system/Linux/testenv.sh

parameters=$*
# no arguments => check all variables
if [ "$#" == 0 ]; then
  parameters="java wrappers sward"
fi

warning_variable "JENA_HOME" "wrappers"

error_variable "AMOS_HOME"
error_variable "MYSQL_HOME" "sward wrappers lr-mysql"
error_variable "JAVA_HOME" "java lr-java"

gmake $@