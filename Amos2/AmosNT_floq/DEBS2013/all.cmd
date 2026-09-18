call setup
call killall
call debs -o  "set :fullgame=check_file('data/full-game');count(full(:fullgame));q();"