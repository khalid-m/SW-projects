../bin/get_nsport.sh
NSPORT=$?
echo Using nameserverport $NSPORT
../bin/amos2 -o "nameserverport($NSPORT);" -n NS &
sleep 2
../bin/amos2 -o "nameserverport($NSPORT);" -O webamos.osql -s WEB-AMOS