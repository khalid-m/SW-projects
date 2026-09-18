@echo off

pushd ..

echo ------Setting environment variables------
call setup

echo ------Compiling source code------
call compile

echo ------Building SWARD system-----
call mkdmp

popd

echo ------Testing SWARD parsers------

echo ------Testing SPARQL parser------
call sparqlParser.cmd

echo ------Creating small example Company/egov relational database-----
call companydb

echo ------Testing SWARD with RDFS Views of the Company relational database------
call company

echo ------Testing SWARD with complete RDFS views of the Company relational database------
call company_complete

echo ------Testing SWARD RDFS views of the E-Government relational database------
call egov


