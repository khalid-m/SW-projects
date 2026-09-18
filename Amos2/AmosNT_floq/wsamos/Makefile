LOCALLIBRARYPATH = -Djava.library.path=$(AMOS_HOME)/bin/
WSMED_LIB=$(AMOS_HOME)/wrappers/WSMED/lib

CLIENT_CLASSPATH=$(WSMED_LIB)/axis.jar:$(WSMED_LIB)/jaxrpc.jar:$(WSMED_LIB)/commons-logging.jar:$(WSMED_LIB)/commons-discovery-0.2.jar:$(WSMED_LIB)/saaj-api.jar:$(WSMED_LIB)/saaj-impl.jar:$(WSMED_LIB)/xercesImpl.jar:$(WSMED_LIB)/wsdl4j.jar:$(AMOS_HOME)/bin/javaamos.jar:
SERVICE_CLASSPATH=$(CLIENT_CLASSPATH):$(WSMED_LIB)/activation.jar:$(WSMED_LIB)/mail.jar:.

DEPLOY_DIR=$(AMOS_HOME)/embeddings/wsmos/WEB-INF
all: client

client:
	javac -classpath $(CLIENT_CLASSPATH) *.java

service:
	cd ../ && javac -g wsamos/Webamos.java
	cd ../ && java -classpath $(SERVICE_CLASSPATH) org.apache.axis.wsdl.Java2WSDL -o webamos.wsdl -l "%my_http%:8080/axis/services/Webamos" -n "urn:WSAmos" -p"wsamos" "urn:WSAmos" wsamos.Webamos
	cd ../ && java -classpath $(SERVICE_CLASSPATH) org.apache.axis.wsdl.WSDL2Java -o . -d application -s -S true -Nurn:WSAmos wsamos webamos.wsdl
	cd ../ && javac -classpath $(SERVICE_CLASSPATH) wsamos/*.java
	cp *.class $(DEPLOY_DIR)/classes/


clean:
	rm ./*.class