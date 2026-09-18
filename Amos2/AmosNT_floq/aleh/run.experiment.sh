./../bin/rootwrap current.dmp experiments/$1 -o "quit;"
echo $1 | mail ruslan@it.uu.se -s "Experiment is done"
