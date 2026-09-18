@echo off
if exist SparQL.dmp del SparQL.dmp 

SparQL "regress/cache_rdf.amosql"
