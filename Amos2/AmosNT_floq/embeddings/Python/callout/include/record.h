#ifndef _PYAMOS_RECORD_H
#define _PYAMOS_RECORD_H

oidtype make_recordfn(bindtype, oidtype);
oidtype record_getfn(bindtype, oidtype, oidtype);
oidtype record_putfn(bindtype, oidtype, oidtype, oidtype);
oidtype record_fieldsfn(bindtype, oidtype);

#endif