WSMED_EMB=$AMOS_HOME/embeddings/wsmos/WEB-INF/
WSMED_EMB_LIB=$WSMED_EMB/lib/
DUMPLIBRARYPATH="-Djava.library.path=$AMOS_HOME/bin/"

java $DUMPLIBRARYPATH -cp ".:$AMOS_HOME/bin/javaamos.jar:$WSMED_EMB/classes:$WSMED_EMB_LIB/activation.jar:$WSMED_EMB_LIB/axis.jar:$WSMED_EMB_LIB/axis-ant.jar:$WSMED_EMB_LIB/commons-discovery-0.2.jar:$WSMED_EMB_LIB/commons-logging-1.0.4.jar:$WSMED_EMB_LIB/jaxrpc.jar:$WSMED_EMB_LIB/log4j-1.2.8.jar:$WSMED_EMB_LIB/mail.jar:$WSMED_EMB_LIB/saaj.jar:$WSMED_EMB_LIB/wsdl4j-1.5.1.jar:$WSMED_EMB_LIB/xercesImpl.jar:$WSMED_EMB_LIB/xml-apis.jar:%CATALINA_HOME%\common\lib\servlet-api.jar:$WSMED_EMB_LIB/jasper-runtime.jar:$WSMED_EMB_LIB/jsp-api.jar" JavaAMOS "./WEB-INF/wsmos.dmp" "WEB-INF/src/amosql/start_server.osql"
