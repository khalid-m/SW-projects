This directory contains 2 projects for Borland C++ Builder 4:

1. oamos.bpr
   This project generates the AMOSII ODBC wrapper DLL, which is then loaded
   by AMOS. It needs libodbc_bc.lib in order to link.

2. libodbc_bc.bpr
   Creates a static library (libodbc_bc.lib) for the libodbc library which
   is an OO API to ODBC, very similar to the JDBC API.
