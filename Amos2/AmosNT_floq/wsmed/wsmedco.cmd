@echo off
if  "%1" EQU "fsc" ("java" JavaAMOS %2 -o " load_lisp('src/lisp/ff_receive_static_co.lsp'); load_lisp('src/lisp/pardecom_ff_static_co.lsp'); ") else (if  "%1" EQU "fdc" ("java" JavaAMOS %2  -o "load_lisp('src/lisp/ff_receive_dynamic_co.lsp'); load_lisp('src/lisp/pardecom_ff_dynamic_co.lsp');"))

if  "%1" EQU "fs" ("java" JavaAMOS %2 -o " load_lisp('src/lisp/ff_receive_static.lsp'); load_lisp('src/lisp/pardecom_ff_static.lsp'); " -c "me") else (if  "%1" EQU "fd" ("java" JavaAMOS %2  -o " load_lisp('src/lisp/ff_receive_dynamic_tuple.lsp'); load_lisp('src/lisp/pardecom_ff_dynamic.lsp');" -c "me"))

if  "%1" EQU "ms" ("java" JavaAMOS %2  -o " load_lisp('src/lisp/ff_receive_static_co.lsp'); load_lisp('src/lisp/ff_receive_static_mixed_co.lsp'); load_lisp('src/lisp/pardecom_ff_static_mixed_co.lsp');") else (if  "%1" EQU "md" ("java" JavaAMOS %2  -o "load_lisp('src/lisp/ff_receive_dynamic_mixed_co.lsp'); load_lisp('src/lisp/pardecom_ff_dynamic_mixed_co.lsp');"))


if  "%1" EQU "d" ("java" JavaAMOS %2  -o "load_lisp('src/lisp/ff_receive_dynamic_co_dr.lsp'); load_lisp('src/lisp/pardecom_ff_dynamic_co.lsp');")


if  "%1" EQU "n" ("java" JavaAMOS %2)