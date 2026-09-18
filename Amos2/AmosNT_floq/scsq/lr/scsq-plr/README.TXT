In order to run scsq-plr with daily expenditure queries enabled 
first seververa (e.g. 2) mysql instances have to be running. 
Then the partitioned Historical data has to be bulk loaded in to the instances.
Finally by running startpeer.sh the system is executed.

1. How to install more than one instance of MySQL

        1-0.    Make the follwoing folders in your home directory:
                    ~/mysqld and ~/mysqld/tmp

	1-1.    Modify the file ./src/my.cnf so that it contains all
   	        the ,configurations for different instances. Then
   	        place it in your home folder.

	1-2.	Create one MySQL data directory for each MySQL instance, e.g.
                     /disk1/torerisc/mysqld/data
                     /disk2/torerisc/mysqld/data
                     
                Goto the mysql home folder and install MySQL default tables 
                on each data partition. For example:
 	        ./scripts/mysql_install_db --datadir=/disk1/torerisc/mysqld/data
                ./scripts/mysql_install_db --datadir=/disk2/torerisc/mysqld/data
	1-3.	Start multiple MySQL instances based my.cnf, for example:
	mysqld_multi --defaults-file=/local/home/torerisc/my.cnf start

	1-4.	Check the status of the instances:
	mysqld_multi --defaults-file=/local/home/torerisc/my.cnf report
                It should report:
                  MySQL server from group: mysqld1 is running
                  MySQL server from group: mysqld2 is running           
                If there is a problem look in the log file:
                    ~/mysqld/multi.log

2. Generate Historical data:
	Compile src/History_data.java in java.
        Then run java History_data L P, for example
              java History_data 10 2 
        where L is the number of expressways and P is the number of
        partitions.  Make sure '.' is in the CLASSPATH.

3. Bulk loading the historical data into mysql tables:

	Step 2 will generate a number of Historical data files based
        on the L rating provided. For bulk loading these values run
        src/master.sh script with the express way value and the number
        of partitions as an argument for example for L=10 with two
        partitioned database: source master.sh 10 2
 
	Bare in mind that the databases created are called LR100 and
	LR101 for L=10 and 2 partitions, these names are needed for
	editing src/mkdmp.osql.  Wait until data is loaded. It is
	loaded when the processed named 'mysql' are finished.

4. Running scsq-plr

	Before running scsq-plr you must edit the file src/mkdmp.osql
        for the number of partition needed (currently 2), First set
        the environment variable TMPDIR to your scratch folder.  Also
        make sure the JDBC diriver for MySQL is in your CLASSPATH,
        e.g. $AMOS_HOME/jarlib/mysql-connector-java-5.1.6-bin.jar Then
        run the 
          mkdmp.sh 
        script to install scsq-plr data image.  Run
          startPeer.sh P 
        with P the number of partitions, and you are in
        SSCQ top loop, for example: 
          source startPeer.sh 2

5. Run the experiments

	to run the experiment run the following SCSQ command:
	  DexpFull(Input binary file, L, M, W, Outputname); 
        where L is the input file L rating, 
              M is the stream multiplyer; the actuial L rating will be L*M
              W is the number of window splitters, 
	      Outputname names the prefix of the output files
        For example, the following file is the last 11 minutes for L=2
	DexpFull('/local/home/torerisc/AmosNT/scsq/lr/data/cdplast11mins.bin',
	2, 5, 4, 'lrout');

        Exit with 
         kill_the_federation();
        so that all the running peers are killed!


6. You can inspace the generated log files in the scratch folder,
   e.g. lrout-dexp, lrout-