SciSPARQL  examples
===================

This folder contains scripts to demonstrate different kinds of
SciSPARQL functionality. 

Make sure the PATH variable incudes the folder '..\bin', for example
by the command:
  set path=..\bin;%path%

Run SSDM with the command:
  ssdm

The file 'talk.sparql' contains examples of SciSPARQL queries.

Some of the SciSPARQL queries require the Python engine and the Python
definitions in 'foreign.py'. To connect the Python engine to SSDM do
the following:

1. Install the Win32 Python interpreter. It can be dowloaded from
http://www.python.org/download/ or
http://user.it.uu.se/~udbl/software/python-2.7.2.msi.  The system is
tested for Python 2.7.2.

2. Test that it works by giving these commands to the SSDM top loop:

DEFINE FUNCTION plus(?a ?b) 
 AS PYTHON 'py:foreign.plus';

plus(1,3);

You can test everything in 'talk.sparql' by running:
  test.cmd


