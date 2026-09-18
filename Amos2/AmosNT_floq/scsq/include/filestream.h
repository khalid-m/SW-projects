/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Erik Zeitler, UDBL
 *
 * Description:  Stream impl for file I/O
 * Language:     C
 ****************************************************************************/

oidtype new_filestream(bindtype env);
int filestream_getc(oidtype file);
int filestream_ungetc(int c, oidtype file);
int filestream_feof(oidtype file);
int filestream_puts(char* s, oidtype file);
int filestream_putc(int c, oidtype file);
int filestream_fflush(oidtype file);
int filestream_fclose(oidtype file);
void register_filestream(void);
