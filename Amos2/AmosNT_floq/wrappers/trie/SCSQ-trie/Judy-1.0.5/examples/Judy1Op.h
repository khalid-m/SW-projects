#ifndef _JUDY1OP_INCLUDED
#define	_JUDY1OP_INCLUDED

// @(#) $Revision: 1.1 $ $Source: /it/project/fo/udbl/CVSRoot/AmosNT/wrappers/trie/SCSQ-trie/Judy-1.0.5/examples/Judy1Op.h,v $
//
// HEADER FILE FOR EXPORTED FEATURES FROM Judy1Op().

#define	JUDY1OP_AND    1L
#define	JUDY1OP_OR     2L
#define	JUDY1OP_ANDNOT 3L

extern int Judy1Op(PPvoid_t PPDest, Pvoid_t PSet1, Pvoid_t PSet2,
                   Word_t Operation, JError_t * PJError);

#endif // ! _JUDY1OP_INCLUDED
