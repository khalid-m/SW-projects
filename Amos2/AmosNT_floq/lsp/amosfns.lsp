;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1998 Tore Risch, el al EDSLAB, UDBL
;;; $RCSfile: amosfns.lsp,v $
;;; $Revision: 1.319 $ $Date: 2013/11/20 22:08:55 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Basic AmosQL built in functions
;;; =============================================================
;;; $Log: amosfns.lsp,v $
;;; Revision 1.319  2013/11/20 22:08:55  torer
;;; nil tolerant aggregate functions
;;;
;;; Revision 1.318  2013/06/26 17:45:26  torer
;;; Reverting (CO-SLEEP)
;;;
;;; Revision 1.316  2013/05/26 20:48:42  torer
;;; Function returning startup folder of system:
;;; startup_dir();
;;;
;;; Revision 1.315  2013/05/20 10:05:41  torer
;;; new function
;;; stats(bag of Number) -> (Number mean, Number stdev, Number min, Number max)
;;;
;;; Revision 1.314  2013/03/27 16:18:35  torer
;;; CSV reader now in C and following EXCEL's format
;;; 2.63 times faster
;;;
;;; Revision 1.313  2013/03/23 12:04:43  torer
;;; rand() in C
;;;
;;; Revision 1.312  2013/03/06 21:17:20  torer
;;; New functions
;;; load_extension(Charstring ext)->Boolean
;;; reload_extension(Charstring ext)->Boolean
;;;
;;; Revision 1.311  2013/02/17 14:42:46  torer
;;; New functiion identity(Object x)->Object
;;; Removed problem with queries coercing numbers to integers
;;;
;;; Revision 1.310  2012/11/08 16:17:31  torer
;;; New function
;;; exposeSource(Boolean);
;;;
;;; Revision 1.309  2012/10/23 19:50:38  torer
;;; added theType(Charstring tpn)->Type
;;;
;;; Revision 1.308  2012/10/12 07:24:27  torer
;;; Reverted kernel C bug
;;;
;;; Revision 1.306  2012/09/06 20:40:58  torer
;;; New Lisp functions to (un)-trace AmosQL functions
;;; (osql-TRACE FNS) and (OSQL-UNTRACE FNS)
;;;
;;; Revision 1.305  2012/08/13 21:22:48  chexu484
;;; stream operator changed(Stream s) -> Stream
;;;
;;; Revision 1.304  2012/08/13 21:11:19  chexu484
;;; stream operator:
;;; changed(Stream s) -> Stream
;;;
;;; Revision 1.303  2012/05/12 13:16:04  torer
;;; average() -> avg()
;;;
;;; Revision 1.302  2012/03/28 09:28:24  torer
;;; Streaming evalv()
;;;
;;; Revision 1.301  2012/03/27 13:03:16  torer
;;; Error message when trying to load extension twice
;;;
;;; Revision 1.300  2012/03/15 17:13:22  zeitler
;;; function_cardinality(function f)->integer:
;;; Compute count(f) of a stored function using its index
;;;
;;; Revision 1.299  2012/02/27 19:52:46  torer
;;; Transients always invisible
;;;
;;; Revision 1.298  2012/02/15 15:31:41  torer
;;; Verbose pc() when _save-intermediates_ not null
;;;
;;; Revision 1.297  2012/02/13 19:22:47  torer
;;; Corrected signatures
;;;
;;; Revision 1.296  2012/02/11 14:59:36  torer
;;; Simpler AmosQL pc()
;;;
;;; Revision 1.295  2012/01/16 13:13:15  torer
;;; Removed obsolete functions
;;;
;;; Revision 1.294  2012/01/15 11:58:17  torer
;;; Nicer messages
;;;
;;; Revision 1.293  2012/01/15 11:08:12  torer
;;; Master comments on Amos functions
;;;
;;; Revision 1.292  2011/12/28 16:09:50  torer
;;; Stricter cost model for shallow-extent
;;;
;;; Revision 1.291  2011/12/22 12:55:14  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.290  2011/12/14 20:06:06  torer
;;; Added warnings for coersions
;;; Removed coresion storage leak
;;;
;;; Revision 1.289  2011/12/01 09:48:03  larme597
;;; Moving stream functions start_at and first_n to Amos.
;;;
;;; Revision 1.288  2011/11/19 17:30:18  torer
;;; Optional error trap in load-extension
;;;
;;; Revision 1.287  2011/11/19 14:06:54  torer
;;; Choice between loading extensions transistently or persistently
;;;
;;; Revision 1.286  2011/10/11 15:04:30  torer
;;; avgstdev with key
;;;
;;; Revision 1.285  2011/10/05 20:48:45  torer
;;; Corrected signature of
;;;   apply(Function fn, Vector args) -> Bag of Vector res
;;;
;;; Revision 1.284  2011/05/20 14:19:41  torer
;;; New function
;;;   extlang(Charstring language)->Boolean
;;; to enable arbitrary external language (i.e. only Python currently)
;;;
;;; Revision 1.283  2011/04/12 20:57:12  torer
;;; remove_null to kernel
;;;
;;; Revision 1.282  2011/02/16 18:47:28  torer
;;; 1. Correct signature for evalv and eval
;;; 2. tuples_in -> tuples
;;;
;;; Revision 1.281  2011/02/16 17:45:38  torer
;;; evalv of empty result -> empty result
;;;
;;; Revision 1.280  2011/02/14 19:46:52  torer
;;; Corrected result type of tuples_in
;;;
;;; Revision 1.279  2011/01/31 06:52:40  torer
;;; New function
;;;   output_lines(Number)->Number
;;; to control # lines to print on terminal
;;;
;;; Revision 1.278  2011/01/29 11:32:49  torer
;;; Forgot a few changes
;;;
;;; Revision 1.277  2011/01/29 11:04:38  torer
;;; Base system uses (...) tuple notation, 'return' statement, and systematic indentation
;;;
;;; Revision 1.276  2011/01/21 07:29:39  torer
;;; debugging(true); enables debug mode without escaping to Lisp
;;;
;;; Revision 1.275  2011/01/19 15:52:59  torer
;;; storagestat(true); to turn on storage statistics
;;;
;;; Revision 1.274  2011/01/15 12:49:59  torer
;;; declare_key can handle -> Bag of <...>
;;;
;;; Revision 1.273  2011/01/06 15:41:03  torer
;;; section over bags renamed to bsection to remove overloading
;;;
;;; Revision 1.272  2011/01/05 10:33:27  torer
;;; Return value of profiling function
;;;
;;; Revision 1.271  2011/01/05 10:28:39  torer
;;; New foreign function to control statistical profiling:
;;;   profiling("on");    Turn on statistical profiling of Amos functions
;;;   profiling("print"); Print profiling report of % spent in functions
;;;   profiling("off");   Turn off statistical profiling
;;;   profiling("all");   Turn on full statistical profiling of both Lisp and
;;;                       Amos functions
;;;
;;; Revision 1.270  2011/01/04 12:07:30  torer
;;; New function to debug ObjectLog: help(tp x)->tp
;;;
;;; Revision 1.269  2011/01/01 19:18:19  torer
;;; Integer -> Number for no argument coersion
;;;
;;; Revision 1.268  2010/12/29 21:28:44  torer
;;; hook before-init-commands-forms renamed to CONNECT-FORMS!
;;;
;;; Revision 1.267  2010/12/29 21:24:53  torer
;;; Hook before-init-commands-forms renamed to simply COMMAND-FORMS
;;;
;;; Revision 1.266  2010/12/29 20:35:29  torer
;;; Removed Java related code
;;;
;;; Revision 1.265  2010/12/25 21:40:17  torer
;;; (Partial) aggregate functions in C now work correctly
;;; Common aggregate functions now in C
;;;
;;; Revision 1.264  2010/12/09 20:14:45  torer
;;; Revert
;;;
;;; Revision 1.262  2010/10/30 11:14:07  torer
;;; Bug when combining autosave(..) and save .. fixed
;;;
;;; Revision 1.261  2010/09/09 08:04:24  torer
;;; Corrected signature of extent
;;;
;;; Revision 1.260  2010/09/08 18:07:18  torer
;;; Invertible apply
;;;
;;; Revision 1.259  2010/09/07 21:07:04  torer
;;; Integer -> Number in function arguments to avoid coersion
;;;
;;; Revision 1.258  2010/09/02 15:01:12  torer
;;; Caching failed compilations
;;;
;;; Revision 1.257  2010/08/27 07:49:55  torer
;;; Type inference of {} in function arguments
;;;
;;; Revision 1.256  2010/08/25 20:52:18  torer
;;; New function dropfunction(Function fn, Integer permanent)->Function
;;;
;;; Revision 1.254  2010/05/04 09:23:22  torer
;;; Added hook just before loading init file
;;;
;;; Revision 1.253  2010/04/14 08:28:50  torer
;;; New function register_saver(Function savefn, Function restorefn)->Boolean
;;;
;;; Revision 1.252  2010/03/27 14:52:37  torer
;;; apply(Function fn, Vector argl) now works also for generic functions
;;;
;;; Revision 1.251  2010/03/13 14:38:52  torer
;;; UNCACHE-COSTS did not clear TBR costs
;;;
;;; Revision 1.250  2010/02/25 21:23:06  torer
;;; New function signature(Function)->Bag of Charstring
;;;
;;; Revision 1.249  2010/02/25 16:19:24  zeitler
;;; Cost hint for mod 'bbb'
;;;
;;; Revision 1.248  2010/02/17 20:27:06  torer
;;; Checking for function existence when creating index
;;;
;;; Revision 1.247  2010/02/17 19:10:43  torer
;;; More informative indexes(Function)
;;;
;;; Revision 1.246  2009/12/14 22:06:49  torer
;;; Equality as foreign predicate in C
;;;
;;; Revision 1.245  2009/12/13 20:58:47  torer
;;; AmosQL function storagestat()
;;;
;;; Revision 1.244  2009/12/07 19:19:47  torer
;;; Variable width first and last
;;;
;;; Revision 1.243  2009/11/16 20:06:33  torer
;;; Strict use of 'in'
;;;
;;; Revision 1.242  2009/11/12 22:08:50  torer
;;; Smarter cost uncaching
;;;
;;; Revision 1.241  2009/11/12 20:18:36  torer
;;; Improved cost caching
;;;
;;; Revision 1.240  2009/11/07 13:15:21  torer
;;; New functions to investigate TBR plans
;;;   pc(Charstring fn, Charstring bpat)->Function
;;;   plan_cost(Charstring fn, Charstring bpat)-> <Real cost, Real fanout>
;;;   theTBR(Function fno, Charstring bpat)->Function
;;;
;;; Revision 1.239  2009/11/05 16:55:57  zeitler
;;; last() emits the last element of a bag (cf. first())
;;;
;;; Revision 1.238  2009/11/02 17:34:11  zeitler
;;; vsum(vector of number) -> number returns the sum of elements
;;;
;;; Revision 1.237  2009/11/01 21:25:56  zeitler
;;; Over- and underflow problems fixed in avgstdev
;;;
;;; Revision 1.236  2009/10/19 09:57:11  torer
;;; Roundoff error in avgstdev
;;;
;;; Revision 1.235  2009/10/07 19:56:56  zeitler
;;; read-ntuples: read is replaced by read-token
;;; write-ntuples: prin1 is replaced by princ to avoid escape characters
;;;
;;; Revision 1.234  2009/10/02 20:22:15  zeitler
;;; Name change:
;;; avgstdev(vector)-><real,real>
;;; replaced by
;;; vavgstdev(vector)-><real,real>
;;;
;;; New function: avgstdev(bag of number)-><real,real>
;;;
;;; Revision 1.233  2009/09/30 15:11:01  zeitler
;;; first(bag)->object
;;; emits first element of a bag and returns immediately
;;;
;;; Revision 1.232  2009/09/09 13:24:34  zeitler
;;; read_ntuples
;;; write_ntuples
;;; generic representation of tuples (vectors) on rows
;;;
;;; Revision 1.231  2009/09/09 11:19:10  zeitler
;;; ntuples is the name!
;;;
;;; Revision 1.230  2009/09/09 11:10:10  zeitler
;;; - euclid(vector of number, vector of number)->real
;;;
;;; - ntriples(bag of vector rowset, charstring outputfile)->charstring
;;;   export bag of vector to file
;;;
;;; Revision 1.229  2009/09/02 17:21:40  torer
;;; Checking tuple positions when sorting
;;;
;;; Revision 1.228  2009/08/22 07:11:32  msabesan
;;; added options
;;;
;;; Revision 1.226  2009/08/21 15:03:54  msabesan
;;; logfile(Charstring filename, Integer loglevel) added
;;;
;;; Revision 1.225  2009/05/07 15:12:02  torer
;;; Documentation of global variables
;;;
;;; Revision 1.224  2009/05/05 18:56:03  torer
;;; Using STRING-LIKE-I
;;;
;;; Revision 1.223  2009/05/02 17:23:17  torer
;;; Removed _image_file_
;;;
;;; Revision 1.222  2009/04/29 20:51:26  torer
;;; Boolean values in foreign functions treated as other values
;;;
;;; Revision 1.221  2009/04/22 17:35:44  torer
;;; ALisp now stand-alone sub-module
;;;
;;; Revision 1.220  2009/04/11 12:26:07  torer
;;; Use of CommonLisp's generalized APPLY simplifies dynamic calls to OSQL-RESULT
;;;
;;; Revision 1.219  2009/03/06 19:05:41  torer
;;; readlines returns stream of charstring
;;;
;;; Revision 1.218  2009/03/06 15:50:57  gyogi445
;;; bag.integer.integer.section->bag ==> stream.integer.integer.section->stream
;;;
;;; Revision 1.217  2009/03/06 07:53:47  torer
;;; ceiling and round to C
;;;
;;; Revision 1.216  2008/12/25 19:24:56  torer
;;; Global variable _USE_DNF_ --> Special variable *use-dnf*
;;;
;;; Revision 1.215  2008/12/06 12:41:49  torer
;;; First argument in concat overloading of '+' must be string, otherwise confusing
;;;
;;; Revision 1.214  2008/12/05 18:34:11  torer
;;; plus(object,object)->Charstring implements concat
;;;
;;; Revision 1.213  2008/11/23 15:00:25  torer
;;; Stricter type checking
;;;
;;; Revision 1.212  2008/11/17 20:04:31  torer
;;; Removed checkequal as it did not always work
;;;
;;; Revision 1.211  2008/11/12 20:16:01  torer
;;; pc(Function fn)->Bag of Function
;;;
;;; Revision 1.210  2008/11/11 19:12:35  torer
;;; Speed of #'xxx' more than 500 times faster!
;;;
;;; Revision 1.209  2008/10/30 18:54:51  torer
;;; Regression test in AmosQL:
;;;
;;; CHECKEQUAL(Charstring tag, Vector tests)->Boolean ok
;;;
;;; Revision 1.208  2008/08/19 09:43:59  torer
;;; Reult type Boolean handled
;;;
;;; Revision 1.207  2008/08/15 11:47:41  torer
;;; Transactional interface variables
;;;
;;; Revision 1.206  2008/08/14 14:47:16  torer
;;; Added function extent(Type)->Bag of Object
;;;
;;; Revision 1.204  2008/07/31 20:25:19  torer
;;; readlines(Charstring file, Charstring delim)->Bag of Charstring
;;; now takes 2nd argument as delimiter between lines. Must be single character.
;;;
;;; not_empty(Charstring str)->Boolean
;;; returns TRUE if STR contains some character that is not whitespace (CR, LF, TAB, SPACE)
;;;
;;; Revision 1.203  2008/07/28 13:54:41  torer
;;; New function
;;;   readlines(Charstrin file)->Bag of Charsting
;;; to read lines from file as bag (stream) of strings
;;;
;;; Revision 1.202  2008/04/03 15:00:48  torer
;;; reopt.lsp depatched
;;;
;;; Revision 1.201  2008/02/01 13:00:25  torer
;;; Calling variable arity plusbbf
;;;
;;; Revision 1.200  2007/11/20 19:20:55  torer
;;; New function to asyncrously call function in peer:
;;;   ship_call(Charstring peer, Function f, Vector args)->Boolean
;;;
;;; Revision 1.199  2007/11/05 16:49:11  torer
;;; apply-pred-+ now handles boolean results correctly
;;;
;;; Revision 1.198  2007/10/30 12:30:43  torer
;;; Function APPLY introduced in AmosQL
;;;
;;; Revision 1.197  2007/10/24 21:14:54  torer
;;; Code moved to make modules independent
;;;
;;; Revision 1.196  2007/10/24 20:31:27  torer
;;; _static_funcs_ added for bootability
;;;
;;; Revision 1.195  2007/10/22 22:32:49  torer
;;; System function MAKEBAG now in C
;;;
;;; Revision 1.194  2007/10/19 13:51:24  torer
;;; _startup-dir_ used
;;;
;;; Revision 1.193  2007/10/18 13:12:36  torer
;;; Now calling FUNCTION-ARGVARS and FUNCTION-RESVARS
;;;
;;; Revision 1.192  2007/10/11 12:20:52  torer
;;; ObjectLog assignments in C
;;;
;;; Revision 1.191  2007/10/10 06:49:33  torer
;;; - for strings removed as it is ambigous
;;;
;;; Revision 1.190  2007/10/09 19:01:33  torer
;;; String - not commutative
;;;
;;; Revision 1.189  2007/10/09 18:19:14  torer
;;; Invertible string concatenation
;;;
;;; Revision 1.188  2007/10/08 09:26:39  silvias
;;; OID_NR now invertible
;;;
;;; Revision 1.187  2007/09/17 04:22:47  torer
;;; Correct handling of NIL in median (failure) so that subsequent arithmetics
;;; never breaks + regression
;;;
;;; Revision 1.186  2007/09/16 20:54:26  torer
;;; New function median(vector)->real in C
;;;
;;; Revision 1.185  2007/09/10 11:07:06  torer
;;; Cost added to remote call_function
;;;
;;; Revision 1.184  2007/09/05 10:56:51  torer
;;; Remote call to Amos II function:
;;;   call_function(Charstring peer, Charstring fn, Vector args, Number stopafter)->Vector
;;;
;;; Revision 1.183  2007/09/03 16:05:54  zeitler
;;; added cost hint to modbbf
;;;
;;; Revision 1.182  2007/09/02 11:01:13  torer
;;; MODbbf in C
;;;
;;; Revision 1.181  2007/09/01 14:41:00  torer
;;; Basic comparison operators in C
;;;
;;; Revision 1.180  2007/08/31 11:55:49  torer
;;; evalv(Charstring)->Bag of Vector
;;;
;;; Revision 1.179  2007/08/21 07:35:02  torer
;;; Bug in ADD/LAST converting DOS filenames
;;;
;;; Revision 1.178  2007/08/08 19:40:32  torer
;;; New function to load subsystem scripts:
;;;   loadSystem(Charstring path, Charstring masterFile)->Charstring file
;;;
;;; Revision 1.177  2007/06/15 12:21:02  ruslan
;;; abs is not multidirectional anymore
;;;
;;; Revision 1.176  2007/03/09 14:34:37  torer
;;; New functions:
;;;   stringify(Object)->Charstring
;;;   unstringify(Charstring)->Object
;;;   theFunction(Charstring fn)->Function (get function named fn or error)
;;;
;;; Revision 1.175  2007/03/01 07:55:01  torer
;;; sqrt(0)=0;
;;;
;;; Revision 1.173  2007/02/18 10:22:37  torer
;;; SQRT(x) now returns only the positive root rather than both roots
;;;
;;; Revision 1.172  2006/12/26 16:55:41  torer
;;; Coercion introduced
;;;
;;; Revision 1.171  2006/12/16 16:23:57  torer
;;; Verifying that T and NIL not used as local variables
;;;
;;; Revision 1.170  2006/12/14 18:22:55  torer
;;; STREAMOF moved to stream.lsp
;;;
;;; Revision 1.169  2006/12/14 16:43:54  torer
;;; 1. Basic functions on type VECTOR into file lsp/vector.lsp
;;; 2. Comparisons on vectors element by element
;;;
;;; Revision 1.168  2006/12/14 14:38:17  torer
;;; Correct result for STREAMOF
;;;
;;; Revision 1.167  2006/11/24 23:03:38  torer
;;; Datatype STREAM (of type) instroduced
;;;
;;; Revision 1.166  2006/11/08 14:16:06  torer
;;; Normalization using property table constructors
;;;
;;; Revision 1.165  2006/11/04 16:18:19  torer
;;; Systematically using GET-RESOLVENT-ARGTYPES and GET-RESOLVENT-RESTYPES
;;;
;;; Revision 1.164  2006/10/20 15:06:34  torer
;;; New function enable_parteval(Boolean)->Boolean;
;;;
;;; Revision 1.163  2006/09/29 08:27:40  petrini
;;; call-function--+ calls mapfunctionres instead of getfunction to prevent construction of enormous list when result is huge.
;;;
;;; Revision 1.162  2006/09/08 17:47:57  torer
;;; sort functions cleaned up, generalized, and documented
;;;
;;; Revision 1.161  2006/08/01 12:41:57  torer
;;; theresolvent message changed
;;;
;;; Revision 1.160  2006/07/28 11:08:41  torer
;;; cost hint functions now take strings and generic function names
;;;
;;; Revision 1.159  2006/07/25 13:20:37  torer
;;; Optimized reoptimize
;;;
;;; Revision 1.158  2006/06/08 21:25:57  torer
;;; Possibility to choose between optimizing top level or including transients
;;;
;;; Revision 1.156  2006/06/07 14:21:14  torer
;;; plan_cost use cashed cost if available. Recomputes if not available.
;;;
;;; Revision 1.155  2006/06/07 13:46:21  torer
;;; Randomized optimization over foreign functions work
;;;
;;; Revision 1.154  2006/06/05 10:06:06  torer
;;; Randomized optimizer called
;;;
;;; Revision 1.153  2006/05/22 19:57:36  torer
;;; Use of DEFAULT-TYPE-PARAMETERS to handle dynamic collections of OBJECT
;;;
;;; Revision 1.152  2006/05/19 13:20:21  zeitler
;;; - roundto in osql
;;; - avgstdev signature (vector)-><real,real>
;;;
;;; Revision 1.151  2006/05/18 15:15:23  zeitler
;;; avg + stdev into aggops
;;;
;;; Revision 1.150  2006/05/16 14:54:03  torer
;;; inn operator
;;;
;;; Revision 1.148  2006/04/16 14:01:41  torer
;;; No integer arithmetics, as in SQL, i.e. 1/2 -> 0.5, 4/2 -> 2
;;;
;;; Revision 1.147  2006/04/15 18:48:22  torer
;;; Possibility to specify 'key' on multidirectional implementation
;;;
;;; Revision 1.146  2006/04/15 15:18:07  torer
;;; Using Makefile rather than command procedure to generate parsers when needed
;;;
;;; Revision 1.145  2006/04/14 18:34:05  torer
;;; Strict result syntax for resolvent_costs
;;;
;;; Revision 1.144  2006/04/14 14:37:46  milena
;;; Added meta-functions returning descriptors (vectors of strings) of function arguments and results.
;;;
;;; Revision 1.143  2006/04/13 10:39:54  ruslan
;;; reoptimize is accessable from lisp and function cost in lisp is added
;;;
;;; Revision 1.142  2006/04/12 08:21:14  torer
;;; Correct reconstruction of variable *BINDINGS* for cost-based optimization
;;;
;;; Revision 1.141  2006/04/10 11:56:20  milena
;;; Added meta-function
;;; call_function_ws(charstring fn, vector args)-<vector res,vector attr>
;;; to call Amos2 function through a web service. returns function results and a desription of the attributes in the result ((type1, name1) ...)
;;;
;;; Revision 1.140  2006/04/08 15:37:44  torer
;;; Compound keys
;;;
;;; Revision 1.139  2006/04/08 14:19:38  torer
;;; (GET-OC FNO) always used as accessor function for OID property ORGCODE
;;;
;;; Revision 1.138  2006/04/07 07:25:36  torer
;;; Derived multi-directional definitions supported
;;;
;;; Revision 1.137  2006/03/28 11:59:11  torer
;;; PC(Charstring fname)->Function as AmosQL function too
;;;
;;; Revision 1.135  2006/03/22 15:38:45  torer
;;; declare_type_container(Charstring fn)->Function
;;; Declares (resolvents of generic) function to be type container
;;;
;;; Revision 1.134  2006/03/21 07:57:27  torer
;;; typesofbb in C
;;;
;;; Revision 1.132  2006/03/20 13:57:28  torer
;;; countbb defined + bug fixed so that typecontainer for VECTOR now works
;;;
;;; Revision 1.131  2006/02/15 17:11:41  torer
;;; abs(Number)->Number in C
;;;
;;; Revision 1.130  2006/02/15 15:44:33  torer
;;; times(number,number)->number in C
;;;
;;; Revision 1.129  2006/02/13 22:08:57  torer
;;; Bags implemented using stream generators
;;;
;;; Revision 1.128  2006/02/07 19:39:56  torer
;;; New AmosQL function
;;; directoryp(Charstring file)->Boolean
;;;
;;; Revision 1.127  2006/02/04 15:15:55  torer
;;; Stored functions now tracable
;;;
;;; Revision 1.126  2006/02/04 10:52:22  torer
;;; New AmosQL function: filedate(Charstring filename)->Date
;;;
;;; =============================================================

(defvar *costfn*)
(defglobal _invisible_)
(defglobal _image-file_)
(document *costfn* "Temporary variable for cost hint functions"
	  _invisible_ "Table of meta-objects invisible for, e.g., Goovi"
	  _image-file_ "Name of database image")

(setq *costfn*
      (create-function typesofcost ((function f)(vector bpat)(vector args)) 
		       ((integer cost)(integer fanout))
		       as foreign (typesofcost)))
(declarecosts  'object.typesof->type '(+ -) *costfn*)
(declarecosts  'object.typesof->type '(- +) *costfn*)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Object naming
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun full-type-name (tp)
  "This function temporary until we name proxy types and functions correctly
   use @ to define source"
  (if (oid-p tp)
      (let ((on (oid-origname tp))
	    (src (getobject tp 'exportto)))
	(cond ((and on src)(concat on "@" src))
	      (t (oid-name tp))))))

(defun namedobj-+ (fno obj str)
  (let ((s (full-type-name obj)))
    (if s
	(osql-result obj
		     (mkstring s)))))

(defun namedobj+- (fno obj str)
  (let* ((atm (mksymbol str))
					; Check if 'str' was capitalized
	 (matches (and (equal (mkstring atm) str)
		       (gethash atm _symbtab_))))
    (dolist (o matches)
      (osql-result o str))))

(defun namedobj-- (fno obj str)
  (if (eq
       (full-type-name obj)
       (mksymbol str))
      (osql-result obj str)))

(osql "
create function objectname(Object o)-> Charstring nm
   /* Get capitalized name of system object */
   as multidirectional
      ('bf' key foreign 'namedobj-+')
      ('fb' foreign 'namedobj+-')
      ('bb' key foreign 'namedobj--');") 

(osql "
create function name(Type t) -> Charstring nm
   /* the name of type t */
   as select objectname(t);")

(osql "
create function name(Function f) -> Charstring nm
  /* The name of function f */
   as select objectname(f);")

(osql "
create function oid_nr(Object o)->Integer i
  /* The number identifying an OID */
  as multidirectional ('bf' foreign 'oid_nr-+')
                      ('fb' foreign 'oid_nr+-');")

(defun oid_nr-+ (fno o i)
   (if (oid-p o) (osql-result o (getobject o 'idno))))

(defun oid_nr+- (fno o i)
  (if (and (>= i 0)(< i (length _objects_))
	   (aref _objects_ i)) 
      (osql-result (aref _objects_ i) i)))

(defun upper-+ (fno str uppr)
  (osql-result str (string-upcase str)))

(osql "
create function upper(Charstring str) -> Charstring uppr
  /* Upper case string */
  as multidirectional
    ('bf' key foreign 'upper-+');")

(declarecosts 'type.name->charstring '(+ +) '(100 100))
(declarecosts 'function.name->charstring '(+ +) '(100 100))
(osql "
create function functionnamed(Charstring nm) -> Function f
  /* The function named nm */
  as select f
     where name(f)=upper(nm);")

(osql "
create function typenamed(Charstring nm) -> Type t
  /* The type named nm */
  as select t
     where name(t)=upper(nm);")

(foreign-lispfn cardinality ((type tp))((integer))
		(foreign-result (type-cardinality tp)))

;;; Partial evaluation

;;static funcs can be executed during compile time if all args are constants 
(setq _static_funcs_
      (create-function _static_funcs_  ((function)) ((boolean))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Type extents 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun shallow_extent-+ (fno type obj)
  (mapextent type (f/l (o)(if (not (dt_obj_p o))
			      (osql-result type o))) nil))

(defun shallow_extent+- (fno type obj)
  (let ((tp (arg-type obj)))
    (if tp (osql-result tp obj))))

(setq _shallow_extent_ 
      (osql "
create function shallow_extent(Type t) -> Bag of Object o key
  /* The shallow extent of type t */
  as multidirectional
     ('bf' foreign 'shallow_extent-+')
     ('fb' foreign 'shallow_extent+-');"))

(defglobal _typeof_ 
  (osql "
create function typeof(Object o) -> Type t
  /* The most specific type of object o */
  as select t
     where o in shallow_extent(t);")
  "OID of TYPEOF function")

(defun shallow_extentcost (obj f bpat args v1 v2)
  (let (res 
	(o (aref args 1))
	(tp (aref args 0))
	(tpub (eq (aref bpat 1) '-)))
    (cond
     (tpub (osql-result f bpat args 1 1))
     ((oid-p tp)
      (cond ((surrogate-type? tp) 
	     (setq res
		   (max 100 (shallow-type-cardinality tp)))
	     (osql-result f bpat args res res))))
     (t (setq res
	      (shallow-type-cardinality _object_))
	(osql-result f bpat args res res)) )))

(setq *costfn*
      (create-function shallow_extentcost 
		       ((function f)(vector bpat)(vector args)) 
		       ((integer cost)(integer fanout))
		       as foreign (shallow_extentcost)))
(declarecosts  'type.shallow_extent->object '(+ -) *costfn*)
(declarecosts  'type.shallow_extent->object '(- +) *costfn*)

;shallow extentS : takes more than one type. one direction only
(setq _shallow_extentS_ 
      (create-function shallow_extentS ((vector tVect))((object o key)) 
		       as multidirectional 
		       (("bf" foreign shallow_extentS_-+)
			("bb" foreign shallow_extents_--))))

(defun shallow_extentS_-+ (fno typeVect obj)
  (dolist (tp (arraytolist typeVect))
    (mapextent (car tp) (f/l (o)(if (not (dt_obj_p o))
				    (osql-result typeVect o))) (cdr tp))))    

(defun shallow_extentS_-- (fno typeVect obj)
  (let ((tp (arg-type obj))
	(atps (arg-types obj)))
    (if (some (f/l (tp_F) 
		   (if (cdr tp_f) 
		       (memq (car tp_F) atps) 
		     (eq tp (car tp_F))))
	      (arraytolist typeVect))
	(osql-result typeVect obj))))

(defun shallow_extentScost (obj f bpat args v1 v2)
  (let (res 
	(o (aref args 1))
	(tpV (aref args 0))
	(tpub (eq (aref bpat 0) '+)))

    (if tpub 
	(osql-result f bpat args 4 1)
      (let ((res
	     (apply (function +)
		    (mapcar 
		     (f/l (tp_sf) 
			  (max 100 
			       (if (cdr tp_sf)
				   (type-cardinality (car tp_sf))
				 (shallow-type-cardinality (car tp_sf)))))
		     (arraytolist tpV)))))
	(osql-result f bpat args res res)))))

(setq *costfn*
      (create-function shallow_extentScost 
		       ((function f)(vector bpat)(vector args)) 
		       ((integer cost)(integer fanout))
		       as foreign (shallow_extentScost)))

(declarecosts  'vector.shallow_extentS->object '(- +) *costfn*)
(declarecosts  'vector.shallow_extentS->object '(- -) *costfn*)

(defun shallow-type-cardinality (tp)
  (let ((n 0))
    (mapextent tp (f/l (o) (setq n (1+ n))) nil)
    n))

(osql "
create function extent(Type t) -> Bag of Object o 
  /* The deep extent of type t */
  as select o where typesof(o) = t;
create function deep_extent(Type tp) -> Object o
   as select extent(tp);")

(defun extent-+ (fno f r)
  "Compute the extent of function if safe"
  (dolist (fno (resolvents f))
    (and (member (functiontype f)
		 '("derived" "stored" "generic"))
	 (catch-error 
	  (map-function-extent 
	   fno 
	   (f/l (row)
		(osql-result f (listtoarray row))))))))

(declarecosts
 (osql "
create function extent(Function f) -> Bag of Vector
  /* The extent of function f */
  as foreign 'extent-+';")
 '(- +) '(100000 10000))

;;; Strange function returning numbers objects of a type
(osql "create function extent_of(Type t)->Integer
       as select oid_nr(p) from Object p where t=typesof(p);")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Primitive functions 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(create-function = ((object i)(object j)) nil 
		 as multidirectional (("bb" foreign "equal--")
				      ("bf" foreign "equal-+")
				      ("fb" foreign "equal+-")))

(osql "
create function iota(Number l, Number u) -> Bag of Integer 
  /* The integers between l and u */
  as foreign 'iota--+';")

(osql "
create function plus(Number x, Number y) -> Number r
  /* Add numbers x and y */
  as multidirectional
     ('bbf' key foreign 'plus--+')
     ('bfb' key foreign 'plus-+-')
     ('fbb' key select x where y+x=r);
create function plus(Number x, Number y, Number z) -> Number r
  /* Add three numbers (internal) */
  as foreign 'plus--+';
create function plus(Number x, Number y, Number z, Number a) -> Number r
  /* Add four numbers (internal) */
  as foreign 'plus--+';")

(osql "
create function minus(Number x, Number y) -> Number z
  /* Subtract y from x */
  as select z
     where x = y+z;")

(osql "
create function times(Number x, Number y) -> Number z
  /* Multiply numbers x and y */
  as multidirectional
     ('bbf' key foreign 'times--+')
     ('bfb' key foreign 'times-+-') 
     ('fbb' key select x where y*x=z);")

(osql "
create function div(Number x, Number y) -> Number z
  /* Divide numbers x and y */
  as select z
     where x = y*z;")

(osql "
create function mod(Number n, Number x) -> Number m
  /* Remainder when dividing number n with x */
  as multidirectional ('bbf' foreign 'mod--+' cost {0.6,1})
                      ('bbb' foreign 'mod--+' cost {0.6, 0.2});")

(osql "
create function integer(Number n) -> Integer
  /* Round number n to an integer */
  as foreign 'round-+';
create function real(Number n) -> Real
  /* Make a real number of integer n */
  as foreign 'real-+';")

(defglobal _coercetointeger_ (osql "
create function cast_integer(Number n) -> Integer
  as n;"))

(defglobal _coercetoreal_ (osql "
create function cast_real(Number n) -> Real
  as n;"))

(defglobal _identity_ (osql "
create function identity(Object o) -> Object
  /* Identity function */
  as select o;"))

(set-resulttypesfn _identity_ 'identity-resulttypes)

(defun identity-resulttypes (fno args)
  (list (arg-type (car args))))

(defun real-+ (fno n r)
   (osql-result n (float n)))

(setfunction _coercers_ (vector _number_ _integer_) (list _coercetointeger_))
(setfunction _coercers_ (vector _real_ _integer_) (list _coercetointeger_))
(setfunction _coercers_ (vector _integer_ _real_) (list _coercetoreal_))
(setfunction _coercers_ (vector _number_ _real_) (list _coercetoreal_))

(defun sqrt-+ (obj x y)
  (if (>= x 0) (osql-result x (sqrt x))))

(osql "
create function sqrt(Number x) -> Number r
  /* The square root of x */
  as multidirectional
     ('bf' foreign 'sqrt-+' cost {2,1})
     ('fb' key select x where r*r=x);")

(create-function != ((object)(object))((boolean)) as foreign (ne--))
(create-function < ((object)(object))((boolean)) as foreign (lt--))

(create-function <= ((object)(object))((boolean)) as foreign (le--))
(create-function > ((object x)(object y))((boolean)) as foreign(gt--))
;  as nil where (< y x)) does not work because of late binding bug
(create-function >= ((object x)(object y)) ((boolean)) as foreign (ge--))
; as nil where (<= y x)) does not work because of late binding bug

(foreign-lispfn min ((object x)(object y)) ((object z))
		(if (list<= x y) (foreign-result x)
		  (foreign-result y)))
(foreign-lispfn max ((object x)(object y)) ((object z))
		(if (list<= y x) (foreign-result x)
		  (foreign-result y)))

;;; Unary minus:
(osql "
create function uminus(Number x) -> Number y
  /* Unary minus */
  as select 0-x;")

(foreign-lispfn log10 ((number x))((real))
		(foreign-result (log10 x)))

(osql "
create function abs(Number x) -> Number y 
  /* Absolute value of number x */
  as foreign 'abs-+';")

(foreign-lispfn roundto ((number num) (number digits))
		((real))
		(foreign-result (roundto num digits)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Random numbers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun rand (low high)
  "Return random integer below low and high"
  (if (> high low) (+ low (random (- high low)))))

(defun rand--+ (fno low high r)
  (let ((res (rand low high)))
    (if res (osql-result low high res))))

(defun rand-+ (fno high r)
  (let ((res (rand 0 high)))
    (if res (osql-result high res))))

(defun frand--+ (fno low high r)
  (osql-result low high (frand low high)))

(osql "
create function rand(Number high) -> Integer
  /* Integer random number 0 <= i < high */
  as foreign 'rand-+';

create function rand(Number low, Number high) -> Integer
  /* Integer random number low <= i < high */ 
  as foreign 'rand--+';

create function frand(Number low, Number high) -> Real
  /* Real random number low <= x < high */
  as foreign 'frand--+';

create function frand(Number high) -> Real
  /* Real random number 0 <= x < high */
  as frand(0,high);
")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Aggregation functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(bind-foreign 'function.makebag->bag '(+) 'make-bag)
(bind-foreign 'function.makebag->bag '(- +) 'make-bag)
(bind-foreign 'function.makebag->bag '(- - +) 'make-bag)
(bind-foreign 'function.makebag->bag '(- - - +) 'make-bag)
(bind-foreign 'function.makebag->bag '(- - - - +) 'make-bag)
(bind-foreign 'function.makebag->bag '(- - - - - +) 'make-bag)
(bind-foreign 'function.makebag->bag '(- - - - - - +) 'make-bag)
(bind-foreign 'function.makebag->bag '(- - - - - - - +) 'make-bag)
(bind-foreign 'function.makebag->bag '(- - - - - - - - +) 'make-bag)
(bind-foreign 'function.makebag->bag '(- - - - - - - - - +) 'make-bag)
(bind-foreign 'function.makebag->bag '(- - - - - - - - - - +) 'make-bag)
(bind-foreign 'function.makebag->bag '(- - - - - - - - - - - +) 'make-bag)

(setq _makebag_ (create-function makebag ((function))((bag)) as foreign))
(putobject _bag_ 'makebag _makebag_)
(putobject _makebag_ 'ismakebag t)

(defun transparent-collection-resulttypes (fno args)
  "The result type is the type parameters of the 1st bag argument"
  (default-type-parameters (arg-type (car args))))

(set-resulttypesfn 
 (foreign-lispfn maxagg ((bag b)) ((object))
		 "Return the largest element in a bag."
		 (let (max)
		   (mapbag b
			   (f/l (row)
				(cond ((null max)
				       (setq max (car row)))
				      ((list< max (car row))
				       (setq max (car row))))))
		   (and max (foreign-result max))))
 'transparent-collection-resulttypes)

(set-resulttypesfn
 (foreign-lispfn minagg ((bag b)) ((object n))
		 "Return the smallest element in a bag."
		 (let (min)
		   (mapbag b
			   (f/l (row)
				(cond ((null min)
				       (setq min (car row)))
				      ((list< (car row) min)
				       (setq min (car row))))))
		   (and min (foreign-result min))))
 'transparent-collection-resulttypes)

(set-type-container 
 (osql "
create function count(Bag b)->Integer 
  /* The number of elements in bag b */
  as multidirectional ('bf' key foreign 'count-+')
                      ('bb' key foreign 'count--' cost {20,0.5});"))

(osql "
create function some (Bag b)->Boolean
  /* Is there any element in bag b */
  as foreign 'some-';

create function notany (Bag b)->Boolean
  /* Is there no element in bag b? */
  as foreign 'notany-';")

(set-resulttypesfn
 (osql "
create function first (Bag b)->Object
  /* The first element in bag b */
  as foreign 'first-+';")
 'transparent-collection-resulttypes)

(set-resulttypesfn
 (osql "
create function last (Bag b)->Object
  /* The last element in bag b */
  as foreign 'bag.last-+';")
 'transparent-collection-resulttypes)

(defun bag.last-+ (fno b res)
  (apply 'osql-result b (let (last)
			  (mapbag b (f/l (x) (setq last x)))
			  last)))

(set-type-container
 (osql "
create function sum(Bag of Number b)->Number 
  /* The sum of the numbers in bag b */
  as foreign 'sum-+';"))

(osql "
create function vsum(Vector of Number v) -> Number
  /* The sum of the numbers in vector v */
  as sum(in(v));")

(defun avgstdev-++ (fno b avg stdev)
  (let ((Mk 0.0) (Qk 0.0) (k 0) (firsttime t))
    (mapbag b (f/l (tpl)
		   (cond ((and firsttime (car tpl))
			  (setq k 1)
			  (setq Mk (car tpl))
			  (setq firsttime nil))
			 ((car tpl)
			  (1++ k)
			  (let ((Mnew (+ Mk (/ (* 1.0 (- (car tpl) Mk)) k)))
				(Qnew (+ Qk (* (/ (- k 1.0) k)
					       (- (car tpl) Mk)
					       (- (car tpl) Mk)))))
			    (setq Mk Mnew)
			    (setq Qk Qnew))))))
    (cond ((= k 0)
	   (osql-result b nil nil))
	  ((= k 1)
	   (osql-result b Mk nil))
	  (t
	   (osql-result
	    b Mk
	    (sqrt (/ Qk (- k 1))))))))

(osql "
create function avgstdev(Bag of Number b key) -> (Number, Number) 
  /* The average and the standard deviation of the numbers in bag b */
  as foreign 'avgstdev-++';")

(defun stats-++++ (fno b avg stdev min max)
  (let ((Mk 0.0) (Qk 0.0) (k 0) (firsttime t)min max)
    (mapbag b (f/l (tpl)
		   (cond (firsttime
			  (setq k 1)
			  (setq Mk (car tpl))
                          (setq max (car tpl))
                          (setq min (car tpl))
			  (setq firsttime nil))
			 (t
			  (1++ k)
			  (let ((Mnew (+ Mk (/ (* 1.0 (- (car tpl) Mk)) k)))
				(Qnew (+ Qk (* (/ (- k 1.0) k)
					       (- (car tpl) Mk)
					       (- (car tpl) Mk)))))
                            (if (> (car tpl) max)(setq max (car tpl)))
                            (if (< (car tpl) min)(setq min (car tpl)))
			    (setq Mk Mnew)
			    (setq Qk Qnew))))))
    (cond ((= k 0))
	  ((= k 1)
	   (osql-result b Mk 0 min max))
	  (t
	   (osql-result
	    b Mk
	    (sqrt (/ Qk (- k 1)))
            min max)))))

(osql "
create function stats(Bag of Number) -> (Real mean, Real stdev, Real min, Real max)
  as foreign 'stats-++++';")

(foreign-lispfn median ((vector v))((real))
		(let ((m (median v)))
		  (if m (foreign-result m))))

(foreign-lispfn concatagg ((bag b)) ((charstring))
		"Concatenate string of elements in bag"
		(let ((str (opentextstream)))
		  (mapbag b
			  (f/l (r)
			       (princ (car r) str)))
		  (foreign-result (textstreamstring str))))

(foreign-lispfn inject((bag b)(object o))((object))
		"Inject O inbetween elements in bag B"
		(let (notfirst)
		  (mapbag b
			  (f/l (r)
			       (if notfirst (foreign-result o)
				 (setq notfirst t))
			       (foreign-result (car r))))
		  ))

(set-resulttypesfn 
 (osql "
create function bsection(Bag b, Number start, Number stop)
                ->Bag of Object
  /* Sub-bag from position start to stop in b */
  as foreign 'section---+';")
 'transparent-collection-resulttypes)

(defun start_at--+ (fno s n r)
  (let ((cnt 0))
    (mapbag s (f/l (row)
		   (if (< cnt n)
		       (1++ cnt)
		     (apply 'osql-result s n row))))))

(set-resulttypesfn
 (osql "create function start_at0(Bag s, Number i) -> Bag of Object
  as foreign 'start_at--+';")
 'transparent-collection-resulttypes)

(defun changed-+ (fno b r)
  (let (previous)
    (mapbag b (f/l (current)
		   (cond ((not (equal previous current))
			  (apply 'osql-result b current)
			  (setq previous current)))))))

(set-resulttypesfn
 (osql "create function changed0(Bag b) -> Bag of Object
  as foreign 'changed-+';")
 'transparent-collection-resulttypes)

(defun tuples-+ (fno b v)
  (mapbag b (f/l (row) (osql-result b (toarray row)))))

(osql "
create function tuples(Bag b) -> Bag of Vector
  /* The tuples in bag b */
  as foreign 'tuples-+';")

;;; Utility aggregation function to make unique bags (i.e. coerce bags to sets)

;;; UNIQUE removes duplicates
;;; Written by K. Orsborn, Added 950119
; Not needed since 'select distinct' now supported (TR)
(set-resulttypesfn
 (osql "create function unique(Bag b) -> Bag of Object
  /* Remove duplicates in bag */
  as foreign 'unique-+';")
 'transparent-collection-resulttypes)

(defun unique-+ (fno b r)
  (let ((been (make-hash-table :test (function equal))))
    (mapbag b (f/l (row)
		   (cond ((gethash row been) nil)
			 (t (setf (gethash row been) t)
			    (apply 'osql-result
				   b row)))))))


;;; EXCLUSIVE returns only those members in a bag that occurs exactly once.
;;; Written by K. Orsborn, Added 950119
(set-resulttypesfn
 (osql "create function exclusive(Bag b) -> Bag of Object
  /* Return the singleton objects in a bag */
  as foreign 'exclusive-+';")
 'transparent-collection-resulttypes)

(defun exclusive-+ (fno b r)
  (let ((been (make-hash-table :test (function equal))))
    (mapbag b (f/l (row)
		   (cond ((gethash row been) (setf (gethash row been) 2))
			 (t (setf (gethash row been) 1)))))
    (maphash (f/l (row dummy)
		  (if (= (gethash row been) 1)
		      (apply 'osql-result b row)))
	     been)))

(set-resulttypesfn
  (osql "
create function remove_null(Bag b) -> Bag of Object
  /* Remove all nil in bag b */
  as foreign 'remove-null-+';")
 'transparent-collection-resulttypes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; System meta-data access functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun object+ (obj x)
  (dotimes
      (i _oidno_)
    (if (aref _objects_ i)
	(osql-result
         (aref _objects_ i)))))

(defun object- (obj x)(osql-result x))

(create-function object ((object x)) nil as foreign (object-))

; USEDWHERE(FUNCTION) -> BAG OF FUNCTION 
; Returns all functions directly using this function.

(foreign-lispfn usedwhere ((function fn)) ((function userfn))
		(let ((gfn (getobject fn 'genfn)))
		  (dolist (userfn (getobject fn 'usedbyfunction))
		    (and (neq userfn gfn) (visible-fn userfn) 
			 (foreign-result userfn)))))

; USESWHICH(FUNCTION) -> BAG OF FUNCTION
; Returns all functions directly used by this function.

(foreign-lispfn useswhich ((function fn)) ((function usedfn))
		(let ((gfn (getobject fn 'genfn)))
		  (dolist (usedfn (getobject fn 'usesobjects))
		    (and (object-typep usedfn _function_)
			 (neq usedfn gfn) (visible-fn usedfn) 
			 (foreign-result usedfn)))))
		 
(foreign-lispfn kindoffunction ((function fn))((charstring k))
                (let ((tp (functiontype fn)))
                  (if tp (osql-result fn tp))))

(create-function argrestypes((function fn))
		 ((integer pos)(type tp)(integer kind))
		 as multidirectional (("bfff" foreign argrestypes-+++)))

(defun argrestypes-+++ (obj fn pos tp kind)
  (let ((i 0)
	(tl (argrestypes fn)))
    (dolist
	(at (car tl))
      (osql-result fn (setq i (1+ i)) at 0))
    (dolist
	(rt (cdr tl))
      (osql-result fn (setq i (1+ i)) rt 1))))

(declarecosts 'function.argrestypes->integer.type.integer '(- + + +) '(3 3))

(create-function argrestypes ((charstring fnn)) 
		 ((integer pos) (type tp)  (integer kind))
		 as (pos tp kind)
		 where (= (tuple pos tp kind)
			  (argrestypes
			   (functionnamed fnn))))

(foreign-lispfn arguments ((function r))
		((vector descr))
		(if (not(generic? r))
		    (let* ((oc (get-oc r))
			   (argdescr (first oc))
			   (resdescr (second oc))
			   (uniques (get-unique-keyposl r)) 
			   )					
		      (foreign-result (mksignaturedescr argdescr 0 uniques)
				      ))))

(defun function.signature-+ (fno fn r)
   (dolist (r (resolvents fn))
     (osql-result fn (function-signature r))))
 
(osql "
create function signature(Function f)->Bag of Charstring
  /* The signature of resolvent f or
     the signature of the resolvents of the generic function f */
  as foreign 'function.signature-+';")

(foreign-lispfn results ((function r))
		((vector descr))
		(if (not(generic? r))
		    (let* ((oc (get-oc r))
			   (argdescr (first oc))
			   (resdescr (second oc))
			   (uniques(get-unique-keyposl r)))
		      (foreign-result (mksignaturedescr 
				       resdescr (length argdescr) uniques)
				      ))))

(foreign-lispfn result_type((function r))
		((type descr))
		(foreign-result 
		 (first (first (second (get-oc r)))))
		)

(defun result_types-+ (fno function types)
  (if (not (generic? function))
      (dolist (type (getrestype function))
	(osql-result function type))))

(defun argument_types-+ (fno function types)
  (if (not (generic? function))
      (dolist (type (get-resolvent-argtypes function))
	(osql-result function type))))

(osql "
create function result_types(Function f) -> Bag of Type 
  /* The result types of function f */
  as foreign 'result_types-+';")

(osql "
create function argument_types(Function) -> Bag of Type 
  /* The argument types of function f */
  as foreign 'argument_types-+';")


(defun getargdescr (fnres)
  "Return vector describing arguments of a function resolvent."
  (let (rd)
    (if (not(generic? fnres))
	(let* ((oc (getobject fnres 'orgcode))
	       (argdescr (first oc)))
	  (setq rd (mapcar (f/l (arg) (listtoarray 
				       (list (mkstring (oid-name (car arg)))
					     (mkstring (cadr arg)))))
			   argdescr))
	  (setq rd (listtoarray rd))
	  )
      (setq rd (listtoarray nil)))))


(defun argdescr-+ (fno function descr)
  (osql-result function (getargdescr function)))

(osql "create function arg_descr(Function f) -> Vector
  /* Vector describing arguments of function f */
  as foreign 'argdescr-+';")
;;;;;;;;;;;;;;;

(foreign-lispfn source_text((object o))((charstring))
		(if(oid-p o)(let ((src(getobject o 'source_text)))
			      (if src (foreign-result src)))))

(cond ((not _release_);; only in development version: 
       (foreign-lispfn grep ((charstring pat)) ((charstring))
		       (dolist (f *loaded-files*)
			 (if (eq (system (grep-command pat f))
				 0)
			     (foreign-result f))))

;;; What files have given string? Save lines in INTOFILE. Borland grep.
       (foreign-lispfn 
	grep ((charstring pat)(charstring intofile)) ((charstring))
	(let ((first t))
	  (dolist (f *loaded-files*)
	    (if (eq (system (concat 
			     (grep-command pat f)
			     (cond (first (setq first nil) " > ")
				   (t " >> "))
			     intofile))
		    0)
		(foreign-result f)))))))

(osql "
create function arity(Function f) -> Integer
  /* Arity of function f */
  as foreign 'arity-of-function';")

(defun arity-of-function (obj f a)
  (osql-result f (getarity f)))

(osql "
create function width(Function f) -> Integer
  /* The width of function f */
  as foreign 'width-of-function';")

(defun width-of-function (obj f w)
  (osql-result f (getwidth f)))

(osql "
create function methods(Type t) -> Function
  /* The functions having type t as only argument */
  as foreign 'get-methods';")

(defun get-methods (obj tp a)
  (mapextent _function_ 
	     (f/l (fn) (let ((at (get-resolvent-argtypes fn))
			     (rt (get-resolvent-restypes fn)))
			 (and at rt (eq tp (car at))
			      (null(cdr at))(null (cdr rt))
			      (visible-fn fn)
			      (osql-result tp fn))))))

(foreign-lispfn resolvents((function f))((function r))
		"Get the resolvents of a given OSQL function"
		(mapc (f/l (r)(foreign-result r))
		      (resolvents f)))

(osql "
create function sourcecode(Function f)->Charstring
  /* The source code of function f */
  as source_text(resolvents(f));")

(defun function-doc (fno)
  "Get the documentation of function"
  (let ((src (getobject fno 'source_text))
	begpos begcom)
    (cond ((null src) nil)
          ((null (setq begpos (string-pos src "/*"))) nil)
          (t (setq begcom (substring begpos (length src) src))
	     (concat (function-signature fno) ":" _cr_ 
		     "    " (substring 2 (1- (string-pos begcom "*/")) 
				       begcom))))))

(defun function.doc-+ (fno fn r)
  (let ((doc (function-doc fn)))
    (if doc (osql-result fn doc))))

(defun the-generic-fn (obj fn res)
  (let ((gfn (getobject fn 'genfn)))
    (if gfn (osql-result fn gfn))))

(osql "
create function generic(Function r)-> Function g
  /* The generic function of function f */
  as foreign 'the-generic-fn';")

(osql "
create function resolventtype(Function f) -> Type t
  /* The type of the first argument of resolvent f */
  as select t where argrestypes(f) = (1,t,0);")

(osql "
create function allfunctions() -> Bag of Function 
  /* All functions in database */
  as select f from Function f;")

(osql "
create function alltypes() -> Bag of Type
  /* All types in database */
  as select t from Type t;")

;; Overloading of allfunctions to return functions related to a given type
;; Given a type, return all functions that uses that type as argument or
;; in the result. Also return the position and kind (= 0 if in argument list)
;;  or (= 1 if in result list)
;; Use function kindoffunction to return if the function is stored 
;; (an attribute), derived (a method), overloaded or foreign.
;; Usage:
;; allfunctions(typenamed("integer")); will return all functions that use 
;; integers
(foreign-lispfn allfunctions ((type tp)) ((function fn) )
                (mapc #'(lambda (fno)
                          (osql-result tp fno))
                      (allfunctionsfortype tp)))

(defun get-generation()
  "The current generation number seen at the prompt"
  (if _generations_
      (1+ (caar _generations_))
    1))

(osql "
create function allobjects(Type t) -> Bag of Object o
   /* All objects of type t */
   as select o where t=typesof(o);")

(defglobal _allobjects_ 
  (foreign-lispfn allobjects ()((object o))
		  "Get all surrogate objects in database"
		  (maparray _objects_
			    (f/l (x i)(and (oid-p x)(foreign-result x)))))
  "OID of function ALLOBJECTS")

;; alltypes (by Martin Sköld)
;; Returns a nested S-expression representing the type tree
;; Arguments:
;; type, the root type of the type tree to be returned
;; Usage:
;; (alltypes) returns all types under type object
;; (alltypes (gettypenamed 'literal)) returns all literal types
(defun alltypes(type)
  (if (null type) (setq type (gettypenamed 'object)))
  (cons (oid-name type)
	(mapcar (f/l (st) (alltypes st)) (subtypes type))))

(defun subtypes-+ (fno super sub)
  (dolist (rt (subtypes super))
    (osql-result super rt)))

(defun subtypes+- (fno super sub)
  (dolist (rt (supertypes sub))
    (osql-result rt sub)))

(osql "
create function subtypes(Type t)->Bag of Type
   /* The types one level below type t in the type hierarchy */
   as multidirectional 
      ('bf' foreign 'subtypes-+')
      ('fb' foreign 'subtypes+-');")

(osql "
create function supertypes(Type t)->Bag of Type 
   /* The types one level above t in the type hierarchy */
   as select super from Type super
      where t in subtypes(super);")

(osql "
create function allsupertypes (Type t)->Type super 
   /* All supertypes above type t in the type hierarchy */
   as foreign 'all-supertypes-+';")

(defun all-supertypes-+ (fno sub super)
  (dolist (x (type-allsupertypes sub))
    (osql-result sub x)))

(declarecosts 'type.allsupertypes->type '(- +) '(10 10))

(foreign-lispfn declare_type_container ((charstring fn))((function))
		(dolist (fno (resolvents (getfunctionnamed (mksymbol fn))))
		  (set-type-container fno)
		  (foreign-result fno)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Dynamic object creation and function invocation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(foreign-lispfn createobject ((type tp)) ((object o))
		"Create instances of a type"
                (foreign-result (/createobject tp nil)))

(osql "
create function createobject(Charstring tpe) -> Object
  /* Create new object of type named tpe */ 
  as begin return createobject(typenamed(tpe)); end;")
                           
(foreign-lispfn deleteobject((object o))()
		(cond ((oid-p o)
		       (deleteobject o)
		       (foreign-result))))

(osql "
create function delete_objects(Bag b) -> Integer
   /* Delete all objects in bag b. 
      Return the number of objects deleted. */
   as select count(
        select true
        from Integer i, Vector v, Object o
        where v = vectorof(b) and
              o = v[i] and
              deleteobject(o));")

(foreign-lispfn addfunction ((function fno)(vector argl)(vector resl))()
		(addfunction-dynamic fno argl resl nil)
                (foreign-result)
		)

(foreign-lispfn setfunction ((function fno)(vector argl)(vector resl))()
		(setfunction-dynamic fno argl resl nil)
                (foreign-result)
		)

(foreign-lispfn remfunction ((function fno)(vector argl)(vector resl))()
		(remfunction-dynamic fno argl resl nil)
                (foreign-result)
		)

(defun dropfunction--+ (fno fn permanent r)
  (clearfunction fn (not (= permanent 1)))
  (osql-result fn permanent fn))

(osql "
create function dropfunction(Function fn, Number permanent)
                             -> Function
  /* Remove all rows of stored function fn. 
     permanent = 1 => cannot be rolled back */
   as foreign 'dropfunction--+';
")  

(foreign-lispfn add_type ((type tp) (object o)) ()
		"Add a type to an object. Parameterized version of:
   add type <tp> to <obj>;"
		(checked-addtype o tp)
		(foreign-result))

(foreign-lispfn remove_type ((type tp) (object o)) ()
		"Remove the type tp from the object o. Prameterized version of:
   remove type <tp> from <obj>;"
		(removetype1 (list o) tp)
		(foreign-result))

(osql "
create function add_type(Charstring tp, Object o) -> Boolean
  /* Add type named tp to object o */
  as select add_type(typenamed(tp), o);

create function remove_type(Charstring tp, Object o) -> Boolean
  /* Remove type named tp from object o */
  as select remove_type(typenamed(tp), o);")

(defmacro amosql (expr) (list 'osql expr))

(defun evalv-+ (fno q o)
  "Evaluate Amosql and return result as bag of vectors"
  (map-query q (f/l (&rest args)(osql-result q (listtoarray args)))))

(osql "
create function evalv(Charstring x) -> Bag of Vector
  /* Evaluate expression x and return result tuples as vectors */
  as foreign 'evalv-+';

create function eval(Charstring x)->Bag of Object o
  /* General eval function with variable width */
  as evalv(x)[0];")

(foreign-lispfn prepare_query ((charstring query)(number params))((function))
		"To support PREPARE in ODBC"
		(foreign-result (prepare-query query params)))            

(defun call-function--+ (fno fn params res)
  "Call the OSQL function 'fn' with parameters 'params'.
   - 'fn' - function object
   - 'params' - vector
   Emit one vector per result tuple"
  (mapfunctionres fn params nil 
		  (f/l (row)
		       (osql-result fn params (listtoarray row)))))

(defun inverse-function (fno)
  "Get the inverse of amosql function FNO"
  (the-tbr-function fno (nconc (buildn (getarity fno) '+)
			       (buildn (getarity fno) '-))))

(defun apply--+ (fno fn params res)
  (let ((r (if (generic? fn)(resolveargs fn (arraytolist params) nil) fn)))
    (mapfunction r params 
		 (f/l (row) (osql-result fn params (listtoarray row))))))

(defun apply-+- (fno fn params res)
  (let* ((rl (resolvents fn))
         (r (if (cdr rl) (error "Cannot apply inverse overloaded function"
                                fn)
	      (inverse-function (car rl)))))
    (mapfunction r res 
		 (f/l (row)
		      (osql-result fn (listtoarray row) res)))))

(osql "
create function apply(Function f, Vector args)->Bag of Vector 
   /* Call the AmosQL function f with parameters args.
      Emit one vector per result tuple */
  as multidirectional ('bbf' foreign 'apply--+')
                      ('bfb' foreign 'apply-+-');

create function call_function(Function fn, Vector params) -> Vector
   as foreign 'call-function--+';

create function call_function(Charstring fnname, Vector params) -> Vector
   as select call_function(functionnamed(fnname), params);")

(defun call_function----+ (fno peer fn args stopafter r)
  (dolist (row (remote-call peer 'callfunction (mksymbol fn)
			    args stopafter))
    (osql-result peer fn args stopafter row)))

(osql "
create function call_function(Charstring peer, Charstring fn, Vector args, 
                              Number stopafter) -> Bag of Vector
  /* Remote procedure call to function named fn on peer */
  as multidirectional ('bbbbf' foreign 'call_function----+' 
                       cost {1000000,10});")

(osql "
create function send_call(Charstring peer, Function fn, Vector args) ->
                         Boolean
  /* Asyncronuous call to function named fn on peer.
     Does not wait for result to be returned */
  as multidirectional('bbb' foreign 'send-call---'
                            cost {10,1});")

(defun send-call--- (o peer fn args)
  (let ((port (port-of-peer (mksymbol peer))))
    (send-form `(pcn , (kwote (oid-name fn)) , args) port)
    (osql-result peer fn args)))

(defun pcn (fn args)
  (proccall (getfunctionnamed fn) args))


(osql "
create function apply_pred(Function f)->Object as foreign 'apply-pred-+';
  
create function apply_pred_cost(Function f, Vector bpat, Vector args)
                            -> (Integer cst, Integer fanout)
   as foreign 'apply_pred_cost---++';")

(defglobal _apply_pred_ 
  (getfunctionnamed 'function.apply_pred->object)
  "OID of function APPLY_PRED")

(putobject _apply_pred_ 'bindings 
	   (list (make-tbr :bpat '*any* :impl 'apply-pred-+)))

(declarecosts _apply_pred_ '*any* 'apply_pred_cost)

(defun apply-pred-+ (fno f &rest args)
  "Applies function f to the arguments arg, if the arity is the same, and the
   binding pattern matches the forward direction of f."
  (let* ((in-arity (length (function-argvars f)))
	 (inargs  (firstn in-arity args))
	 (out-args (nthcdr in-arity args)))
    (if (some #'anonymous-varsymbolp inargs)
	(error "Yep, can only run this forwards" f))
    (mapfunction f args 
		 (f/l (result) 
		      (apply #'osql-result 
			     f (append inargs 
				       (remove-true-result result)))))))

(defun apply_pred_cost---++ (fno apply-fno bpat args cost fanout)
  (if (eq (getobject apply-fno 'name) 'FUNCTION.APPLY_PRED->OBJECT)
      (let* ((argl (arraytolist args))
					; must be declared using *any*
	     (costhint (getcosthint (first argl) nil)))
	(if (not costhint) (error "no cost hint for anonymous SQL function"))
	(let* ((cost-fno (getfunctionnamed (getcosthint (first argl) nil)))
	       (costtuple (first 
			   (getfunction 
			    cost-fno 
			    (list (first argl) #() 
				  (listtoarray (rest argl)))))))
	  (osql-result apply-fno bpat args (first costtuple) 
		       (second costtuple))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; File I/O
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(foreign-lispfn print((object o))() 
		"General print function"
		(if (stringp o)(princ o *mystream*)
		  (print-amos-object o *mystream*))
                (terpri *mystream*)
                (if (null *mystream*)(co-sleep _print-delay_))
                (foreign-result))

(foreign-lispfn output_lines((number n))((number))
		"Control # of lines to print on terminal"
		(if (< n 1)(setq _output-lines_ nil)
		  (setq _output-lines_ n))
		(foreign-result _output-lines_))

(defun write-ntuples--+ (fno bag filename r)
  (with-output-file
   s filename
   (mapbag
    bag
    (f/l (row)
	 (maparray
	  (car row)
	  (f/l (x i)
	       (princ x s)
	       (princ " " s)))
	 (terpri s))))
  (osql-result bag filename filename))

(defun read-ntuples-+ (fno filename r)
  (with-input-file
   s filename
   (mapstream
    s #'read-line
    (f/l (row)
       (with-textstream
        tstr row
        (let (v)
         (mapstream
          tstr #'read-token
          (f/l (o)
               (setq v (push-vector v o))))
         (osql-result filename v)))))))

(osql "
create function write_ntuples(Bag of Vector rowset, Charstring file)
                            -> Charstring
  /* Write tuples in rowset as N-tuples in file */
  as foreign 'write-ntuples--+';

create function read_ntuples(Charstring file)
                           -> Bag of Vector
  /* Read N-tuples in file as bag of vectors */
  as foreign 'read-ntuples-+';")

(foreign-lispfn load_lisp((charstring file))((charstring r))
		"Load file with Lisp code"
		(foreign-result (load file)))

(defun load-amosql- (fno osqlfile result)
  "Load file with AmosQL commands"
  (osql-result osqlfile (load-amosql osqlfile)))

(osql "
create function load_amosql(Charstring file) -> Charstring
  /* Evaluatee AmosQL statements in file */
  as foreign 'load-amosql-';")

(defun readlines--+ (fno file delim row)
  (with-input-file str file
		   (let (row)
		     (while (not (eq (setq row (read-line str delim)) '*eof*))
		       (osql-result file delim row)))))

;;; System definitions

(osql "
create function loadedSystems()->Bag of Charstring
  /* Table of loaded AmosQL master files */
  as stored;
create function loadedSystem(Charstring file)->Boolean
  /* Is master file loaded? */
  as select where file in loadedSystems();")

(defun loadsystem-- (fno dir sysfile result)
  "Load file with AmosQL commands defining subsystem in directory DIR"
  (let ((fullfile (fullpath (concat (add/last dir) sysfile))))
    (cond ((getfunction 'loadedSystem (list fullfile))
	   nil)
	  (t (with-directory dir (load-amosql sysfile))
	     (addfunction 'loadedSystems nil (list fullfile))
	     (osql-result dir sysfile fullfile)))))

(osql
"create function loadSystem(Charstring directory, Charstring file)->Charstring
  /* Load master file with AmosQL commands in directory */
  as foreign 'loadsystem--';") 

;;; End of system definitions

(defun filedate- (fno file date)
  (let ((tv (file-write-date file)))
    (if tv (osql-result file tv))))

(defun directoryp- (fno file)
   (if (directoryp file) (osql-result file)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Tuning, debugging, toggling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(osql "
create function optmethod(Charstring m)->Charstring r
  /* Choose query optimization method m used:
     exhaustive: dynamic programming
     ranksort:   greedy ranking
     randomopt:  randomized optimization */ 
  as foreign 'optmethod-+';")

(defun optmethod-+ (fno m r)
  (selectq (mkatom m)
	   (ranksort (/setglobal '*optmethod* 'ranksort))
	   (exhaustive (/setglobal '*optmethod* 'exhaustive))
	   (randomopt  (/setglobal  '*optmethod* 'randomopt))
	   (amos-error "Unknown optimization method: " m))
  (osql-result m m))

(foreign-lispfn optlevel ((number x)(number y))()
   (set-optlevel x y))

(foreign-lispfn opttrace ((boolean flg))()
		"To toggle tracing of Ranksort"
		(if (eq flg 'false)(setq flg nil))
		(/setglobal '*printopt* flg)
		(if flg (foreign-result)))

(foreign-lispfn optlog ((charstring file))((charstring))
		"Sets file for tracing optimizer"
		(/setglobal '*optlog* (if (equal file "") nil file))
		(foreign-result file))

(foreign-lispfn enable_parteval ((boolean flg))()
		"To enable partial evaluation"
		(if (eq flg 'false)(setq flg nil))
		(/setglobal '*enable-parteval* flg)
		(if flg (foreign-result)))

(foreign-lispfn latebinding ((charstring m)) ((charstring r))
  ;;; Use of /SETGLOBAL makes setting transactional!
		(cond
		 ((equal m "OR")  (/setglobal '_USE_DTR_ nil))
		 ((equal m "DTR") (/setglobal '_USE_DTR_ t)))
		(foreign-result (if _USE_DTR_ "DTR" "OR"))) 

(foreign-lispfn storagestat((boolean v))()
		(cond ((eq v 'true)(storagestat t)(foreign-result))
		      (t (storagestat nil))))

(foreign-lispfn debugging((boolean v))()
		(cond ((eq v 'true)(debugging t)(foreign-result))
		      (t (debugging nil))))

(foreign-lispfn exposeSource((boolean v))()
		(cond ((eq v 'true)(/setglobal '_include-source_ t)(foreign-result))
		      (t (/setglobal '_include-source_ nil))))

(foreign-lispfn  normalization ((boolean m)) ((charstring r))
  ;;; Use of /SETGLOBAL makes settings transactional
		 (cond
		  ((eq m 'TRUE) (/setglobal '*USE-DNF* t))
		  ((eq m 'FALSE) (/setglobal '*USE-DNF* nil)))
  
		 (foreign-result (if *USE-DNF* "DNF normalization"
				   "No normalization")))

(foreign-lispfn printstat()()
		(printstat))

(foreign-lispfn setup_mdb()()
		(setq *USE-DNF* T)
		(setq _USE_DTR_ nil))

(defun set-costhint (f bpat q)
  (let ((bp (bpatlist bpat)))
    (if (neq (length bp)(+ (getarity f)(getwidth f)))
	(amos-error "Wrong size of binding pattern:" bpat))
    (cond 
     ((stringp q)
      (declarecosts 
       f bp (mkatom q)))
     ((function_p q)
      (declarecosts 
       f bp q))
     ((arrayp q)
      (declarecosts 
       f bp (arraytolist q)))
     (t (amos-error "illegal cost hint" q)))))

(foreign-lispfn costhint((function f) (charstring bpat)(object q)) ((function))
		(set-costhint f bpat q)
                (foreign-result f))

(foreign-lispfn costhints ((function f))((charstring bpat)(object c))
		"Get the cost hints and their binding patterns for a resolvent"
		(mapbpats
		 f 
		 (f/l (tbr)
		      (let ((c (tbr-cost tbr)))
			(cond(c (if(eq c 'fail)(setq c nil))
				(foreign-result (listbpat (tbr-bpat tbr))
						(if (listp c)(listtoarray c)
						  c))))))))

(defun reoptimize0-+(fno f r)
  (dolist (r (resolvents1 f))
    (reoptimize r) ; exclude transient subqueries
    (osql-result f r)))

(defun reoptimize-+(fno f r)
  (dolist (r (resolvents1 f))
    (reoptimize r t) ; include transient subqueries
    (osql-result f r)))

(defun recompile-+ (fno f r) 
  (dolist (r (resolvents1 f))
    (recompile r)
    (osql-result f r)))

(defun subplans-+ (fno fn tr)
  (dolist (r (resolvents1 fn))
    (dolist (tr (function-subqueries r))
      (osql-result fn tr))))

(foreign-lispfn uncache_cost ((function f))((function))
		(uncache-costs f)
		(foreign-result f))

(setq *costfn*
      (foreign-lispfn methods-cost ((function tp)(vector bpat)(vector args))
		      ((number cost)(number fanout))
		      (foreign-result (* 0.5 (type-cardinality _function_)) 
				      10)))
(declarecosts 'type.methods->function '(- +) *costfn*)

(foreign-lispfn dp ((object o)(number priority))()
		"Debug print object O.  
   PRIORITY  is a user specified number the higher the earlier in plan."
		(print o)(foreign-result))

(declarecosts
 'object.number.dp->boolean '(- -)
 (foreign-lispfn 
  dp-cost ((function tp)(vector bpat)(vector args))
  ((number cost)(number fanout))
  "Cost of call to DP as specified by PRIORITY"
  (let ((priority (aref args 1)))
    (if (and (numberp priority)(> priority 0))
	(foreign-result 1 (/ 1 (float priority)))
      (error "Priority in DP must be positive number" priority)))))

(foreign-lispfn trace ((function fno))((function))
		(dolist (f (resolvents fno))
		  (let ((ft (functiontype f)))		
		    (cond ((equal ft "foreign")
			   (trace-olog f t)
			   (foreign-result f))
			  ((equal ft "stored")
                           (trace-olog (get-relation f) t)
			   (foreign-result f))))))

(foreign-lispfn untrace ((function fno))((function))
		(dolist (f (resolvents fno))
		  (let ((ft (functiontype f)))		
		    (cond ((equal ft "foreign")
			   (trace-olog f nil)
			   (foreign-result f))
			  ((equal ft "stored")
                           (trace-olog (get-relation f) nil)
			   (foreign-result f))))))

(osql "
create function trace(Charstring fn) -> Function
  /* Trace function named fn.
     Derived functions cannot be traced */
  as select trace(functionnamed(fn));

create function untrace(Charstring fn) -> Function
  /* Untrace function named fn */
  as select untrace(functionnamed(fn));")

(defun trace-osql (fns)
  "Trace AMOSQL function(s)"
  (mapcar (f/l (fn) (caar(getfunction 'trace (list (mkstring fn)))))
          (mklist fns)))

(defun untrace-osql (fns)
  "Untrace AMOSQL function(s)"
  (mapcar (f/l (fn)(caar (getfunction 'untrace (list (mkstring fn)))))
          (mklist fns)))

(defun profiling-+ (fno action res)
  (cond ((equal action "on") (start-profile t))
        ((equal action "all") (start-profile nil))
        ((equal action "off") (stop-profile))
        ((equal action "print") (pps (profile)))
        (t (error "Illegal profiling action" action)))
  (osql-result action action))

(osql "
create function profiling(Charstring action)->Charstring
  /* Control statistical profiling by action:
     on: turn on statistical profiling of Amos II functions
     all: turn on statistical prifiling of Amos II and Lisp
     off: turn off statistical profiling
     print: print percentage time spent in functions */
  as foreign 'profiling-+';")

(defun get-unique-keyposl (fno)
  (let ((p (get-relation fno)))
    (and p (mapcar (f/l (i)(and (index-unique i)(index-pos i)))
		   (relation-indexes p))))) 

 
(defun pardescr-to-posl (rno vardescr)
  "Convert vector of function parameter names into parameter position list"
  (let (posl)
    (maparray vardescr (f/l (v i)(push (get-function-varpos rno (mksymbol1 v)) 
				       posl)))
    (nreverse posl)))

(defun get-function-varpos (fno var)
  (let* ((dcll (function-dcll fno))
         (root (isome dcll (f/l(x)(eq (dcl-variable x) var)))))
    (cond ((null root) (amos-error "No parameter of " fno " named " var))
	  (t (- (length dcll)(length root))))))

(defun function-dcll (fno)
  (let ((orgcode (get-oc fno)))
    (append (orgcode-argl orgcode)
	    (let ((rl (orgcode-resl orgcode)))
	      (cond ((and (null (cdr rl))
                          (eq (caar rl) _bag_)
			  (eq (cadar rl) 'of))
		     (cadr (cdar rl)))
		    (t rl))))))

(defun posl-to-pardescr (fno posl)
  "Convert parameter position list to vector of function parameter names"
  (let ((dcll (function-dcll fno)))
    (listtoarray (mapcar (f/l (i)(mkstring (dcl-variable (nth i dcll))))
			 posl))))

(foreign-lispfn declare_key((function f)(vector keydescr))((vector))
   (dolist (r (resolvents f))
     (let ((keyposl (pardescr-to-posl r keydescr)))
     (add-keygroup r keyposl)
     (dolist (kg (keygroups r))
        (foreign-result (posl-to-pardescr r kg))))))

(foreign-lispfn undeclare_key((function f)(vector keydescr))((vector))
   (dolist (r (resolvents f))
     (let ((keyposl (pardescr-to-posl r keydescr)))
     (rem-keygroup r keyposl)
     (dolist (kg (keygroups r))
        (foreign-result (posl-to-pardescr r kg))))))

(foreign-lispfn declared_keys((function f))((vector))
		(dolist (r (resolvents f))
		  (dolist (kg (keygroups r))
		    (foreign-result (posl-to-pardescr r kg)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Index management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(osql "
create function index_data(Relation ro key)
                -> Bag of (Vector id key, Charstring kind, Charstring keyc)
  /* Index properties of relation */
  as foreign 'relation-indexdata';")

(defun relation-indexdata (obj ro id kind unique)
  (dolist (i (relation-indexes ro))
    (osql-result ro 
		 (vector ro (index-pos i))
		 (mkstring(index-type i))
		 (if (index-unique i) "unique" "multiple"))))

(foreign-lispfn relation_of((function fn))((relation))
		(dolist (fno (resolvents fn))
		  (let ((ro (get-relation fno)))
		    (if ro (foreign-result ro)))))

(defun build-index (oid fno var indtype multiplicity pos)
  (let ((ixd (createindex 
	      fno (mksymbol var) (mksymbol indtype)
	      (cond ((equal multiplicity "unique") t)
		    ((equal multiplicity "multiple") nil)
		    (t (amos-error 
			"Illegal multiplicity in index definition: " 
			multiplicity))))))
    (osql-result fno var indtype multiplicity (vector (car ixd)(cdr ixd)))))

(defun drop-index (obj fno var res)
  (let* ((res (getuniqueresolvent fno))
	 (pos (get-function-indexpos res (mksymbol var))))
    (/dropindex (delpredfunction res) pos)
    (osql-result fno var pos)))

(foreign-lispfn index_cardinality ((vector ix))((integer))
		(foreign-result (index-cardinality 
				 (getindex (aref ix 0)(aref ix 1)))))

(foreign-lispfn 
 function_cardinality 
 ((function fno)) ((integer c))
 (let ((r (theresolvent fno)))
   (cond ((equal (functiontype fno) "stored") 
	  (foreign-result (index-cardinality(car(relation-indexes(get-relation r))))))
	 (t (error "Cardinality is computed only on stored functions")))))

(foreign-lispfn indexes 
		((function f))((vector))
		(let (ro)
		  (dolist 
		      (r (resolvents f))
		    (if (setq ro (get-relation r))
			(dolist (ind (relation-indexes ro t))
			  (foreign-result 
			   (vector ro (index-pos ind)
				   (string-downcase (index-type ind))
				   (if (index-unique ind) "unique"
				     "multiple"))))))))

(foreign-lispfn primary_index ((function f))((vector))
		(let (ro ind)
		  (dolist 
		      (r (resolvents f))
		    (and (setq ro (get-relation r))
			 (setq ind (relation-indexes ro t))
			 (foreign-result 
			  (vector ro (index-pos (car ind))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Text processing functions.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; case-sensitive check if a string matches a pattern
(defun like-- (fno str pat)
  (if (string-like str pat)
      (osql-result str pat)))

(osql "
create function like(Charstring str, Charstring pat)-> Boolean b
  /* Match string str against regualr expression pat */
  as multidirectional
    ('bb' foreign 'like--');")

; case-insensitive check if a string matches a pattern
(defun like-i-- (fno str pat)
  (if (string-like-i str pat)
      (osql-result str pat)))

(osql "
create function like_i(Charstring str, Charstring pat)-> Boolean b
  /* Match string str against regualr expression pat ignoring case */
  as multidirectional
     ('bb' foreign 'like-i--');")

(defun lower-+ (fno str lowr)
  (osql-result str (string-downcase str)))

(osql "
create function lower(Charstring str) -> Charstring lowr
  /* Lower case string */
  as multidirectional
    ('bf' foreign 'lower-+');

create function atoi(Charstring s) -> Number i
  /* Convert string s to number */
  as multidirectional
     ('bf' foreign 'atoi-+' cost {1,1})
     ('fb' foreign 'atoi+-' cost {1,1});

create function itoa(Number i) -> Charstring a
  /* Convert integer to string */
  as select a where atoi(a) = i;")

(defun atoi-+ (fno str num)
  (let ((a (mkatom str)))
    (if (numberp a)(osql-result str a))))

(defun atoi+- (fno str num)
  (osql-result (mkstring num) num))

(foreign-lispfn char_length((charstring s))((integer))
		(foreign-result (length s)))

(foreign-lispfn substring ((charstring str1) (number start) (number end))
		((charstring str2))
		(foreign-result (substring start end str1)))

(osql "
create function plus(Charstring x, Object y)->Charstring r
  /* Concatenate string. Inverses produce prefix or suffix */
  as multidirectional ('bbf' foreign 'concat--+')
                      ('bfb' foreign 'concat-+-')
                      ('fbb' foreign 'concat+--');")

(defun stringify-+ (fno o e)
  (osql-result o (stringify-amos-object o)))

(defun stringify+- (fno o e)
  (let ((res (catch-error (caar (amos-execute (concat e ";"))))))
    (and res (not (error? res))
	 (osql-result res e))))

(osql "
create function stringify (Object o)-> Charstring e
  /* Convert object o to string */
  as multidirectional('bf' key foreign 'stringify-+' cost {5,1})
                     ('fb' key foreign 'stringify+-' cost {20,1});

create function unstringify(Charstring e)->Object o
  /* Parse string to object */
  as select o where stringify(o)=e;")

(defun not-empty- (fno str)
  (if (whitespaces str) nil
    (osql-result str)))

(osql "
create function not_empty(Charstring s)->Boolean
  /* Is string s empty? */
  as foreign 'not-empty-';")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; System interface functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq _invisible_ (osql "
create function invisible(Object) -> Boolean 
  /* Declare meta-objects not seen by GOOVI */
  as stored;"))

(osql "
create function set_invisible_fn(Charstring fn) -> Boolean
  /* Declare function named FN invisible for GOOVI */
  as begin set invisible(functionnamed(fn)) = TRUE; end;

create function set_invisible_type(Charstring fn) -> Boolean
  /* Declare function named FN invisible for GOOVI */
  as begin set invisible(typenamed(fn)) = TRUE; end;")

(defun visible-fn (fno)
  "Functions with - in their generic names are invisible"
  (and (not (transientp fno))
       (null (string-pos (generic-fnname fno) "-"))
       (not (getfunction _invisible_ (list fno)))
       (not (getfunction _invisible_ (list (generic-function-of fno))))))

(foreign-lispfn amos_version()((charstring))
		(foreign-result _system-version_))

(foreign-lispfn not_dt_object ((object obj)) nil
    (if (not (dt_obj_p obj))
        (foreign-result)))

(foreign-lispfn 
 save_all_images ((charstring prefix)) ((charstring srv) (charstring img))
 (let ((srv-images
	(global-eval `(concat (pwd) "/" , prefix _amosid_ ".dmp"))))
   (dolist (si srv-images)
     (if (eq _amosid_ (first si))(saveimage (second si))
       (send-form (list 'saveimage (second si))
		  (port-of-peer (first si)))))
   (dolist (res srv-images)
     (foreign-result (mkstring (first res)) (mkstring (second res))))))

(osql "
create function save_all_images () -> (Charstring, Charstring)
   as select save_all_images('');")

(defglobal _generations_ nil
  "Save points per generation number")

(foreign-lispfn abort () ()
		(reset))

(foreign-lispfn error ((charstring msg)) ()
                "Raise exception"
		(error msg))

(defun help-+ (fno x r)(help "ObjectLog")(osql-result x x))

(defun arg-resulttype (fno args) 
  "Result argument type same as argument"
  (list (arg-type (car args))))

(set-resulttypesfn (osql "
create function help(Object x) -> Object 
  as foreign 'help-+';")
		   'arg-resulttype)

(foreign-lispfn sleep ((number i))((number))
		(foreign-result (sleep i)))

(foreign-lispfn clock ()((real))
		(foreign-result (clock)))

(foreign-lispfn pwd () ((charstring dir))
		(foreign-result (pwd)))

(defun add/last (string)
  "Make STRING into a directory path ended with /"
  (let* ((up (subst "/" "\\" (explode string)))
         (root up))
    (while root;; remove //
      (while (and (equal (car root) "/")(equal (cadr root) "/"))
	(rplacd root (cddr root)))
      (pop root))
    (cond ((null up) string)
	  ((equal (car (last up)) "/") string)
	  (t (apply 'concat (nconc1 up "/"))))))

(or (getd 'cd)
    (defun cd (name)			; In case OS based CD not implemented
      (setq *load-directory* (add/last name))
      name))

(foreign-lispfn cd ((charstring dirname)) ((charstring))
		(foreign-result (cd dirname)))

(foreign-lispfn gethostname () ((charstring name))
		(foreign-result (gethostname)))

(foreign-lispfn getenv ((charstring var)) ((charstring val))
		(let ((val (getenv var)))
		  (if val (foreign-result val)
		    (amos-error "Environment variable not set: " var))))

(defvar *saved-image* nil "Bound to currently saved image in INIT form")
(defvar *in-saveimage* nil "True if inside SAVEIMAGE call")

(advise-around 
 'saveimage
 '(if *in-saveimage* nil
    (let ((*saved-image* (car !args))
	  (*in-saveimage* t))
      "If the image is NULL save the current image by default."
      (if (or (equal *saved-image* "") (null *saved-image*))
	  (setq *saved-image* _IMAGE-FILE_)
	(setq *saved-image* (mkstring *saved-image*)))
      (commit)
      *)))

(foreign-lispfn save_database ()()
		(saveimage nil))

(foreign-lispfn save_database ((charstring dmpfile))()
		(saveimage dmpfile))

(foreign-lispfn autosave ((boolean state)) ()
		(cond ((eq state 'TRUE)
		       (setq _AUTO_SAVE_ON_COMMIT_ T)
		       (foreign-result))
		      (t
		       (setq _AUTO_SAVE_ON_COMMIT_ nil))))

(foreign-lispfn autosave () ()
		(if _AUTO_SAVE_ON_COMMIT_
		    (foreign-result)))

(foreign-lispfn image_file () ((charstring image))
		(foreign-result _IMAGE-FILE_))

(foreign-lispfn startup_dir ()((charstring folder))
		(foreign-result (startup-dir)))

(movd 'commit 'oldcommit)
(defc 'commit '(lambda ()
                 (unbind-interface-variables)
		 (cond (_AUTO_SAVE_ON_COMMIT_
			(if _history_
			    (saveimage _IMAGE-FILE_))
			(oldcommit))
		       (t (oldcommit)))))

(defun register-saveimage (savefn restorefn)
  (register-rollout-form 
   `(getfunction , savefn (list *saved-image*))
   'first)
  (register-connect-form 
   `(getfunction , restorefn (list _image-file_))))

(defun register-saver-- (fno savefno restorefno)
   (register-saveimage savefno restorefno)
   (osql-result savefno restorefno))

(osql "
create function register_saver (Function savefn, Function restorefn)->Boolean
  /* savefn(Charstring image) is called before image is saved, 
     restorefn(Charstring image) when image is initialized */
  as foreign 'register-saver--';")

(defun logfile (fno flname options)
  (if (not (equal flname "")) 
      (redirect-basic-stdout flname))
  (if (string-like options "*comm*") (trace-packets t))
  (if (string-like options "*call*") (trace-cinterface t))
  )

(osql "
create function logfile(Charstring filename,charstring options)-> boolean
   as foreign 'logfile';")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; sorting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun sort-vector-fn--+ (obj v1 compfno v2)  
  "Sort vector of objects or tuples using COMPFNO"
  (osql-result v1 compfno 
	       (listtoarray (sort (arraytolist v1)
				  (f/l (x y)
				       (getfunction compfno (list x y)))))))

(defun bag-to-list (b)
  "Make list of objects or vectors from bag of tuples"
  (let (res)
    (mapbag b (f/l (x) (if (cdr x)(push (listtoarray x) res)
			 (push (car x) res))))
    res))
    
(defun sort-bag-fn--+ (obj b compfno v)
  "Sort bags of objects and tuples"
  (osql-result b compfno 
	       (listtoarray (sort (bag-to-list b)
				  (f/l (x y)
				       (getfunction compfno (list x y)))))))

(defun sortorder-symbol (x)
  (cond ((equal x "inc") 'inc)
	((equal x "dec") 'dec)
	(t (amos-error "Illegal sort order: " x))))
          
(defun access-pos (x ind)
  "Access position in result tuple or object"
  (cond ((not (arrayp x)) (if (= ind 0) x
			    (error "Illegal sorting position" (1+ ind))))
	((and (>= ind 0) (< ind (length x))) (aref x ind))
	(t (error "Illegal sorting position" (1+ ind)))))

(defun sort-bag-pos---+ (obj bag pos order vec)
  "Sort bags of objects or tuples coerced to vectors"
  (let ((order-sym (sortorder-symbol order))
	(idx (1- pos))
	sorted)
    (setq sorted (sort (bag-to-list bag)
		       (f/l (x y)
			    (let ((compres (compare (access-pos x idx)
                                                    (access-pos y idx))))
			      (if (eq order-sym 'inc)
				  (< compres 0)
				(>= compres 0))))))
    (osql-result bag pos order (listtoarray sorted))))

(defun sort-bag-posl---+ (obj bag posv orderv vec)
  "Sort bags of objects or tuples coerced to vectors using
   vectors of positions and directions"
  (let (sorted)
    (or (and (arrayp posv)(arrayp orderv)
             (= (length posv)(length orderv)))
        (amos-error "Wrong order specification in " obj))
    (setq sorted 
	  (sort (bag-to-list bag)
		(f/l (x y)
		     (maparray 
		      posv 
		      (f/l (e i)
			   (let ((compres 
				  (compare (access-pos x (1- e))
					   (access-pos y (1- e)))))
			     (cond ((< compres 0)
				    (if (eq (sortorder-symbol (aref orderv i))
					    'inc) (return t)
				      (return  nil)))
				   ((> compres 0)		     
				    (if (eq (sortorder-symbol (aref orderv i))
					    'inc) (return nil)
				      (return t))))))))))
    (osql-result bag posv orderv (listtoarray sorted))))

(defun sort-bag-tpl--+ (obj bag order vec)
  "Sort bags by the alphabetical order of the tuples as a whole."
  (let ((order-sym (sortorder-symbol order))
	unsorted sorted)
    (setq unsorted (bag-to-list bag))
    (setq sorted (sort unsorted
		       (f/l (x y)
			    (let ((compres (compare x y)))
			      (if (eq order-sym 'inc)
				  (< compres 0)
				(>= compres 0))))))
    (osql-result bag order (listtoarray sorted))))

(osql "
/* Vectors */
create function sortvector(Vector v, Function f) -> Vector
  /* Sort tuples in vector v using comparison function f */
  as foreign 'sort-vector-fn--+';

create function sortvector(Vector v, Charstring compfn) -> Vector
   as select sortvector(v, functionnamed(compfn));

/* Bags */
create function sortbag(Bag b, Function f) -> Vector
  /* Sort tuples in bag b using comparison function f */
  as select sortvector(vectorof(b), f);

create function sortbag(Bag b, Charstring compfn) -> Vector
   as select sortvector(vectorof(b), functionnamed(compfn));

create function sortbagby(Bag b, Number pos, Charstring order) -> Vector
  /* Sort tuples in bag b on values in postion pos using comparison function f.
     The order can be 'inc' or 'dec' */
  as foreign 'sort-bag-pos---+';

create function sort(Bag b, Charstring order) -> Vector
   /* Sort elements in a bag ordered by entire result tuples.
      The order can be 'inc' or 'dec' */
   as foreign 'sort-bag-tpl--+';

create function sort(Bag b) -> Vector
   /* Sort tuples in bag b in ascending order */
   as select sort(b, 'inc');

create function sortbagby(Bag b, Vector positions, Vector directions)->Vector
   /* Sort tuples in bag b based on position vectors */
   as foreign 'sort-bag-posl---+';")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Functions to access execution plans, the cost model, profiling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun plan-cost-++(o fno cost fanout)
  (let ((cf (exec-cost-of-fn fno nil)))
    (and cf (osql-result fno (first cf)(second cf)))))

(defun thetbr--+ (o fno bpat r)
  (osql-result fno bpat (the-tbr-function fno (bpatlist bpat))))

(osql "
create function theTBR(Function f, Charstring bpat) -> Function
  /* The TBR of function f for binding pattern bpat */
  as foreign 'thetbr--+';

create function theFunction(Charstring fn) -> Function 
  /* The only function named fn.
     An error is raised if fn is a generic function with several resolvents */
  as if notany(functionnamed(fn)) then error('No function named',fn)
     else return functionnamed(fn);
                   
create function theType(Charstring tpe) -> Type
  /* The type named tpe.
     An error is raised if no type is named tpe */
  as if notany(typenamed(tpe)) then error('No type named',tpe)
     else return typenamed(tpe);

create function theResolvent(Charstring fn) -> Function as
  /* If FN is the name of a resolvent return it. 
     If FN is a generic function with a single resolvent return the resolvent.
     If there not exactly one resolvent raise an error */
  if count(resolvents(theFunction(fn))) != 1 
     then error('Function has more than one resolvent',fn)
  else return resolvents(theFunction(fn));

create function plan_cost(Function f) -> (Real co, Real fo)
  /* The estimated cost of executing function f */
  as foreign 'plan-cost-++';

create function plan_cost(Charstring fn) -> (Real co, Real fo)
   as select plan_cost(theresolvent(fn));

create function plan_cost(Charstring f, Charstring bpat) 
                -> (Real co, Real fo)
  /* The extimated cost of executing function f for binding pattern bpat */
   as select plan_cost(theTBR(theresolvent(f),bpat));
")

(defun pc-+ (o fno r)
  (dolist (r (resolvents1 fno))
    (pc r nil (null _save-intermediates_))
    (osql-result fno r)))

(osql "
create function pc(Function f) -> Bag of Function r
  /* Display the execution plan of function f. 
     If f is generic display execution plans of its resolvents */
  as foreign 'pc-+';

create function pc(Charstring fn) -> Bag of Function 
  /* Display the execution plan of function named fn.
     If fn is generic display execution plans of its resolvents */ 
  as pc(functionnamed(fn));

create function pc(Charstring f, Charstring bpat) -> Function
  /* Display the execution plan of function f for binding pattern bpat */
  as pc(theTBR(theresolvent(f), bpat));")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Property list constructor used by normalizer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun rowprops--++ (fno props vals p v)
  (and (arrayp props)
       (arrayp vals)
       (= (length props)(length vals))
       (maparray props 
		 (f/l (prop i)
		      (osql-result props vals prop (aref vals i))))))
(setq _rowprops_ (osql "
create function rowprops(Vector props, Vector vals)
                     -> (Object p, Object v)
  as foreign 'rowprops--++';"))

                  
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; GOOVI interface
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun get-type-structure (type)
  (if (not (getfunction _invisible_ (list type)))
      (list (apply (function vector)
		  type
		  (mapcan (function get-type-structure) 
			  (subtypes type))))))

(defun get-type-structure2 (type)
  (if (not (getfunction _invisible_ (list type)))
      (list (apply (function vector)
		   type
		   (mapcan (function get-type-structure2) 
			   (subtypes type))))))

(foreign-lispfn get_type_structure((type type))((charstring)(vector))
		(foreign-result "*hierarchy*" 
				(car (get-type-structure type))))

(foreign-lispfn get_type_structure2((type type))((charstring)(vector))
		(foreign-result "*hierarchy*" 
				(car (get-type-structure2 type))))

(defun mksignaturedescr (ad startpos uniqueposl)
  (apply 'vector 
	 (mapcar (f/l (x)
		      (prog1
			  (vector (first x)(mkstring(second x))
				  (if (member startpos uniqueposl) 
				      "key" "nonkey"))
			(1++ startpos))) 
		 ad)))

;;;; Extenders

(defun extlang-+ (fno lang)
  (if (load-extension (concat lang "_ext") t nil)(osql-result lang)))

(osql "
create function extlang(Charstring lang)->Boolean
  as foreign 'extlang-+';"
      )

(defun load-extension-+ (fno ext r)
  (if (cond ((extension-loaded ext) nil)
	    (t (load-extension ext t nil nil)))
      (osql-result ext 'true)))

(defun reload-extension-+ (fno ext r)
  (if (cond ((extension-loaded ext)(load-extension ext t nil t))
	    (t (load-extension ext t nil nil)))
      (osql-result ext 'true)))
  
(osql "
create function load_extension(Charstring ext)->Boolean
  as foreign 'load-extension-+';
create function reload_extension(Charstring ext)->Boolean
  as foreign 'reload-extension-+';")
