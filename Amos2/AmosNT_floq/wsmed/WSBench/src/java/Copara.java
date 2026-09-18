
public class Copara{
   public static String change(String opara){
    int i;
    String[] arr=opara.split(",");
    String[] arr1=opara.split(",");
    String[] arr2=opara.split(",");
    String str="";
    for (i=0; i<arr.length; i++)
    {
        if (arr[i].indexOf("Integer ")>-1)
        { arr1[i]= arr[i].replace("Integer ","");
         }
        else if (arr[i].indexOf("Charstring ")>-1)
        {arr1[i]= arr[i].replace("Charstring ","");
        }
        else if (arr[i].indexOf("Real ")>-1)
        {arr1[i]= arr[i].replace("Real ","");
        }
    }

   for (i=0; i<arr.length; i++)
   {  if (arr[i].indexOf("Integer ")>-1)
      { arr2[i]= arr1[i].replace(arr1[i],"\"+"+arr1[i]+"+\"");
      }
           else if (arr[i].indexOf("Charstring ")>-1)
           { arr2[i]= arr1[i].replace(arr1[i],"'\"+"+arr1[i]+"+\"'");
           }
            else if (arr[i].indexOf("Real ")>-1)
           { arr2[i]= arr1[i].replace(arr1[i],"\"+"+arr1[i]+"+\"");
           }
          
       str+=arr2[i]+",";
   }
   str=str.substring(0, str.length()-1);

   return str;

   }

}