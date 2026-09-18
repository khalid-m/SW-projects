
#pragma hdrstop
#include <condefs.h>
#include "callin.h"
#include "complex.h"

//---------------------------------------------------------------------------
USELIB("..\bin\amos.lib");
USEUNIT("..\gsdm\C\udp_source.cpp");
USEUNIT("..\gsdm\C\siggen.cpp");
USEUNIT("..\gsdm\C\siggena.cpp");
//---------------------------------------------------------------------------
#pragma argsused
extern void register_signal_generator(void);
extern void register_udp_packet_functions(void);

int main(int argc, char* argv[])
{
        init_amos(argc,argv);
        register_signal_generator();
        register_udp_packet_functions();
        amos_toploop("Amos");
        return 0;
}

