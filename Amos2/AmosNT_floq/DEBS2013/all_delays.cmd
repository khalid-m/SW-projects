call setup
call killall
call debs -o  "propagate_delays(true);set :fullgame=check_file('data/full-game');count(full(:fullgame));q();"