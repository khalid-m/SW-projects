Instructions for generating input data with Mitsim for Linear Road
-----------------------------------------------

1. Download MITSIMLab from the Linear Road website.
2. Extract MITSIMLab into a folder such as /home/username/MITSIMLab
3. Make sure your system meets the requiremnts:
    * Perl--Version 5.0 or later. Install DBI, FileHandle and Math::Random modules for Perl using CPAN. 
    * PostgreSQL--7.0 or later. 
  
    * Create a PostgreSQL user with PostgreSQL administration privileges-usually created using the PostgreSQL createuser [username] command.
    * It is recommended that the PostgreSQL username and the Linux account name under which MITSIMLab will run are the same.
    * Run initdb to initialize a PostgreSQL database.
    * Run createdb [databasename] to create the PostgreSQL database you will be using.
4. Edit the mitsim.config file located in the MITSIMLab folder to update the proper database information. Make sure the following variables are properly set:
  * databasename: should match the data base name you used setting up Postgres.
  * databaseuser: should match the username used by Postgres.
  * databasepassword: should match the password for the user in step 4.
  * directoryforoutput: The directory where you'd like your MITSIM data files created. Please use the full path such as /home/username/MITSIMLab/data/
  * Note: This directory must be writable by PostgreSQL user. It is advisable that you change this directory to writable to all users before doing step 6. numberofexpressways: number of expressways you'd like MITSIMLab to generate. The system excepts any number starting at 0.5 incremented by 0.5. Thus the first three acceptable values are: 0.5, 1, 1.5.
5. Make sure that all files in MITSIMLab have execution privileges turned on in Linux.
6. If step 7 fails, the table "input" must be removed with the SQL-command "drop input;" in the program "psql databasename" (see step 4)
7. To start MITSIMLab type in "./run mitsim.config" and hit enter.
8. If you see and error like this: "libstdc++-libc6.2-2.so.3: cannot open shared object file: No such file" you probably must install an older version of libstd++. 
9. MITSIM output will be in the folder designated as the directoryforoutput above. Three ouput files: cardatapoints.out, historical-tolls.out, maxCarid.out will be needed to run the benchmark.