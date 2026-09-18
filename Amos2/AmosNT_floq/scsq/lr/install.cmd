if exist lr.dmp del lr.dmp
if exist historylr.dmp del historylr.dmp
if exist scsq.dmp del scsq.dmp
pushd ..
call install
popd
call mkdmp
