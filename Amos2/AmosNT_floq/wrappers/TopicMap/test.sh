#!/bin/bash
if [ "$JENA_HOME" == "" ]; then
  echo "*******************************************************************************"
  echo "* Please set environment variable JENA_HOME first!"
  echo "* TopicMap will be be compiled or tested"
  echo "*******************************************************************************"
  exit 0
fi
gmake test
