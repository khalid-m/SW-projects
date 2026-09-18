This folder contains examples of extensions to SVALI.

csvwrapper.c: Implementation of foreign function in C
                 my_csv_tuples(Charstring file) -> Stream of Numarray
              to read file with scaled CSV tuples as a stream of Numarrays

numtuples.c: Implementation of foreign function in C
                numtuples(Number delay) -> Stream of Numarray
             to generate numarray of integer triples (ts, id, rnd)
             where ts: number of microseconds since stating the stream
                   id: tuple number in stream
                   rnd: random integer

signatures.osql: Registering the foreign functions above.

csvwrapper folder: Microsoft Visual Studio 6.0 project to complie
csvwrapper.c into ../bin/csvwrapper.dll

numtuples folder: Microsoft Visual Studio 6.0 project to complie
numtuples.c into ../bin/numtuples.dll

To use the foreing functions do the following:

1. Goto folder ../bin

2. svali

3. < '../extensions/signatures.osql'; /* Load stream function definition */

4. save "myimage.dmp"; /* Save local database with all meta-data */

5. quit; /* Quit svali */

rem Start svali with the new local database:
svali myimage.dmp 

set :s = my_csv_stream("../extensions/humbledata.csv"); 
         /* :s is stream handle */

in(:s); /* Run the entire stream */

set :s2 = numtuples(0.5); /* Stream of random tuple values */

in(:s2);
