package udbl.amos.purejavaclient;

public class TupleMaker {

	/**
	 * @param args
	 */
	@SuppressWarnings("unused")
	private LispObject lsp;
	@SuppressWarnings("unused")
	private ALisp ap;
	private ReadPrint rp;
	public Tuple tp;
	public TupleMaker(String row){
		rp= new ReadPrint();
		this.lsp = this.rp.read(row);
		this.ap = this.rp.ap;
		this.tp = this.ConstructTuple(lsp, ap);
	}
	public Tuple ConstructTuple(LispObject lsp, ALisp ap){
		tp = new Tuple(lsp,ap);
		return tp;
	}
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		TupleMaker tt = new TupleMaker("(1)");
	}

}
