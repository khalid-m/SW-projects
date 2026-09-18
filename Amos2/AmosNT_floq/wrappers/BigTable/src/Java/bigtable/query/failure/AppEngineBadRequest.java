package bigtable.query.failure;

import callin.AmosException;

/**
 * Superclass for all kinds of bad requests.
 * In contrast to {@link AppEngineFailure}s these failures are not
 * recoverable, the query will be aborted.
 */
public class AppEngineBadRequest extends AmosException {
    private static final long serialVersionUID = 1L;
    public AppEngineBadRequest(String msg) {
	super(msg);
    }
}
