////////////////////////////////////////////////////////////////////////////
//
// UDP Producer C interface 
// by  Arsenij Vodjanov
//
////////////////////////////////////////////////////////////////////////////

#ifndef UDP_PRODUCER__H_
#define UDP_PRODUCER__H_

#include "../../C/alisp.h"
#include "../../C/storage.h"

extern void udp_register_producer_functions(void);
extern oidtype udp_producer_debugfn( bindtype env, oidtype toggle );
extern oidtype udp_producer_startfn( bindtype env );
extern oidtype udp_producer_stopfn( bindtype env );
extern oidtype udp_producer_handle_commandfn( bindtype env, oidtype host, oidtype port, oidtype data, oidtype datasize, oidtype radiostreamid );
extern oidtype udp_producer_send_packetfn( bindtype env, oidtype data, oidtype datasize );

#endif
