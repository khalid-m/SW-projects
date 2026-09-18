package udbl.amos.purejavaclient;

public class ReadS extends java.lang.Object {
	public boolean stringDetected;
	public boolean backSlashDetected;
	public boolean floatNumber;
	public int signValue;
	public boolean rNumOpr() {
		clearName();
		if (compareChar('<')) {
			if (compareChar('=') || compareChar('>')) {
				xLispObect = lisp.recSymbol(name);
				return true;
			}
			xLispObect = lisp.recSymbol(name);
			return true;
		}
		if (compareChar('>')) {
			if (compareChar('=')) {
				xLispObect = lisp.recSymbol(name);
				return true;
			}
			xLispObect = lisp.recSymbol(name);
			return true;
		}
		if (compareChar('=') || compareChar('+') || compareChar('*') || compareChar('/')) {
			xLispObect = lisp.recSymbol(name);
			return true;
		} else if(compareChar('-')){
			if(!compareChar(' ')){
				signValue=-1;
				return false;
			} else {
				xLispObect = lisp.recSymbol("-");
				return true;
			}
		} else
			return false;
	}

	public LispObject read(CQueue i) {
		inCQ = i;
		return read();
	}

	public boolean readQuote() {
		while (readEndChar())
			;
		if (!compareChar('\''))
			return false;
		if (!readS())
			return false;
		ListCell l2 = new ListCell();
		l2.a = xLispObect;
		l2.d = lisp.nilSymbol;
		ListCell l1 = new ListCell();
		l1.a = lisp.recSymbol("QUOTE");
		l1.d = l2;
		xLispObect = l1;
		return true;
	}

	public ALisp lisp;

	public boolean readList() {
		ListCell l, w1, w2;
		while (readEndChar())
			;
		if (!compareChar('('))
			return false;
		if (!readS())
			return false;
		l = new ListCell();
		l.a = xLispObect;
		l.d = lisp.nilSymbol;
		w1 = l;
		w2 = l;
		while (readS()) {
			w2 = new ListCell();
			w2.a = xLispObect;
			w2.d = lisp.nilSymbol;
			w1.d = w2;
			w1 = w2;
		}
		if (!compareChar(')'))
			return false;
		xLispObect = l;
		return true;
	}

	public boolean readS() {
		while (readEndChar()) {
			try {
				Thread.sleep(10);
			} catch (InterruptedException e) {

			}
		}
		;
		if (readAtom())
			return true;
		if (readQuote())
			return true;
		if (readSharpSign())
			return true;
		if (readList())
			return true;
		return false;
	}

	public boolean readNumber() {
		double s;
		double n;
		s = 1;
		n = 0;
		clearName();
		if (!rNum())
			return false;
		while (rNum())
			;
		try {
			n = Double.parseDouble(name);
		} catch (NumberFormatException e) {

		}
		xLispObect = new MyNumber(signValue * n, floatNumber);
		signValue=1;
		if (floatNumber)
			floatNumber = false;
		return true;
	}

	public boolean readEndChar() {
		int x = inCQ.prevRead1();
		if (x == (int) ' ') {
			inCQ.rNext();
			return true;
		}
		if (x == (int) '\n') {
			inCQ.rNext();
			return true;
		}
		if (x == 13) {
			inCQ.rNext();
			return true;
		}
		if (x == 10) {
			inCQ.rNext();
			return true;
		}
		return false;
	}

	public void clearName() {
		name = "";
	}

	public boolean rSymbol() {
		clearName();
		if (rNumOpr())
			return true;
		if (!readAlphBkSlashQuote())
			return false;
		while (readAlphBkSlashQuote() || rNum() || compareChar('-'))
			;
		xLispObect = lisp.recSymbol(name);
		return true;

	}

	public boolean rNum() {
		int x = inCQ.prevRead1();
		if (((int) '0' <= x && x <= (int) '9') || x == (int) '.') {
			if (x == (int) '.')
				floatNumber = true;
			conc(x);
			inCQ.rNext();
			return true;
		}
		return false;
	}

	public boolean compareChar(char c) {
		int x = inCQ.prevRead1();
		if (x == (int) c) {
			conc(x);
			inCQ.rNext();
			return true;
		}
		return false;
	}

	public CQueue inCQ;

	public void conc(int x) {
		name = name + (char) x;
	}

	public String name;

	public boolean readAlphBkSlashQuote() {
		int x = inCQ.prevRead1();
		if ((int) 'a' <= x && x <= (int) 'z') {
			conc(x);
			inCQ.rNext();
			return true;
		}
		if ((int) 'A' <= x && x <= (int) 'Z') {
			conc(x);
			inCQ.rNext();
			return true;
		}
		if ((int) '\\' == x) {
			conc(x);
			inCQ.rNext();
			return true;
		}
		if ((int) '\"' == x) {
			conc(x);
			inCQ.rNext();
			x = inCQ.prevRead1();
			if (x == (int) ' ') {
				stringDetected = false;
			} else if (x == (int) ')') {
				if(inCQ.tail==null){
					stringDetected = false;
				}
			} else {
				stringDetected = true;
			}
			return true;
		}
		if (stringDetected) {
			conc(x);
			inCQ.rNext();
			return true;
		}
		if ((int) ':' == x) {
			conc(x);
			inCQ.rNext();
			return true;
		}
		if ((int) ';' == x) {
			conc(x);
			inCQ.rNext();
			return true;
		}
		if ((int) '%' == x) {
			conc(x);
			inCQ.rNext();
			return true;
		}

		return false;
	}

	public boolean readSharpSign() {
		int x = inCQ.prevRead1();
		if (x == (int) '#') {
			inCQ.rNext();
			x = inCQ.prevRead1();
		} else
			return false;
		if (x == (int) '[') {
			inCQ.rNext();
			x = inCQ.prevRead1();
			if (x == (int) 'O') {
				inCQ.rNext();
				x = inCQ.prevRead1();
				if (x == (int) 'I') {
					inCQ.rNext();
					x = inCQ.prevRead1();
					if (x == (int) 'D') {
						inCQ.rNext();
						AddOID();
						return true;
					}
				}
			}  
			else if (x == (int) 'X') {
				inCQ.rNext();
				AddXOID();
				return true;
			}else if (x == (int) 'b') {
				inCQ.rNext();
				x = inCQ.prevRead1();
				if (x == (int) 'u') {
					inCQ.rNext();
					x = inCQ.prevRead1();
					if (x == (int) 'f') {
						inCQ.rNext();
						x = inCQ.prevRead1();
						if (x == (int) 'f') {
							inCQ.rNext();
							x = inCQ.prevRead1();
							if (x == (int) 'e') {
								inCQ.rNext();
								x = inCQ.prevRead1();
								if (x == (int) 'r') {
									inCQ.rNext();
									x = inCQ.prevRead1();
									if (x == (int) ' ') {
										inCQ.rNext();
										x = inCQ.prevRead1();
										while( x != (int) ']'){
											inCQ.rNext();
											x = inCQ.prevRead1();
										}
										//return true;
										inCQ.rNext();
									}
									
								}
								
							}
							
						}
					}
				}  
			}

		} 
		return false;
	}

	public void AddXOID() {
		int x = inCQ.prevRead1();
		if (x == (int) ' ') {
			inCQ.rNext();
			x = inCQ.prevRead1();
			clearName();
			while (x <= (int) '9' && x >= (int) '0') {
				conc(x);
				inCQ.rNext();
				x = inCQ.prevRead1();
			}
			Oid o = new Oid(Integer.parseInt(name));
			clearName();
			if (x == (int) ' ') {
				inCQ.rNext();
				x = inCQ.prevRead1();
				if (x == (int) '\"') {
					inCQ.rNext();
					x = inCQ.prevRead1();
					while (x != (int) '\"') {
						conc(x);
						inCQ.rNext();
						x = inCQ.prevRead1();
					}
					inCQ.rNext();
				}

			}
			o.name = name;
			xLispObect = (LispObject) o;
			inCQ.rNext();
			x = inCQ.prevRead1();
			clearName();
			// readList();
		}

	}

	public void AddOID() {
		int x = inCQ.prevRead1();
		if (x == (int) ' ') {
			inCQ.rNext();
			x = inCQ.prevRead1();
			clearName();
			while (x <= (int) '9' && x >= (int) '0') {
				conc(x);
				inCQ.rNext();
				x = inCQ.prevRead1();
			}
			Oid o = new Oid(Integer.parseInt(name));
			clearName();
			if (x == (int) ' ') {
				inCQ.rNext();
				x = inCQ.prevRead1();
				if (x == (int) '\"') {
					inCQ.rNext();
					x = inCQ.prevRead1();
					while (x != (int) '\"') {
						conc(x);
						inCQ.rNext();
						x = inCQ.prevRead1();
					}
					inCQ.rNext();
				}

			}
			o.name = name;
			xLispObect = (LispObject) o;
			inCQ.rNext();
			x = inCQ.prevRead1();
			clearName();
			// readList();
		}

	}

	public boolean readAtom() {
		if (rSymbol() || readNumber())
			return true;
		return false;
	}

	public LispObject read() {
		boolean rtn = readS();
		if (rtn)
			return xLispObect;
		else
			return null;

	}

	public String inLine;

	public void init() {
		xLispObect = null;
		inLine = "";
		stringDetected = false;
		backSlashDetected = false;
		floatNumber = false;
		signValue=1;
	}

	public void SetCQ(CQueue cq) {
		inCQ = cq;
	}

	public void SetAlisp(ALisp lsp) {
		lisp = lsp;
	}

	public ReadS() {
		init();
	}

	public LispObject xLispObect;
}