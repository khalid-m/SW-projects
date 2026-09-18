package bigtable.query.failure;

import callin.AmosException;

public class UnresumableRequest extends AmosException {
    private static final long serialVersionUID = 1L;
    public UnresumableRequest(String msg) {
	super(msg);
    }
}
