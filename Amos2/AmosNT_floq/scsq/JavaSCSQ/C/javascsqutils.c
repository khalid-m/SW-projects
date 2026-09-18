#include "fileaccess.h"
#include "port.h"
#include "sproc.h"
#include "extract.h"
#include "numarray.h"
#include "a_fft.h"
#include "twinagg.h"
#include "bgcommon.h"
#include "bgextract.h"

#ifdef NT
#include "wproctime.h"
#endif
#ifdef LINUX
#include "pipestream.h"
#include "wproctime.h"
#include "fork.h"
#endif

EXTERN int delay_emit;
EXTERN int materialized_remote_scan;

oidtype stopsymbol;
oidtype emitsymbol;
oidtype eofsym;

void javascsq_init(void *x) { 
  delay_emit=FALSE;
  materialized_remote_scan = FALSE;  
  register_fileaccess();
  register_port();
  register_extract();
  register_bgextract();
  register_sproc();
  register_scsq_functions();
  register_numarray();
  register_multina();
  register_lrmultiply();
  register_bgcommon();
  register_fft();
  register_twinagg();
  register_lrmultiply();
#ifdef LINUX
	register_pipestream();
	register_fork();
#endif
}
