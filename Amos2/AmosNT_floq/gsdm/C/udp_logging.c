////////////////////////////////////////////////////////////////////////////////
//
// UDP Broadcaster logging functions
// by Arsenij Vodjanov
//
////////////////////////////////////////////////////////////////////////////////

#include "udp_common.h"
#include <stdarg.h>

static void udp_log_write(char *filename, char *message)
{
  FILE *logfile;
#ifndef BROADCASTER_IS_DAEMON
  fprintf(stdout, "%s", message);
#endif
  logfile = fopen(filename, "a");
  if (logfile==NULL) return;
  fprintf(logfile, "%s", message);
  fclose(logfile);
}

void udp_log_message(char *fmt, ...)
{
  va_list ap;
  char message[2048];
  va_start(ap, fmt);
  vsprintf(message, fmt, ap);
  va_end(ap);
  udp_log_write(MSGLOG_FILE, message);
}


void udp_log_error(char *fmt, ...)
{
  va_list ap;
  char message[2048];
  va_start(ap, fmt);
  vsprintf(message, fmt, ap);
  va_end(ap);
  udp_log_write(ERRLOG_FILE, message);
}


////////////////////////////////////////////////////////////////////////////
// Logging from lisp
//
// Returns: nil
//
oidtype udp_log_messagefn(bindtype args, bindtype env)
{
  // todo: do
  return nil;
}
//
////////////////////////////////////////////////////////////////////////////
