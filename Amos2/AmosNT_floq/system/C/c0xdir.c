/* Only used for building amoslib.lib in MSVC. EZ/2006-02-06 */

/*******************************************************************************
* c0xdir.c
*	Test implementation for the ISO C <stddir.h> proposal at:
*	<http://david.tribble.com/text/c0xdir.html>.
*
*	This code is designed to run reasonably well on Unix and Win32 systems.
*
* Notes
*	Define the macro '_unix' when compiling on POSIX (Unix) systems.
*	Also define the macro '_linux' when compiling on Linux systems.
*	Define the macro 'DEBUGS' to a nonzero value to enable debug traces.
*
* Contains
*	typedef c0x_DIR (struct c0x_DirContext)
*	struct c0x_dirent
*	c0x_closedir()
*	c0x_createdir()
*	c0x_getcurrdir()
*	c0x_getdirname()
*	c0x_getfilename()
*	c0x_getfiletype()
*	c0x_mkdirname()
*	c0x_mkfilename()
*	c0x_opendir()
*	c0x_readdir()
*	c0x_rewinddir()
*	c0x_setcurrdir()
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


/* Identification */

static const char	REV[] =
    "@(#)drt/text/stdc/c0xdir.c $Revision: 1.3 $ $Date: 2010/12/26 17:08:37 $\n";


/* System includes */

#include <ctype.h>
#include <errno.h>
#include <iso646.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#if DEBUGS
 #include <stdio.h>
#endif

#if defined(_unix)
 #include <dirent.h>
 #include <unistd.h>
 #include <sys/types.h>
 #include <sys/stat.h>
#elif defined(_WIN32)
 /*#include <direct.h>*/
 /*#include <io.h>*/
 #define WIN32_LEAN_AND_MEAN	1
 #include <windows.h>
#else
 #error Unsupported OS
#endif


/* Local includes */

#define c0x_c0xdir_c	1
#include "c0xdir.h"


/*==============================================================================
* Constants
*=============================================================================*/

#if defined(_unix)
 #define _FNAME_MAX	1024
#elif defined(_WIN32)
 #define _FNAME_MAX	1024
#else
 #error Unsupported OS
#endif


/*==============================================================================
* Types
*=============================================================================*/

/*------------------------------------------------------------------------------
* struct c0x_DirContext (typedef DIR)
*	Directory search context information.
*
* @see
*	<http://david.tribble.com/text/c0xdir.html#type-DIR>
*
* @since	1.1, 2003-10-26
*/

#define c0x_DirContext_VS	20040715	/* Struct version	*/

struct c0x_DirContext
{
#if defined(_unix)
    DIR *		m_ctx;		/* Search context		*/
    struct c0x_dirent	m_ent;		/* Current entry		*/
    char		m_pad[2*_FNAME_MAX+1];

#elif defined(_WIN32)
    HANDLE		m_hdl;		/* Search handle		*/
    char *		m_path;		/* Search pathname		*/
    unsigned int	m_count;	/* Entry counter		*/
    WIN32_FIND_DATA	m_ctx;		/* Search context		*/
    unsigned char	m__r[8];	/* (Reserved)			*/
    struct c0x_dirent	m_ent;		/* Current entry		*/
    char		m_pad[2*_FNAME_MAX+1];

#else
    #error Unsupported OS

#endif
};


/*==============================================================================
* Functions
*=============================================================================*/

/*------------------------------------------------------------------------------
* c0x_getcurrdir()
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
*	<http://david.tribble.com/text/c0xdir.html#func-getcurrdir>
*
* @since	1.1, 2003-10-25
*/

int c0x_getcurrdir(char *dir, size_t max)
{
#if defined(_unix)
    #if DEBUGS
        printf("$ getcurrdir(dir=%08p, max=%u)\n",
            dir, max);
    #endif

    /* Retrieve the current execution directory */
    if (getcwd(dir, max) == NULL)
        return (-1);
    else
        return (strlen(dir));

#elif defined(_WIN32)
    size_t	len;

    #if DEBUGS
        printf("$ getcurrdir(dir=%08p, max=%u)\n",
            dir, max);
    #endif

    /* Retrieve the current execution directory */
    len = GetCurrentDirectory(max, dir);
    if (len == 0  or  len >= max)
        return (-1);
    return (len);
 
#else
    #error Unsupported OS

#endif
}


/*------------------------------------------------------------------------------
* c0x_setcurrdir()
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
*	<http://david.tribble.com/text/c0xdir.html#func-setcurrdir>
*
* @since	1.1, 2003-10-25
*/

int c0x_setcurrdir(const char *dir)
{
    #if DEBUGS
        printf("$ setcurrdir(dir=%08p='%.9999s')\n",
            dir, (dir != NULL ? dir : ""));
    #endif

#if defined(_unix)
    return (chdir(dir));

#elif defined(_WIN32)
    if (not SetCurrentDirectory(dir))
        return (-1);
    return (0);

#else
    #error Unsupported OS

#endif
}


/*------------------------------------------------------------------------------
* c0x_createdir()
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
*	<http://david.tribble.com/text/c0xdir.html#func-createdir>
*
* @since	1.1, 2003-10-25
*/

int c0x_createdir(const char *dir)
{
    #if DEBUGS
        printf("$ createdir(dir=%08p='%.9999s')\n",
            dir, (dir != NULL ? dir : ""));
    #endif

#if defined(_unix)
    return (mkdir(dir, 0777));

#elif defined(_WIN32)
    if (not CreateDirectory(dir, NULL))
        return (-1);
    return (0);

#else
    #error Unsupported OS

#endif
}


/*------------------------------------------------------------------------------
* c0x_getdirname()
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
*	<http://david.tribble.com/text/c0xdir.html#func-getdirname>
*
* @since	1.1, 2003-12-26
*/

int c0x_getdirname(char *dir, size_t max, const char *path)
{
#if defined(_unix)
    const char *	cp;

    #if DEBUGS
        printf("$ getdirname(dir=%08p, max=%u, path=%08p='%.9999s')\n",
            dir, max, path, (path != NULL ? path : ""));
    #endif

    /* Find the directory prefix of the pathname */
    cp = strrchr(path, '/');
    if (cp == NULL)
    {
        /* Pathname has no directory prefix */
        if (max <= 1)
        {
            errno = E2BIG;
            return (-1);
        }
        strcpy(dir, ".");
        return (1);
    }
    else
    {
        size_t	len;

        /* Extract the directory prefix from the pathname */
        len = cp - path;
        if (len >= max)
        {
            errno = E2BIG;
            return (-1);
        }

        memcpy(dir, path, len);
        dir[len] = '\0';
        return (len);
    }

#elif defined(_WIN32)
    const char *	cp;
    const char *	p;

    #if DEBUGS
        printf("$ getdirname(dir=%08p, max=%u, path=%08p='%.9999s')\n",
            dir, max, path, (path != NULL ? path : ""));
    #endif

    /* Find the device/directory prefix of the pathname */
    p = path;
    if (p[0] == '\\'  and  p[1] == '\\')
    {
        p += 2;
        while (p[0] != '\0'  and  p[0] != '\\'  and  p[0] != '/')
            p++;
    }

    if (p[0] == '\\'  or  p[0] == '/')
    {
        if (isalpha(p[1])  and  p[2] == ':')
            p += 3;
    }
    else if (isalpha(p[0])  and  p[1] == ':')
        p += 2;

    cp = (p == path ? NULL : p);
    for ( ;  *p != '\0';  p++)
    {
        if (*p == '\\'  or  *p == '/')
            cp = p;
    }

    if (cp == NULL)
    {
        /* Pathname has no directory prefix, assume the current directory */
        if (max <= 1)
        {
            errno = E2BIG;
            return (-1);
        }

        strcpy(dir, ".");
        return (1);
    }
    else
    {
        size_t	len;

        /* Extract the directory prefix from the pathname */
        len = cp - path;
        if (len >= max)
        {
            errno = E2BIG;
            return (-1);
        }

        memcpy(dir, path, len);
        dir[len] = '\0';
        return (len);
    }

#else
    #error Unsupported OS

#endif
}


/*------------------------------------------------------------------------------
* c0x_getfilename()
*	Extract the file component from a path name.
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
*	<http://david.tribble.com/text/c0xdir.html#func-getfilename>
*
* @since	1.1, 2003-12-26
*/

int c0x_getfilename(char *file, size_t max, const char *path)
{
#if defined(_unix)
    const char *	cp;
    const char *	tp;
    size_t		len;

    #if DEBUGS
        printf("$ getfilename(file=%08p, max=%u, path=%08p='%.9999s')\n",
            file, max, path, (path != NULL ? path : ""));
    #endif

    /* Find the filename suffix of the pathname */
    cp = strrchr(path, '/');
    cp = (cp == NULL ? path : cp+1);

    /* Extract the filename suffix from the pathname */
    len = strlen(cp);

    tp = strrchr(cp, '.');
    if (tp != NULL)
        len = tp - cp;

    if (len >= max)
    {
        errno = E2BIG;
        return (-1);
    }

    memcpy(file, cp, len);
    file[len] = '\0';
    return (len);

#elif defined(_WIN32)
    const char *	cp;
    const char *	tp;
    size_t		len;

    #if DEBUGS
        printf("$ getfilename(file=%08p, max=%u, path=%08p='%.9999s')\n",
            file, max, path, (path != NULL ? path : ""));
    #endif

    /* Skip the device/directory prefix of the pathname */
    if (path[0] == '\\'  and  path[1] == '\\')
    {
        path += 2;
        while (path[0] != '\0'  and  path[0] != '\\'  and  path[0] != '/')
            path++;
    }

    if (path[0] == '\\'  or  path[0] == '/')
    {
        if (isalpha(path[1])  and  path[2] == ':')
            path += 3;
    }
    else if (isalpha(path[0])  and  path[1] == ':')
        path += 2;

    cp = NULL;
    for (len = 0, tp = path;  *tp != '\0';  tp++, len++)
    {
        if (*tp == '\\'  or  *tp == '/')
            cp = tp;
    }
    cp = (cp == NULL ? path : cp+1);

    /* Extract the filename suffix from the pathname */
    len = strlen(cp);

    tp = strrchr(cp, '.');
    if (tp != NULL)
        len = tp - cp;

    if (len >= max)
    {
        errno = E2BIG;
        return (-1);
    }

    memcpy(file, cp, len);
    file[len] = '\0';
    return (len);

#else
    #error Unsupported OS

#endif
}


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
* @since	1.7, 2004-07-17
*/

int c0x_getfiletype(char *type, size_t max, const char *path)
{
#if defined(_unix)
    const char *	cp;
    size_t		len;

    #if DEBUGS
        printf("$ getfiletype(type=%08p, max=%u, path=%08p='%.9999s')\n",
            type, max, path, (path != NULL ? path : ""));
    #endif

    /* Find the type suffix of the pathname */
    cp = strrchr(path, '.');
    cp = (cp == NULL ? "" : cp+1);

    /* Extract the type suffix from the pathname */
    len = strlen(cp);

    if (len >= max)
    {
        errno = E2BIG;
        return (-1);
    }

    memcpy(type, cp, len+1);
    return (len);

#elif defined(_WIN32)
    const char *	cp;
    size_t		len;

    #if DEBUGS
        printf("$ getfiletype(type=%08p, max=%u, path=%08p='%.9999s')\n",
            type, max, path, (path != NULL ? path : ""));
    #endif

    /* Find the type suffix of the pathname */
    cp = strrchr(path, '.');
    cp = (cp == NULL ? "" : cp+1);

    /* Extract the type suffix from the pathname */
    len = strlen(cp);

    if (len >= max)
    {
        errno = E2BIG;
        return (-1);
    }

    memcpy(type, cp, len+1);
    return (len);

#else
    #error Unsupported OS

#endif
}


/*------------------------------------------------------------------------------
* makefilename()
*	Create a file or subdirectory name from a given directory name and a
*	given file or subdirectory name within that directory.
*	This is a static helper function.
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
*	c0x_mkdirname
*	c0x_mkfilename
*
* @since	1.6, 2004-07-16
*/

static int makefilename(char *path, size_t max, const char *dir,
    const char *file, const char *type)
{
#if defined(_unix)
    size_t	dlen;
    size_t	flen;
    size_t	tlen;
    char *	p;
    char	sep;

    /* Determine the sizes of the pathname components */
    sep = '/';
    dlen = strlen(dir);
    if (dlen == 0)
        sep = '\0';
    else if (dir[dlen-1] == '/')
        dlen--;

    flen = strlen(file);
    tlen = strlen(type);

    if (dlen + (sep == '\0' ? 0 : 1) + flen + (tlen > 0 ? 1 : 0) + tlen >= max)
    {
        errno = E2BIG;
        return (-1);
    }

    /* Combine the directory, name, and type components into a pathname */
    p = path;
    if (dlen > 0)
    {
        memcpy(p, dir, dlen);
        p += dlen;
    }

    if (sep != '\0')
        *p++ = '/';

    memcpy(p, file, flen);
    p += flen;

    if (tlen > 0)
    {
        *p++ = '.';
        memcpy(p, type, tlen);
        p += tlen;
    }

    *p++ = '\0';

    #if DEBUGS
        printf("$  >path=%08p='%.9999s',\n", path, path);
    #endif

    return (p - path);

#elif defined(_WIN32)
    size_t	dlen;
    size_t	flen;
    size_t	tlen;
    char *	p;

    /* Determine the sizes of the pathname components */
    dlen = strlen(dir);
    if (dir[dlen-1] == '/')
        dlen--;
    flen = strlen(file);
    tlen = strlen(type);

    if (dlen + 1 + flen + (tlen > 0 ? 1 : 0) + tlen >= max)
    {
        errno = E2BIG;
        return (-1);
    }

    /* Combine the directory, name, and type components into a pathname */
    p = path;
    memcpy(p, dir, dlen);
    p += dlen;
    if (isalpha(dir[0])  and  dir[1] == ':')
        dir += 2;
    if ((dir[0] != '\\'  and  dir[0] != '/')  or  dir[1] != '\0')
        *p++ = '\\';
    memcpy(p, file, flen);
    p += flen;
    if (tlen > 0)
    {
        *p++ = '.';
        memcpy(p, type, tlen);
        p += tlen;
    }
    *p = '\0';

    flen = GetFullPathName(path, max, path, &p);

    if (flen == 0  or  flen >= max)
    {
        errno = E2BIG;
        return (-1);
    }

    #if DEBUGS
        printf("$  >path=%08p='%.9999s',\n", path, path);
    #endif

    return (p - path);

#else
    #error Unsupported OS

#endif
}


/*------------------------------------------------------------------------------
* c0x_mkfilename()
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
*	<http://david.tribble.com/text/c0xdir.html#func-mkfilename>
*
* @since	1.1, 2003-12-26
*/

int c0x_mkfilename(char *path, size_t max, const char *dir, const char *file,
    const char *type)
{
    #if DEBUGS
        printf("$ mkfilename(path=%08p, max=%u, dir=%08p='%.9999s',\n"
                "$  file=%08p='%.9999s', type=%08p='%.9999s')\n",
            path, max,
            dir, (dir != NULL ? dir : ""),
            file, (file != NULL ? file : ""),
            type, (type != NULL ? type : ""));
    #endif

#if defined(_unix)
    return (makefilename(path, max, dir, file, type));

#elif defined(_WIN32)
    return (makefilename(path, max, dir, file, type));

#else
    #error Unsupported OS

#endif
}

/*------------------------------------------------------------------------------
* c0x_mkdirname()
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
*	<http://david.tribble.com/text/c0xdir.html#func-mkdirname>
*
* @since	1.5, 2004-01-10
*/

int c0x_mkdirname(char *path, size_t max, const char *dir, const char *subdir,
    const char *type)
{
    #if DEBUGS
        printf("$ mkdirname(path=%08p, max=%u, dir=%08p='%.9999s',\n"
                "$  subdir=%08p='%.9999s', type=%08p='%.9999s')\n",
            path, max,
            dir, (dir != NULL ? dir : ""),
            subdir, (subdir != NULL ? subdir : ""),
            type, (type != NULL ? type : ""));
    #endif

#if defined(_unix)
    return (makefilename(path, max, dir, subdir, type));

#elif defined(_WIN32)
    return (makefilename(path, max, dir, subdir, type));

#else
    #error Unsupported OS

#endif
}


/*------------------------------------------------------------------------------
* startsearch()
*	Initiate a search within a directory.
*	This is a static helper function.
*
* @param	dp
*	A directory searching context object to initialize.
*
* @param	path
*	The pathname to search for.
*
* @return
*	On success, the function initializes and returns pointer 'dp', and
*	returns a positive value.  On failure, the function returns a negative
*	value after modifying the value of 'errno'.
*
* @see
*	c0x_opendir()
*	c0x_rewinddir()
*	c0x_seekdir()
*
* @since	1.2, 2003-12-27
*/

static int startsearch(c0x_DIR *dp, const char *path)
{
#if defined(_unix)
    /* Create and initialize a directory searching context */
    memset(dp, 0, sizeof(c0x_DIR));

    dp->m_ctx = opendir(path);

    if (dp->m_ctx == NULL)
    {
        /* Cannot start the directory search, fail */
        errno = ENOENT;
        return (-1);
    }

    return (0);

#elif defined(_WIN32)
    size_t	len;

    /* Create and initialize a directory searching context */
    memset(dp, 0, sizeof(c0x_DIR));
    dp->m_path = NULL;
    dp->m_count = 0; 

    dp->m_hdl = FindFirstFile(path, &dp->m_ctx);

    if (dp->m_hdl == NULL  or  dp->m_ctx.cFileName[0] == '\0')
    {
        /* Cannot start the directory search, fail */
        errno = ENOENT;
        return (-1);
    }

    /* Success, save the search pathname */
    len = strlen(path);
    dp->m_path = (char *) malloc(len+1);
    memcpy(dp->m_path, path, len+1);

    return (0);

#else
    #error Unsupported OS

#endif
}


/*------------------------------------------------------------------------------
* c0x_opendir()
*	Initiate a search within a directory.
*
* @param	dir
*	The name of a directory to search.
*
* @return
*	On success, the function creates and returns a pointer to an object
*	containing context information for searching the specified directory.
*	This object can subsequently be passed to the other directory searching
*	functions, and is destroyed by a subsequent call to 'closedir()'.
*	On failure, the function returns null after modifying the value of
*	'errno'.
*
* @see
*	<http://david.tribble.com/text/c0xdir.html#func-opendir>
*
* @since	1.2, 2003-12-26
*/

c0x_DIR * c0x_opendir(const char *dir)
{
    c0x_DIR *	dp;
    char	path[_FNAME_MAX+1];

    #if DEBUGS
        printf("$ opendir(dir=%08p='%.9999s')\n",
            dir, (dir != NULL ? dir : ""));
    #endif

    /* Check args */
    if (dir == NULL)
    {
        errno = EFAULT;
        return (NULL);
    }

    if (dir[0] == '\0')
    {
        errno = EINVAL;
        return (NULL);
    }

    /* Create and initialize a directory searching context */
#if defined(_unix)
    c0x_mkfilename(path, sizeof(path), dir, "", "");
#elif defined(_WIN32)
    c0x_mkfilename(path, sizeof(path), dir, "*", "");
#endif
    dp = (c0x_DIR *) malloc(sizeof(c0x_DIR));

    if (startsearch(dp, path) < 0)
    {
        #if DEBUGS
            printf("$ opendir: fail\n");
        #endif

        /* Cannot start the directory search */
        free(dp);
        return (NULL);
    }

    /* Success */
    return (dp);
}


/*------------------------------------------------------------------------------
* c0x_stopsearch()
*	Terminate the directory search initiated by a previous call to
*	'opendir()'.  This is a static helper function.
*
* @param	dp
*	Points to the directory search context information that was returned by
*	a previous call to 'opendir()'.  If the pointer is null, the behavior is
*	undefined.
*
* @return
*	If successful, the search context pointed to by 'dp' is terminated and
*	the function returns a non-negative value.  On failure, the function
*	returns a negative value after modifying the value of 'errno'.
*
* @see
*	c0x_closedir()
*	c0x_readdir()
*	c0x_rewinddir()
*	c0x_seekdir()
*
* @since	1.2, 2003-12-26
*/

static int stopsearch(c0x_DIR *dp)
{
#if defined(_unix)
    int		rc;

    /* Check args */
    if (dp == NULL)
    {
        errno = EFAULT;
        return (-1);
    }

    if (dp->m_ctx == NULL)
    {
        errno = EINVAL;
        return (-1);
    }

    /* Terminate the directory search */
    rc = closedir(dp->m_ctx);
    dp->m_ctx = NULL;

    if (rc < 0)
    {
        errno = EIO;
        return (-1);
    }

    return (0);

#elif defined(_WIN32)
    int		rc;

    /* Check args */
    if (dp == NULL)
    {
        errno = EFAULT;
        return (-1);
    }

    if (dp->m_hdl == NULL)
    {
        errno = EINVAL;
        return (-1);
    }

    /* Terminate the directory search */
    rc = FindClose(dp->m_hdl);
    dp->m_hdl = NULL;

    if (not rc)
    {
        errno = EIO;
        return (-1);
    }

    return (0);

#else
    #error Unsupported OS

#endif
}


/*------------------------------------------------------------------------------
* c0x_closedir()
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
*	<http://david.tribble.com/text/c0xdir.html#func-closedir>
*
* @since	1.2, 2003-12-26
*/

int c0x_closedir(c0x_DIR *dp)
{
#if defined(_unix)
    int		rc;

    #if DEBUGS
        printf("$ closedir(dp=%08p)\n", dp);
    #endif

    /* Check args */
    if (dp == NULL)
    {
        errno = EFAULT;
        return (-1);
    }

    if (dp->m_ctx == NULL)
    {
        errno = EINVAL;
        return (-1);
    }

    /* Terminate and deallocate the directory searching context */
    rc = 0;
    if (dp->m_ctx != NULL)
        rc = stopsearch(dp);

    free(dp);
    return (rc);

#elif defined(_WIN32)
    int		rc;

    #if DEBUGS
        printf("$ closedir(dp=%08p)\n", dp);
    #endif

    /* Check args */
    if (dp == NULL)
    {
        errno = EFAULT;
        return (-1);
    }

    /* Terminate and deallocate the directory searching context */
    rc = 0;
    if (dp->m_hdl != NULL)
        rc = stopsearch(dp);

    if (dp->m_path != NULL)
    {
        dp->m_path[0] = '\0';
        free(dp->m_path);
        dp->m_path = NULL;
    }

    free(dp);
    return (rc);

#else
    #error Unsupported OS

#endif
}


/*------------------------------------------------------------------------------
* c0x_readdir()
*	Read the next entry contained within a directory being searched.
*
* @param	dp
*	Points to the directory search context information that was returned by a
*	previous call to 'opendir()'.  If the pointer is null, the behavior is
*	undefined.
*
* @return
*	If successful, a pointer to a structure is returned, where the structure
*	contains information about the next directory entry within the directory
*	search context.  The position of the search is advanced to the next directory
*	entry.
*	On failure, or if there are no more entries to be found in the directory
*	search, the function returns a null pointer after modifying the value of
*	'errno'.
*
* @see
*	<http://david.tribble.com/text/c0xdir.html#func-readdir>
*
* @since	1.2, 2003-12-26
*/

struct c0x_dirent * c0x_readdir(c0x_DIR *dp)
{
#if defined(_unix)
    struct dirent *	drent;
    struct c0x_dirent *	ent;
    size_t		nlen;
    size_t		tlen;
    char *		cp;

    #if DEBUGS
        printf("$ readdir(dp=%08p)\n", dp);
    #endif

    /* Check args */
    if (dp == NULL)
    {
        errno = EFAULT;
        return (NULL);
    }

    if (dp->m_ctx == NULL)
    {
        errno = EINVAL;
        return (NULL);
    }

    /* Search for the next directory entry */
    drent = readdir(dp->m_ctx);

    if (drent == NULL)
    {
        #if DEBUGS
            printf("$ readdir: end\n");
        #endif

        /* No more directory entries, fail */
        errno = ENOENT;
        return (NULL);
    }

    /* Copy the found filename entry */
    /*        0123456789012 345678901 2
    * m_name="filename.ext\0filename\0"
    *                  |    |    name="filename.ext", nlen=12 tlen=3
    *                  |    +- m_namoff=13, m_namlen=8
    *                  +- m_typeoff=9, m_typelen=3
    */
    /*        012345678 901234567 8
    * m_name="filename\0filename\0"
    *                  ||    name="filename", nlen=8 tlen=0
    *                  |+- m_namoff=9, m_namlen=8
    *                  +- m_typeoff=8, m_typelen=0
    */
    ent = &dp->m_ent;
#if defined(_linux)
    nlen = strlen(drent->d_name);
#else
    nlen = drent->d_namlen;
#endif
    memcpy(ent->d_name, drent->d_name, nlen+1);
    cp = strrchr(ent->d_name, '.');
    tlen = (cp == NULL ? 0 : nlen - (cp+1 - ent->d_name));
    tlen = (tlen < nlen ? tlen : 0);
    ent->d_typelen = tlen;
    ent->d_typeoff = nlen - tlen;
    ent->d_namlen = nlen - (tlen > 0 ? tlen+1 : 0);
    ent->d_namoff = nlen + 1;
    tlen += (tlen > 0 ? 1 : 0);
    memcpy(ent->d_name + nlen + 1, ent->d_name, nlen - tlen);
    ent->d_name[nlen + 1 + nlen - tlen] = '\0';

    return (ent);

#elif defined(_WIN32)
    struct c0x_dirent *	ent;
    size_t		nlen;
    size_t		tlen;
    char *		cp;

    #if DEBUGS
        printf("$ readdir(dp=%08p)\n", dp);
    #endif

    /* Check args */
    if (dp == NULL)
    {
        errno = EFAULT;
        return (NULL);
    }

    if (dp->m_hdl == NULL)
    {
        errno = EINVAL;
        return (NULL);
    }

    /* Search for the next directory entry */
    if (dp->m_count > 0)
    {
        if (not FindNextFile(dp->m_hdl, &dp->m_ctx))
        {
            #if DEBUGS
                printf("$ readdir: end\n");
            #endif

            /* No more directory entries, fail */
            errno = ENOENT;
            return (NULL);
        }
    }

    if (dp->m_ctx.cFileName[0] == '\0')
    {
        #if DEBUGS
            printf("$ readdir: end\n");
        #endif

        /* No more directory entries, fail */
        errno = ENOENT;
        return (NULL);
    }

    /* Copy the found filename entry */
    /*        0123456789012 345678901 2
    * m_name="filename.ext\0filename\0"
    *                  |    |    name="filename.ext", nlen=12 tlen=3
    *                  |    +- m_namoff=13, m_namlen=8
    *                  +- m_typeoff=9, m_typelen=3
    */
    /*        012345678 901234567 8
    * m_name="filename\0filename\0"
    *                  ||    name="filename", nlen=8 tlen=0
    *                  |+- m_namoff=9, m_namlen=8
    *                  +- m_typeoff=8, m_typelen=0
    */
    dp->m_count++;
    dp->m__r[0] = '\0';
    ent = &dp->m_ent;
    nlen = strlen(dp->m_ctx.cFileName);
    memcpy(ent->d_name, dp->m_ctx.cFileName, nlen+1);
    cp = strrchr(ent->d_name, '.');
    tlen = (cp == NULL ? 0 : nlen - (cp+1 - ent->d_name));
    tlen = (tlen < nlen ? tlen : 0);
    ent->d_typelen = tlen;
    ent->d_typeoff = nlen - tlen;
    ent->d_namlen = nlen - (tlen > 0 ? tlen+1 : 0);
    ent->d_namoff = nlen + 1;
    tlen += (tlen > 0 ? 1 : 0);
    memcpy(ent->d_name + nlen + 1, ent->d_name, nlen - tlen);
    ent->d_name[nlen + 1 + nlen - tlen] = '\0';

    return (ent);

#else
    #error Unsupported OS

#endif
}


/*------------------------------------------------------------------------------
* c0x_seekdir()
*	Restore the search position of a given directory search to a previously
*	ascertained position.
*
*	NOTE: This is not a function defined in the proposal.
*
* @param	dp
*	Points to the directory search context information that was returned by
*	a previous call to 'opendir()'.  If the pointer is null, the behavior is
*	undefined.
*
* @param	pos
*	A position within the directory search to return the search context to.
*	This value must have been obtained by a previous call to 'telldir()',
*	otherwise the behavior is undefined.
*
* @return
*	If successful, the directory search context is modified and the function
*	returns a non-negative value.  On failure, the function returns a
*	negative value after modifying the value of 'errno'.
*
* @see
*	c0x_rewinddir()
*
* @see
*	<http://david.tribble.com/text/c0xdir.html#func-seekdir>
*
* @since	1.2, 2003-12-26
*/

int c0x_seekdir(c0x_DIR *dp, long int pos)
{
#if defined(_unix)
    int		rc;

    #if DEBUGS
        printf("$ seekdir(dp=%08p, pos=%ld)\n",
            dp, pos);
    #endif

    /* Check args */
    if (dp == NULL)
    {
        errno = EFAULT;
        return (-1);
    }

    if (dp->m_ctx == NULL)
    {
        errno = EINVAL;
        return (-1);
    }

    /* Seek to the specified position */
    seekdir(dp->m_ctx, pos);
    return (0);

#elif defined(_WIN32)
    char *	path;

    #if DEBUGS
        printf("$ seekdir(dp=%08p, pos=%ld)\n",
            dp, pos);
    #endif

    /* Check args */
    if (dp == NULL)
    {
        errno = EFAULT;
        return (-1);
    }

    if (dp->m_hdl == NULL)
    {
        errno = EINVAL;
        return (-1);
    }

    /* Terminate the search */
    if (stopsearch(dp) != 0)
        return (-1);

    /* Restart the directory search */
    path = dp->m_path;
    if (startsearch(dp, path) < 0)
    {
        /* Cannot restart the directory search */
        dp->m_path = path;
        return (-1);
    }

    /* Skip entries up to the specified seek position */
    while ((long int)dp->m_count < pos)
    {
        /* Skip the next entry */
        if (c0x_readdir(dp) == NULL)
            return (-1);
    }

    return (0);

#else
    #error Unsupported OS

#endif
}


/*------------------------------------------------------------------------------
* c0x_telldir()
*	Determine the current position of a directory search.
*
*	NOTE: This is not a function defined in the proposal.
*
* @param	dp
*	Points to the directory search context information that was returned by
*	a previous call to 'opendir()'.  If the pointer is null, the behavior is
*	undefined.
*
* @return
*	If successful, the function returns a non-negative value indicating the
*	current position of the directory search.  This value may be passed to
*	the 'seekdir()' function for the same directory search context.  On
*	failure, the function returns a negative value after modifying the value
*	of 'errno'.
*
* @see
*	<http://david.tribble.com/text/c0xdir.html#func-telldir>
*
* @see
*	c0x_rewinddir()
*
* @since	1.2, 2003-12-26
*/

long int c0x_telldir(c0x_DIR *dp)
{
#if defined(_unix)
    long int	pos;

    #if DEBUGS
        printf("$ telldir(dp=%08p)\n", dp);
    #endif

    /* Check args */
    if (dp == NULL)
    {
        errno = EFAULT;
        return (-1);
    }

    if (dp->m_ctx == NULL)
    {
        errno = EINVAL;
        return (-1);
    }

    /* Retrieve the current search position */
    pos = telldir(dp->m_ctx);

    return (pos < 0 ? -1 : pos);

#elif defined(_WIN32)
    #if DEBUGS
        printf("$ telldir(dp=%08p)\n", dp);
    #endif

    /* Check args */
    if (dp == NULL)
    {
        errno = EFAULT;
        return (-1L);
    }

    if (dp->m_hdl == NULL)
    {
        errno = EINVAL;
        return (-1L);
    }

    #if DEBUGS
        printf("$ telldir: %ld\n", (long) dp->m_count);
    #endif

    /* Retrieve the current search position */
    return ((long) dp->m_count);

#else
    #error Unsupported OS

#endif
}


/*------------------------------------------------------------------------------
* c0x_rewinddir()
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
*	<http://david.tribble.com/text/c0xdir.html#func-rewinddir>
*
* @since	1.3, 2003-12-29
*/

int c0x_rewinddir(c0x_DIR *dp)
{
    #if DEBUGS
        printf("$ rewinddir(dp=%08p)\n", dp);
    #endif

#if defined(_unix)
    /* Seek to the beginning of the directory */
    return (c0x_seekdir(dp, 0L));

#elif defined(_WIN32)
    /* Seek to the beginning of the directory */
    return (c0x_seekdir(dp, 0L));

#else
    #error Unsupported OS

#endif
}

/* End c0xdir.c */

