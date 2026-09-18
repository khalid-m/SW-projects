1. change the current directory to the WSMED home directory:
   cd %AMOS_HOME%\wrappers\wsmed\record_v

2. Run setup

3. Run compile

4. Run  mkdmp

5. Run wsmed

6. Run :
   < importwsdl("WSDL URI");

7. Import the wrapped functions for the webservice from the file with the name of the WSDL  URI
 < 'src\amosql\WSDL URI.amosql';

8. Import the user created amosql file that contains the view definitions.
   <'src\amosql\views.amosql';

9. Run SQL queries
	sql("SQL QUERY");

