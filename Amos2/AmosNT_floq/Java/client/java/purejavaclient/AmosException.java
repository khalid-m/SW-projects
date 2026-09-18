package udbl.amos.purejavaclient;

import java.lang.Throwable;

/**
 * This exception is thrown from various methods in the packages callin and
 * callout. It represents that some kind of error has happened in the
 * AMOS2-database.
 * 
 * @author Daniel Elin
 * @version 1.3 (Last modified 990419)
 */
@SuppressWarnings({ "unused", "serial" })
public class AmosException extends Exception {

	/**
	 * Holds the Amos II error number. The basic error numbers can be viewed in
	 * the ..\..\C\storage.h C-header file.
	 */
	public int errno;

	/**
	 * Holds the Amos II error message
	 */
	public String errstr;

	/**
	 * Holds the Amos II error argument
	 */
	public Oid errform;

	/**
	 * Constructor. Creates the exception.
	 */
	public AmosException() {
		super("AmosException");
	}

	/**
	 * Preferred constructor in Java. Raises new Amos II exception.
	 */
	public AmosException(String AmosMsg) {
		super(AmosException.AmosErrorMessage(-1, null, AmosMsg));

		this.errform = null;
		this.errstr = AmosMsg;
		this.errno = -1;
	}

	/**
	 * Constructor called from C. Creates internal AmosException when Amos II
	 * exception occured in C. theErrorMessage is the error message to be
	 * printed in Java The Amos error message is constructed from the error
	 * number ErrNo. If ErrNo == -1 there is specific Amos error message.
	 */
	public AmosException(int ErrNo, Oid ErrorForm, String AmosMsg) {
		super(AmosException.AmosErrorMessage(ErrNo, ErrorForm, AmosMsg));
		this.errform = ErrorForm;
		this.errstr = AmosMsg;
		this.errno = ErrNo;
	}

	/**
	 * Construct an Amos II error message (Should be in kernel)
	 */
	private static String AmosErrorMessage(int ErrNo, Oid ErrorForm,
			String AmosMsg) {
		String formstr;

		if (ErrorForm == null)
			formstr = null;
		else {
			formstr = ErrorForm.toAmosString();
			if (formstr.equals("NIL"))
				formstr = null;
		}
		if (ErrNo > 0) {
			if (formstr == null)
				return "ERROR " + ErrNo + ": " + AmosMsg;
			else
				return "ERROR " + ErrNo + ", " + AmosMsg + ": " + formstr;
		} else if (formstr == null)
			return "ERROR " + AmosMsg;
		else
			return "ERROR " + AmosMsg + " " + formstr;
	}
}
