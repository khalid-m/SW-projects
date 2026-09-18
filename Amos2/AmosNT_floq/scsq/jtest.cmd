call install
start cmd.exe /c javascsq scsq.dmp -ns
javascsq scsq.dmp -o "sp_exename('javascsq');sp_dumpfile('scsq.dmp');" -O regress/master.osql -O regress/scsqlregress.osql -O regress/bgcoregress.osql
