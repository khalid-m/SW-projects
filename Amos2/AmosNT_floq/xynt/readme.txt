1. Install XYNTService

Simply run the command procedure ONCE:

   install.cmd

It will copy all files in this directory to a folder
%programfiles%\xynt and install XYNTService as a Windows
service. However, the service is NOT activated yet.

2. Configure XYNTService
 
Goto folder %programfiles%/xynt and edit file
%programfiles%/xynt/XYNTService.ini. 

Replace string %programfiles% with the actual value of %programfiles%.

The provided XYNTService.ini file provides as EXAMPLE how to launch an
Amos II nameserver, given that Amos II is installed in folder
%programfiles%/AmosII. 

NOTICE that the example requires that you first copy the version of
Amos II you wish to have as service to %programfiles%/AmosII. Easiest
to create %programfiles%/AmosII is to make an Amos II zip by calling
mkrunnable.bat in %amos_home% and unzip it to %programfiles%/AmosII.

NOTICE that the regression test (testmaster.bat) will fail if the
nameserver is runing as a service. Stop the service before running
testmaster.bat!

NOTICE that an important reason for using a separate copy of Amos II
(%programfiles%\AmosII) for the service as in the example is that if
you use the CVS version for the service you will be unable to update
Amos II since DLLs will be locked by the service.

You can configure many services by adding new ones named [Process1]
etc. at the end.

The checked in XYNTService.ini file shows how to start Amos II name
server service.  

3. Start the XYNTService
 
To start your services specified by the xyntservice.ini file do: Open
control panel - administrative tools - services and start service
named 'xyntservice'.

You can test that the example nameserver runs as a service by starting
Amos II and call the function
   amos_servers();

4. To add new services when xyntservice is already installed
      4.1 Edit xyntservice.ini file to add new service
      4.2 Update service in control panel (see 3.) 

5. Uninstalling XYNTService 

To removing the xyntservice do:
      5.1. Open control panel - administrative tools - services
           and stop service named 'xyntservice'
      5.2  xyntservice -u

NOTICE you MUST remove the XYNTService before you can delete files in
the directory where XYNTService is started
(%programfiles%\xynt).  
