Installing
----------

1) Download debs.zip to some folder, e.g. C:\Epic and unzip it there.

2) Download
http://lafayette.tosm.ttu.edu/debs2013/grandchallenge/full-game.gz and
extract it into 'C:\Epic\debs\debs2013\data\full-game'.

After this the system is ready to run.

Running the DEBS Challenge
--------------------------

To run the entire DEBS Challenge script execute the command:

all.cmd

The DEBS Challenge output streams are saved in the folder 'output' as
CSV files named:

q1a.csv (current running statistics)
q1b_1M.csv (aggregate running statistics for 1 minute window)
q1b_5M.csv (aggregate running statistics for 5 minute window)
q1b_20M.csv (aggregate running statistics for 20 minute window)
q1b_landmark.csv (aggregate running statistics for the entire game)
q2playerpossession.csv
q2teampossession_1min.csv
q2teampossession_20min.csv
q2teampossession_5min.csv
q2teampossession_landmark.csv
q3_1M.csv
q3_5M.csv
q3_10M.csv
q3_landmark.csv
q4.csv


You can also run separately each of the queries with the commands:

q1.cmd
q2.cmd
q3.cmd
q4.cmd


Delay logging
-------------

The system has a facility to log the time spent in the system in order
to produce each row in the output CSV files. To run the DEBS Challenge
with this delay logging tuned on, execute:

all_delays.cmd

When delay propagation is turned on the system records when a CSV
tuple arrives into the system and propagates this timestamp
downstream. In the output CSV log files there are two extra elements
first in each row, containing i) the wall time when the latest input
CSV row that contributed to the result row arrived into the system and
ii) the wall time when the output CSV row was printed to the log
file. The wall time is defined as the number of seconds since 14:29:22
on 2013-05-17. The delay in seconds is the difference between the two
time stamps.
