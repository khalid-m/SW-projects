del svali.zip
call installVortex.cmd
call installVortex2013.cmd
zip svali.zip bin/amos2.dll bin/JavaSCSQ.dll bin/amos2.lib bin/amos2.exe bin/amos2.dmp 
zip svali.zip bin/demo2012.dmp bin/goovi.cmd bin/xt.dll bin/bt.dll bin/demo2013.dmp
zip svali.zip bin/svali.dll bin/svali.dmp bin/svali.exe bin/svali.lib C/*.h
zip svali.zip bin/pca.py bin/corenet_streamer.py
zip svali.zip extensions/*.c extensions/readme.txt extensions/*.osql 
zip svali.zip extensions/*.csv extensions/csvwrapper/*.dsp 
zip svali.zip extensions/csvwrapper/*.dsw extensions/csvwrapper/*.opt
zip svali.zip extensions/numtuples/*.dsw extensions/numtuples/*.dsp 
zip svali.zip extensions/numtuples/*.opt
zip svali.zip Java/*.cmd Java/*.java Java/*.txt Sandvik/corenet.zip 
zip svali.zip Sandvik/corenet_streamer.py Sandvik/server.cmd 
zip svali.zip Sandvik/readme.txt bin/javaamos.jar bin/JavaAmos.dll
zip svali.zip Sandvik/MillWrapper.osql Sandvik/MillingModel.osql
zip svali.zip Sandvik/SandvikMetaData.osql schema/SmartVortexSchema.osql 
zip svali.zip Hagglunds/readme.txt Hagglunds/data/COOLER.zip 
zip svali.zip Hagglunds/testCOOLER.cmd Hagglunds/pca.py
zip svali.zip Hagglunds/HagglundsLogWrapper.osql
zip svali.zip Hagglunds/HagglundsCOOLERDump.osql Hagglunds/HagglundsCOOLERWrapper.osql
zip svali.zip Hagglunds/HagglundsCOOLERModel.osql Hagglunds/HagglundsCOOLERValidator.osql
zip svali.zip Hagglunds/HagglundsCOOLERMetaData.osql Hagglunds/HagglundsCOOLERDemo.osql
zip svali.zip Hagglunds/regress/cooler.lsp
zip svali.zip Volvo/CanBusWrapper.osql Volvo/RecordedCanBusWrapper.osql Volvo/WheelLoaderWrapper.osql
zip svali.zip Volvo/WheelLoaderModel.osql Volvo/VolvoMetaData.osql
zip svali.zip Volvo/data/CanBus_Recorded.csv Volvo/data/cbd.csv
zip svali.zip Volvo/data/canbuslog2013-11-14_1.csv Volvo/data/canbuslog2013-11-14_2.csv