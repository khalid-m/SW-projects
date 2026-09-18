AC_PREREQ(2.61)
AC_INIT([Amosgsl], [0.11], [Tim <timl@treshna.com>], [amosgsl])
AC_CONFIG_AUX_DIR(config)
AC_CANONICAL_SYSTEM
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_SRCDIR(README)
AC_CONFIG_MACRO_DIR([m4])

dnl For fairly severe build strictness change foreign to gnu
dnl or gnits to comply with GNU standards.
AM_INIT_AUTOMAKE([dist-bzip2 -Wall -Werror foreign 1.9.6])

dnl Checks for programs.
AC_PROG_CC
AM_PROG_CC_C_O
AC_LANG_C
AC_ENABLE_SHARED
AC_PROG_LIBTOOL


dnl Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([stdlib.h])

dnl Checks for typedefs, structures, and compiler characteristics.
case "$target" in
  *-linux*-*)
  AC_DEFINE([LINUX], 1, [We are running this on Linux])
  AC_DEFINE([UNIX], 1, [We are running this on *nix])
  AC_DEFINE([_unix], 1, [We are running this on *nix])
  AC_DEFINE([_linux], 1, [We are running this on Linux])
        ;;
esac

dnl Checks for libraries
AC_CHECK_LIBM
dnl AC_CHECK_LIB([m],[cos])

dnl Check for a BLAS interface (Atlas, netlib) and sets
dnl BLAS_LIBS.  Should link with $BLAS_LIBS $LIBS $FLIBS
ACX_BLAS

dnl Checks for library functions
AC_FUNC_MALLOC

dnl BEGIN: GSL/BLAS/AMOSBLAS tests

dnl (gsl/configure.ac) Checks for typedefs, structures, and
dnl compiler characteristics.
case "$host_os" in
     *mingw*)
	MINGW=true
	;;
esac
AM_CONDITIONAL(MINGW32_HOST, test "$MINGW" = "true")

dnl BEGIN: Debugging

dnl Configure options: --enable-debug[=no].
AC_ARG_ENABLE([debug],
  [AS_HELP_STRING([--enable-debug],
    [enable debug code (default is no)])],
  [debug="$enableval"], [debug=no])

dnl Configure DEBUG source code, if requested.
if test "x$debug" != xno; then
  AC_DEFINE([DEBUG], [], [Define to enable debugging features])
fi
dnl END: Debugging


dnl BEGIN: tests check dependencies
AC_ARG_ENABLE([tests], 
  [AS_HELP_STRING([--enable-tests],
                  [compile unit tests using check (default is no)])],
  [enable_tests="$enableval"], 
  [enable_tests=no])

dnl Check check if tests are enabled
if test "x$enable_tests" != xno; then
   PKG_CHECK_MODULES([CHECK], [check >= 0.9.4], [enable_tests=yes], [enable_tests=no])
   AC_SUBST(CHECK_CFLAGS)
   AC_SUBST(CHECK_LIBS)
fi 
dnl Add test directory if check is found and tests enabled
if test "x$enable_tests" != xno; then
   AC_CONFIG_FILES([tests/Makefile])
fi
AM_CONDITIONAL(WITH_TESTS, test "x$enable_tests" = "xyes")
dnl END: tests

dnl ** GSL is required **
PKG_CHECK_MODULES(GSL, gsl >= 1.11)
AC_SUBST(GSL_CFLAGS)
AC_SUBST(GSL_LIBS)

dnl Use locally built amos2 if it exists : amos2 pkg-config 
PKG_CONFIG_PATH+=:.:../amos2
dnl ** Amos2 is required **
PKG_CHECK_MODULES(AMOS2, amos2)
AC_SUBST(AMOS2_CFLAGS)
AC_SUBST(AMOS2_LIBS)

dnl END: GSL/BLAS/AMOSBLAS tests


dnl Place cplusplus check macro at the top of config.h,
dnl instead of in each header.
AH_TOP([
#ifdef __cplusplus
#  define BEGIN_C_DECLS extern "C" {
#  define END_C_DECLS   }
#else /* !__cplusplus */
#  define BEGIN_C_DECLS
#  define END_C_DECLS
#endif /* __cplusplus */
])

AMOSGSL_CFLAGS="-I$includedir"
AMOSGSL_LIBS="-L$libdir -lamosgsl"

AC_SUBST(AMOSGSL_CFLAGS)
AC_SUBST(AMOSGSL_LIBS)

AC_SUBST(DUMP_FILE, ../amosgsl.dmp)
AC_SUBST(DATADIR, $datadir)
AC_DEFINE_UNQUOTED([DUMP_FILE], ["${DUMP_FILE}"], [The default Amos data dump file.])

dnl Output files
AC_CONFIG_FILES([Makefile
  amosgsl-uninstalled.pc
  amosgsl.pc
  atlas.pc])

AC_OUTPUT
