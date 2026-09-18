
import java.lang.Character.*;
//used to find out the paramertes matched table name
public class Get_table{
   public static String look(String sqlq){
    int i,j;
    String str="";
    String[] arr=sqlq.split("select");
    String[] arr1=sqlq.split("select ");

    for (i=0; i<arr.length; i++)
    {   if(arr[i].indexOf("from") > -1 && arr[i].indexOf("where") > -1)
        {   arr1[i]=arr[i].substring((arr[i].indexOf("from")+5), (arr[i].indexOf("where")));}
        else if (arr[i].indexOf("from")>-1&&arr[i].indexOf("where")<=-1)
          {arr1[i]=arr[i].replace(arr[i],""); }
        else{arr1[i]=arr[i].replace(arr[i],"");}

    str+=arr1[i];
       }
    return str;

}
}


