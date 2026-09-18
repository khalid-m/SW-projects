#!/bin/bash
echo --------------------------------------------------
echo starting  name server 
echo --------------------------------------------------

(( port = $(../bin/get_nsport.sh) ))
echo "Using nameserverport " $port

amos2 -o "nameserverport($port);" -ns &

echo --------------------------------------------------
echo starting  standalone Amos web server .....
echo --------------------------------------------------

cd $AMOS_HOME/embeddings/wsmos/AmosWebServer

gmake

nr_class_in_emb_wsmos=`ls -la $AMOS_HOME/embeddings/wsmos/ -R | grep "\.class" | wc -l`

if [ $nr_class_in_emb_wsmos -lt 14 ]; then
  for((i=0;$i<=$nr_class_in_emb_wsmos;i=$(($i+1))));do
    $AMOS_HOME/wsmed/wait.sh 1
  done
fi


WSMOS_EMB_SERVER=$AMOS_HOME/embeddings/wsmos/AmosWebServer
WSMOS_EMB_SERVER_LIB=$WSMOS_EMB_SERVER/lib/
AMOSLIBRARYPATH="-Djava.library.path="$AMOS_HOME/bin/

java $AMOSLIBRARYPATH -cp $WSMOS_EMB_SERVER:$WSMOS_EMB_SERVER_LIB/axis.jar:$WSMOS_EMB_SERVER_LIB/commons-discovery-0.2.jar:$WSMOS_EMB_SERVER_LIB/jaxrpc.jar:$WSMOS_EMB_SERVER_LIB/saaj.jar:$AMOS_HOME/bin/javaamos.jar:$WSMOS_EMB_SERVER_LIB/QuickServer.jar:$WSMOS_EMB_SERVER_LIB/commons-httpclient-3.0-rc4.jar:$WSMOS_EMB_SERVER_LIB/commons-pool.jar: org.AmosSoapServer.AmosSoapServer &

cd $AMOS_HOME/embeddings/wsmos/

WSMOS_EMB=$AMOS_HOME/embeddings/wsmos/WEB-INF/
WSMOS_EMB_LIB=$WSMOS_EMB/lib/
WSMOS_EMB_CLASSPATH=$WSMOS_EMB_LIB/activation.jar:$WSMOS_EMB_LIB/axis.jar:$WSMOS_EMB_LIB/axis-ant.jar:$WSMOS_EMB_LIB/commons-discovery-0.2.jar:$WSMOS_EMB_LIB/commons-logging-1.0.4.jar:$WSMOS_EMB_LIB/jaxrpc.jar:$WSMOS_EMB_LIB/log4j-1.2.8.jar:$WSMOS_EMB_LIB/mail.jar:$WSMOS_EMB_LIB/saaj.jar:$WSMOS_EMB_LIB/wsdl4j-1.5.1.jar:$WSMOS_EMB_LIB/xercesImpl.jar:$WSMOS_EMB_LIB/xml-apis.jar:$WSMOS_EMB_LIB/servlet-api.jar:$WSMOS_EMB_LIB/jasper-runtime.jar:$WSMOS_EMB_LIB/jsp-api.jar:$AMOS_HOME/bin/javaamos.jar

export WSDL_HOME=$AMOS_HOME/wsmed/regress/


javac -cp $WSMOS_EMB/classes:$WSMOS_EMB_CLASSPATH -d WEB-INF/classes WEB-INF/src/server/*.java

if [ $nr_class_in_emb_wsmos -lt 4 ]; then
  for((i=0;$i<=$nr_class_in_emb_wsmos;i=$(($i+1))));do
    $AMOS_HOME/wsmed/wait.sh 1
  done
fi

WSMED_REGRESS=$AMOS_HOME/wsmed/regress/
WSMED_REGRESS_LIB=$WSMED_REGRESS/lib/

javac -cp $WSMOS_EMB/classes:$WSMOS_EMB_CLASSPATH -d WEB-INF/classes WEB-INF/src/wsdlcreator/*.java

if [ $nr_class_in_emb_wsmos -lt 20 ]; then
  for((i=0;$i<=$nr_class_in_emb_wsmos;i=$(($i+1))));do
    $AMOS_HOME/wsmed/wait.sh 1
  done
fi

java $AMOSLIBRARYPATH -cp $WSMOS_EMB/classes:$WSMOS_EMB_CLASSPATH JavaAMOS amos2.dmp WEB-INF/src/amosql/server.osql

java $AMOSLIBRARYPATH -cp $WSMOS_EMB/classes:$WSMOS_EMB_CLASSPATH:$AMOS_HOME/bin/javaamos.jar JavaAMOS amos2.dmp WEB-INF/src/amosql/client.osql


nr_dumps_in_emb_wsmos=`ls -la $AMOS_HOME/embeddings/wsmos/ -R | grep "\.dmp" | wc -l`
if [ $nr_dumps_in_emb_wsmos -lt 2 ]; then
  for((i=0;$i<=$nr_dumps_in_emb_wsmos;i=$(($i+1))));do
    $AMOS_HOME/wsmed/wait.sh 1
  done
fi

echo --------------------------------------------------
echo starting  database server ....
echo --------------------------------------------------

java $AMOSLIBRARYPATH -cp WEB-INF/classes:$WSMOS_EMB_LIB/wsdl4j-1.5.1.jar:$AMOS_HOME/bin/javaamos.jar JavaAMOS "WEB-INF/wsmos.dmp" -o "nameserverport($port);register('WSMOS');listen();" &

cd $AMOS_HOME/wsmed/


echo --------------------------------------------------
echo Starting WSMED...............
echo --------------------------------------------------

gmake

echo --------------------------------------------------
echo Testing record structure and then PAP operator...............
echo --------------------------------------------------

nr_dumpsclass_in_emb_wsmos=`ls -la $AMOS_HOME/wsmed/ -R | egrep -i "\.dmp|\.class" | wc -l`
if [ $nr_dumps_in_emb_wsmos -lt 14 ]; then
  for((i=0;$i<=$nr_dumps_in_emb_wsmos;i=$(($i+1))));do
    $AMOS_HOME/wsmed/wait.sh 1
  done
fi

WSMED_LIB=$AMOS_HOME/wsmed/lib/
WSMED_CLASSPATH=classes:$WSMOS_EMB_CLASSPATH:$WSMED_LIB/castor-1.0.2.jar:$WSMED_LIB/jdom.jar

java $AMOSLIBRARYPATH -cp $WSMED_CLASSPATH JavaAMOS wsmed.dmp -o "nameserverport($port);" -O src/amosql/testcoroutine1.amosql
$AMOS_HOME/wsmed/wait.sh 3

cd $AMOS_HOME/embeddings/wsmos/AmosWebServer/
./killSoapServer.sh

cd $AMOS_HOME/wsmed/

