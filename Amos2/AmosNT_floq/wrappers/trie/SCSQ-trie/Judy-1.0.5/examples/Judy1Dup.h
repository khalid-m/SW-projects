/* @(#) $Revision: 1.1 $ $Source: /it/project/fo/udbl/CVSRoot/AmosNT/wrappers/trie/SCSQ-trie/Judy-1.0.5/examples/Judy1Dup.h,v $ */

#include <Judy.h>

/* ******************************************************************
 * Name: Judy1Dup
 *
 * Description:
 *       Clone (duplicate) a Judy Array.
 *
 * Parameters:
 *       PPvoid_t PPDest (OUT)
 *            Pointer to a new Judy array with the same
 *            index/value pairs as PSource.
 *            Any initial value pointed to by PPDest is ignored.
 *
 *       Pvoid_t PSource (IN)
 *            Ptr to source Judy array being duplicated.
 *            If PSource is NULL, TRUE is returned since this
 *            is simply a valid Null Judy array.
 *
 *       JError_t *PJError (OUT)
 *            Judy error structure pointer.
 *
 * Returns:
 *       JERR - error, see PJError
 *      !JERR - success
 */

int
Judy1Dup(PPvoid_t PPDest, Pvoid_t PSource, JError_t * PJError);
