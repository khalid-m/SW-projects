# ---------------------------------------------------------------------------
VERSION = BCB.04.04
# ---------------------------------------------------------------------------
!ifndef BCB
BCB = $(MAKEDIR)\..
!endif
# ---------------------------------------------------------------------------
PROJECT = testcpp.exe
OBJFILES = testcpp.obj democpp.obj
RESFILES = 
DEFFILE =
RESDEPEN = $(RESFILES)
LIBFILES = ..\bin\amos.lib
LIBRARIES = vcldbx40.lib vcldb40.lib vclx40.lib vcl40.lib
SPARELIBS = vcl40.lib vclx40.lib vcldb40.lib vcldbx40.lib
PACKAGES =
PATHASM = .;
PATHCPP = .;
PATHPAS = .;
PATHRC = .;
DEBUGLIBPATH = $(BCB)\lib\debug
RELEASELIBPATH = $(BCB)\lib\release
SYSDEFINES = NO_STRICT
USERDEFINES =
# ---------------------------------------------------------------------------
CFLAG1 = -Ic:\torri\amos2\;$(BCB)\projects;$(BCB)\include;$(BCB)\include\vcl -Od -Hc \
  -H=$(BCB)\lib\vcl40.csm -w -Ve -r- -a4 -k -y -v -vi- \
  -D$(SYSDEFINES);$(USERDEFINES) -c -b- -w-par -w-inl -Vx -WE -w-rch -tWM
CFLAG2 =
CFLAG3 =
PFLAGS = -Uc:\torri\amos2\;$(BCB)\projects;$(BCB)\lib\obj;$(BCB)\lib;$(DEBUGLIBPATH) \
  -Ic:\torri\amos2\;$(BCB)\projects;$(BCB)\include;$(BCB)\include\vcl \
  -AWinTypes=Windows;WinProcs=Windows;DbiTypes=BDE;DbiProcs=BDE;DbiErrs=BDE -$YD \
  -$W -$O- -v -JPHNV -M -JPHNE
RFLAGS = -ic:\torri\amos2\;$(BCB)\projects;$(BCB)\include;$(BCB)\include\vcl
AFLAGS = /ic:\torri\amos2 /i$(BCB)\projects /i$(BCB)\include /i$(BCB)\include\vcl /mx \
  /w2 /zd
LFLAGS = -Lc:\torri\amos2\;$(BCB)\projects;$(BCB)\lib\obj;$(BCB)\lib;$(DEBUGLIBPATH) -ap \
  -Tpe -x -v
IFLAGS =
LINKER = ilink32
# ---------------------------------------------------------------------------
ALLOBJ = c0x32.obj sysinit.obj $(OBJFILES)
ALLRES = $(RESFILES)
ALLLIB = $(LIBFILES) $(LIBRARIES) import32.lib cp32mt.lib
# ---------------------------------------------------------------------------
.autodepend

!ifdef IDEOPTIONS

[Version Info]
IncludeVerInfo=0
AutoIncBuild=0
MajorVer=1
MinorVer=0
Release=0
Build=0
Debug=0
PreRelease=0
Special=0
Private=0
DLL=0
Locale=1033
CodePage=1252

[HistoryLists\hlRunParameters]
Count=1
Item0=..\bin\amos2.dmp

[Debugging]
DebugSourceDirs=

[Parameters]
RunParams=..\bin\amos2.dmp
HostApplication=
RemoteHost=
RemotePath=
RemoteDebug=0

[Compiler]
InMemoryExe=0
ShowInfoMsgs=1

!endif

$(PROJECT): $(OBJFILES) $(RESDEPEN)
    $(BCB)\BIN\$(LINKER) @&&!
    $(LFLAGS) +
    $(ALLOBJ), +
    $(PROJECT),, +
    $(ALLLIB),, +
    $(ALLRES) 
!

.pas.hpp:
    $(BCB)\BIN\dcc32 $(PFLAGS) { $** }

.pas.obj:
    $(BCB)\BIN\dcc32 $(PFLAGS) { $** }

.cpp.obj:
    $(BCB)\BIN\bcc32 $(CFLAG1) $(CFLAG2) -o$* $* 

.c.obj:
    $(BCB)\BIN\bcc32 $(CFLAG1) $(CFLAG2) -o$* $**

.rc.res:
    $(BCB)\BIN\brcc32 $(RFLAGS) $<
#-----------------------------------------------------------------------------
