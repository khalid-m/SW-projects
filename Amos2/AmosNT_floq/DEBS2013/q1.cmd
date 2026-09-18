call setup.cmd
call killall
call debs -o  "set :fullgame=check_file('data/full-game');count(q1alone(:fullgame));q();"