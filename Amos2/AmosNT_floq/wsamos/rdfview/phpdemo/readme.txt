	How to deploy and run phpdemo

1) Install Amos II, PHP and Apache so that 
   
   - PHP is plug-in to Apache
   - PHPAmos is plug-in to PHP

Instructions on how to make this can be found in %AMOS_HOME%\embeddings\PHP\readme.txt

2) Deploy the phpdemo files
    
Please, have in mind that all the php files are copied (by deploy.cmd) to the direcory
%AHD%/htdocs, where %AHD% is the 'Apache Home Directory', which is usually 
C:\Program Files\Apache Group\Apache2. So, if you have not set 
an environment variable called %AHD% and pointing to the Apache Home, it is necessary to do it.

Once this is done run:
deploy.cmd


