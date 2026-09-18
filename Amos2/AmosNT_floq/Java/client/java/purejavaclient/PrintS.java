package udbl.amos.purejavaclient;

import java.util.*;

public class PrintS extends java.lang.Object{
    public String print(LispObject s){
        out=""; printS(s); return out;
    }
    public void pCh(char c){
        out=out+c;
    }
    public void printList(LispObject s){
        pCh('(');
        while(!lisp.atom(s)){
            printS(((ListCell)s).a);
            s=((ListCell)s).d;
            pCh(' ');
        }
        if(!lisp.Null(s)){
            pCh('.');
            printAtom(s);
        }
        out=out.substring(0, out.length()-1);
        pCh(')'); 
        //pCh('\n');
    }
    public void printNumber(LispObject s){
		if(((MyNumber)s).floatNumber)
			out=out+ ((MyNumber)s).number;
		else
			out=out+ (int)((MyNumber)s).number;
    }
    public void printSymbol(LispObject s){
    	//Symbol sy = new Symbol(s.);
    	if(s instanceof MyNumber){
    		if(((MyNumber)s).floatNumber)
    			out=out+ ((MyNumber)s).number;
    		else
    			out=out+ (int)((MyNumber)s).number;
    	}
    	else if (s!=null)
    		out=out+(String)(lisp.symbolTable.get(new Integer(((Symbol)s).hc)));

    }
    public void printOid(LispObject s){
    	if(!((Oid)s).name.equals(""))
    		out = out + "#[OID " + ((Oid)s).oidtypeHandle + " \"" + ((Oid)s).name+ "\"]";
    	else
    		out = out + "#[OID " + ((Oid)s).oidtypeHandle + "]";
    }
    public void printAtom(LispObject s){
        if(lisp.numberp(s)) 
        	printNumber(s);
        else if(s instanceof Oid)
        	printOid(s);
        else
        	printSymbol(s);
    }
    public ALisp lisp;
    public String out;
    public void printS(LispObject s){
        if(lisp.atom(s)) 
        	printAtom(s);
        else 
        	printList(s);
    }
    @SuppressWarnings("rawtypes")
	public Hashtable symbolTable;
    public void SetAlisp(ALisp lsp){
        lisp=lsp;
    }
    public PrintS(){
    }
}