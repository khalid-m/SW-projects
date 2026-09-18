pushd MVC
msdev amos2.dsw /rebuild /make "amos2 - Win32 Release With Debug"

msdev pyamos/pyamos.dsw /rebuild /make "pyamos - Win32 Release"
popd