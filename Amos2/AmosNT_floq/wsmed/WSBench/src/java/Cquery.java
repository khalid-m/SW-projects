public class Cquery{
   public static String show (String sqlq, String opara){
    int i,j;
    String sqlq1 = sqlq;
    String[] arr=opara.split(",");
    String[] arr1 = opara.split(",");
    for (i=0; i<arr.length; i++)
    {
        if (arr1[i].indexOf("Integer ")>-1)
        {  arr1[i]= arr1[i].replace("Integer ","");
         }
        else {arr1[i]= arr1[i].replace("Charstring ","");}
    }

    for (i=0; i<arr.length; i++){
      for(j=0; j<4; j++){
         if (sqlq.indexOf("=?"+arr1[i])>-1 && arr[i].indexOf("Integer ")>-1)
            {sqlq1=sqlq1.replace("=?"+arr1[i],"=?");
             }

          else if (sqlq.indexOf("=?"+arr1[i])>-1 && arr[i].indexOf("Charstring ")>-1)
             {sqlq1=sqlq1.replace("=?"+arr1[i],"=?");}

          else if (sqlq.indexOf("<?"+arr1[i])>-1 && arr[i].indexOf("Integer ")>-1){
             sqlq1=sqlq1.replace("<?"+arr1[i],"<?");}

          else if (sqlq.indexOf("<?"+arr1[i])>-1 && arr[i].indexOf("Charstring ")>-1)
             {sqlq1=sqlq1.replace("<?"+arr1[i],"<?");}

          else if (sqlq.indexOf(">?"+arr1[i])>-1 && arr[i].indexOf("Charstring ")>-1)
             {sqlq1=sqlq1.replace(">?"+arr1[i],">?");}

          else if (sqlq.indexOf(">?"+arr1[i])>-1 && arr[i].indexOf("Integer ")>-1)
             {sqlq1=sqlq1.replace(">?"+arr1[i],">?");}

          else{ sqlq1=sqlq1;}
        }
    }
    return sqlq1;
}

}