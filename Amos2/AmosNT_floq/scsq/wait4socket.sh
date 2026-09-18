#!/bin/bash

while netstat -antu |grep 35021; do sleep 5;done
