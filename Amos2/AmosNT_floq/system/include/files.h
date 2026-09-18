/***************************************************************
 * AMOS
 * 
 * Author: (c) 1993 Jonas S Karlsson, Magnus Werner, CAELAB
 * $RCSfile: files.h,v $
 * $Revision: 1.1 $ $Date: 2003/08/05 14:26:42 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Implements a file function library.
 *
 * Requirements: 
 * =============================================================
 * $Log: files.h,v $
 * Revision 1.1  2003/08/05 14:26:42  torer
 * Source code in C for Amos II communication primitives now available
 *
 * Revision 1.6  1996/06/19  13:56:27  marsk
 * Added support for accessing AMOS:es through clint-server interface
 * in embedded, event-driven systems.
 *
 * Revision 1.5  1994/05/16  12:47:36  jonka
 * Functions to "lock" a directory in a unix-portable way.
 * Can detect program termination over NFS.
 *
 * Revision 1.4  1994/01/18  09:11:08  jonka
 * lsp_files: lisp: ftok, ftokfn added for giving uniq number from file.
 * lsp_process: includes amos.h
 *
 * Revision 1.3  1993/10/07  13:17:46  magwe
 * Added declaration of restorefn, stdoutstream and stderrstream to make
 * them visible and usable out side lsp_files.c
 *
 * Revision 1.2  1993/09/01  07:47:08  magwe
 * Changed header to support CVS, added rewind.
 *
 */

#ifndef _lsp_files_h_
#define _lsp_files_h_

#define STDIN 0
#define STDOUT 1
#define STDERR 2
#define LOCKDBDIR "Locked"
#define LOCKDBFILE "Locked/Indicator"

extern oidtype zero;

/********************************
 * rewind
 * ======
 * Rewinds the textstream STR
 */
# define rewind(str) textstreamposfn(varstack, str, zero)

oidtype filesizefn(/*env, name*/);
oidtype fileexistspfn(/*env, name*/);
oidtype symlinkfn(/*env, name, sym*/);
oidtype deletefilefn(/*env, name*/);
oidtype ftokfn(/*env, name, num*/);

oidtype dirlockfn(/*env, name*/);
oidtype dirunlockfn(/*env, handle*/);

extern oidtype restorefn(/*env, stream*/);

extern oidtype stdoutstream, stderrstream;

void register_files_functions(/**/);

#endif

    
