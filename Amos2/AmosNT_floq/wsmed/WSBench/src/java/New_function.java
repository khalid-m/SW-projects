import java.util.*;
import java.io.*;
import callin.*;
import callout.*;
 
public class New_function{

 public void create_amossql(CallContext cxt, Tuple tpl) throws AmosException
    {
    
        String o_name=tpl.getStringElem(0);
        String o_query=tpl.getStringElem(1);
        boolean b= true;
        String sqlq = null;
        String para = null;
        String opara1= null;
        String fpara = null;
        String q_para= null;
        String q_end = null;
    
	      FileOutputStream out1,out2,out3,out4; // declare  file output objects
	      PrintStream p,q,s; // declare  print stream objects
        
        Q_Vpara v= new Q_Vpara();
        q_para = v.compos(cxt,o_query);
        
        Get_type f=new Get_type();
        fpara=f.comb(cxt,o_query);
        
        Cquery d= new Cquery();
        sqlq= d.show(o_query,fpara);

        Get_para g=new Get_para();
        para= g.get(o_query);

        
        Copara w= new Copara();
        opara1 = w.change(fpara);      
        

        Q_end e = new Q_end();
        q_end = e.end(cxt,o_query);
	
        
        Delete del= new Delete();
        try{del.delete(o_name);}
        catch (Exception e4){}
	
      
   
    String[] sqlqs=sqlq.split(" ");
    String str="";
    for (int i=0; i<sqlqs.length; i++)
    {
        if (sqlqs[i].equalsIgnoreCase("from")){ 
           str+= sqlqs[i].replace("from"," , sleep(?) from ");
         }
	    else str+= " "+sqlqs[i];
       
    }
	sqlq=str;

	      if(b) {
               try
	          {
		    // Create a new file output stream
		    // connected to user_defined.amossql
              out1 = new FileOutputStream(System.getenv("AMOS_HOME")+"wsmed/WSBench/src/amosql/user_defined.amosql",true);
		       
		
		    // Connect print stream to the output stream
		       p = new PrintStream(out1);
                       if (para.equalsIgnoreCase(""))   {
			   p.println ("create function "+o_name+"("+fpara+")->"+q_para+"sql(getJDBC(),\""+sqlq+" limit ?;\",{ delay, t_number}) "+q_end);
		       }
		       else{
		       p.println ("create function "+o_name+"("+fpara+")->"+q_para+"sql(getJDBC(),\""+sqlq+" limit ?;\",{delay, "+para+", t_number}) "+q_end);
		       }
		       p.close();
                
	           }

	       catch (Exception e1)
	         {
		    System.err.println ("Error writing to file");
	         }
               
               /*try
	          {
		    // Create a new file output stream
		    // connected to user_defined.amossql
                out3 = new FileOutputStream(System.getenv("APACHE_HOME")+"/www/information/user_defined.txt",true);
		       
		
		    // Connect print stream to the output stream
		       s = new PrintStream(out3);
             if (para.equalsIgnoreCase(""))   {
			   s.println ("create function "+o_name+"("+fpara+")->"+q_para+"sql(getJDBC(),\""+sqlq+" limit ?;\",{delay,t_number}) "+q_end);
		       }
		       else{
		       s.println ("create function "+o_name+"("+fpara+")->"+q_para+"sql(getJDBC(),\""+sqlq+" limit ?;\",{delay, "+para+", t_number}) "+q_end);
		       }
		       s.close();
                
	           }

	       catch (Exception e2)
	         {
		    System.err.println ("Error writing to file");
		    }*/

                

               try
	          {
		    // Create a new file output stream
		    // connected to WSBench_wsop.amosql
                    out2 = new FileOutputStream(System.getenv("AMOS_HOME")+"wsmed/WSBench/src/amosql/user_defined_wsop.amosql",true);

		 
		
		    // Connect print stream to the output stream
		       q = new PrintStream(out2);
		       q.println ("create function ws"+o_name+"("+fpara+")-> Bag of "+q_para+"ship(\"WSBench\",\""+o_name+"("+opara1+");\") "+q_end );
		       q.close();
                
	           }

	       catch (Exception e3)
	         {
		    System.err.println ("Error writing to file");
	         }
	       //To ebale with WSMED demo page
                 try
	          {
		    // Create a new file output stream
		    // connected to WSBench_wsop.amosql
                    out4 = new FileOutputStream(System.getenv("AMOS_HOME")+"wsmed/WSBench/src/amosql/user_defined_wsop_wsmed.amosql",true);
		    // Connect print stream to the output stream
		       q = new PrintStream(out4);
		      
q.println ("create function ws"+o_name+"("+fpara+",Charstring userID)-> Bag of "+q_para+"ship(userID,\""+o_name+"("+opara1+");\") "+q_end );
		       q.close();
                
	           }

	       catch (Exception e4)
	         {
		    System.err.println ("Error writing to file");
	         }

              }   cxt.emit(tpl);
    }    
}
