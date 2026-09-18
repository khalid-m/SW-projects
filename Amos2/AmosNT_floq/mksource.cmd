del prebuilt.zip
set releasing=
pushd embeddings\php
call compile.cmd
popd
echo Making image...
pushd bin
call install
popd

echo Building new amos2.zip ...
zip -r prebuilt bin/Makefile README bin/README bin/initialize.cmd bin/javaamos.bat bin/amos2.exe bin/grep.exe bin/alisp.exe bin/gmake.exe bin/JavaAmos.dll bin/php_amos.dll bin/msvcrtd.dll demo/wcdata.amosql demo/tutorial.amosql demo/*.dsp demo/*.dsw demo/*.opt demo/scenario/* java/*  doc/*.pdf doc/*.html doc/*.gif doc/*.jpg C/* embeddings/PHP/* embeddings/PHP/amos/* embeddings/PHP/htdocs/* wrappers/Amos/* wrappers/*.lsp wrappers/datasource/* wrappers/JDBC/* wrappers/JDBC/jdbc_interface/* wrappers/JDBC/regress/*  wrappers/relational/* SQL/* SQL/project/* SQL/regress/* lsp/* system/C/* system/include/* system/Linux/* system/MVC/* regress/*.lsp regress/*.osql


