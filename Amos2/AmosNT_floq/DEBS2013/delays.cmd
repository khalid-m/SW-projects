:: -Calculates the response time statistics by running through all the output files
:: -Assumes that the output files are located in /output directory
:: -Writes the report to delays.csv

call setup
call killall
call debs -o  "<'src/delays.osql';q();"