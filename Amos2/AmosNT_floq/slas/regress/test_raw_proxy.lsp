(checkequal 
 "Testing count # of sensor readings"
 ((osql "count(sql('select m,s,bt, et from RawFile'));")
  '((100000))))

(checkequal 
 "Testing count # of sensor readings deviating from its expected value 11 (bars) more than 240 seconds"
 ((osql "count(sql('select m,s,et-bt,mv from RawFile where abs(mv - 20) > 11 and et-bt>240.0'));")
  '((50))))


