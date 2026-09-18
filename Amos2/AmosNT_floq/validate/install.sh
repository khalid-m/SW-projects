#!/bin/bash

if [ ! -n "$AMOS_HOME" ]; then
echo AMOS_HOME is not set.
exit 1
fi

	cd ../scsq
	./install.sh
	cd ../validate
	make
	. ./mkdmp.sh
