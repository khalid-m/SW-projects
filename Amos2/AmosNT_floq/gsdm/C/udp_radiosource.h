////////////////////////////////////////////////////////////////////////////
//
// UDP Consumer C interface 
// by  Arsenij Vodjanov
//
////////////////////////////////////////////////////////////////////////////

#ifndef UDP_RADIOSOURCE_H__
#define UDP_RADIOSOURCE_H__

#include "../../C/alisp.h"
#include "../../C/storage.h"

#define Foffs	  1.0000086		// Frequency calibration
#define Sfrq	  6120.0		// Starting Frequency KHz
#define Sred      12                    // Starting Scale

extern oidtype udp_radiosource_debugfn(bindtype env, oidtype toggle);
extern oidtype udp_radiosource_openfn( bindtype env, oidtype streamid, oidtype host, oidtype port );
extern oidtype udp_radiosource_closefn( bindtype env, oidtype radioid );
extern oidtype udp_radiosource_identfn( bindtype env, oidtype radioid );
extern oidtype udp_radiosource_startstopfn( bindtype env, oidtype radioid, oidtype onflag, oidtype bcastflag );
extern oidtype udp_radiosource_setscalefn( bindtype env, oidtype radioid, oidtype red);
extern oidtype udp_radiosource_setfreqfn( bindtype env, oidtype radioid, oidtype freq);
extern oidtype udp_radiosource_getfromfn( bindtype env, oidtype radioid );
extern oidtype udp_encode_winfn(bindtype env, oidtype rd1, oidtype rd2);

extern void udp_register_radiosource_functions();
extern int udp_radiosource_open( int streamid, char *host, int port );
extern int udp_radiosource_close( int radioid );
extern int udp_radiosource_ident( int radioid );
extern int udp_radiosource_startstop( int radioid, int onoff, int broadcast );
extern int udp_radiosource_setscale( int radioid, double red );
extern int udp_radiosource_setfreq( int radioid, double freq );


#endif
