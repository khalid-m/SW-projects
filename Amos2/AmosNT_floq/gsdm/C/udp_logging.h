////////////////////////////////////////////////////////////////////////////////
//
// UDP Broadcaster 
// Linux daemon configuration
//
// by Arsenij Vodjanov
//
////////////////////////////////////////////////////////////////////////////////

#ifndef UDP_LOGGING__H_
#define UDP_LOGGING__H_

#define MSGLOG_FILE    "broadcaster_log.txt"
#define ERRLOG_FILE    "broadcaster_err.txt"

void udp_log_message(char *fmt, ...);
void udp_log_error(char *fmt, ...);

#endif
