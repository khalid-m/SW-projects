for ((i=0; i<21; i++))
  do
  export i
  cat input/$i/historical-tolls.out | \
      awk 'BEGIN {FS=","; file = "input/" ENVIRON["i"] "/cumulvid"; \
           getline offset < file} ; \
           {print $1+offset "," $2 "," ENVIRON["i"] ","  $4}' > \
      hist$i
done
