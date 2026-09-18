////////////////////////////////////////////////////////////////////////////
//
// UDP Producer C interface 
// by  Arsenij Vodjanov
//
////////////////////////////////////////////////////////////////////////////

#ifndef UDP_HOUSEKEEP__H_
#define UDP_HOUSEKEEP__H_

#include "../../C/alisp.h"
#include "../../C/storage.h"

extern void udp_register_housekeep_functions(void);
extern oidtype udp_housekeep_debugfn( bindtype env, oidtype toggle );
extern oidtype udp_housekeep_startfn( bindtype env );
extern oidtype udp_housekeep_stopfn( bindtype env );
extern oidtype udp_housekeep_handle_commandfn( bindtype env, 
					       oidtype host, oidtype port, 
					       oidtype data, oidtype datasize );
extern oidtype udp_housekeep_send_packetfn( bindtype env, oidtype data, oidtype datasize );

#endif
