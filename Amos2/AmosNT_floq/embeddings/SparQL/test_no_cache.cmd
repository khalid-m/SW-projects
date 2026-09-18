@echo off
if exist SparQL.dmp del SparQL.dmp 

SparQL "regress/not_cache_rdf.amosql"