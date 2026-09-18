package udbl.amos.purejavaclient;

class CQueue extends java.lang.Object
// implements Runnable
{
	public void waitNext() {
		while (isEmpty()) {
			try {
				wait();
			} catch (InterruptedException e) {
				System.out.println(e);
				return;
			}
		}
	}

	public Thread me;

	public boolean isEmpty() {
		return tail == null;
	}

	public synchronized int getAuxW() {
		int c;
		// while(true){
		waitNext();
		c = getAux();
		if (c != -1)
			return c;
		else
			return -1;

		// }
	}

	public int getNW() {
		if (charBuffer == 0)
			charBuffer = getAux();
		int rtn = charBuffer;
		charBuffer = 0;
		return rtn;
	}

	public synchronized void putString(String s) {
		int i;
		int length = s.length();
		for (i = 0; i < length; i++) {
			char c = s.charAt(i);
			put((int) c);
		}
	}

	public synchronized void rNext() {
		@SuppressWarnings("unused")
		int x = get();
	}

	public synchronized int get() {
		int rtn;
		if (charBuffer == 0)
			charBuffer = getAuxW();
		if (charBuffer == 0)
			rtn = 0;
		rtn = charBuffer;
		charBuffer = 0;
		return rtn;
	}

	public int charBuffer;

	public synchronized int prevRead1() {
		if (charBuffer == 0)
			charBuffer = getAuxW();
		return charBuffer;
	}

	public synchronized int getAux() {
		// System.out.println("getAux()...");
		if (tail == null) {
			head = null;
			tail = null;
			return -1;
		} else {
			int rtn = tail.c;
			tail = tail.next;
			// System.out.println("getAux-"+rtn+"-");
			return rtn;
		}

	}

	public synchronized void put(int c) {
		CList p = new CList();
		//System.out.println("put("+(char)c+")");
		if (charBuffer == -1)
			charBuffer = 0;
		p.c = c;
		p.next = null;
		if (tail == null) {
			head = p;
			tail = p;
		} else {
			head.next = p;
			head = p;
		}
		notify();
	}
	public CList head;
	public CList tail;
	public CQueue() {
		head = null;
		tail = null;
		charBuffer = 0;
	}
}
