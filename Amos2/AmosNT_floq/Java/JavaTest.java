/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2001 Tore Risch, UDBL
 * $RCSfile: JavaTest.java,v $
 * $Revision: 1.27 $ $Date: 2013/02/28 05:38:13 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Basic Java - Amos II interfaces regression test
 * ===========================================================================
 * $Log: JavaTest.java,v $
 * Revision 1.27  2013/02/28 05:38:13  torer
 * Informative threads test
 *
 * Revision 1.26  2010/12/04 14:09:23  torer
 * Removed annoying println
 *
 * Revision 1.25  2008/12/14 17:02:31  torer
 * Testing multi-threaded callout
 *
 * Revision 1.24  2006/10/23 18:44:55  torer
 * getBooleanElem instead of getbooleanElem
 * Tuple.isBoolean and Tuple.isNull defined
 *
 * Revision 1.23  2006/02/17 07:56:01  torer
 * Amos II typetag exported to Java allows for basic type access
 *
 ****************************************************************************/

import callin.*;
import callout.*;
import java.lang.Math.*;

public class JavaTest {
  public static boolean EvalDone = true;
  public static Connection theConnection;
  public static boolean ErrorOccurred=false;
  public static int threadCount=0;
  public static void main(String argv[]) throws AmosException
  /**
    This is the driver program
  */
  {
  try
  {
    System.out.println("Initializing ...");
    Connection.initializeAmos("../bin/amos2.dmp");
    theConnection = new Connection("");

    new OidTest().Test();
    new AmosException("hej");
    new AmosException(1,null,"hej");
    //new AmosException(2,new Oid(12),"hopp");
    new Primitive().Test();
    new Iteration().Test();
    new SingleRowResult().Test();
    new FastPath().Test();
    new ObjectCreation().Test();
    new SimpleForeignFunction().Test();
    new ComplexForeignFunction().Test();
    new MultiDirectionalForeignFunction().Test();
    new ForeignFunctionException().Test();
    new NullPointer().Test();
    new ThrowException().Test();
    new Booleans().Test();
    new TestThreads().Test();
    new TestThreads2().Test();
  }
  catch(Exception e)
  {
      System.out.println(e.getMessage());
      e.printStackTrace();
      ErrorOccurred=true;
  }
  finally
  {
     if(ErrorOccurred)
    {
       System.out.println("**************************************************");
       System.out.println("********** Java regression test error ************");
       System.out.println("**************************************************");
    }
    else System.out.println("Java regression test OK!");
  }}

  static String CallStringString(Connection theConnection, String fn, String arg) throws AmosException
  /**
    This method illustrates how to call an Amos II function through the fast-path interface.
    The nname of the function to call is fn.
    The function has a single actual parameter arg of type string.
    The function returns a single string as the result.
    */
    {
      Tuple argl;
      Scan s;

      argl = new Tuple(1);  // There is one argument
      argl.setElem(0, arg); // the argument is passed as parameter arg
      s = theConnection.callFunction(fn,argl,1);
      if(s.eos()) return null;
      return s.getRow().getStringElem(0);
    }

    static double CallRealReal(Connection theConnection, String fn, double arg) throws AmosException
  /**
    This method illustrates how to call an Amos II function through the fast-path interface.
    The nname of the function to call is fn.
    The function has a single actual parameter arg of type REAL.
    The function returns a single REAL as the result.
    */
    {
      Tuple argl;
      Scan s;

      argl = new Tuple(1);  // There is one argument
      argl.setElem(0, arg); // the argument is passed as parameter arg
      s = theConnection.callFunction(fn,argl,1);
      return s.getRow().getDoubleElem(0);
    }

    static double CallStringReal(Connection theConnection, String fn, String arg) throws AmosException
  /**
    The nname of the function to call is fn.
    The function has a single actual parameter arg of type CHARACTER.
    The function returns a single REAL as the result.
    */
    {
      Tuple argl;
      Scan s;

      argl = new Tuple(1);  // There is one argument
      argl.setElem(0, arg); // the argument is passed as parameter arg
      s = theConnection.callFunction(fn,argl,1);
      return s.getRow().getDoubleElem(0);
    }

  public void absbf(CallContext cxt, Tuple tpl) throws AmosException
  {

     double x;

     x = tpl.getDoubleElem(0); // pick up first argument
     if(x<0) tpl.setElem(1,-x);
     else    tpl.setElem(1,x);
     cxt.emit(tpl);
  }

  public void jotabf(CallContext cxt, Tuple tpl) throws AmosException
  {

     int low=tpl.getIntElem(0), up=tpl.getIntElem(1), i;

     for(i=low;i<=up;i++)
     {
        tpl.setElem(2,i);
        cxt.emit(tpl);
     }
  }

  public void JavaEval(CallContext cxt, Tuple tpl) throws AmosException
  {
    Scan tmpScan;
    Tuple t;
    boolean Alltuples=false;

    // Pick up the argument
    String query = tpl.getStringElem(0);

    EvalDone = false; // for regression
    try
    {
       tmpScan = theConnection.execute(query);
       while (!tmpScan.eos())
       {
          t = tmpScan.getRow();
          tpl.setElem(1, t.getOidElem(0));
          cxt.emit(tpl);
          tmpScan.nextRow();
       };
       Alltuples = true;
    }
    catch (AmosException e)
    {
      System.out.println(e.getMessage());
    }
    finally
    {
      EvalDone = Alltuples;
    }
   }

  public void jsqrtbf(CallContext cxt, Tuple tpl) throws AmosException
  {

    double x;

    x = tpl.getDoubleElem(0);	// Pick up the argument
    if (x == 0.0) // One root
    {
      tpl.setElem(1,0.0);
      cxt.emit(tpl);
    }
    if (x > 0.0) // two roots
    {
      double r = Math.sqrt(x);

      tpl.setElem(1, r);
      cxt.emit(tpl);
      tpl.setElem(1, -r);
      cxt.emit(tpl);
    }
    // negative numbers have no roots
  }

  public void jsqrtfb(CallContext cxt, Tuple tpl) throws AmosException
  {
    double x;

    x = tpl.getDoubleElem(1);	// Pick up the result
    tpl.setElem(0,x*x);  // compute the inverse of the square root
    cxt.emit(tpl);
  }

  public void jsqrtbfcost(CallContext c, Tuple tpl) throws AmosException
  {
     Oid f = tpl.getOidElem(0);
     Tuple bpat = tpl.getSeqElem(1);
     Tuple arg = tpl.getSeqElem(2);

     tpl.setElem(3,2.0);
     tpl.setElem(4,4.0);
     c.emit(tpl);
  }

  public void testname(CallContext c, Tuple tpl) throws AmosException
  {
     if(tpl.getElem(1)==null)
        tpl.setElem(1,tpl.getOidElem(0).getName());
     c.emit(tpl);
  }

  public void errorbb(CallContext c, Tuple tpl) throws AmosException
  {
     String msg = tpl.getStringElem(0);

     //new Double("a");
      throw(new AmosException(msg));
  }

     static Oid createPerson(Connection theConnection, String name) throws AmosException
  /**
    This method illustates how to allocate a new database object
    and set propteries of the new object
    */
    {
      Oid nw = theConnection.createObject("person");
      Tuple argl = new Tuple(1);
      Tuple resl = new Tuple(1);
      argl.setElem(0,nw);
      resl.setElem(0,name);
      theConnection.addFunction("name",argl,resl);
      return nw;
    }
}  // ends class JavaTest

class Regression extends JavaTest
{
    public void Test() throws AmosException
    {
       System.out.println("[Testing "+tag()+" ...");
       if(CodeOK()) System.out.println("OK]");
       else
       {
          System.out.println("NOT OK]");
          ErrorOccurred = true;
       }
    }
    String tag() {return  "undefined";};
    public boolean CodeOK() throws AmosException
    {
       System.out.println("No Tester defined!");
       return false;
    }
}

class Type extends Oid
{
   public Type(){super();}

   /**
     * Construct a persistent object of type TYPE and its Java proxy
     */
   public Type(Connection c) throws AmosException
   {
      super(c.getType("type"));
   }

   /**
     * Coerce an Oid to a Type
     */
   public static Type downcast(Oid o)  throws AmosException
   {
      Type d = new Type();
      if(o==null) throw(new AmosException("null argument to MyType constructor"));
      d.CopyProps(o);
      return d;
   }

   /**
     * Get the first supertype of a type proxy
     */
   public Type supertype() throws AmosException
   {
      Connection c = this.getConnection();
      Oid dbres = c.callOidFunction("supertypes",this);
      return downcast(dbres);
   }
};


class OidTest extends Regression
{
   public String tag() {return "Oid subclass creation";}
   public boolean CodeOK() throws AmosException
   {
      Type fn, st, p;
      Connection con = new Connection("");
      String nm;

      p = new Type(con);
      fn = Type.downcast(con.getType("function"));
      st = fn.supertype();
      if(!fn.getType().equals(st.getType())) return false;
      if(!fn.getName().equals("FUNCTION")) return false;
      return true;
   }
}

class Primitive extends Regression
{
   public String tag(){return  "Primitive Amos interface types";}
   public boolean CodeOK() throws AmosException
  {
     Tuple tpl = new Tuple(4), tpl2 = new Tuple("hopp");

     tpl.setElem(0,1);
     tpl.setElem(1,0.0);
     tpl.setElem(2,"hej");
     tpl.setElem(3,tpl2);
     if(tpl.getIntElem(0)==1 && tpl.getDoubleElem(1)==0.0 &&
        tpl.getStringElem(2).equals("hej") &&
        tpl.getSeqElem(3).getElem(0).equals("hopp"))
        return true;
     return false;
  }
}

class Iteration extends Regression
{
  public String tag(){return "Iteration through Scans";};
 public boolean CodeOK() throws AmosException
  {
    Scan theScan;
    int i=0;

    theScan = theConnection.execute("select name(t) from type t;");
    while (!theScan.eos()) // While there are more rows in the scan
    {
	    Tuple row; // Will hold each result tuple in scan
	    String str; // Will hold each type name in each result tuple

	    row = theScan.getRow();    // Get current row in the scan
      str = row.getStringElem(0);   // Get 1st element (enumerated 0 and up) in row as a string
      i++;
      theScan.nextRow();	    // Advance the scan forward
    }
    if(i>0) return true;
    else return false;
  }
}

class SingleRowResult extends Regression
{
   public String tag(){return "Testing calls returning a single row";}
   public boolean CodeOK() throws AmosException
  /**
    This methos illustrates how to execute an AMOSQL statement returning a single
    row containing a single string.
    */
    {
      String str;
      Scan s;

      s = theConnection.execute("concat('a','b');");
      if(s.eos()) return false;
      str = s.getRow().getStringElem(0);
      if(str.equals("ab")) return true;
      return false;
    }
}

class FastPath extends Regression
{
   public String tag(){return "fast path interface";};
   public boolean CodeOK() throws AmosException
   {
     return (CallStringString
             (theConnection,"charstring.lower->charstring","HELLO WORLD")
             .equals("hello world"));
   }
}

class ObjectCreation extends Regression
{
   public String tag(){return "object creation";};
   public boolean CodeOK() throws AmosException
   {
      int i;
      Connection c = theConnection;

      c.execute("create type person properties (name charstring);");
      for(i=0;i<1000;i++)
      {
         String s = "Tore"+i;
         Oid o = createPerson(c,s);
         if(!o.getName().equals(s)) return false;
      }
      return true;
   }
}

class SimpleForeignFunction extends Regression
{
   public String tag(){return "Simple foreign function";};
   public boolean CodeOK() throws AmosException
   {
      Connection c = theConnection;
      c.execute("create function testname(object)->character as foreign 'JAVA:JavaTest/testname';");
      c.execute(
         "create function jabs(real x)->real as foreign 'JAVA:JavaTest/absbf';");
      if(CallRealReal(c,"jabs",-1.2)!=1.2) return false;
      if(!CallStringString(c,"testname","a").equals("**UnknownName**")) return false;
      return true;
   }
}

class ComplexForeignFunction extends Regression
{
  public String tag(){return "Foreign function returning a scan";};
  public boolean CodeOK() throws AmosException
  {
    Connection c = theConnection;
    c.execute(
         "create function jeval(character x)->real as foreign 'JAVA:JavaTest/JavaEval';");
    c.execute(
         "create function jota(integer l, integer u)->integer as foreign 'JAVA:JavaTest/jotabf';");
    return (CallStringReal(c,"jeval","jota(1,1000)+0.0;")==1.0) &&
           !EvalDone;
  }
}

class MultiDirectionalForeignFunction extends Regression
{
    public String tag(){return "Multidirectional foreign function";}
    public boolean CodeOK() throws AmosException
    {
	Connection c = theConnection;
        Scan s;

        c.execute(
         "create function jsqrtbfcost(function fno, vector b, vector a)" +
                          " -> <real c, real f> " +
         "as foreign 'JAVA:JavaTest/jsqrtbfcost';");

        c.execute(
         "create function jsqrt(real x)->real as multidirectional" +
         "('bf' foreign 'JAVA:JavaTest/jsqrtbf' cost jsqrtbfcost)" +
         "('fb' foreign 'JAVA:JavaTest/jsqrtfb' cost {1,1});");

        double r1 = CallRealReal(c,"jsqrt",4.0);

        s = c.execute(
		     "select r from real r where sqrt(r)=2.0;");

        double r2 = s.getRow().getDoubleElem(0);

        return r1==2.0 && r2==4.0;
    }
}

class ForeignFunctionException extends Regression
{
  public String tag(){return "Exception raised in foreign function";};
  public boolean CodeOK() throws AmosException
  {
    Connection c = theConnection;

    CallStringString(c,"jeval","1+'a';");
    return !EvalDone;
  }
}

class NullPointer extends Regression
{
  public String tag(){return "Null pointer";};
  public boolean CodeOK() throws AmosException
  {
      Tuple t=new Tuple(2);
      Oid o=null;

      t.setElem(1,o);

      return true;
  }
}

class ThrowException extends Regression
{
   public String tag(){return "Raising Amos exception";};
   public boolean CodeOK() throws AmosException
   {
      theConnection.execute(
         "create function myerror(character msg)->boolean as foreign 'JAVA:JavaTest/errorbb';");
      try
      {
         theConnection.execute("myerror('Testing error');");
      }
      catch(AmosException e)
      {
         System.out.println(e.getMessage());
         return true;
      }
      return false;
   }
}

class Booleans extends Regression
{
    public String tag(){return "Boolean and null values";};
    public boolean CodeOK() throws AmosException 
    {
	boolean OK=false;
	Tuple argl = new Tuple(1);
	Tuple resl = new Tuple(1);

	theConnection.execute("create function testbool(boolean)->boolean as stored;");
	try
	    {
		argl.setElem(0,new Boolean(true));
		resl.setElem(0,new Boolean(true));
		theConnection.setFunction("testbool",argl,resl);
		argl.setElem(0,false);
		resl.setElem(0,true);
		theConnection.setFunction("testbool",argl,resl);
		if(theConnection.execute("select true;").getRow().getBooleanElem(0)
		   == true &&
                   theConnection.execute("select true;").getRow().isBoolean(0) &&
		   theConnection.execute("select false;").getRow().getBooleanElem(0)
		   == false &&
                   theConnection.execute("select false;").getRow().isBoolean(0) &&
		   theConnection.execute("select nil;").getRow().getElem(0)==null &&
		   theConnection.execute("testbool(true);").getRow().getElem(0).equals(new Boolean(true)) &&
		   theConnection.execute("testbool(false);").getRow().getElem(0).equals(new Boolean(true)))
		    OK = true;
	    }
	catch (AmosException e)
	    {
		System.out.println(e.getMessage());
		return false;
	    }
	return OK;
    }
}

class MyThread extends Thread
{
    Connection conn;
    int ind;
    MyThread(Connection c, int m)
    {
	this.conn = c;
        this.ind = m;
    }
    public void run() 
    {   
	try
	    {   
                //System.out.println(">"+ind);
		if(ind%2==0) 
		    {
			System.out.println(">Q1 "+ind);
			conn.execute("select sqrt(r) from real r where r=2.0;");
			System.out.println("<Q1 "+ind);
		    }
                else if(ind%3==0)
		    {
			System.out.println(">Q2 "+ind);
			conn.execute("sleep(1);"); 
			System.out.println("<Q2 "+ind);
		    }
		else 
		    {
			System.out.println(">Q3 "+ind);
			JavaTest.CallRealReal(conn,"sqrt",4.0);
			System.out.println("<Q3 "+ind);
		    }
	    }
	catch(AmosException e)
	    {System.out.println(e.getMessage());}
	//System.out.println("<"+ind);
        JavaTest.threadCount++;
    }
}

class TestThreads extends Regression
{
    public String tag(){return "Multi-threaded application";};
    public boolean CodeOK() throws AmosException
    {
	MyThread t;
	int i;
	int threads=10;
        //try{Thread.sleep(20000);} catch (InterruptedException e){}
	for(i=0;i<threads;i++)
	    {
		try{ Connection c = new Connection("");
		t = new MyThread(c,i);
		t.start();
		}
                catch (AmosException e)
		    {System.out.println(e.getMessage());}
	    }
        for(i=0;i<10;i++)
	{
	 try{Thread.sleep(500);}
	 catch (Exception e)
	    {
		System.out.println("Sleep failed");
	    }
	 if(threadCount==threads) return true;
	}
	return false;
    }
}

class MyThread2 extends Thread
{
    MyThread2(){}
    public void run() 
    {   
	int i;
	for(i=0;i<1000;i++)   
	    {Tuple t = new Tuple(10);
		try{
		    t.setElem(0,false);
		}
                catch (AmosException e)
		    {System.out.println(e.getMessage());}
	    }
        JavaTest.threadCount++;
    }
}

class TestThreads2 extends Regression
{
    public String tag(){return "Multi-threaded allocation";};
    public boolean CodeOK() throws AmosException
    {
	MyThread2 t;
	int i;
	int threads=70;
        threadCount = 0;
	for(i=0;i<threads;i++)
	    {
		t = new MyThread2();
		t.start();
	    }
        for(i=0;i<10;i++)
	{
	 try{Thread.sleep(500);}
	 catch (Exception e)
	    {
		System.out.println("Sleep failed");
	    }
	 if(threadCount==threads) return true;
	}
	return false;
    }
}


