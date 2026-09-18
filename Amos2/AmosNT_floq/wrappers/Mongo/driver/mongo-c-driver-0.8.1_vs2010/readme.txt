MongoDB Driver Build under Microsoft Visual Studio 2010

Two files have been created
targetver.h
stdafx.h
all the files from <mongodb driver>\src\ has been put to mongo_driver directory 
together with the above two files.

===========================
Project Properties

Dll output directory
	..\..\bin

Preprocessor
	WIN32
	_DEBUG
	_WINDOWS
	_USRDLL
	MONGO_USE__INT64
	MONGO_ENV_STANDARD

Linking additional dependencies
	ws2_32.lib



===========================



This following files will be created in the AmosNT\bin directory

mogo_driver.dll
mogo_driver.lib
mogo_driver.ilk
mogo_driver.pdb







Amos foreign functions in C
===========================

This folder contains examples of how to extend Amos based systems with
new AmosQL functions implemented in C.

For Linux and OSX use the command 'make' after having set the
environment variable ARCHITECTURE to either Linux32 or Apple32.

For Windows there is a Visual Studio 2010 project
myAmosExtenders.vcxproj. It handles both Debug and Release
configurations. Open it and do 'Build Solution'.

How to make your own Amos foreign functions in C:
-------------------------------------------------

For Linux and OSX simply copy the Makefile to the folder for the new
extender and follow the instructions in the header comment of the
Makefile.

The easiest way to make your own Windows extender is to copy
myAmosExtenders.vcxproj to the folder for the new extender and rename
the vcsproj file to the name of the new extender.  Then edit the new
vcxproj file and change in it 'myAmosExtenders' and 'MYAMOSEXTENDERS'
to the (capitalized) name of the new extender.

SConscript Commands
-------------------------------------------------

scons: Reading SConscript files ...
Compiling for amd64
Checking for C library json... no
scons: done reading SConscript files.
scons: Building targets ...
cl /Fosrc\md5.obj /c src\md5.c /nologo -DMONGO_ENV_STANDARD -DMONGO_HAVE_STDINT -DMONGO_DLL_BUILD /Isrc
md5.c
cl /Fosrc\mongo.obj /c src\mongo.c /nologo -DMONGO_ENV_STANDARD -DMONGO_HAVE_STDINT -DMONGO_DLL_BUILD /Isrc
mongo.c
cl /Fosrc\env.obj /c src\env.c /nologo -DMONGO_ENV_STANDARD -DMONGO_HAVE_STDINT -DMONGO_DLL_BUILD /Isrc
env.c
cl /Fosrc\gridfs.obj /c src\gridfs.c /nologo -DMONGO_ENV_STANDARD -DMONGO_HAVE_STDINT -DMONGO_DLL_BUILD /Isrc
gridfs.c
cl /Fosrc\bcon.obj /c src\bcon.c /nologo -DMONGO_ENV_STANDARD -DMONGO_HAVE_STDINT -DMONGO_DLL_BUILD /Isrc
bcon.c
cl /Fosrc\bson.obj /c src\bson.c /nologo -DMONGO_ENV_STANDARD -DMONGO_HAVE_STDINT -DMONGO_DLL_BUILD /Isrc
bson.c
cl /Fosrc\numbers.obj /c src\numbers.c /nologo -DMONGO_ENV_STANDARD -DMONGO_HAVE_STDINT -DMONGO_DLL_BUILD /Isrc
numbers.c
cl /Fosrc\encoding.obj /c src\encoding.c /nologo -DMONGO_ENV_STANDARD -DMONGO_HAVE_STDINT -DMONGO_DLL_BUILD /Isrc
encoding.c
lib   mongoc.lib  ws2_32.lib src\md5.obj src\mongo.obj src\env.obj src\gridfs.obj src\bcon.obj src\bson.obj src\numbers.obj src\encoding.obj
   Creating library mongoc.lib and object mongoc.exp
link /nologo /dll /out:bson.dll /implib:bson.lib ws2_32.lib src\md5.obj src\bcon.obj src\bson.obj src\numbers.obj src\encoding.obj
   Creating library bson.lib and object bson.exp
scons: done building targets.

