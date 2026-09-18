cd AmosXtree\imgproc
javac -classpath . *.java
cd ..\..
msdev AmosXtree/AmosXtree.dsp /make "AmosXtree - Win32 Release" /NORECURSE /USEENV /REBUILD