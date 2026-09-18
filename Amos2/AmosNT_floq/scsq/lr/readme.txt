Instructions for running Linear Road under SCSQ
-----------------------------------------------

To run Linear Road under SCSQ a Windows based system is needed. The
testbed we used was a Windows-XP based laptop with a 1.73GHz intel
dualcore processor with 1Gb of RAM.  It was able to successfully run
Linear Road for L=1.5 (1.5 expressways).

A. Install SCSQ and Linear Road files
-------------------------------------

A1. Extract the files to directory, the 'LR home directory'. 

A2. Install the system by in the LR home directory running the scripts:

       mkhist.cmd 
    followed by
       mkdmp.cmd 

A3. Test the installation by running the script
    
      test.cmd
    
It should exit successfully after having run a small Linear Road event
sequence. At this point you have succesfully installed LR. 

The system can be run interactively by the script:

      lr.cmd

It enters a query interaction loop where you can specify SCSQL
queries.  The language is an extension of AmosQL, documented in
http://user.it.uu.se/~udbl/amos/doc/amos_users_guide.html

B. Download data used by Linear Road benchmark
----------------------------------------------

1. Ready made Linear Road datafiles for L=1.0 and L=1.5 can be found here:
	http://udbl2.it.uu.se/LR/

2. Put all data files in <lr>/data where <lr> is the Linear Road home
directory.

3. If you want to create more data files, the Linear Road data
generator can be used on a Linux system to produce the input files:

http://www.cs.brandeis.edu/%7Elinearroad/tools.html

To get the generated files on the form requiered by the SCSQ-LR engine
use the script prprocess.sh

C. Run the Linear Road benchmark on your PC
-------------------------------------------

C1. Load the historical data into the database by running one of the
scripts
 
        mkhist10.cmd for L=1.0  or
	mkhist15.cmd for L=1.5

C2. Save the full database image in file lr.dmp by running:

        mkdmp.cmd

C3. Start SCSQL query loop with the command:

        lr.cmd

C4. Run Linear Road

To run Linear Road for L=1.0 execute the SCSQL function call:

        runLR('data/cardatapoints10.out');

To run Linear Road for L=1.5 execute the SCSQL function call:

        runLR('data/cardatapoints15.out');

runLr is a foreign function in SCSQ-LR that runs the Linear Road
benchmark according to the benchmark specification. This includes
required time delays between arriving events. The very compact source
code of runLR is in file src/historytest.osql and the data provider is
in src/lread.lsp.

After the run execute the SCSQL function call:

        responsetime();

This function will produce the worst case response time for the
different queries by scanning the output event files from the latest
runLR.

After the run exit SCSQ-LR with the command: 

        quit;

C5. All output events are in the files:

        o-acc-alert    	:accident alerts
        o-t2		:accountbalances	
        o-t3		:daily expenditure
        o-tollalert	:toll alerts

These files log the output events produced by SCSQ while running
Linear Road. The outputs can be validated by running the Linear Road
validation system, which needs a Linux installation with PostGres
installed, as explained below. 

The full validation process is described next.

D. Running the Linear Road validator
------------------------------------

To run the validator a Linux-based computer is needed. See
http://www.cs.brandeis.edu/%7Elinearroad/sysreqs.html for system
requirements.

D1. Download and install the validator from the Linear Road homepage:

	http://www.cs.brandeis.edu/%7Elinearroad/tools.html

D2. Use the provided linux-script preverify.sh to transform the output
files from SCSQ to the format required by the validator.

D3. Rename the validator folder to validator-orig and apply the patch in download/validator.patch by running "patch -p0 -i ./validator.patch" in the top directory of validator-org.

D4. Follow the instructions on Linear Road homepage for the validator.


