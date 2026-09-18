#Here we only compile python_ext.so, which is used in other projects

CFLAGS = -shared -rdynamic -ldl -m32 -DLINUX=1 -DUNIX=1

SRCDIR = C

BINDIR=$(AMOS_HOME)/bin

SRC = amosmodule.c pyamos_init.c pycallout.c pymodule.c pyobj.c

OTHER_SRC = $(BINDIR)/libamos.a

INCLUDE = -I$(AMOS_HOME)/system/include -I$(AMOS_HOME)/C -I../include -I$(PYTHON_HOME)/Include -I$(NUMPY_HOME)/numpy/core/include/numpy

all: python_ext

python_ext: 
	cd $(SRCDIR) && gcc $(CFLAGS) -o$(BINDIR)/python_ext.so  $(INCLUDE) $(SRC) $(OTHER_SRC) 

clean:
	rm $(BINDIR)/python_ext.so

