package bigtable.query.valuestream;

import java.io.LineNumberReader;
import java.io.InputStreamReader;

import bigtable.query.failure.AppEngineFailure;
import callin.AmosException;
import callin.Tuple;

public abstract class ValueStream {
	
    protected LineNumberReader lineReader = null;
	
    /**
     * Schema tuple arity
     */
    protected int schemaArity = 0;
    /**
     * Query projection arity
     */
    protected int queryArity = 0;
	
    /**
     * echo on when resuming a query
     */
    private boolean resumeEchoOn = true;
    /**
     * the last returned line
     */
    private String resumePoint;
    /**
     * Separator is loaded from ODDSE params
     */
    protected final String separator;

	
    public ValueStream(String separator) {
	this.separator = separator;
    }

    public abstract Tuple next(int arity) throws AmosException, AppEngineFailure;
	

    /**
     * Checks resume state while forwarding on the valuestream.
     * Enables emit to start after the {@link #resumePoint} is found. 
     * @param currentPoint the current row as a String
     */
    protected final void updateResumeState(Object currentPoint){
	// echo off, looking for resume point
	if( !resumeEchoOn && resumePoint != null && resumePoint.equals(currentPoint))
	    resumeEchoOn = true;
    }
	
    /**
     * Whether to emit a tuple currently
     * @return
     */
    protected final boolean doEmit(){
	return resumeEchoOn;
    }
	

    /**
     * Loads the next result {@link Tuple} from the internal value stream
     * Query should be resumed from the last tuple
     */
    public Tuple next() throws AmosException, AppEngineFailure {
	//System.out.println("here is next function ");
	return next(0);
    }
	
    public boolean isClosed(){
	return ( lineReader==null );
    }
}
