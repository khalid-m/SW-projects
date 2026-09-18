LOCALLIBRARYPATH="-Djava.library.path="$AMOS_HOME/bin/
WSMED_LIB=$AMOS_HOME"/wrappers/WSMED/lib"
COMPILE_CLASSPATH=$WSMED_LIB/activation.jar:$WSMED_LIB/axis.jar:$WSMED_LIB/jaxrpc.jar:$WSMED_LIB/commons-logging.jar:$WSMED_LIB/commons-discovery-0.2.jar:$WSMED_LIB/mail.jar:$WSMED_LIB/saaj-api.jar:$WSMED_LIB/saaj-impl.jar:$WSMED_LIB/xercesImpl.jar:$WSMED_LIB/wsdl4j.jar:$AMOS_HOME/bin/javaamos.jar:.

cd $AMOS_HOME && java -classpath $COMPILE_CLASSPATH wsamos.TestWebamos $USER