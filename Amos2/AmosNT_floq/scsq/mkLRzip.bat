@echo off
pushd lr
call install.cmd
call mkhist.cmd
call mkdmp.cmd
popd
echo Removing old SCSQ-LR.zip ...
del SCSQ-LR.zip
echo Building new SCSQ-LR.zip ...
zip SCSQ-LR lr\scsq.exe lr\scsq.dmp lr\lr.dmp lr\mkhist.cmd lr\mkdmp.cmd lr\test.cmd lr\lr.cmd lr\data\hist_lite.out lr\data\cdp_mid15.out lr\src\Accident_check.osql lr\src\Historical_data.osql lr\src\historytest.osql lr\src\loadhistory.osql lr\src\lread.lsp lr\src\master.osql lr\src\mkdmp.osql lr\src\test.osql lr\src\Timecalc.osql lr\src\toll_calc.osql lr\src\visited.lsp lr\readme.txt lr\mkhist10.cmd lr\mkhist15.cmd lr\src\loadhistory10.osql lr\src\loadhistory15.osql lr\src\statfns.osql lr\extractLavs.pl lr\preverify.sh lr\preprocess.sh

:END
