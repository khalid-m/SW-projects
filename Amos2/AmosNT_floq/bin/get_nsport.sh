#!/bin/bash

# Default Amos2 nameserver port
(( port=35021 ))

# Silently (>> /dev/null) see if the port is free, 
# otherwise increase counter to find a free port
while netstat -antu | grep $port >> /dev/null
do
  (( port += 1 ))
done

echo $port
