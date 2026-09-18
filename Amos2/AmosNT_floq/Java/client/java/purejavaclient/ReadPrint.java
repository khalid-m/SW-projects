package udbl.amos.purejavaclient;

import java.awt.TextArea;

public class ReadPrint {
	public String x;
	public CQueue cq;
	public ALisp ap;
	public LispObject lsp;
	public TextArea tx1,tx2;
	public LispGui lg;
	public PrintS prn;
	public ReadS rd;
	
	public ReadPrint() {
		super();
		this.cq = new CQueue();
		this.ap = new ALisp();
		this.tx1 = new TextArea("");
		this.tx2 = new TextArea("");
		this.prn = new PrintS();
		this.rd = new ReadS();
		this.lsp = new LispObject();
		this.lg = new LispGui();
	}
	public LispObject read(String x){
		
		this.cq.putString(x);
		this.tx1.setText(x);
		this.ap.init(this.tx1, this.tx2, this.cq, lg);
		this.prn.SetAlisp(this.ap);
		this.rd.SetAlisp(this.ap);
		this.rd.SetCQ(this.cq);
		return this.rd.read();
	}
	public String print(LispObject lo){
		String s=this.prn.print(lo);
		//System.out.println(s);
		return s;
	}
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		ReadPrint rp= new ReadPrint();
		rp.print(rp.read("(1)"));
	}

}
