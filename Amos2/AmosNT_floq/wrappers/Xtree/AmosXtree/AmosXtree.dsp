# Microsoft Developer Studio Project File - Name="AmosXtree" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=AmosXtree - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "AmosXtree.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "AmosXtree.mak" CFG="AmosXtree - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "AmosXtree - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "AmosXtree - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "AmosXtree - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /MD /W3 /GX /O2 /I "$(JAVA_HOME)\include" /I "$(JAVA_HOME)\include\win32" /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib jvm.lib ws2_32.lib /nologo /subsystem:console /machine:I386 /out:"./AmosXtree.exe" /libpath:"$(JAVA_HOME)\lib"
# SUBTRACT LINK32 /nodefaultlib

!ELSEIF  "$(CFG)" == "AmosXtree - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "."
# PROP Intermediate_Dir "."
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD CPP /nologo /MD /W3 /Gm /GX /ZI /Od /I "$(JAVA_HOME)\include" /I "$(JAVA_HOME)\include\win32" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /FD /GZ /c
# SUBTRACT CPP /YX
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 Ws2_32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib jvm.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept /libpath:"$(JAVA_HOME)\lib"

!ENDIF 

# Begin Target

# Name "AmosXtree - Win32 Release"
# Name "AmosXtree - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\amosXtree.c
# End Source File
# Begin Source File

SOURCE=.\cj.c
# End Source File
# Begin Source File

SOURCE=.\indexhooks.c
# End Source File
# Begin Source File

SOURCE=.\xfile.c
# End Source File
# Begin Source File

SOURCE=.\xpbuild.c
# End Source File
# Begin Source File

SOURCE=.\xsearch.c
# End Source File
# Begin Source File

SOURCE=.\xtree.c
# End Source File
# Begin Source File

SOURCE=.\xtree.config
# End Source File
# Begin Source File

SOURCE=..\..\..\bin\amoslib.lib
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=..\..\..\C\alisp.h
# End Source File
# Begin Source File

SOURCE=.\amosXtree.h
# End Source File
# Begin Source File

SOURCE=..\..\..\C\callin.h
# End Source File
# Begin Source File

SOURCE=..\..\..\C\callout.h
# End Source File
# Begin Source File

SOURCE=.\cj.h
# End Source File
# Begin Source File

SOURCE=.\xtree.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# Begin Group "AmosQL"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\sql\amosXtree.amosql
# End Source File
# Begin Source File

SOURCE=.\regress.osql
# End Source File
# End Group
# Begin Group "Java"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\imgproc\CJFacade.java
# End Source File
# Begin Source File

SOURCE=.\imgproc\CJProxy.java
# End Source File
# Begin Source File

SOURCE=.\imgproc\ColorHistogramExtractor.java
# End Source File
# Begin Source File

SOURCE=.\imgproc\Photo.java
# End Source File
# Begin Source File

SOURCE=.\imgproc\PhotoAlbum.java
# End Source File
# End Group
# Begin Source File

SOURCE=.\rewriter.lsp
# End Source File
# End Target
# End Project
