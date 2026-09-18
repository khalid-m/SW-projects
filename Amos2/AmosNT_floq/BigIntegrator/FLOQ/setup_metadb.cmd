rem GRANT ALL PRIVILEGES ON metadb.* TO regress @'%' IDENTIFIED BY 'regress'; 

set portdb=3306


set database=metadb


call javaamos -O popmetadb.amosql
