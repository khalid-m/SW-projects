SWARD_ROOT=$(AMOS_HOME)/SWARD
LOCALLIBRARYPATH = -Djava.library.path=$(AMOS_HOME)/bin/


all: compile dump

compile:
	cd ./rdqlParser && gmake
	cd ./sparqlParser && gmake
	cd ./MVC && gmake

	cd ./src/Java/swardAPI && javac -classpath $(AMOS_HOME)/bin/javaamos.jar -d $(SWARD_ROOT)/classes RDFScan.java
	cd ./src/Java/swardAPI && javac -classpath $(SWARD_ROOT)/classes:$(AMOS_HOME)/bin/javaamos.jar -d  $(SWARD_ROOT)/classes RDFViewer.java
	cd ./src/Java/swardAPI && javac -classpath $(SWARD_ROOT)/classes:$(AMOS_HOME)/bin/javaamos.jar -d  $(SWARD_ROOT)/classes TestEmbed.java

	cp $(AMOS_HOME)/bin/javaamos.jar $(AMOS_HOME)/bin/sward.jar 
	cd ./classes && jar -uf $(AMOS_HOME)/bin/sward.jar *.class
	cd ./classes && jar -uf $(AMOS_HOME)/bin/sward.jar $(SWARD_ROOT)/classes/swardAPI *.class 

dump:
	sward amos2.dmp ./src/AmosQL/mkdmp.amosql

test:
	sparqlParser amos2.dmp -O$(SWARD_ROOT)/src/AmosQL/ds.amosql -L./src/lsp/h.lsp -O$(SWARD_ROOT)/src/AmosQL/h.amosql -O$(SWARD_ROOT)/src/AmosQL/sparql.amosql -O$(SWARD_ROOT)/regress/sparql.amosql -o"quit;"
	sward sward.dmp ./regress/rdql.amosql -o "quit;"
	sparqlParser amos2.dmp -O$(SWARD_ROOT)/src/AmosQL/ds.amosql -L$(SWARD_ROOT)/src/lsp/h.lsp -O$(SWARD_ROOT)/src/AmosQL/h.amosql -O$(SWARD_ROOT)/src/AmosQL/sparql.amosql -o "quit;"

	cd regress && ./test.sh