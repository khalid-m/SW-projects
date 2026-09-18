/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, UDBL
 *
 * Description:  Pipes for Unix inter process streams
 * Language:     C
 ****************************************************************************/

oidtype new_pipestream(bindtype env);
int pipe_getc(oidtype pipe);
int pipe_ungetc(int c, oidtype pipe);
int pipe_feof(oidtype pipe);
int pipe_puts(char* s, oidtype pipe);
int pipe_putc(int c, oidtype pipe);
int pipe_fflush(oidtype pipe);
int pipe_fclose(oidtype pipe);
void register_pipestream(void);
