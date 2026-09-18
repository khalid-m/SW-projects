call javac ExinmaDemo.java
@echo ----------------------------------------------------------
@echo Index data with MYMAP and save it
@echo -----------------------------------------------------------
call javaamos  -o "<'exinmademo.osql'; save 'exinmademo.dmp'; quit;"

@echo -----------------------------------------------------------
@echo Load MYMAP index info 
@echo -----------------------------------------------------------
call javaamos exinmademo.dmp -o "q();pc('q');quit;"
