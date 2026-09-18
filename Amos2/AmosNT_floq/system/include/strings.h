/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Lars Melander, UDBL
 * $RCSfile: strings.h,v $
 * $Revision: 1.3 $ $Date: 2011/08/23 12:01:16 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Extra string management functions
 * ===========================================================================
 * $Log: strings.h,v $
 * Revision 1.3  2011/08/23 12:01:16  larme597
 * Lisp string functions.
 *
 * Revision 1.2  2011/04/13 11:36:50  larme597
 * A better explode function.
 *
 * Revision 1.1  2011/04/12 20:34:25  larme597
 * Extra string management functions. Adding explode function.
 *
 ****************************************************************************/

#ifndef __strings_functions__
#define __strings_functions__

/**
 * Divide a string into an array of strings.
 *
 * Parameters:
 *    arr_ptr  A pointer to the (uninitialized) string array that is to be
 *             populated.
 *
 *        str  The delimited string.
 *
 *  delimiter  A character that separates the strings.
 *
 * Returns:    Size of the string array.
 *
 * Examples:   char **arr;
 *             char *str = "sen massa  strings";
 *
 *             explode(&arr, str, ' '); // ->
 * 
 *               // arr = ["sen", "massa", "", "strings"]
 *               // size = 4
 *
 *             explode(&arr, str, 's'); // ->
 *
 *               //  arr = ["", "en ma", "", "a  ", "tring", ""]
 *               //  size = 6
 *
 *             free(arr);  // deallocate string array
 *
 */
int explode(char ***arr_ptr, char *str, char delimiter);

void register_strings();

#endif
