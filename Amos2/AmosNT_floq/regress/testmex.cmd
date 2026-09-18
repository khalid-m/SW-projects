pushd ..\bin
alisp -L ..\regress\testmex.lsp -l "(test1 bt) (rollout 'foo.dmp) (quit)"
REM Testing Save-Restore MEXIMA on ALisp when BT extension is moved
if exist bt.dll1 del bt.dll1
ren bt.dll bt.dll1
alisp foo.dmp -l "(test2 bt)(quit)"

REM Testing MEXIMA on ALisp when BT extension is restored back
ren bt.dll1 bt.dll
alisp foo.dmp -l "(test1 bt)(quit)"
if exist foo.dmp del foo.dmp
popd

REM Testing Save-Restore MEXIMA on Amos2
amos2 -O testmex.osql -o "quit;"
amos2 foo.dmp -l "(test-mexi)(quit)"

REM Testing Save-Restore MEXIMA on Amos2 when BT extension is moved
pushd ..\bin
amos2 -O ..\regress\testmex.osql -o "quit;"
if exist bt.dll1 del bt.dll1
ren bt.dll bt.dll1
amos2 foo.dmp -l "(test-mexi-when-extension-couldnot-be-loaded)(quit)"

REM Testing MEXIMA on ALisp when BT extension is restored back
ren bt.dll1 bt.dll
alisp foo.dmp -l "(test-mexi)(quit)"
if exist foo.dmp del foo.dmp
popd