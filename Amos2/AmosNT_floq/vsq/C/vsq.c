/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Lars Melander, UDBL
 * $RCSfile: vsq.c,v $
 * $Revision: 1.2 $ $Date: 2011/12/14 18:19:43 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Driver program for VSQ.
 *              "stopafter", amos function for running a stream a set amount
 *              of seconds.
 *              "sink", amos function for running a stream and discard
 *              the return values.
 * ===========================================================================
 * $Log: vsq.c,v $
 * Revision 1.2  2011/12/14 18:19:43  larme597
 * *** empty log message ***
 *
 * Revision 1.1  2011/11/02 13:29:05  larme597
 * *** empty log message ***
 *
 * Revision 1.2  2011/11/01 15:31:59  larme597
 * Added headers.
 *
 ****************************************************************************/

#include "init_vsq.h"
#include "scsq.h"

int main(int argc, char **argv)
{
  int error;

  error = init_vsq(argc, argv);

  if (error == 0)
    {
      amos_toploop("VSQ");
    }

  return error;
}
