D=:
ifeq ($(OS),Windows_NT)
D=;
endif
amosh = ../..
wrapperdir = $(amosh)/wrappers/JDBC
package = jdbc_interface
classdir = $(wrapperdir)/$(package)
classpth = ../../bin/javaamos.jar$(D).$(D)../../Java/$(D).
classes = $(package)/ResultSetWrapper.class \
	  $(package)/JDBCInterface.class \
	  $(package)/ConnectionWrapper.class 

default: $(classes)
	jar uvf $(amosh)/bin/javaamos.jar $(classes)

$(package)/%.class: $(package)/%.java
	echo $(classpth)
	javac -classpath "$(classpth)" $<

clean: 
	rm jdbc_interface/*.class

test: $(classes) $(classdir)/Test.class
	java -cp .;$(classpth) jdbc_interface/Test
