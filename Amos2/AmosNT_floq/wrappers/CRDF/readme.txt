 		    How to install and run CRDFAmos
		     wrapper of RDF and RDFSchema

1. Download Win32 Binary of Redland RDF Application Framework from
   http://librdf.org/. Source was compiled with redland-1.0.3 on
   21/07/2006.  Mirror in
   http://user.it.uu.se/~udbl/software/redland-1.0.3-Win32-Dev.zip.
				
2. Set environment variable RAPTOR_HOME to home directory of Redland,
   e.g. C:\redland-1.0.3-win32-Dev

3. Compile C code by calling
    compile.cmd

4. Add Redland directory %REDLAND_HOME% to PATH and restart so that
   DLLs under Redland directory can be found.
		
5. Generate Amos II database image for CRDFAmos by calling
    mkdmp.cmd

6. Test RDFAmos by calling
    test.cmd

7. Run CRDFAmos by calling
    CRDFAmos.cmd

