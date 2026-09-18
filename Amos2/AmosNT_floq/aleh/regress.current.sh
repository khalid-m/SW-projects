./mkdmp.current.sh
./../bin/rootwrap current.dmp regress/stream.structs.hagrid.2005.osql -o "quit;"
./../bin/rootwrap current.basic.dmp regress/stream.structs.limited.2005.osql -o "quit;"
./../bin/rootwrap current.dmp regress/stream.structs.hagrid.osql -o "quit;"
./../bin/rootwrap current.limited.dmp regress/stream.structs.limited.osql -o "quit;"
