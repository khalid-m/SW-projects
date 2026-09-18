@echo off

pushd ..

echo ------Compiling source code------
call compile

echo ------Building SARD system-----
call mkdmp

popd

echo ------Creating small example Company/egov relational database-----
call companydb

echo ------Testing SARD with RDFS Views of the Company relational database - LISP PARSER ------
call company_lisp_parser

echo ------Testing SARD with RDFS Views of the EGov relational database - LISP PARSER ------
call egov_lisp_parser







