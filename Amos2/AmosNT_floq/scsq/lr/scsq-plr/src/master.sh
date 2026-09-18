#!/bin/bash

for i in `seq 0 $(expr $2 \- 1)`; do
    echo "CREATE DATABASE IF NOT EXISTS LR$1$i;" > master$i.sql
    echo "USE LR$1$i;" >> master$i.sql
    echo "source /disk1/init.sql" >> master$i.sql
    echo "truncate hist;" >> master$i.sql
    echo "LOAD DATA INFILE '$AMOS_HOME/scsq/lr/scsq-plr/src/Historical_partition$i' INTO TABLE hist FIELDS TERMINATED BY ',';" >> master$i.sql
    (mysql -u root --protocol=tcp -P $(expr 13306 \+ $i) < master$i.sql &)	
done
