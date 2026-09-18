#!/bin/bash

call install

start cmd.exe /c lr -ns
call lr -O "src/wintest.osql" -o "quit;"
