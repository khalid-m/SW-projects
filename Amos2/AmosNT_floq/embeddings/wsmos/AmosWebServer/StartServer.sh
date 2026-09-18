WSMED_SERVER=$AMOS_HOME/embeddings/wsmos/AmosWebServer/
WSMED_SERVER_LIB=$WSMED_SERVER/lib/
DUMPLIBRARYPATH="-Djava.library.path=$AMOS_HOME/bin/"

java $DUMPLIBRARYPATH -cp $WSMED_SERVER:$WSMED_SERVER_LIB/axis.jar:$WSMED_SERVER_LIB/commons-discovery-0.2.jar:$WSMED_SERVER_LIB/jaxrpc.jar:$WSMED_SERVER_LIB/saaj.jar:$AMOS_HOME/bin/javaamos.jar:$WSMED_SERVER_LIB/QuickServer.jar:$WSMED_SERVER_LIB/commons-httpclient-3.0-rc4.jar:$WSMED_SERVER_LIB/commons-pool.jar: org.AmosSoapServer.AmosSoapServer &