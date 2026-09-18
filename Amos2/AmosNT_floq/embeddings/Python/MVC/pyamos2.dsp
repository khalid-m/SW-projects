# Microsoft Developer Studio Project File - Name="pyamos2" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=pyamos2 - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "pyamos2.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "pyamos2.mak" CFG="pyamos2 - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "pyamos2 - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "pyamos2 - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE "pyamos2 - Win32 Release With Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "pyamos2 - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "."
# PROP Intermediate_Dir "."
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /MD /W3 /GX /O2 /I "$(PYTHON_HOME)\Include" /I "$(PYTHON_HOME)\Lib\site-packages\numpy\core\include\numpy" /I "$(AMOS_HOME)\C" /I "$(AMOS_HOME)\system\include" /I "$(AMOS_HOME)\embeddings\Python\callout\include" /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /D "PYTHONDLL_EXPORTS" /YX /FD /c
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib Ws2_32.lib /nologo /subsystem:console /pdb:"../bin/pyamos2.pdb" /machine:I386 /out:"../bin/pyamos2.exe" /libpath:"$(PYTHON_HOME)\libs" /libpath:"$(AMOS_HOME)\bin" /libpath:"$(AMOS_HOME)\embeddings\Python\callout\libs" /verbose:lib
# SUBTRACT LINK32 /pdb:none
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Cmds="$(AMOS_HOME)\embeddings\Python\callout\bin\pyamos2" "$(AMOS_HOME)bin\amos2.dmp" "$(AMOS_HOME)\embeddings\Python\callout\osql\init.osql" -o "save '$(AMOS_HOME)\embeddings\Python\callout\bin\pyamos2.dmp'; quit;"
# End Special Build Tool

!ELSEIF  "$(CFG)" == "pyamos2 - Win32 Debug"

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
# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /MDd /W3 /Gm /GX /ZI /Od /I "$(PYTHON_HOME)\Include" /I "$(AMOS_HOME)\C" /I "$(AMOS_HOME)\system\include" /I "$(AMOS_HOME)\embeddings\Python\callout\include" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /D "PYTHONDLL_EXPORTS" /FR /FD /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib Ws2_32.lib /nologo /subsystem:console /pdb:"../bin/pyamos2_d.pdb" /debug /machine:I386 /out:"../bin/pyamos2_d.exe" /pdbtype:sept /libpath:"$(PYTHON_HOME)\libs" /libpath:"$(AMOS_HOME)\bin" /libpath:"$(AMOS_HOME)\embeddings\Python\callout\libs" /verbose:lib
# SUBTRACT LINK32 /pdb:none
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Cmds="$(AMOS_HOME)\embeddings\Python\callout\bin\pyamos2_d" "$(AMOS_HOME)bin\amos2.dmp" "$(AMOS_HOME)\embeddings\Python\callout\osql\init.osql" -o "save '$(AMOS_HOME)\embeddings\Python\callout\bin\pyamos2.dmp'; quit;"
# End Special Build Tool

!ELSEIF  "$(CFG)" == "pyamos2 - Win32 Release With Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "pyamos2___Win32_Release_With_Debug"
# PROP BASE Intermediate_Dir "pyamos2___Win32_Release_With_Debug"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "pyamos2___Win32_Release_With_Debug"
# PROP Intermediate_Dir "pyamos2___Win32_Release_With_Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MD /W3 /GX /O2 /I "$(PYTHON_HOME)\Include" /I "$(PYTHON_HOME)\Lib\site-packages\numpy\core\include\numpy" /I "$(AMOS_HOME)\C" /I "$(AMOS_HOME)\system\include" /I "$(AMOS_HOME)\embeddings\Python\callout\include" /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /D "PYTHONDLL_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MD /W3 /GX /ZI /Od /I "$(PYTHON_HOME)\Include" /I "$(PYTHON_HOME)\Lib\site-packages\numpy\core\include\numpy" /I "$(AMOS_HOME)\C" /I "$(AMOS_HOME)\system\include" /I "$(AMOS_HOME)\embeddings\Python\include" /D "WIN32" /D "DEBUG" /D "_CONSOLE" /D "_MBCS" /D "PYTHONDLL_EXPORTS" /FR /FD /c
# SUBTRACT CPP /u /YX /Yc /Yu
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib Ws2_32.lib /nologo /subsystem:console /pdb:"../bin/pyamos2.pdb" /machine:I386 /out:"../bin/pyamos2.exe" /libpath:"$(PYTHON_HOME)\libs" /libpath:"$(AMOS_HOME)\bin" /libpath:"$(AMOS_HOME)\embeddings\Python\callout\libs" /verbose:lib
# SUBTRACT BASE LINK32 /pdb:none
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib Ws2_32.lib amos2.lib /nologo /subsystem:console /incremental:yes /debug /machine:I386 /out:"../bin/pyamos2.exe" /pdbtype:sept /libpath:"$(PYTHON_HOME)\libs" /libpath:"$(AMOS_HOME)\bin" /libpath:"$(AMOS_HOME)\embeddings\Python\libs"
# SUBTRACT LINK32 /pdb:none
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Cmds="$(AMOS_HOME)\embeddings\Python\bin\pyamos2" "$(AMOS_HOME)\bin\amos2.dmp" "$(AMOS_HOME)\embeddings\Python\osql\init.osql" -o "save '$(AMOS_HOME)\embeddings\Python\bin\pyamos2.dmp'; quit;"
# End Special Build Tool

!ENDIF 

# Begin Target

# Name "pyamos2 - Win32 Release"
# Name "pyamos2 - Win32 Debug"
# Name "pyamos2 - Win32 Release With Debug"
# Begin Group "Source Files"

# PROP Default_Filter ".c"
# Begin Source File

SOURCE=..\C\amosmodule.c
# End Source File
# Begin Source File

SOURCE=..\C\pyamos2.c
# End Source File
# Begin Source File

SOURCE=..\C\pycallout.c
# End Source File
# Begin Source File

SOURCE=..\C\pymodule.c
# End Source File
# Begin Source File

SOURCE=..\C\pyobj.c
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter ".h"
# Begin Source File

SOURCE=..\include\amosmodule.h
# End Source File
# Begin Source File

SOURCE=..\include\pycallout.h
# End Source File
# Begin Source File

SOURCE=..\include\pymodule.h
# End Source File
# Begin Source File

SOURCE=..\include\pyobj.h
# End Source File
# Begin Source File

SOURCE=..\include\record.h
# End Source File
# End Group
# Begin Group "ref"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\regress\callin.py
# End Source File
# Begin Source File

SOURCE=..\regress\callout.osql
# End Source File
# Begin Source File

SOURCE=..\regress\callout.py
# End Source File
# Begin Source File

SOURCE=..\compile.cmd
# End Source File
# Begin Source File

SOURCE=..\install.cmd
# End Source File
# Begin Source File

SOURCE=..\..\..\..\C\intcalloutdemo.c

!IF  "$(CFG)" == "pyamos2 - Win32 Release"

!ELSEIF  "$(CFG)" == "pyamos2 - Win32 Debug"

!ELSEIF  "$(CFG)" == "pyamos2 - Win32 Release With Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=..\..\..\..\system\C\JavaCallout.cpp

!IF  "$(CFG)" == "pyamos2 - Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "pyamos2 - Win32 Debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "pyamos2 - Win32 Release With Debug"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=..\regress\list.lsp
# End Source File
# Begin Source File

SOURCE=..\regress\master.osql
# End Source File
# Begin Source File

SOURCE=..\..\..\system\include\scan.h
# End Source File
# Begin Source File

SOURCE=..\test.cmd
# End Source File
# End Group
# Begin Source File

SOURCE=..\..\..\bin\amos2.lib
# End Source File
# End Target
# End Project
