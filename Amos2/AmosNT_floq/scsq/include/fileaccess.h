/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, UDBL
 *
 * Description:  File system access primitives
 * Language:     C
 ****************************************************************************/

#include "amos.h"

void dir_bf(a_callcontext cxt, a_tuple tpl);
void readlofarvectorfile(a_callcontext cxt, a_tuple tpl);
void readtextvectorfile(a_callcontext cxt, a_tuple tpl);
void register_fileaccess(void);
