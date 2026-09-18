export NSPORT := $(shell ../bin/get_nsport.sh)
export mexi=1

all: load setup test xtree run_java kill nbg aleh datamining scsq css lr
load:
	make -C ../system/Unix

setup:
	@echo Using nameserverport $(NSPORT)
	../bin/amos2 -o "nameserverport($(NSPORT));" -O it1.osql -n foo&
	sleep 2
	../bin/amos2 -o "nameserverport($(NSPORT));" -O it2.osql -s fie&
	sleep 2
remoteeval:
	alisp -L remoteeval.lsp
test:
#	../bin/amos2 -O testin.osql

	../bin/amos2 -o "<'test.osql'; quit;"
	../bin/amos2 -o "nameserverport($(NSPORT)); <'remote.osql'; quit;"
	../bin/amos2 -o "nameserverport($(NSPORT)); <'remote.osql'; quit;" # testing rollback of connections
	../bin/amos2 -o "nameserverport($(NSPORT)); <'test_jiis_example.osql'; quit;"
	../bin/amos2 -o "nameserverport($(NSPORT)); <'mdb.osql'; quit;"

coro:
	cd ../system/C/regress && make

java:	setup run_java

run_java:
	cd ../Java && make test2

kill:
	../bin/amos2 -o "nameserverport($(NSPORT));" -O shutdown.osql

nbg: 
	./nbgtest.sh

aleh:
	../aleh/simpletest.sh

sward:
	cd ../SWARD && make
	cd ../SWARD && make test

topicmap:
	cd ../wrappers/TopicMap && ./test.sh

datamining:
	cd ../applications/DataMining && make

scsq:
	cd ../scsq && ./test.sh

ezgen:
	cd ../scsq/generator && ./test.sh

css:
	cd ../scsq/css && ./test.sh

lr: lr-basic lr-mysql

lr-java: lr-installall lr-jdbc

lr-install:
	cd ../scsq/lr && ./install.sh

lr-installall:
	cd ../scsq/lr && ./installall.sh

lr-basic:
	cd ../scsq/lr && bash ./test.sh

lr-jdbc:
	cd ../scsq/lr && ./mytest.sh

lr-mysql:
	cd ../scsq/lr/mysql && ./install.sh && ./test.sh

wrappers:
	cd ../wrappers && make test

wsmed:
	cd ../wsmed && ./regress.sh

xtree:
	cd ../extenders/XTREE/regress && source ./regress.sh
