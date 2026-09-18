TO COMPILE:

set %MATLAB_HOME% to e.g. C:\Program Files\MATLAB\R2012b

extern/lib/win32/microsoft/*.lib files are required during compilation

run compile.cmd


TO RUN:

If 32-bit MATLAB is installed, the following directory should be in the beginning of system PATH:

%MATLAB_HOME%/bin/win32


If MATLAB is not installed, MATLAB MCR (32bit) needs to be downloaded from

http://www.mathworks.se/products/compiler/mcr/

and installed first.

System PATH should include (in its beginning) bin/win32 in the MCR installation directory.
