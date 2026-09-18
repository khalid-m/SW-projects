If you run on Linux do the following:

1. Download the 32 bits Java JVM.

On lux.it.uu.se Java is pre-installed under /home/thanh/jdk1.6.0_20/.

Download JVM to your home directory from 
http://user.it.uu.se/~udbl/software/JVM/jdk-6u20-linux-i586.bin

chmod +x jdk-6u20-linux-i586.bin
./jdk-6u20-linux-i586.bin

The JVM will be installed in
./jdk1.6.0_20

2. Download MySQL 5.1

On lux.it.uu.se MySQL is preinstalled under
/home/thanh/mysql-5.1.34-linux-i686-glibc23/

Download MySQL to your home directory from 
http://user.it.uu.se/~udbl/software/MySQL/mysql-5.1.34-linux-i686-glibc23.tar

tar xvf mysql-5.1.34-linux-i686-glibc23.tar

MySQL will be installed in
./mysql-5.1.34-linux-i686-glibc23


3. Add the following to your .bashrc file

On lux.it.uu.se:

export CVSROOT=:ext:<userid>@hamberg.it.uu.se:/it/project/fo/udbl/CVSRoot
export AMOS_HOME=~/AmosNT
export PATH=$PATH:~/AmosNT/bin
export JAVA_HOME=/home/thanh/jdk1.6.0_20/
export CLASSPATH=$CLASSPATH:$JAVA_HOME/lib/
export PATH=$JAVA_HOME/bin/:$PATH
export MYSQL_HOME=/home/thanh/mysql-5.1.34-linux-i686-glibc23/
export JENA_HOME=/home/thanh/Jena-2.1
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$AMOS_HOME/bin

Other computers:

export CVSROOT=:ext:<userid>@harpo.it.uu.se:/it/project/fo/udbl/CVSRoot
export CVS_SERVER=cvs
export CVS_RSH=/usr/bin/ssh
export AMOS_HOME=$HOME/AmosNT/
export JAVA_HOME=~/jdk1.6.0_20/
export CLASSPATH=$JAVA_HOME/lib/
export MYSQL_HOME=~/mysql-5.1.34-linux-i686-glibc23/
export PATH=$AMOS_HOME/bin/:$JAVA_HOME/bin/:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$AMOS_HOME/bin
export PYTHON_HOME=~/Python-2.7.3   #the directory where Python 2.7 is installed
export NUMPY_HOME=~/numpy-1.6.0  #the directory where NumPY is installed

Substitute <userid> as under Windows.

3.5 Parser for RDF as part of Jena2

On lux.it.uu.se Jena is pre-installed under
/home/thanh/Jena-2.1. 

Source:
http://user.it.uu.se/~udbl/software/Jena-2.1.zip

Purpose: Parser for 'semantic web' language RDF. Used by extension
RDFAmos.

unzip ./Jena-2.1.zip

Set variable JENA_HOME to point to its root directory:
Add the following to your .bashrc:
export JENA_HOME=~/Jena-2.1

Jena2 is required for full Amos II source code regression testing. Not
needed for simple source code installation.

REQUIRED for full regression testing.


4. Check out AmosNT

cvs checkout AmosNT

5. Compile Amos II
 cd $AMOS_HOME/system/Linux
 make
 make -f Makefile.java

6. Run regression test
  cd $AMOS_HOME/regress
  ./test.sh

7. Setup emacs for AmosNT
  edit ~/.emacs
  insert on first line file      
      (load (concat (getenv "AMOS_HOME") "/lsp/init.el"))

  This allows you to run the system under the emacs shell.
  P1 jumps to source of selected Lisp function
  P2 sends Lisp form for evaluation
  P3 sets the emacs region mark (CTRL-blank)

