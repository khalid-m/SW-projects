pushd ..
call debszip.cmd
pscp Epic.zip udbl@udblserver1:../../wamp/www/DEBS/ 
popd
pscp index.html udbl@udblserver1:../../wamp/www/DEBS/ 

