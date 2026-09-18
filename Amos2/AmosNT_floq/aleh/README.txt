This directory contains an application which is developed as a test case of the project POQSEC.
The application is called Analysis of LHC Events for Higgs (ALEH). The goal of it is to find (select) those events that satisfy certain conditions. The filtering divided to 6 steps called cuts.
ALEH is extension of AMOS2. The extension consists of C++ code that loads data from ROOT files, osql code of the schema of the data and osql and lisp code of the cuts.
===============================================
Content of the directory
===============================================
C - C/C++ code of the project for materialized ontology with loading entire file
osql - amosql code of ALEH
lsp - alisp code of ALEH
regress - code for regression tests
aleh.dsw - VC++ workspace file of the project for materialized ontology with loading entire file
aleh.dsp = VC++ project file
simpletest.cmd - script for running regression test without using ROOT library
testmaster.cmd - master script to run regression test of ALEH over test file t.root
NOTE: mkdmp.cmd and run.cmd are NOT working
===============================================
Regression tests
===============================================
Run regression test without installing ROOT library by executing simpletest.cmd script. This test is also included in main regression test of AMOS II.
Run regression tests with ROOT library by executing testmaster.cmd script. It compiles and tests ROOT wrapper first, then it tests different implementations of ALEH. For ROOT wrapper instructions see %AMOS_HOME%\wrappers\ROOTWrap\readme.txt. Instructions for installing different implementations of ALEH see below.

===============================================
Installation and running instructions
===============================================
1. Call install.cmd (it will install ROOT wrapper, ALEH and all images)

2. Running latest stream implementation:
A. Using cost model without grouping:
Call run.stream.closed.dyngroups.cmd
Do in amos:
	cd('osql');
	<'cuts.const.stream.osql';
	expcuts();
It will execute expensive query searching for Higgs bosons according original implementation from Christian.
Or for using another query:
	cd('osql');
	<'cuts2005.stream.osql';
	expcuts();
It will execute expensive query searching for Higgs bosons according latest paper from Christian.

B. Using profiled grouping approach with profiling for 70 events
Call run.stream.closed.dyngroups.cmd
Do in amos:
	cd('osql');
	<'cuts.const.stream.osql';
	grouping(true);
	reoptimize0('expcuts->event');
	grouping(false);
	expcuts();
It will execute expensive query searching for Higgs bosons according original implementation from Christian.
Or for using another query:
	cd('osql');
	<'cuts2005.stream.osql';
	grouping(true);
	reoptimize0('expcuts->integer');
	grouping(false);
	expcuts();
It will execute expensive query searching for Higgs bosons according latest paper from Christian.

C. Using profiled grouping with profiling during execution. By default profiling will stop when no changes in join order of groups were done.
Call run.stream.profiling.cmd
Do in amos:
	cd('osql');
	<'cuts.const.stream.osql';
	grouping(true);
	reoptimize0('expcuts->event');
	profiling(true);
	expcuts(); /* Doing profiling during execution */
	unprofileall('expcuts->event');
	expcuts();
It will execute expensive query searching for Higgs bosons according original implementation from Christian.
Or for using another query:
	cd('osql');
	<'cuts2005.stream.osql';
	grouping(true);
	reoptimize0('expcuts->integer');
	profiling(true);
	expcuts(); /* Doing profiling during execution */
	unprofileall('expcuts->integer');
	expcuts();
It will execute expensive query searching for Higgs bosons according latest paper from Christian.

D. Without any cost model, i.e. MAN and UNOPT approaches.
Call run.stream.closed.limited.cmd
Do in amos:
	cd('osql');
	<'cuts.const.stream.nohints.osql';
	optallcuts(); /* MAN */
	expcuts(); /* UNOPT, will run for more than 800 seconds */

===============================================
OLD Installation and running instructions
===============================================

Install ROOT library and compile ROOT wrapper. See instructions in %AMOS_HOME%\wrappers\ROOTWrap\readme.txt

A. Materialized onltology with loading entire file

  1. Compile ALEH in MS project or export make file with dependencies and execure compile script.

  2. Create impage file by executing  mkdmp.load.cmd

  3. Running (also see examples in regress/materialized.load.osql)
	Start aleh aleh_load.dmp
	You can investigate how many data in a ROOT file and load it by:
	no_root_objects("path\name"); - returns number of elements in the file
	load_root_file("path\name"); - loads all file to ALEH (can take time, one minute for 25 000), 
						returns how many elements were loaded
	load_root_file("path\name",int begin, int end); - loads subset of elements within start-end range. 
					E.g., to read all file with 25000 elements set start=0, end=24999. 
					Returns how many elements were loaded
	Execute cuts, e.g. 
		select id(e) from event e, parameters g where e=optallcuts(e,g);
	For other cuts see section Cuts at the end of this readme.

  4. Running regression test: regress.load.cmd

B. Streamed without ontology

  1. Create image file by executing mkdmp.basic.cmd script

  2. Running (also see examples in regress/basic.osql)
	Start ..\wrappers\rootwrap\rootwrap aleh_basic.dmp
	Execute cuts, e.g.
		count(select vkey from vector vkey, vector v, parameters g where 
		<vkey,v> = aleh_access("../wrappers/ROOTWrap/t.root") and 
		vkey=threeleptoncut(vkey,v,g));
	For other cuts see section Cuts at the end of this readme.

  3. Running regression test: regress.basic.cmd

C. Streamed with materialized ontology

D. Derived hierarchical ontology
Not ready

E. Derived non-hierarchical ontology
Not ready

F. Materialized ontology and optimization strategies described in the paper
   R.Fomkin, T.Risch "Dynamic group cost model for scientific queries"

F1. Limited simple cost model. All aggregates have same cost, all numerical
    UDFs have same cost

  1. Create image file by executing mkdmp.load.cost_model.limited.cmd

  2. To start it execute: aleh aleh_load.cost_model.limited.dmp
	For example of cuts to run see cuts.const.nohints.osql, where they are
	defined in.

  3. Running regression test: regress.load.cost_model.limited.cmd

F2. Complete static cost model for aggregates and numerical operations.

  1. Create image file by executing mkdmp.load.cost_model.static.cmd

  2. To start it execute: aleh aleh_load.cost_model.static.dmp
	For example of cuts to run see cuts.const.osql, where they are
	defined in.

  3. Running regression test: regress.load.cost_model.static.cmd

F3. Dynamic group cost model.

  1. Create image file by executing mkdmp.load.cost_model.dynamic.cmd

  2. To start it execute: aleh aleh_load.cost_model.dynamic.dmp
	For example how to run the dynamic group cost model see
	expriments/script.fdc.samples.osql. For example of cuts to run 
	see cuts.grouped.const.osql, where they are defined in. 

  3. Running regression test: regress.load.cost_model.dynamic.cmd


=======================================================
Cuts
=======================================================
With ontology:
threeleptoncut(event,parameters)->event - very cheap query
zvetocut(event,parameters)->event - very expensive query
topcut(event,parameters)->event - extremly expensive query
jetvetocut(event,parameters)->event - extremely expensive query
leptoncuts(event,parameters)->event - cheap query
misseecuts(event,parameters)->event - expensive query
allcuts(event,parameters)->event - applies all cuts in the same order as Christian does, 
						but not in optimal order
optallcuts(event,parameters)->event - applies all cuts in the optimal order

Without ontology:
threeleptoncut(vector v_key, vector props,parameters)->vector v_key - very cheap query
zvetocut(vector v_key, vector props,parameters)->vector v_key - very expensive query
topcut(vector v_key, vector props,parameters)->vector v_key - extremly expensive query
jetvetocut(vector v_key, vector props,parameters)->vector v_key - extremely expensive query
leptoncuts(vector v_key, vector props,parameters)->vector v_key - cheap query
misseecuts(vector v_key, vector props,parameters)->vector v_key - expensive query
allcuts(vector v_key, vector props,parameters)->vector v_key - applies all cuts in the same order 
									as Christian does, but not in optimal order
optallcuts(event,parameters)->vector v_key - applies all cuts in the optimal order
