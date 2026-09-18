#/bin/bash


mkdir /scratch/$USER
mkdir /tmp/$USER
mkdir /scratch/$USER/pgdata
initdb -D --username=$USER /scratch/$USER/pgdata
/usr/bin/pg_ctl -D /scratch/$USER/pgdata -l /tmp/$USER/dblog start

mkdir /scratch/$USER/lr
cp ~/data/* /scratch/$USER/lr

createdb validateone
 
