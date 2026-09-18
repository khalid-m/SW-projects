#!/bin/bash

if [ -f config/spconfig-$HOSTNAME.osql ]
    then
    cp config/spconfig-$HOSTNAME.osql osql/spconfig.osql
    else
    echo "No host-specific spconfig found. Using default spconfig."
    cp config/spconfig-linux.osql osql/spconfig.osql
fi

../bin/scsq.exe -i ../lsp/init.lsp -o \
  "loadsystem('osql','sc.osql'); save '../bin/scsq.dmp'; quit;"
