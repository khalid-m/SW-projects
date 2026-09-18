package bigtable;

import bigtable.schema.GAEDataStoreSchema;
import callin.AmosException;
import callin.Connection;
import callin.Oid;
import callin.Scan;
import callin.Tuple;

public class MetaDataSaver {
    /**
     * common static connection to Amos
     */
    private static Connection conn;
	
    private static void initConn() throws AmosException{
	if(conn==null)
	    conn = new Connection("");
    }
	
    /**
     * Gets a connection to Amos
     */
    public static Connection getConnection() throws AmosException{
	initConn();
	return conn;
    }
	
    /**
     * Calls the given Amos function
     */
    public static Scan callFunction(String functionname, Object[] params) throws AmosException{
	initConn();
	Tuple args = new Tuple(params.length);
	// set the params
	for (int i = 0; i < params.length; i++) {
	    args.setElem(i, params[i]);
	}
	return conn.callFunction(functionname,args);
    }
    
    public static void populateLocalbigtableURL(String inputs, String outputs) throws AmosException{
	initConn();
	Tuple argl = new Tuple(1), resl = new Tuple(1);		
	argl.setElem(0, inputs );	     
	resl.setElem(0, outputs);			       
	conn.addFunction( "bigTableURL", argl, resl );
    }

    public static void populateLocalbigTables(String inputs, String outputs) throws AmosException{
	initConn();
	Tuple argl = new Tuple(1), resl = new Tuple(1);		
	argl.setElem(0, inputs );
	resl.setElem(0, outputs);
	conn.addFunction( "bigTables", argl, resl );
    }

    public static void populateLocalbigtableKeyattri(String[] inputs, String outputs) throws AmosException{
	initConn();
	Tuple argl = new Tuple(2), resl = new Tuple(1);		
	argl.setElem(0, inputs[0] );
	argl.setElem(1, inputs[1] );
	resl.setElem(0, outputs);
	conn.addFunction( "bigTableKeyAttribute", argl, resl );
    }

    public static void populateLocalmetatableattributes(Object[] inputs, Object[] outputs) throws AmosException{
	initConn();
	Tuple argl = new Tuple(2), resl = new Tuple(5);	
	Tuple argtemp = new Tuple(1);  
	String attributetype;
	argtemp.setElem(0, outputs[2]);
	attributetype = conn.callFunction("TYPE.NAME->CHARSTRING",argtemp).getRow().getStringElem(0);
	argl.setElem(0, inputs[0] );
	argl.setElem(1, inputs[1] );
	resl.setElem(0, outputs[0]);
	resl.setElem(1, outputs[1]);
	resl.setElem(2, attributetype);
	resl.setElem(3, outputs[3]);
	resl.setElem(4, outputs[4]);
	conn.addFunction( "bigTableAttributes", argl, resl );
    }

    //for statistic
    public static void populateCharstringColStat(Object[] inputs, Integer numOfDiffVals) throws AmosException{
	initConn();
	Tuple argl = new Tuple(3), resl = new Tuple(1);
	argl.setElem(0, inputs[0] );
	argl.setElem(1, inputs[1] );
	argl.setElem(2, inputs[2] );
	resl.setElem(0, numOfDiffVals);
	conn.addFunction( "colCharstringStatistic", argl, resl );
    }

    public static void populateIntColStat(Object[] inputs, Integer minVal, Integer maxVal) throws AmosException{
	initConn();
	Tuple argl = new Tuple(3), resl_max = new Tuple(1), resl_min = new Tuple(1);
	argl.setElem(0, inputs[0] );
	argl.setElem(1, inputs[1] );
	argl.setElem(2, inputs[2] );
	resl_max.setElem(0, maxVal);
	resl_min.setElem(0, minVal);
	conn.addFunction( "colInt_maxVal", argl, resl_max );
	conn.addFunction( "colInt_minVal", argl, resl_min );
    }

    public static void populateIntColMaxVal(Object[] inputs, Integer maxVal) throws AmosException{
	initConn();
	Tuple argl = new Tuple(3), resl_max = new Tuple(1);
	argl.setElem(0, inputs[0] );
	argl.setElem(1, inputs[1] );
	argl.setElem(2, inputs[2] );
	resl_max.setElem(0, maxVal);
	conn.addFunction( "colInt_maxVal", argl, resl_max );		
    }

    public static void populateIntColMinVal(Object[] inputs, Integer minVal) throws AmosException{
	initConn();
	Tuple argl = new Tuple(3), resl_min = new Tuple(1);
	argl.setElem(0, inputs[0] );
	argl.setElem(1, inputs[1] );
	argl.setElem(2, inputs[2] );
	resl_min.setElem(0, minVal);
	conn.addFunction( "colInt_minVal", argl, resl_min );
    }

    //store number of tuples for a table in bigtable
    public static void populateNumOfTuplesForABTTable(String[] inputs, String outputs) throws AmosException{
	initConn();
	Tuple argl = new Tuple(2), resl = new Tuple(1);		
	argl.setElem(0, inputs[0] );
	argl.setElem(1, inputs[1] );
	if(outputs.equals("")){
	    resl.setElem(0, 0);}
	else
	    resl.setElem(0, Integer.parseInt(outputs));	
	//conn.addFunction( "bigTableNumOfTuples", argl, resl );
	conn.addFunction( "collectionSize", argl, resl );
    }


    /**
     * Gets properties of an entity type
     */
    private static Tuple getTypeProperties(String typename, boolean getKeys)throws AmosException{
	initConn();
	Scan scan = null; Tuple args = null;
	args = new Tuple(1);
	// get properties from core cluster function
	args.setElem(0, typename);
	scan = conn.callFunction(getKeys?"getTypeKeyProperties":"getTypeProperties",args);
	if(scan.eos())
	    throw new AmosException("Could not retrieve properties for type "+typename);
	return scan.getRow().getSeqElem(0);
    }
 
    /**
     * Gets properties of an entity type
     */
    public static Tuple getTypeProperties(String typename)throws AmosException{
	return getTypeProperties(typename, false);
    }
	

    /**
     * Loads type for given name from Amos
     */
    public static Oid getMappedValueType(String typename)throws AmosException{
	initConn();
	Scan scan = null; Tuple args = null;
	// get type
	args = new Tuple(1);
	args.setElem(0, typename); // arguments
	scan = conn.callFunction("typenamed",args);
	// check result
	if(scan.eos()) 
	    throw new AmosException("Type "+typename+" doesn't exist!");
	return scan.getRow().getOidElem(0);
    }

    /* key or non-key attribute specification */
    public static String specifyKeyAttri(GAEDataStoreSchema schema, Integer i){
	int keyAttribute = schema.getKeyProperties().indexOf( schema.getProperties().get(i) );
	if(keyAttribute == 0){
	    return "key";}
	else if(keyAttribute == -1){
	    return "non-key";}
	else{
	    return "unknown";}
    }
	
    /* Stores GAE data store schema meta data into stored functions of Amos */
    public static void storeMetadata(GAEDataStoreSchema schema, String dsn) throws AmosException{
	String tablename = schema.getTypename();

	//store URL for a dsn
	populateLocalbigtableURL(dsn, schema.getLocation());

	//store tables in a dsn
	populateLocalbigTables(dsn, schema.getTypename());

	//store number of tuples of a table
	String[] params1 = new String[]{dsn,tablename};
	populateNumOfTuplesForABTTable(params1, schema.getnumOfTuples());

	//store key attribute for a table 
	String[] params2 = new String[]{dsn,tablename};
	for (int i = 0; i < schema.getKeyProperties().size(); i++) {
	    populateLocalbigtableKeyattri(params2, schema.getKeyProperties().get(i));
	}

	//store attributes infor for a table			      
	Object[] params3 = new Object[]{dsn,tablename};
	for (int i = 0; i < schema.getProperties().size(); i++) {
	    populateLocalmetatableattributes(params3, new Object[]{i,
								       schema.getProperties().get(i),
								       getMappedValueType(schema.getPropertyTypes().get(i)),
								       //schema.getKeyProperties().indexOf( schema.getProperties().get(i) ),
								       specifyKeyAttri(schema,i),
								       "index"});
	}
    }

    public static void storeColStatData(GAEDataStoreSchema schema, String dsn) throws AmosException{
	String tablename = schema.getTypename();
	int j=0;
	//put debug function here
	System.out.println("here is storeColStatData");
	//int propertysize = schema.getproperties().size();
	//System.out.println("schema.getProperties.size is: " + propertysize);
	//System.out.println("schema.getPropertiesType.size is: " + schema.getPropertyTypes().size());
	System.out.println("schema table is: " + tablename);
	//store attributes statistic infor for a table of a dsn			      
	Object[] params2 = new Object[]{dsn,tablename};
	for (int i = 0; i < schema.getProperties().size(); i++) {
	    //System.out.println("schema.getProperties.size is: " + schema.getProperties().size());
	    //System.out.println("schema.getPropertiesType.size is: " + schema.getPropertyTypes().size());
		       
	    String aname = schema.getProperties().get(i);
	    String atype = schema.getPropertyTypes().get(i);
	    //System.out.println("dsn is " + dsn);
	    //System.out.println("tablename is " + tablename);
	    //System.out.println("aname is " + aname);
	    //System.out.println("atype is " + atype);
	    //System.out.println("i value is " + i);
	    //System.out.println("population value is " + schema.getPropertyValStat().get(i));
	    if(atype.equals("CHARSTRING")){
		//System.out.println("here comes into populateCharstringColStat method");
		populateCharstringColStat(new Object[]{dsn, tablename, aname}, schema.getPropertyValStat().get(i)); 
	    }
	    if(atype.equals("INTEGER")){
		//System.out.println("here comes into populateIntColStat method");
		switch (j){
		case 0:  populateIntColMaxVal(new Object[]{dsn, tablename, aname}, schema.getPropertyValStat().get(i)); j=1; break;
		case 1:  populateIntColMinVal(new Object[]{dsn, tablename, aname}, schema.getPropertyValStat().get(i)); j=0; break;
		}
	    } 
	}
		
    }

    public static AmosException toAmosExc(String msg, StackTraceElement[] trace){
	AmosException a = new AmosException( msg );
	a.setStackTrace(trace);
	return a;
    }
	
    public static AmosException toAmosExc(Throwable e){
	if (e instanceof AmosException) {
	    return (AmosException) e;
	} else {
	    AmosException a;
	    if(e != null){
		a = new AmosException("["+e.getClass().getSimpleName()+"]"+e.getMessage());
		a.setStackTrace(e.getStackTrace());
	    } else {
		a = new AmosException("An unknown exception occured (NULL was thrown!).");
	    }
	    return a;
	}
    }
}
