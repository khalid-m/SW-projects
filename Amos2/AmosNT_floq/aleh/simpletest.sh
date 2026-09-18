#!/bin/bash
pushd ../aleh/regress
../../bin/amos2 cutstest.osql -o "quit;"
../../bin/amos2 cutstest.load.paper.osql -o "quit;"
popd
