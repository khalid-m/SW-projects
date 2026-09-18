
pushd ..
start /min svali debs.dmp -ns
start /min svali debs.dmp -s debs
popd
amos2 -o "wait_for('debs'); quit;"

@echo -------------------
@echo MultiScan check
@echo -------------------
multiScan %AMOS_HOME%/bin/scsq.dmp
