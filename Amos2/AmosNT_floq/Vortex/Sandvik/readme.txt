	 How to run SVALI with the CORENET data stream server
	 ----------------------------------------------------

NOTICE: 
======================================================================
The CORENET system is developed by Sandvik Coromant AB.
It is proprietary and cannot be used outside the Smart Vortex project.
======================================================================

----------------------------------------------------------------------
1. Make sure you have unpacked the CORENET data stream server by
doing:

pushd ..\Sandvik
unzip corenet.zip
popd

----------------------------------------------------------------------
2. Run the CORENET data stream server:

pushd ..\Sandvik
start /min server mill.csv 1337
popd

  NOTICE: 
  In the CoreNetServer panel, make sure to configure Data Provider
  correctly:

  a. Click 'Stop live'
  b. Enter private key and the certificate from ..\Sandvik\corenet\cert
  c. Click the 'Configure' button
  d. Uncheck 'Send date and timestamp'
  e. Check 'Loop file when eof reached'
  f. Click 'Reload' button
  g. Click 'Save settings' button
  h. Click 'Go live'
----------------------------------------------------------------------
3. Run SVALI with the November 2012 review database:

..\bin\svali demo2012.dmp

You will enter the SVALI top loop where you can give SCSQL commands.

----------------------------------------------------------------------
4. Test CQs to CORENET in the SVALI top loop

Example of CQs for milling defined as function calls:

CQ 1: This CQ returning the power consumption on machine "A" 
     (in() runs the stream):

   playback(MillPower("A"));

CQ 2: This CQ runs the validation according to the milling model.
      When there is significant deviation it returns the time stamp and 
      power consumption on machine "A": 

   playback(ValidateMill("A"));

CQ 3: This CQ runs an alert stream of messages when the validation CQ
      has indicated significant deviations:

   playback(MillAlerts("A"));

----------------------------------------------------------------------
5. Start SVALI name server:

start svali -n

----------------------------------------------------------------------
6. Start the SVALI server

To start a SVALI server named S, enter these commands to the SVALI top
loop:
  
  register("s");
  listen();

Now SVALI is running as a server with the name 'S' registered in the
name server. Java applications can connect to the SVALI server using
the name 'S'. 

If the name server is running on another host than the application the
environment variable NAMESERVERHOST should be set to the nameserver's
host.

----------------------------------------------------------------------

Questions about SVALI and CORENET: Cheng.Xu@it.uu.se