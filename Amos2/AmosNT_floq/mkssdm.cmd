call killall
del ssdm.zip
call mkrunnable
ren amos2.zip ssdm.zip
zip ssdm.zip bin/ssdm.dll bin/ssdm.dmp bin/ssdm.cmd bin/python_ext.dll
zip ssdm.zip ssdm/talk.ttl ssdm/talk.sparql ssdm/readme.txt ssdm/foreign.py ssdm/test.cmd

