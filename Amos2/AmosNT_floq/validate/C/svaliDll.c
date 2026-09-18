
#include "scsq.h"

extern register_lprint_functions(void);
extern register_swincell(void);
extern register_swinfns(void);


EXPORT void a_initialize_extension(void *argv) 
{	

	register_swincell();
	register_swinfns();
}