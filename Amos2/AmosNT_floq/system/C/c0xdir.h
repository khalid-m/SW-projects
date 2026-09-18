/* Only used for building amoslib.lib in MSVC. EZ/2006-02-06 */

/*******************************************************************************
* c0xdir.h, <stddir.h>
*	Test implementation for the ISO C <stddir.h> proposal at:
*	<http://david.tribble.com/text/c0xdir.html>.
*
*	This code is designed to run reasonably well on POSIX and Win32 systems.
*
* Notes
*	Define the macro '_unix' when compiling on POSIX (Unix) systems.
*
* Contains
*	macro __STDC_DIR__
*	macro __STDC_SETCURRDIR__
*	typedef DIR
*	struct dirent
*	closedir()
*	createdir()
*	getcurrdir()
*	getdirname()
*	getfilename()
*	getfiletype()
*	mkdirname()
*	mkfilename()
*	opendir()
*	readdir()
*	rewinddir()
*	setcurrdir()
*
* Acknowledgments
*	This code was written by David R. Tribble, Oct 2003.
*	It is hereby placed into the public domain, and may be used for all
*	purposes, both commercial and private.  No warranty is provided for this
*	source code, and the author cannot be held liable for its use in any
*	way.
*
* See also
*	<http://david.tribble.com/text/c0xdir.html>
*	<news:comp.std.c>
*	<http://groups.google.com/groups?q=comp.std.c>
*/

#ifndef c0x_c0xdir_h
#define c0x_c0xdir_h	107


/* Identification */

#ifndef NO_H_IDENT
static const char	c0x_c0xdir_h_REV[] =
    "@(#)drt/text/stdc/c0xdir.h $Revision: 1.1 $ $Date: 2006/02/06 18:47:47 $\n";
#endif


/* System includes */

#include <stddef.h>


/*==============================================================================
* Constants
*=============================================================================*/

#define __STDC_DIR__	200407

#if defined(_unix)
 #define __STDC_SETCURRDIR__	1	/* setcurrdir() supported	*/
#elif defined(_WIN32)
 #define __STDC_SETCURRDIR__	1	/* setcurrdir() supported	*/
#else
 #error Unsupported OS
#endif


/*==============================================================================
* Types
*=============================================================================*/

/*------------------------------------------------------------------------------
* typedef DIR
*	Directory search context information.
*
* @see
*	<http://david.tribble.com/text/c0xdir.html#type-DIR>
*
* @since	1.1, 2003-10-25
*/

struct c0x_DirContext;
typedef struct c0x_DirContext	c0x_DIR;


/*------------------------------------------------------------------------------
* struct dirent
*	Directory entry information.
*
*	Note that the last member 'd_name' is actually a variable-length array,
*	and will contain more than one character.
*
* @see
*	<http://david.tribble.com/text/c0xdir.html#struct-dirent>
*
* @since	1.1, 2003-10-25
*/

#define C0X_DIRENT_VS	20040715	/* Struct version		*/

struct c0x_dirent
{
    size_t		d_namlen;	/* Entry name length		*/
    int			d_namoff;	/* Entry name offset		*/
    size_t		d_typelen;	/* Entry type length		*/
    int			d_typeoff;	/* Entry type offset		*/
    char		d_name[1];	/* Entry name			*/
};


/*==============================================================================
* Functions
*=============================================================================*/

/*------------------------------------------------------------------------------
* getcurrdir()
*	Determines the current directory associated with the execution unit.
*
* @param	dir
*	A string buffer that is to be filled with the name of the current
*	execution directory.
*
* @param	max
*	Maximum number of characters, including a terminating null character
*	('\0'), to be written into 'dir'.
*
* @return
*	If successful, the function returns a non-negative value after filling
*	the contents of string 'dir'.  On failure, the function returns a
*	negative value after modifying the value of 'errno'.
*
* @see
*	<http://david.tribble.com/text/c0xdir.html#Function-getcurrdir>
*
* @since	1.2, 2003-12-23
*/

extern int c0x_getcurrdir(char *dir, size_t max);


/*------------------------------------------------------------------------------
* setcurrdir()
*	Establishes the current directory associated with the execution unit.
*
* @param	dir
*	String containing the name of the new current execution directory.
*
* @return
*	If successful, the function returns a non-negative value; otherwise, it
*	modfies the value of 'errno' and returns a negative value.
*
* @see
*	<http://david.tribble.com/text/c0xdir.html#Function-setcurrdir>
*
* @since	1.2, 2003-12-23
*/

extern int c0x_setcurrdir(const char *dir);


/*------------------------------------------------------------------------------
* createdir()
*	Create a new directory.
*
* @param	dir
*	String containing the name of the new directory to create.
*
* @return
*	If successful, the function returns a non-negative value; otherwise, it
*	modfies the value of 'errno' and returns a negative value.
*
* @see
*	<http://david.tribble.com/text/c0xdir.html#Function-createdir>
*
* @since	1.1, 2003-10-25
*/

extern int c0x_createdir(const char *dir);


/*------------------------------------------------------------------------------
* getdirname()
*	Extract the directory component from a path name.
*
* @param	dir
*	Points to a string buffer into which is written the directory component
*	of the given path name.  No more that 'max' characters, including a
*	terminating null character, will be written.
*
* @param	max
*	The maximum number of characters, including a terminating null
*	character, to write into string 'dir'.  If the directory component of
*	the given path name exceeds 'max', this function fails.
*
* @param	path
*	A path name.  This must not be null.
*
* @return
*	If successful, the function returns a positive value indicating the
*	length of the resulting file name component (i.e., the number of
*	characters, excluding the terminating null character, written into
*	'file').  On failure, the function returns a negative value after
*	possibly modifying the value of 'errno'.
*
* @see
*	<http://david.tribble.com/text/c0xdir.html#Function-getdirname>
*
* @since	1.1, 2003-10-25
*/

extern int c0x_getdirname(char *dir, size_t max, const char *path);


/*------------------------------------------------------------------------------
* getfilename()
*	Extract the file name component from a path name.
*
* @param	file
*	Points to a string buffer into which is written the file component of
*	the given path name.  No more that 'max' characters, including a
*	terminating null character, will be written.
*
* @param	max
*	The maximum number of characters, including a terminating null
*	character, to write into string 'file'.  If the file component of the
*	given path name exceeds 'max', this function fails.
*
* @param	path
*	A path name.  This must not be null.
*
* @return
*	If successful, the function returns a positive value indicating the
*	length of the resulting file name component (i.e., the number of
*	characters, excluding the terminating null character, written into
*	'file').  On failure, the function returns a negative value after
*	possibly modifying the value of 'errno'.
*
* @see
*	<http://david.tribble.com/text/c0xdir.html#Function-getfilename>
*
* @since	1.1, 2003-10-25
*/

extern int c0x_getfilename(char *file, size_t max, const char *path);


/*------------------------------------------------------------------------------
* getfiletype()
*	Extract the file type component from a path name.
*
* @param	type
*	Points to a string buffer into which is written the file type component
*	of the given path name.  No more that 'max' characters, including a
*	terminating null character, will be written.
*
* @param	max
*	The maximum number of characters, including a terminating null
*	character, to write into string 'file'.  If the file component of the
*	given path name exceeds 'max', this function fails.
*
* @param	path
*	A path name.  This must not be null.
*
* @return
*	If successful, the function returns a positive value indicating the
*	length of the resulting file type component (i.e., the number of
*	characters, excluding the terminating null character, written into
*	'type').  On failure, the function returns a negative value after
*	possibly modifying the value of 'errno'.
*
* @see
*	<http://david.tribble.com/text/c0xdir.html#Function-getfilename>
*
* @since	1.7, 2004-07-15
*/

extern int c0x_getfiletype(char *type, size_t max, const char *path);


/*------------------------------------------------------------------------------
* mkdirname()
*	Create a directory name from a given directory name and a given
*	subdirectory name within that directory.
*
* @param	path
*	Points to a character array that is to be filled with the file name
*	resulting from combining the given directory name 'dir' and file name
*	'file' components.  If the components cannot be combined into a valid
*	file name, the function fails.  If this pointer is null, the behavior is
*	undefined.
*
* @param	max
*	The maximum number of characters, including a terminating null character
*	('\0'), to write into string 'path'.  If the resulting file name
*	contains more than 'max' characters, the function fails.
*
* @param	dir
*	A string containing the name of a directory.  If the string is empty
*	(""), it is assumed to specify the name of the current execution
*	directory.  If this pointer is null, the behavior is undefined.
*
* @param	subdir
*	A string containing the name of a subdirectory located within the
*	directory designated by the 'dir' string.  If this pointer is null, the
*	behavior is undefined.
*
* @param	type
*	A string containing the type of a subdirectory located within the
*	directory designated by the 'dir' string.  If this pointer is null, the
*	behavior is undefined.
*
* @return
*	If successful, the function returns a positive value indicating the
*	length of the resulting subdirectory name (i.e., the number of
*	characters, excluding the terminating null character, written into
*	string 'path').  On failure, the function returns a negative value after
*	possibly modifying the value of 'errno'.
*
* @see
*	<http://david.tribble.com/text/c0xdir.html#Function-mkdirname>
*
* @since	1.5, 2004-01-10
*/

int mkdirname(char *path, size_t max, const char *dir, const char *subdir,
    const char *type);


/*------------------------------------------------------------------------------
* mkfilename()
*	Create a filename from a given directory name and a given file name
*	within that directory.
*
* @param	path
*	Points to a character array that is to be filled with the file name
*	resulting from combining the given directory name 'dir' and file name
*	'file' components.  If the components cannot be combined into a valid
*	file name, the function fails.  If this pointer is null, the behavior is
*	undefined.
*
* @param	max
*	The maximum number of characters, including a terminating null character
*	('\0'), to write into string 'path'.  If the resulting file name
*	contains more than 'max' characters, the function fails.
*
* @param	dir
*	A string containing the name of a directory.  If the string is empty
*	(""), it is assumed to specify the name of the current execution
*	directory.  If this pointer is null, the behavior is undefined.
*
* @param	file
*	A string containing the name of a file located within the directory
*	designated by the 'dir' string.  If this pointer is null, the behavior
*	is undefined.
*
* @param	type
*	A string containing the type of a file located within the directory
*	designated by the 'dir' string.  If this pointer is null, the behavior
*	is undefined.
*
* @return
*	If successful, the function returns a positive value indicating the
*	length of the resulting file name (i.e., the number of characters,
*	excluding the terminating null character, written into string 'path').
*	On failure, the function returns a negative value after possibly
*	modifying the value of 'errno'.
*
* @see
*	<http://david.tribble.com/text/c0xdir.html#Function-mkfilename>
*
* @since	1.1, 2003-10-25
*/

extern int c0x_mkfilename(char *path, size_t max, const char *dir,
    const char *file, const char *type);


/*------------------------------------------------------------------------------
* opendir()
*	Initiate a search within a directory.
*
* @param	dir
*	The name of a directory to search.
*
* @return
*	On success, the function creates and returns a pointer to an object
*	containing context information for searching the specified directory.
*	This object can subsequently be passed to the other directory searching
*	functions, and is destroyed by a subsequent call to 'closedir()'.  On
*	failure, the function returns null after modifying the value of 'errno'.
*
* @see
*	<http://david.tribble.com/text/c0xdir.html#Function-opendir>
*
* @since	1.2, 2003-12-23
*/

extern c0x_DIR * c0x_opendir(const char *dir);


/*------------------------------------------------------------------------------
* closedir()
*	Terminate the directory search initiated by a previous call to
*	'opendir()'.
*
* @param	dp
*	Points to the directory search context information that was returned by
*	a previous call to 'opendir()'.  If the pointer is null, the behavior is
*	undefined.
*
* @return
*	If successful, the context information pointed to by 'dp' is destroyed
*	and the function returns a non-negative value.  On failure, the function
*	returns a negative value after modifying the value of 'errno'.
*
* @see
*	<http://david.tribble.com/text/c0xdir.html#Function-closedir>
*
* @since	1.2, 2003-12-23
*/

extern int c0x_closedir(c0x_DIR *dp);


/*------------------------------------------------------------------------------
* readdir()
*	Read the next entry contained within a directory being searched.
*
* @param	dp
*	Points to the directory search context information that was returned by
*	a previous call to 'opendir()'.  If the pointer is null, the behavior is
*	undefined.
*
* @return
*	If successful, a pointer to a structure is returned, where the structure
*	contains information about the next directory entry within the directory
*	search context.  The position of the search is advanced to the next
*	directory entry.  On failure, or if there are no more entries to be
*	found in the directory search, the function returns a null pointer after
*	modifying the value of 'errno'.
*
* @see
*	<http://david.tribble.com/text/c0xdir.html#Function-readdir>
*
* @since	1.2, 2003-12-23
*/

extern struct c0x_dirent * c0x_readdir(c0x_DIR *dp);


/*------------------------------------------------------------------------------
* rewinddir()
*	Reset the search position of a given directory search to its initial
*	position.
*
* @param	dp
*	Points to the directory search context information that was returned by
*	a previous call to 'opendir()'.  If the pointer is null, the behavior is
*	undefined.
*
* @return
*	If successful, the directory search context is modified and the function
*	returns a non-negative value.  On failure, the function returns a
*	negative value after modifying the value of 'errno'.
*
* @see
*	<http://david.tribble.com/text/c0xdir.html#Function-rewinddir>
*
* @since	1.4, 2003-12-29
*/

extern int c0x_rewinddir(c0x_DIR *dp);


/*==============================================================================
* Aliases
*=============================================================================*/

/* Type aliases */
#ifndef c0x_c0xdir_c
 #define DIR		c0x_DIR
 #define dirent		c0x_dirent
#endif

/* Function aliases */
#ifndef c0x_c0xdir_c
 #define getcurrdir	c0x_getcurrdir
 #define setcurrdir	c0x_setcurrdir
 #define createdir	c0x_createdir
 #define getdirname	c0x_getdirname
 #define getfilename	c0x_getfilename
 #define getfiletype	c0x_getfiletype
 #define mkdirname	c0x_mkdirname
 #define mkfilename	c0x_mkfilename
 #define opendir	c0x_opendir
 #define closedir	c0x_closedir
 #define readdir	c0x_readdir
 #define rewinddir	c0x_rewinddir
#endif


#endif /* c0x_c0xdir_h */

/* End c0xdir.h */

