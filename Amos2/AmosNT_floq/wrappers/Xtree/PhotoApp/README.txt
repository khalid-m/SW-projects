---------------------------------------------------------------------------------
Introduction
---------------------------------------------------------------------------------
Provided that Xtree is an system index., this application is an example of how to 
ultilize Xtree index by searching similar photo over indexed photo.


---------------------------------------------------------------------------------
How to use
---------------------------------------------------------------------------------
A)  Make database image having definitions of Photo, Album and other objects.
      Then a set of photos is loaded into database image.

mkdmp.cmd

in which the following command line is executed

javaamos ..\AmosXtree\sql\photoAlbum.amosql -o "'save photoAlbum.dmp'; quit;"

B) Testing

test.cmd

which executes the below command

javaamos photoAlbum.dmp ..\AmosXtree\test\ 
