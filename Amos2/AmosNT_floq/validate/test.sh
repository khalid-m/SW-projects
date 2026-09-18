#!/bin/bash

if [ ! -n "$AMOS_HOME" ]; then
    echo AMOS_HOME is not set.
    exit 1
fi

./install.sh

svali -o "loadsystem('regress', 'test_validate.osql');"