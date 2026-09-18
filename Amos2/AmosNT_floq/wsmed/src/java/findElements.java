import java.util.*;
import java.io.*;

public class findElements {
    
   
   

    public static String pickupElements(String str, String elename, String wsdltype, String min, String max)
    {
	/* For the datatypes created by wsmos with name 'row'*/
       
	if (elename.equalsIgnoreCase("'row'"))
	    return "";
       
        
	StringTokenizer stk = new StringTokenizer(str, " ");
	//System.out.println("string  "+ str);
	String telename="",twsdltype="", tmin="",tmax="",eleinstance="";
	while (stk.hasMoreTokens()) {
	    if (stk.nextToken().equalsIgnoreCase("Element"))
		{
		    stk.nextToken();
                    eleinstance=stk.nextToken();
		    while (!(stk.nextToken().equalsIgnoreCase("="))){}
		    telename=stk.nextToken();
                    //System.out.println("tele name "+telename);
                    

		    
		    if (telename.equals(elename))
			{
			    while (!(stk.nextToken().equals("="))){}
			    twsdltype =stk.nextToken();
			    //System.out.println("twsdltype "+twsdltype);
			    if (twsdltype.equals(wsdltype))
				{
				    //SKIP wsmedtype
				    while (!(stk.nextToken().equals("="))){}
				    // find minoccurs
				    while (!(stk.nextToken().equals("="))){}
				    tmin =stk.nextToken();
				    //System.out.println("tmin  "+tmin);
				    if (min.equalsIgnoreCase(tmin))
					{
					    while (!(stk.nextToken().equals("="))){}
					    tmax =stk.nextToken();
					    if (max.equals(tmax))
						{
						    //System.out.println("tmax "+tmax+ " "+telename)  ;                                                             
						    break;
						}
					    else
						tmax="";
					}
				}
			}                                                                                                                                                                                                                                         
		}
	}
	if (tmax.equals(""))
            eleinstance="";
	return eleinstance;
	
    }
    
  public static String checkDupname(String inputstr, String checkname)
    {
        
	if (checkname.equalsIgnoreCase("type"))
	    checkname=checkname+"1";

       
	StringTokenizer stk = new StringTokenizer(inputstr, " ");
	//System.out.println("inputstring  "+ inputstr+" checkstr "+checkname);
	StringTokenizer chkst = new StringTokenizer(checkname, "_");
	int len=stk.countTokens();
	String[] arrchkstr= new String[chkst.countTokens()];
	String[] arrinstr= new String[len];
	int chindex=0;
	int inindex=0;
	
	//tokenizing the inputstr
	while (stk.hasMoreTokens())
	    {
		arrinstr[inindex]=stk.nextToken();
		//System.out.println("input token "+arrinstr[inindex]);
		inindex+=1;
	    }
	//tokenizing the checkname
	while (chkst.hasMoreTokens())
	    {
		arrchkstr[chindex]=chkst.nextToken();
		//System.out.println("checkstring token "+arrchkstr[chindex]);
		chindex+=1;
	    }
	chindex-=1;
	
	checkname=arrchkstr[chindex];
	String intok=arrinstr[0];

	inindex=0;
	
	while (inindex< len) {
		    	
	    //System.out.println(arrinstr[inindex]);
	    if (arrinstr[inindex].equalsIgnoreCase(checkname))
		{
		    //System.out.println("check name " +checkname);
		    chindex-=1;
		    checkname=arrchkstr[chindex]+"_"+checkname;
		   
		}
	    else
		inindex+=1;
			
	}
		
	//System.out.println("final str "+ checkname);

	// only this check needed for regression test of WSMED
	if (checkname.equals("1")) checkname="v1";

	return checkname;
	
    }

   public static String checkDuptablename(String inputstr, String checkname)
    {

	StringTokenizer stk = new StringTokenizer(inputstr, " ");
	//System.out.println("inputstring  "+ inputstr+" checkstr "+checkname);
	
	int len=stk.countTokens();
	String[] arrinstr= new String[len];

	int inindex=0;
	
	//tokenizing the inputstr
	while (stk.hasMoreTokens())
	    {
		arrinstr[inindex]=stk.nextToken();
		//System.out.println("input token "+arrinstr[inindex]);
		inindex+=1;
	    }

	String intok=arrinstr[0];

	inindex=0;
	
	while (inindex< len) {
		    	
	    //System.out.println(arrinstr[inindex]);
	    if (arrinstr[inindex].equalsIgnoreCase(checkname))
		{
		    //System.out.println("check name " +checkname);
		  
		    checkname=checkname+"_1";
		    inindex=0;
		   
		}
	    else
		inindex+=1;
			
	}
		
	//System.out.println("final str "+ checkname);

	

	return checkname;
	
    }
    /**
     * To rename the reserved keywords
     *
     * @param   inputstr string need to be searched
     *
     * @return  cleaned str
     *    
     */
    public static String checkReservedKW(String inputstr){
	StringTokenizer stk = new StringTokenizer(inputstr, " ");
	//System.out.println("inputstring  "+ inputstr+" checkstr "+checkname);
	inputstr="";
	String tempStr="";
	int len=stk.countTokens();
       	//tokenizing the inputstr
	while (stk.hasMoreTokens()){
	    tempStr=stk.nextToken();
	    inputstr+=" "+tempStr;
	    if (tempStr.equalsIgnoreCase("type"))
		inputstr+="_d";
	}
	return inputstr;
       
    }
    public static void main(String[] args) {
	
	System.out.println(checkDupname(", Lon , Lat  , INTEGER theme  , CHARSTRING scale ",args[0]));
        
	}
    
    

}
