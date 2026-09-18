call install
start cmd.exe /c gen -l "(trace server-eval system)" -ns
call gen -O "src/test.osql" -o "quit;"
