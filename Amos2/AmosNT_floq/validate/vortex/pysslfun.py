# -*- coding: utf-8 -*-
"""
Created on Wed Oct 26 11:01:13 2011

@author: ds38298 chengxu
"""

import sys, socket, ssl, pprint, json, collections

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
	ssl_sock.write("STREAM ALL")

	buffer = ssl_sock.read(4096)
	done = False
	
	while not done:
                if "\n" in buffer:
                    (line, buffer) = buffer.split("\n", 1)
                    #new line available:
		    yield line
		    #yield convert(json.loads(line))
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
		    #yield convert(json.loads(line))
		else:
                    yield buffer
                    #yield convert(json.loads(buffer))
		    buffer = ''

def json_client(host, port):
	#get the ssl connection
	ssl_sock = connection(host, port)
	
	if ssl_sock:
		for line in client(ssl_sock):
			yield convert(json.loads(line))
	else:
		print "connection failed!"

def record():
	return convert(json.loads("{\"data}\":[{\"value\":182,\"title\":\"Id\"},{\"value\":0,\"title\":\"Random\"}]}"))

# converting unicode record to str record
# how to set the encoding when calling json.loads?
def convert(data):
    if isinstance(data, unicode):
        return str(data)
    elif isinstance(data, collections.Mapping):
        return dict(map(convert, data.iteritems()))
    elif isinstance(data, collections.Iterable):
        return type(data)(map(convert, data))
    else:
        return data
