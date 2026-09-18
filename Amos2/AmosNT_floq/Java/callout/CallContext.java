/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1999 Daniel Elin, Tore Risch, UDBL
 * $RCSfile: CallContext.java,v $
 * $Revision: 1.8 $ $Date: 2009/01/06 14:54:43 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Java callout interface
 * ===========================================================================
 * $Log: CallContext.java,v $
 * Revision 1.8  2009/01/06 14:54:43  torer
 * Background computations possible in coroutine threads
 *
 * Revision 1.7  2008/12/14 16:48:52  torer
 * New method: CallContext.connection()
 * to get correct connection inside foreign function definitions in Java
 *
 ****************************************************************************/

package callout;
import callin.*;

/**
 * Class corresponding to the C-type a_callcontext. An object of this class is
 * passed as an argument to each foreign Java-function. It is used to emit
 * result(s) from the foreign function.
 */
public class CallContext 
{

    //
    // ===== Public interface =================================================
    //

    public Connection connection()
	throws AmosException
    { 
	return Connection.callbackConnection();
    }

    /**
     * Emits a result from a foreign-function implemented in Java to AMOS2.
     * The elements of tpl represent the combination of the emitted argument
     * values and the corresponding result values. (see T.Risch: AMOS2 External
     * Interfaces)
     *
     * @param tpl See above.
     */
    public native void emit(callin.Tuple tpl);

    /**
     * Get current background thread.
     */
    public native Oid getBG();
 
    /**
     * Enter background busy state for current background thread bg.
     * WARNING: You are not allowed to call any Amos II operations
     * in a busy thread
     */
    public native void enterBG(Oid bg);

    /**
     * Leave background state for current coroutine thread.
     */
    public native void leaveBG(Oid bg);

    //
    // ===== Private interface ================================================
    //

    /**
     * Holds a pointer-value to a struct a_callcontext.
     * It is safe to save this pointer because once such a pointer is declared
     * it doesn't change value. Of course, this implementation relies on the
     * fact that sizeof(struct ... *) = 4.
     */
    private int cxtPointer;
    
    /**
     * Constructor. Used by the C-code.
     * Called from callJava(), stores a pointer (struct a_callcontext *) in
     * ctxPointer. This pointer is used by the native implementation of emit().
     *
     * @param ctxPointer A stored pointer (struct a_callcontext *).
     */
    private CallContext(int cxtPointer) 
    {
	this.cxtPointer = cxtPointer;
    }
}
