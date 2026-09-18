@echo off

pushd ..

echo ------Compiling source code------
call compile

echo ------Building SARD2 system-----
call mkdmp

popd

echo ------Creating small example Company/egov relational database-----
call companydb

echo ------Testing SARD2 with RDF Views of the Company relational database - LISP TYPE PARSER ------
call company_lisp_parser

echo ------Testing SARD2 with RDF Views of the EGov relational database - LISP TYPE PARSER ------
call egov_lisp_parser









