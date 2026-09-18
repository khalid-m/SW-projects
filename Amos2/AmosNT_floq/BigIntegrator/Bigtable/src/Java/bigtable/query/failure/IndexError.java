package bigtable.query.failure;

public class IndexError extends AppEngineBadRequest {
    private static final long serialVersionUID = 1L;

    public IndexError(String msg){
	super( msg.replace('|', '\n') 
	       // RESTRICTION Manage indices automatically by IndexManager later
	       + "\nCurrently the index has to be manually added to 'index.yaml' "
	       );
    }
}
