The Amos II Python extender
===========================

This folder contains scripts to demonstrate different kinds of Amos
foreign functions implemented in Python:

foreign.py:     Foreign function implementations in Python
pythonfns.osql: Foreign function definitions and examples of use

Installation of the Amos II Python extender:
--------------------------------------------

1. Place the file python_ext.dll in Amos' 'bin' directory.

2. Install the Win32 Python interpreter. It can be dowloaded from
http://www.python.org/download/ or
http://user.it.uu.se/~udbl/software/python-2.7.2.msi.  The system is
tested for Python 2.7.2.

3. Run amos2 top loop with the commands in the file pythonfns.osql
