mv o-acc-alert o-acc-alert.old
mv o-tollalert o-tollalert.old
mv o-t2 o-t2.old
mv o-t3 o-t3.old
cat o-acc-alert.old |sed 's/#(//g'|sed 's/)//g'|awk '{print $1,$2,int($3+0.5),$4,$5}'|sed 's/ /,/g' >o-acc-alert
cat o-tollalert.old |sed 's/#(//g'|sed 's/)//g'|awk '{print $1,$2,$3,int($4+0.5),int($5),int($6)}'|sed 's/ /,/g' >o-tollalert
cat o-t2.old |sed 's/#(//g'|sed 's/)//g'|awk '{print $1,$2,int($3+0.5),$4,int($5+0.5),int($6+0.5)}'|sed 's/ /,/g' >o-t2
cat o-t3.old |sed 's/#(//g'|sed 's/)//g'|awk '{print $1,$2,int($3+0.5),$4,$5}'|sed 's/ /,/g' >o-t3
