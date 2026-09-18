# Microsoft Developer Studio Generated NMAKE File, Based on bkAmos.dsp
!IF "$(CFG)" == ""
CFG=bkAmos - Win32 Debug
!MESSAGE No configuration specified. Defaulting to bkAmos - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "bkAmos - Win32 Release" && "$(CFG)" != "bkAmos - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "bkAmos.mak" CFG="bkAmos - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "bkAmos - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "bkAmos - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

!IF  "$(CFG)" == "bkAmos - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

ALL : "$(OUTDIR)\bkAmos.exe"


CLEAN :
	-@erase "$(INTDIR)\bk_foreign.obj"
	-@erase "$(INTDIR)\bk_helpfunc.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(OUTDIR)\bkAmos.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /ML /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /Fp"$(INTDIR)\bkAmos.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

RSC=rc.exe
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\bkAmos.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /incremental:no /pdb:"$(OUTDIR)\bkAmos.pdb" /machine:I386 /out:"$(OUTDIR)\bkAmos.exe" 
LINK32_OBJS= \
	"$(INTDIR)\bk_foreign.obj" \
	"$(INTDIR)\bk_helpfunc.obj"

"$(OUTDIR)\bkAmos.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "bkAmos - Win32 Debug"

OUTDIR=.\.
INTDIR=.\.
# Begin Custom Macros
OutDir=.\.
# End Custom Macros

ALL : "..\..\bin\bkAmos.exe" "$(OUTDIR)\bkAmos.bsc"


CLEAN :
	-@erase "$(INTDIR)\bk_foreign.obj"
	-@erase "$(INTDIR)\bk_foreign.sbr"
	-@erase "$(INTDIR)\bk_helpfunc.obj"
	-@erase "$(INTDIR)\bk_helpfunc.sbr"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(OUTDIR)\bkAmos.bsc"
	-@erase "$(OUTDIR)\bkAmos.pdb"
	-@erase "..\..\bin\bkAmos.exe"
	-@erase "..\..\bin\bkAmos.ilk"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /MD /W3 /GX /Zi /I "..\..\C" /I "$(BDB_HOME)\build_win32" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /FR"$(INTDIR)\\" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

RSC=rc.exe
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\bkAmos.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\bk_foreign.sbr" \
	"$(INTDIR)\bk_helpfunc.sbr"

"$(OUTDIR)\bkAmos.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
LINK32_FLAGS=..\..\bin\amoslib.lib $(BDB_HOME)\build_win32\Debug\*.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib Ws2_32.lib /nologo /subsystem:console /incremental:yes /pdb:"$(OUTDIR)\bkAmos.pdb" /debug /machine:I386 /out:"..\..\bin\bkAmos.exe" /pdbtype:sept /libpath:"e:\mala\camos2release\c\\" 
LINK32_OBJS= \
	"$(INTDIR)\bk_foreign.obj" \
	"$(INTDIR)\bk_helpfunc.obj"

"..\..\bin\bkAmos.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 


!IF "$(NO_EXTERNAL_DEPS)" != "1"
!IF EXISTS("bkAmos.dep")
!INCLUDE "bkAmos.dep"
!ELSE 
!MESSAGE Warning: cannot find "bkAmos.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "bkAmos - Win32 Release" || "$(CFG)" == "bkAmos - Win32 Debug"
SOURCE=.\bk_foreign.c

!IF  "$(CFG)" == "bkAmos - Win32 Release"


"$(INTDIR)\bk_foreign.obj" : $(SOURCE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "bkAmos - Win32 Debug"


"$(INTDIR)\bk_foreign.obj"	"$(INTDIR)\bk_foreign.sbr" : $(SOURCE) "$(INTDIR)"


!ENDIF 

SOURCE=.\bk_helpfunc.c

!IF  "$(CFG)" == "bkAmos - Win32 Release"


"$(INTDIR)\bk_helpfunc.obj" : $(SOURCE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "bkAmos - Win32 Debug"


"$(INTDIR)\bk_helpfunc.obj"	"$(INTDIR)\bk_helpfunc.sbr" : $(SOURCE) "$(INTDIR)"


!ENDIF 


!ENDIF 

