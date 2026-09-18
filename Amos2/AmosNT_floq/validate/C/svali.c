
#include "scsq.h"

extern register_lprint_functions(void);
extern register_swincell(void);
extern register_swinfns(void);

int main(int argc,char **argv)
{
  bindtype env;

  a_default_image = "svali.dmp";
  init_scsq(argc,argv);

  register_swincell();
  register_swinfns();

  env = topframe();

  amos_toploop("svali");

  return 0;
}

