1. change the current directory to WSMED home directory:
   cd %AMOS_HOME%\wsmed

2. To check WSMED is working fine:
  Run regress

3. To start WSMED:
  Run wsmed

4. To consume a web service illustrated with a WSDL URL , a user need to import the WSDL URL.
   Run :
   < importwsdl("WSDL URI");

   E.g: importwsdl("http://user.it.uu.se/~msabesan/WSDL/TerraService2.wsdl");

5. Run SQL queries
	sql("SQL QUERY");
   E.g:
    sql("select gl.City ,  gl.PlaceTypeId from GetPlaceList gl where  gl.placeName='Atlanta'and gl.MaxItems=100 and gl.imagePresence='true'");
   

