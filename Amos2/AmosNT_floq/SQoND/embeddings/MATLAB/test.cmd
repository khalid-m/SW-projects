pushd MATLAB

start amos2 -n
start amos2 -o "register('peer');" -o "listen();"
start ssdm -o "register('ssdmpeer');" -o "listen();"

matlab -nodesktop -nodisplay -nosplash -r demoScript;exit -wait 

amos2 -o "register('killer');" -o "kill_the_federation();";

popd