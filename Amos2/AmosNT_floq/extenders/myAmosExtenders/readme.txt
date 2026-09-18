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
