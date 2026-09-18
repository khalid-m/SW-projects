import callin.*;
import callout.*;
import java.util.*;
import java.io.*;

//used to get the type of the parameters
public class Get_type{
        static Connection theConnection;

 public static String comb(CallContext cxt, String sqlq) throws AmosException {

        int i,j;
        Scan s;
        Tuple arg1= new Tuple(2);
        String c_para="";
        String f_para="";
        String para="";

        //get table and column names
        Check_para c= new Check_para();
        c_para=c.fcheck(sqlq);
        
        Get_para g= new Get_para();
        para = g.get(sqlq);
        
        if (para==""){ f_para="Integer t_number,Real delay";}
        
        else{
        String[] arr=c_para.split(",");
        String[] arr2=para.split(",");
        String str1="";
        String str2="";
        String[][] arr1= new String[100][100];

        for (i=0;i<arr.length;i++)
        {
                arr1[i] = arr[i].split(" ");

        }
        for(i=0;i<arr.length;i++)
            {   for(j=0;j<1;j++){
                arg1.setElem(0, arr1[i][j]);
                arg1.setElem(1, arr1[i][j+1]);
		s =  cxt.connection().callFunction("charstring.charstring.check_type->charstring",arg1);
		str1=s.getRow().getStringElem(0);
		if (str1.equals("int")|| str1.equals("double")){
		    str1="Integer";}
		else if (str1.equals("char")|| str1.equals("varchar"))
		    {str1="Charstring";}
		else{}
		str2=str1+" "+arr2[i]+",";
                f_para+=str2;
	    }
            }

        f_para=f_para.substring(0, f_para.length()-1)+",Integer t_number,Real delay";}

        return f_para;
	     }


}
