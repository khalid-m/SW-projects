@echo off
pushd regress
amos2 cutstest.osql -o "quit;"
amos2 cutstest.load.paper.osql -o "quit;"
popd
