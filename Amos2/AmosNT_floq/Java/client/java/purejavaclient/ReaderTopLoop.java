package udbl.amos.purejavaclient;

import java.awt.TextArea;
import java.io.IOException;

public class ReaderTopLoop {
	public String x;
	public CQueue cq;
	public ALisp ap;
	public LispObject lsp;
	public TextArea tx1,tx2;
	public LispGui lg;
	public PrintS prn;
	public ReadS rd;
	
	public ReaderTopLoop() {
		super();
		this.cq = new CQueue();
		this.ap = new ALisp();
		this.tx1 = new TextArea("");
		this.tx2 = new TextArea("");
		this.prn = new PrintS();
		this.rd = new ReadS();
		this.lsp = new LispObject();
		this.lg= new LispGui();
	}
	public void InterPret(String x){
		
		this.cq.putString(x);
		this.tx1.setText(x);
		this.ap.init(this.tx1, this.tx2, this.cq, this.lg);
		this.prn.SetAlisp(this.ap);
		this.rd.SetAlisp(this.ap);
		this.rd.SetCQ(this.cq);
		this.lsp=this.rd.read();
		@SuppressWarnings("unused")
		Tuple tp= new Tuple(this.lsp,this.ap);
		String s=this.prn.print(this.lsp);
		System.out.println(s);
	}
	public static void main(String args[]) throws Exception {
		char c;
		String word = "";
		ReaderTopLoop tp = new ReaderTopLoop();

		while (true) {
			word = "";
			System.out.print(">");
			while ((c = getChar()) != '\r') {
				word = word + c;
			}
			tp.InterPret(word);
		}
	}

	static public char getChar() throws IOException {
		char ch = (char) System.in.read();
		return ch;
	}
}
