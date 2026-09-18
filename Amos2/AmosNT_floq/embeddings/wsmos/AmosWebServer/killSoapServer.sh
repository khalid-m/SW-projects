PORTNUMBER="8082"
kill -9 `netstat -ntpl 2> /dev/null |grep "$PORTNUMBER" | awk '{print $7}' | cut -d / -f 1` 2> /dev/null