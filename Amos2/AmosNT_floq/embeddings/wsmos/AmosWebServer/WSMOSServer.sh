WSMED_EMB=$AMOS_HOME/embeddings/wsmos/
WSMED_EMB_SERVER=$WSMED_EMB/AmosWebServer/
WSMED_EMB_SERVER_LIB=$WSMED_EMB_SERVER/lib/

LOCALCLASSPATH=$WSMED_EMB_SERVER_LIB/axis.jar:$WSMED_EMB_SERVER_LIB/commons-discovery-0.2.jar:$WSMED_EMB_SERVER_LIB/jaxrpc.jar:$WSMED_EMB_SERVER_LIB/saaj.jar:$WSMED_EMB_SERVER_LIB/QuickServer.jar:$WSMED_EMB_SERVER_LIB/commons-httpclient-3.0-rc4.jar:$WSMED_EMB_SERVER_LIB/commons-pool.jar:$AMOS_HOME/bin/javaamos.jar:.

LIBRARYPATH="-Djava.library.path=$AMOS_HOME/bin/"

java $LIBRARYPATH -classpath $LOCALCLASSPATH org.AmosSoapServer.AmosSoapServer