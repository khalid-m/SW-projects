
import sys, socket, ssl

def connection(host, port):
        basesocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        ssl_sock = ssl.wrap_socket(basesocket,
                                   ssl_version=ssl.PROTOCOL_SSLv3, 
                                   cert_reqs=ssl.CERT_NONE)
        state = "NOT CONNECTED"

        ssl_sock.connect((host, port))
        
        #handshake
        data = ssl_sock.read().strip()
        if data != "corenet who":
            ssl_sock.close()
            return 0
            
        ssl_sock.write("corenet Python\r\n")
        data = ssl_sock.read().strip()
	if data == "corenet welcome Python":
            state = "CONNECTED"
	    return ssl_sock
	else:
            print "Handshake fail!"
	    ssl_sock.close()
	    return 0

def client(ssl_sock):
	#initiate stream
	ssl_sock.write("CURR STREAM ALL")

	buffer = ssl_sock.read(4096)
	done = False
	
	while not done:
                if "\n" in buffer:
                    (line, buffer) = buffer.split("\n", 1)
                    #new line available:
		    yield line
                else:
                    more = ssl_sock.read(4096)
                    if not more:
                        done = True
                    else:
                        buffer = buffer + more
	while buffer:
                if "\n" in buffer:
                    (line, buffer) = buffer.split("\n", 1)
		    yield line
		else:
                    yield buffer
		    buffer = ''

def dispatch(host, port, sock):
	#get the ssl connection
	ssl_sock = connection(host, port)
	
	if ssl_sock:
		for line in client(ssl_sock):
			sock.send(line)
	else:
		print "connection failed!"

arguments = sys.argv;
if len(arguments) < 5:
    print "usage: foo.py servhost servno outhost outno"
    sys.exit(0)
servhost = arguments[1]
servno = int(arguments[2])
outhost = arguments[3]
outno = int(arguments[4])

print "reading from server: " + str(servhost) + " via port number: " + str(servno)

outsocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

outsocket.connect((outhost, outno))

msg = outsocket.recv(1024).strip()
if msg != "START":
    outsocket.close()
else:
    print "forwarding..."
    dispatch(servhost, servno, outsocket)
