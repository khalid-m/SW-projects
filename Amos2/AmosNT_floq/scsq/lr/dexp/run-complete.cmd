@echo off
rem Run SCSQ-LR in single-node for L=0.5
javascsq mysql-lr.dmp -O "src/run_complete_single_node.osql" -o "quit;";