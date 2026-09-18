WSMED_ROOT=$AMOS_HOME/wsmed
WSMED_LIB=$WSMED_ROOT/lib

COMPILE_CLASSPATH=$AMOS_HOME/bin/javaamos.jar:classes:$WSMED_LIB/xercesImpl.jar:$WSMED_LIB/jdom.jar:$WSMED_LIB/qname.jar:$WSMED_LIB/wsdl4j.jar:$WSMED_LIB/castor-1.0.2.jar:$WSMED_LIB/saaj-api.jar:$WSMED_LIB/jaxp-api.jar:$WSMED_LIB/jax-qname.jar:$WSMED_LIB/jaxm-api.jar

LOCALLIBRARYPATH="-Djava.library.path="$AMOS_HOME/bin/

java $LOCALLIBRARYPATH -classpath $COMPILE_CLASSPATH JavaAMOS wsmed.dmp -o "load_lisp('src/lisp/ff_receive_dynamic_mixed_co.lsp'); load_lisp('src/lisp/pardecom_ff_dynamic_mixed_co.lsp');"
