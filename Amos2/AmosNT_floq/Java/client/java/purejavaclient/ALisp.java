package udbl.amos.purejavaclient;

import java.util.*;
import java.awt.*;
public class ALisp extends java.lang.Object implements Runnable
{
    
    public LispObject equal2(LispObject x, LispObject y)
    {
        if(equal(x,y)) return tSymbol;
        else        return nilSymbol;
    }
    public void stop()
    {
        if(me!=null){ me=null;}
    }
    public void start()
    {
        if(me==null){me=new Thread(this); me.start();}
    }
    public void run()
    {
        while(me!=null){
            if(inqueue!=null){
              while(!inqueue.isEmpty()){
               LispObject s=read.read(inqueue);
               if(s!=null){
                 LispObject r=preEval(s,environment);
          //   LispObject r=eval(s,environment);
                 String o=print.print(r);
                 printArea.append(o+"\n");
               }
               printArea.repaint();
             }
            }
            try{ Thread.sleep(100);}
            catch(InterruptedException e){System.out.println(e);}
        }
//        stop();
    }
    public void rplcd(LispObject x, LispObject y)
    {
        if(atom(x)) { printArea.append("rplcd failed\n"); return;}
        ((ListCell)x).d=y;
        return;

   }
    public void rplca(LispObject x, LispObject y)
    {
        if(atom(x)) { printArea.append("rplca failed\n"); return;}
        ((ListCell)x).a=y;
        return;

    }
    public LispObject setf(LispObject form, LispObject val)
    {
        return setf(form,val,environment);
    }
    public LispObject setf(LispObject form, LispObject val, LispObject env)
    {
        environment=setfx(form,val,env);
        return form;
    }
/*
   The following "append" and "reverse" is
   added by Tomoki Katayama, Kyushu Institute of Technology,
   27 Feb.1998
*/
    public LispObject append(LispObject x,LispObject y){
        if (Null(x))
        	return y;
        else{
            return cons(car(x), append(cdr(x),y));
        }
    }
    public LispObject reverse(LispObject x)
        {
        if(Null(x)){
            return nilSymbol;
        }
        else if(Null(cdr(x))){
            return cons(car(x),nilSymbol);
        }
        else {
            return append(reverse(cdr(x)),cons(car(x),nilSymbol));
        }
    }

    public LispGui gui;
    public LispObject atom2(LispObject s)
    {
        if(atom(s)) 
        	return tSymbol;
        else
        	return nilSymbol;
    }
    public LispObject evalcond(LispObject cond, LispObject env)
    {
        while(true){
        	if(Null(cond)) 
        		return nilSymbol;
            LispObject pair=car(cond);
            LispObject px=eval(car(pair),env);
            if(!Null(px)) 
            	return eval(second(pair),env);
            cond=cdr(cond);
        }
    }
    public boolean isDefun(LispObject form)
    {
        if(atom(form)) 
        	return false;
        if(eq(car(form),recSymbol("defun"))) 
        	return true;
        return false;
    }

    @SuppressWarnings("unused")
	public LispObject caseOfDefun(LispObject f, LispObject env)
    {
        LispObject fn=cons(recSymbol("get"),
                      cons(
                        cons(recSymbol("quote"),
                        cons(car(f),nilSymbol)),
                      cons(
                        cons(recSymbol("quote"),
                        cons(recSymbol("lambda"),nilSymbol)),
                      nilSymbol)));
        LispObject val=cons(recSymbol("lambda"),
                       cdr(f));
        LispObject x=setf(fn,val);
        return environment;
    }
//    public JTerm jterm;
    public LispObject bindVars(LispObject vars, LispObject vals)
    {
        return bindVars(vars,vals,nilSymbol);
    }
    public LispObject bindVars(LispObject vars, LispObject vals, LispObject alist)
    {
        while(true){
            if(Null(vars)) return alist;
            if(Null(vals)) return alist;
            alist=cons(cons(car(vars),
                       cons(car(vals),
                            nilSymbol)),alist);
            vars=cdr(vars); vals=cdr(vals);
        }
    }
    public LispObject get(LispObject sym, LispObject attr, LispObject env)
    {
         LispObject getf=cons(recSymbol("get"),
                        cons(sym,
                        cons(attr, nilSymbol)));
         LispObject w=assoc(getf,env);
         if(Null(w)) return nilSymbol;
         else return second(w);
    }
    public LispObject get(LispObject sym, LispObject attr)
    {
        return get(sym,attr,environment);
    }
    public boolean isSetf(LispObject form)
    {
        if(atom(form)) 
        	return false;
        if(eq(car(form),recSymbol("setf"))) 
        	return true;
        return false;
    }
    public LispObject preEval(LispObject s, LispObject env){
        if(isSetf(s)) {
            environment=caseOfSetf(cdr(s),env);
            return second(car(environment));
        }
        else
	        if(isDefun(s)){
	            environment=caseOfDefun(cdr(s),env);
	            return second(s);
	        }
	        else
	        	return eval(s,env);
    }
    public LispObject caseOfSetf(LispObject form, LispObject env){
        while(true){
          if(Null(form)) 
        	  return env;
          else {
        	  env =setfx(car(form), eval(second(form),env),env);
        	  form= cdr(cdr(form));
          }
        }
    }
    public boolean equal(LispObject x, LispObject y){
        if(atom(x)) 
        	return eq(x,y);
        if(atom(y)) 
        	return false;
        if(equal(car(x),car(y)))
            return equal(cdr(x),cdr(y));
        else 
        	return false;
    }
    public LispObject setfx(LispObject form, LispObject value, LispObject env){
        LispObject key=null;
        if(symbolp(form)){
//            return cons(cons(form,cons(value,nilSymbol)),env);
        	key=form;
        }
        else
	        if(eq(car(form),recSymbol("get"))){
	            LispObject fa=eval(second(form),env);
	            LispObject sa=eval(third(form),env);
	            key=cons(car(form),cons(fa,cons(sa,nilSymbol)));
	//            return cons(cons(key,cons(value,nilSymbol)),env);
	        }
	        LispObject obj=assoc(key,env);
        if(!Null(obj)) {
        	rplca(cdr(obj),value); return env;
        }
        else 
        	return cons(cons(key,cons(value,nilSymbol)),env);
    }
    public LispObject eq2(LispObject x, LispObject y){
        if(eq(x,y)) 
        	return tSymbol;
        else        
        	return nilSymbol;
    }
    public void plist(String s, LispObject x){
          String a=""+s;
          String o=print.print(x);
          printArea.append(a+o+"\n");
          printArea.repaint();

    }
    public boolean symbolp(LispObject s){
        if(s.getClass().getName().equals("ListCell"))
             return false;
        if(s.getClass().getName().equals("Symbol"))
             return true;
        else return false;
   }
    public LispObject Null2(LispObject s)
    {
        if(Null(s)) 
        	return tSymbol;
        else 
        	return nilSymbol;
    }
    public LispObject apply(LispObject proc, LispObject argl, LispObject env){
        LispObject f;
        if(gui.traceFlag.getState()){
           plist("apply-",proc);
           plist("argl-",argl);
        }
        if(symbolp(proc)){
            if(eq(proc,recSymbol("car"))||eq(proc,recSymbol("first")))
                return car(car(argl));
            if(eq(proc,recSymbol("cdr"))||eq(proc,recSymbol("rest")))
                return cdr(car(argl));
            if(eq(proc,recSymbol("cons")))
                return cons(car(argl),second(argl));
            if(eq(proc,recSymbol("atom")))
                return atom2(car(argl));
            if(eq(proc,recSymbol("null")))
                return Null2(car(argl));
            if(eq(proc,recSymbol("eq")))
                return eq2(car(argl),second(argl));
            if(eq(proc,recSymbol("equal")))
                return equal2(car(argl),second(argl));
/*
   The following append and reverse is
   added by Tomoki Katayama, Kyushu Institute of Technology,
   27 Feb.1998
*/
            if(eq(proc,recSymbol("append")))
                return append(car(argl),second(argl));
            if(eq(proc,recSymbol("reverse")))
                return reverse(car(argl));
//
            if(eq(proc,recSymbol("list")))
                return argl;
            if(eq(proc,recSymbol("+"))){
            	double x=((MyNumber)(car(argl))).number;
                double y=0;
                LispObject p=cdr(argl);
                while(!Null(p)){
                   y=((MyNumber)(car(p))).number;
                   p=cdr(p);
                   x=x+y;
                }
                return new MyNumber(x,true);
            }
            if(eq(proc,recSymbol("-"))){
                double x=((MyNumber)(car(argl))).number;
                LispObject p=cdr(argl);
                if(Null(p)) 
                	return new MyNumber(-x,true);
                double y=((MyNumber)(car(p))).number;
                return new MyNumber(x-y,true);
            }
            if(eq(proc,recSymbol("*"))){
            	double x=((MyNumber)(car(argl))).number;
            	double y=0;
                LispObject p=cdr(argl);
                while(!Null(p)){
                   y=((MyNumber)(car(p))).number;
                   p=cdr(p);
                   x=x*y;
                }
                return new MyNumber(x,true);
            }
            if(eq(proc,recSymbol("/"))){
            	double x=((MyNumber)(car(argl))).number;
                double y=((MyNumber)(second(argl))).number;
                return new MyNumber(x/y,true);
            }
            if(eq(proc,recSymbol("="))){
            	double x=((MyNumber)(car(argl))).number;
            	double y=((MyNumber)(second(argl))).number;
                if(x==y) 
                	return tSymbol;
                else     
                	return nilSymbol;
            }
            if(eq(proc,recSymbol(">"))){
            	double x=((MyNumber)(car(argl))).number;
            	double y=((MyNumber)(second(argl))).number;
                if(x>y)
                	return tSymbol;
                else
                	return nilSymbol;
            }
            if(eq(proc,recSymbol("<"))){
            	double x=((MyNumber)(car(argl))).number;
            	double y=((MyNumber)(second(argl))).number;
                if(x<y)
                	return tSymbol;
                else
                	return nilSymbol;
            }
            if(eq(proc,recSymbol(">="))){
            	double x=((MyNumber)(car(argl))).number;
            	double y=((MyNumber)(second(argl))).number;
                if(x>=y)
                	return tSymbol;
                else
                	return nilSymbol;
            }
            if(eq(proc,recSymbol("<="))){
            	double x=((MyNumber)(car(argl))).number;
            	double y=((MyNumber)(second(argl))).number;
                if(x<=y)
                	return tSymbol;
                else
                	return nilSymbol;
            }
            if(eq(proc,recSymbol("print"))){
                LispObject p=argl;
                while(!Null(p)){
                    String o=print.print(car(p));
                    printArea.append(o+"\n");
                    printArea.repaint();
                    p=cdr(p);
                }
                return car(argl);
            }
            if(eq(proc,recSymbol("read"))){
                return read.read(inqueue);
            }
            else{
               f=get(proc, recSymbol("lambda"));
               if(Null(f)) {
                    f=assoc(proc,env);
                    if(Null(f)) {
                        plist("can not find out ",proc);
                        return nilSymbol;
                    }
                    else 
                    	f=second(f);
               }
               return apply( f,argl,env);
           }
        }
        else{
            LispObject newEnv=bindVars(second(proc),
                                       argl,env);
            LispObject rtn=nilSymbol;
            LispObject ps=cdr(cdr(proc));
            while(!Null(ps)){
                rtn=eval(car(ps),newEnv);
                ps=cdr(ps);
            }
            return rtn;
        }
    }
    public LispObject evalArgl(LispObject argl, LispObject env)
    {
        if(Null(argl)) 
        	return nilSymbol;
        LispObject y=evalArgl(cdr(argl),env);
        LispObject x=eval(car(argl),env);
        return cons(x,y);
    }
    public LispObject fourth(LispObject x)
    {
        return car(cdr(cdr(cdr(x))));
    }
    public LispObject third(LispObject x)
    {
        return car(cdr(cdr(x)));
    }
    public LispObject assoc(LispObject key, LispObject alist)
    {
        LispObject l=alist;
        while(true){
          if(Null(l))
        	  return nilSymbol;
          if(equal(key,car(car(l))))
        	  return car(l);
          l=cdr(l);
        }
    }
    public LispObject second(LispObject x)
    {
        return car(cdr(x));
    }
    public LispObject eval(LispObject form, LispObject env)
    {
        LispObject rtn;
        if(gui.traceFlag.getState())
        	plist("eval..",form);
        if(atom(form)){
            if(numberp(form)) 
            	rtn= form;
            else
            	if(eq(tSymbol,form)) 
            		rtn= tSymbol;
            	else
            		if(eq(nilSymbol,form)) 
            			rtn= nilSymbol;
            		else{
		               LispObject w=assoc(form,env);
		               if(Null(w)){
		                 plist("can not find out ",form);
		                 return nilSymbol;
		               }
		               rtn= second(w);
		            }
        }
        else{
            LispObject fform=car(form);
            if(eq(fform,recSymbol("quote")))
                 rtn= second(form);
            else
	            if(eq(fform,recSymbol("if"))) {
	               if(!Null( eval(second(form),env)))
	                     rtn=  eval(third(form), env);
	               else  rtn=  eval(fourth(form),env);
	            }
	            else
		            if(eq(fform,recSymbol("cond")))
		               rtn= evalcond(cdr(form),env);
		            else
			            if(eq(fform,recSymbol("get")))
			               rtn= get(eval(second(form),env),eval(third(form), env), env);
			            else
				            if(eq(fform,recSymbol("apply")))
				               rtn= apply( eval(second(form),env), eval(third(form),env),env);
				            else
					            if(eq(fform,recSymbol("setq"))){
					                return setf( second(form), eval(third(form),env));
					            }
					            else 
					            	rtn= apply(fform, evalArgl(cdr(form),env),env);
        }
        if(gui.traceFlag.getState())
        	plist("eval return ...",rtn);
        return rtn;
    }
    public void evals(CQueue iq){
        inqueue=iq;
        /*
        if(me==null){
          inqueue=iq;
          me=new Thread(this);
          me.start();
        }
        else{

        }
        */
        /*
        while(!inqueue.isEmpty()){
          LispObject s=read.read(inqueue);
          LispObject r=preEval(s,environment);
       //   LispObject r=eval(s,environment);
          String o=print.print(r);
          printArea.appendText(o+"\n");
          printArea.repaint();
        }
        */
    }
    public TextArea printArea;
    public TextArea readArea;
    @SuppressWarnings("rawtypes")
	public void init(TextArea rarea, TextArea parea,CQueue iq,LispGui g)
    {
         me=null;
         inqueue=iq;
        symbolTable=new Hashtable();
        nilSymbol  = recSymbol("nil");
        environment=nilSymbol;
        tSymbol    = recSymbol("t");
    //    inqueue=iq;
    //    outqueue=oq;
        readArea=rarea;
        printArea=parea;
        read=new ReadS();
        read.SetCQ(inqueue);
        read.SetAlisp(this);
        //print=new PrintS(this);
        print= new PrintS();
        print.SetAlisp(this);
        gui=g;
    }
    public ALisp(){
    }
    public boolean eq(Object x, Object y){
    	
    	if ((x instanceof Symbol) && !(y instanceof Symbol))
    		return false;
    	else if (!(x instanceof Symbol) && (y instanceof Symbol))
    		return false;
    	
    	else if ((x instanceof ListCell) && (y instanceof ListCell))
    		return false;
    	else if (!(x instanceof ListCell) && (y instanceof ListCell))
    		return false;

    	else if ((x instanceof LispObject) && (y instanceof LispObject))
    		return false;
    	else if (!(x instanceof LispObject) && (y instanceof LispObject))
    		return false;

    	Symbol i = (Symbol) x;
    	Symbol j = (Symbol) y;
    	if(x==y) 
    		return true;
        if(!atom((LispObject) x)) 
        	return false;
        if(!atom((LispObject) y)) 
        	return false;
        if(numberp(x)){
            if(numberp(y))
               return ((MyNumber)x).number
                       ==((MyNumber)y).number;}
        return i.hc == j.hc;
    }
    public Thread me;
    public Symbol tSymbol;
    public Symbol nilSymbol;
    public PrintS print;
    public ReadS read;
    public CQueue inqueue;
    public ALisp(TextArea in, TextArea out,CQueue iq,LispGui g)
    {
        init(in,out,iq,g);
    }
    public boolean numberp(Object s)
    {
        if(s instanceof ListCell)
             return false;
        if(s instanceof MyNumber)
             return true;
        else return false;
    }
    public LispObject cons(LispObject x, LispObject y)
    {
        ListCell z=new ListCell();
        z.a=x; z.d=y;
        return z;
    }
    public boolean Null(LispObject s)
    {
        if(!atom(s)) return false;
        if(s==nilSymbol) return true;
        if(eq(nilSymbol,s)) return true;
        return false;
    }
    public boolean atom(LispObject s)
    {
        if(s instanceof ListCell)
        	return false;
        else 
        	return true;
    }
    public LispObject cdr(LispObject s)
    {
        if(s.getClass().getName().equals("ListCell"))
            return ((ListCell)s).d;
        else{  System.out.println("error");}
        return null;
    }
    public LispObject car(LispObject s)
    {
        if(s.getClass().getName().equals("ListCell"))
            return ((ListCell)s).a;
        else{  System.out.println("error");}
        return null;
   }
    @SuppressWarnings("unchecked")
	public Symbol recSymbol(String s)
    {
        int hc=s.hashCode();
        symbolTable.put(new Integer(hc),s);
        Symbol x=new Symbol(hc);
        return x;
    }
    public LispObject environment;
    @SuppressWarnings("rawtypes")
	public Hashtable symbolTable;
}
