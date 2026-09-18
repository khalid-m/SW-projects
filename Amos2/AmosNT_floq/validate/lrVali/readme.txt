1. First run master.cmd

2. Then as in validation.cmd, the validation is run by calling the function
	lrvalidationg(Charstring exec, Charstring filename, Charstring hostname);
   the argument:
	"exec" must be a DSMS program which accepts five sockets numbers
		the first socket number for reading input streams
		the rest four for sending output streams
	"filename" is the file for generating input stream (to make it run make sure you have the file in the right directory)
	"hostname"