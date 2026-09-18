#!/bin/bash

for i in 1 2 3 4 5 6 7 8
  do
  sed "s/XX/$i/;s/YY/alldata/" BGMLR.osql > all_bgmlr$i.osql
  sed "s/XX/$i/;s/YY/firstone/" BGMLR.osql > bgmlr$i.osql
done
