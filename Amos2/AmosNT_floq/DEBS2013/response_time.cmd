:: -Calculates the response time by running through all the output files
:: -Assumes that the output files are located in /output directory
:: -Writes the report to /output/response_time.csv

call killall
call debs -o  "<'src/response_time.osql';q();"