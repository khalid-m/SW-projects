EXTERN oidtype co_yieldfn(bindtype env, oidtype co);
EXTERN void co_enterbg0();
EXTERN void co_leavebg(oidtype cr);
EXTERN int co_this_thread_busy();
EXTERN void co_leavebg0();
EXTERN void a_sleep0(double s);

struct globals
{
  bindtype varstack;
  int varstacksize;
  bindtype varstacktop;
  bindtype varstackslack;
  bindtype topenv;
  jmp_buf *resetlabelp;
  void *current_contdata;
  oidtype thiscr;
  int suppress_error;
  int errorflag;
  int a_errno;
  oidtype errform;
};

void SaveGlobals(struct globals *gl);
void RestoreGlobals(struct globals *gl);

