mkdir %programfiles%\xynt
copy * "%programfiles%\xynt"
pushd %programfiles%\xynt
"%programfiles%\xynt\XYNTService" -i
popd
