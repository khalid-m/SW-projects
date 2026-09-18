Installation instructions: 

1. In case you don't have Python installed already (try command
'python'):
 download Python installer from http://www.python.org/download/
   
2. Set environment variable PYTHON_HOME to the Python home directory,
e.g. C:/Python27

3. Download NumPy intaller from
http://sourceforge.net/projects/numpy/files/NumPy/1.6.0b2/numpy-1.6.0b2-win32-superpack-python2.7.exe/download

4. Install Amos 2
5. Install pyamos by running install.cmd

Now you can enable foreign functions in Python by running amos2 and
call the Amos II function

Amos 1> extlang("python");

6. For regression testing, run
    test.cmd
