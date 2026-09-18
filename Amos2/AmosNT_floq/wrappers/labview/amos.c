#include <windows.h>
#include <extcode.h>
#include "callout.h"

a_connection amos_labview_connection = NULL;
extern int amos_initialized;
int amos_init_count = 0;

CRITICAL_SECTION lv_cs;
#define ECS(x) EnterCriticalSection(&x)
#define LCS(x) LeaveCriticalSection(&x)

void __declspec(dllexport) amos_get_error(int error_num, LStrHandle *error_str)
{
	DSDisposeHandle(*error_str);
	*error_str = (LStrHandle) DSNewHClr((40 + strlen(a_errstr)) * sizeof(char));
	LStrPrintf(*error_str, "Error %d: %s", error_num, a_errstr);
}

int __declspec(dllexport) scan_open_query(char *code, unsigned int *scan)
{
	int error = 0, finished = 0;
	ECS(lv_cs);
	{
		unwind_protect_begin;
		a_let(*scan, call_lisp(mksymbol("open-query-scan"), topframe(), 1, mkstring(code)));
		finished = 1;
		unwind_protect_catch;
		if (!finished)
			error = a_errno;
	}
	LCS(lv_cs);
	return error;
}

int __declspec(dllexport) scan_open_function(char *fn, unsigned int tuple, unsigned int *scan)
{
	int error = 0, finished = 0;
	dcloid(fno);
	ECS(lv_cs);
	{
		unwind_protect_begin;
		a_let(fno, call_lisp(mksymbol("theresolvent"), topframe(), 1, mkstring(fn)));
		a_let(*scan, call_lisp(mksymbol("open-function-scan"), topframe(), 2, fno, tuple));
		finished = 1;
		unwind_protect_catch;
		if (!finished)
			error = a_errno;
		else if (fno != nil)
			a_free(fno);
	}
	LCS(lv_cs);
	return error;
}

int __declspec(dllexport) scan_nextrow(unsigned int scan, unsigned int *tuple)
{
	int error = 0, finished = 0;
	ECS(lv_cs);
	{
		unwind_protect_begin;
		a_setf(*tuple, call_lisp(mksymbol("scan-nextrow"), topframe(), 1, scan));
		finished = 1;
		unwind_protect_catch;
		if (!finished)
			error = a_errno;
		}
	LCS(lv_cs);
	return error;
}

int __declspec(dllexport) scan_eos(unsigned int scan, int *ret)
{
	int error = 0, finished = 0;
	dcloid(value);
	ECS(lv_cs);
	{
		unwind_protect_begin;
		a_let(value, call_lisp(mksymbol("scan-eos"), topframe(), 1, scan));
		finished = 1;
		unwind_protect_catch;
		if (!finished)
			error = a_errno;
		else if (value == nil)
			*ret = 0;
		else
			*ret = 1;
	}
	if (value != nil)
		a_free(value);
	LCS(lv_cs);
	return error;
}

int __declspec(dllexport) scan_close(unsigned int scan)
{
	int error = 0, finished = 0;
	ECS(lv_cs);
	{
		unwind_protect_begin;
		release(call_lisp(mksymbol("scan-close"), topframe(), 1, scan));
		finished = 1;
		unwind_protect_catch;
		a_free(scan);
		if (!finished)
			error = a_errno;
	}
	LCS(lv_cs);
	return error;
}

/* Tuple operations */

void __declspec(dllexport) init_tuple(unsigned int *tuple)
{
	ECS(lv_cs);
	if (*tuple != 0)
	{
		a_free(*tuple);
		*tuple = 0;
	}
	LCS(lv_cs);
}

int __declspec(dllexport) build_tuple_add_string(unsigned int *tuple, char *str)
{
	int error = 0, finished = 0;
	ECS(lv_cs);
	{
		unwind_protect_begin;
		a_setf(*tuple, call_lisp(mksymbol("cons"), topframe(), 2, mkstring(str), *tuple));
		finished = 1;
		unwind_protect_catch;
		if (!finished)
			error = a_errno;
	}
	LCS(lv_cs);
	return error;
}

int __declspec(dllexport) build_tuple_add_dbl(unsigned int *tuple, double dbl)
{
	int error = 0, finished = 0;
	ECS(lv_cs);
	{
		unwind_protect_begin;
		a_setf(*tuple, call_lisp(mksymbol("cons"), topframe(), 2, mkreal(dbl), *tuple));
		finished = 1;
		unwind_protect_catch;
		if (!finished)
			error = a_errno;
	}
	LCS(lv_cs);
	return error;
}

int __declspec(dllexport) build_tuple_add_int(unsigned int *tuple, int val)
{
	int error = 0, finished = 0;
	ECS(lv_cs);
	{
		unwind_protect_begin;
		a_setf(*tuple, call_lisp(mksymbol("cons"), topframe(), 2, mkinteger(val), *tuple));
		finished = 1;
		unwind_protect_catch;
		if (!finished)
			error = a_errno;
	}
	LCS(lv_cs);
	return error;
}

void __declspec(dllexport) tuple_getinteger(unsigned int tuple, int *value)
{
	ECS(lv_cs);
	*value = getinteger(fhd(tuple));
	LCS(lv_cs);
}

void __declspec(dllexport) tuple_getreal(unsigned int tuple, double *value)
{
	ECS(lv_cs);
	*value = getreal(fhd(tuple));
	LCS(lv_cs);
}

/* Amos objects */

void __declspec(dllexport) amos_oidtype(unsigned int *o)
{
	*o = nil;
}

void __declspec(dllexport) amos_a_free(unsigned int oid)
{
	ECS(lv_cs);
	if (oid != nil)
		a_free(oid);
	LCS(lv_cs);
}

/* Amos initialization */

int __declspec(dllexport) amos_init()
{
	int error = 0;
	size_t len;
	char *amos, *amos_dmp = "bin\\amos2.dmp";

	if (amos_labview_connection == NULL)
	{
#ifdef NT
  InitializeCriticalSection(&lv_cs);
#else
  pthread_mutexattr_setkind_np(&lv_cs_attr, PTHREAD_MUTEX_RECURSIVE_NP);
  pthread_mutex_init(&lv_cs, &lv_cs_attr);
#endif

		ECS(lv_cs);
		if ((len = GetEnvironmentVariable("AMOS_HOME", NULL, 0)) == 0)
		{
			DbgPrintf("AMOS_HOME not defined!");
			return -1;
		}
		amos = _alloca(len + strlen(amos_dmp) + 1);
		if (GetEnvironmentVariable("AMOS_HOME", amos, len) == 0)
		{
			DbgPrintf("Could not retrieve AMOS_HOME!");
			return -1;
		}
		strcat(amos, amos_dmp);

		amos_labview_connection = a_init_connection();
		error = a_initialize(amos, TRUE);
		if (error == 0)
			error = a_connect(amos_labview_connection, "", TRUE);
		else
			DbgPrintf("Amos initialization failed!");
		LCS(lv_cs);
	}
	return error;
}

/*
int __declspec(dllexport) amos_init()
{
	if (!amos_initialized)
		return a_errno;
	return 0;
}

MgErr __declspec(dllexport) amos_load()
{
	int error = 0;
	size_t len;
	char *amos, *amos_dmp = "bin\\amos2.dmp";

	if (amos_init_count++ == 0 && !amos_initialized)
	{
		if ((len = GetEnvironmentVariable("AMOS_HOME", NULL, 0)) == 0)
		{
			DbgPrintf("AMOS_HOME not defined!");
			return -1;
		}
		amos = _alloca(len + strlen(amos_dmp) + 1);
		if (GetEnvironmentVariable("AMOS_HOME", amos, len) == 0)
		{
			DbgPrintf("Could not retrieve AMOS_HOME!");
			return -1;
		}
		strcat(amos, amos_dmp);

		amos_labview_connection = a_init_connection();
		error = a_initialize(amos, TRUE);
		if (error == 0)
			error = a_connect(amos_labview_connection, "", TRUE);
		else
			DbgPrintf("Amos initialization failed!");
	}
	DbgPrintf("init count: %d", amos_init_count);
	return error;
}

MgErr __declspec(dllexport) amos_unload()
{
	if (--amos_init_count == 0)
		; // TODO: unload
	DbgPrintf("init count: %d", amos_init_count);
	return 0;
}
*/