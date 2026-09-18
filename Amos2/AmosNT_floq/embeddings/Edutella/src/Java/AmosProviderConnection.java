/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2002 Johan Petrini, UDBL
 * $RCSfile: AmosProviderConnection.java,v $
 * $Revision: 1.2 $ $Date: 2005/02/23 16:33:13 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Handles QEL3 queries to PSELO and corresponding 
 * response to consumer.
 *
 ****************************************************************************/

package pselo;

import java.io.*;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Vector;

import net.jxta.edutella.eqm.Query;
import net.jxta.edutella.eqm.Result;
import net.jxta.edutella.eqm.ResultSet;
import net.jxta.edutella.eqm.io.QELQueryFormat;
import net.jxta.edutella.provider.AbstractProviderConnection;
import net.jxta.edutella.peer.characterize.DescriptionModel;
import net.jxta.edutella.peer.characterize.DescriptionModelImpl;

import net.jxta.edutella.util.Option;
import callin.AmosException;
import callin.Connection;
import callin.Scan;
import callin.Tuple;

import org.apache.log4j.*;

import com.hp.hpl.jena.mem.ModelMem;
import com.hp.hpl.jena.rdf.model.Literal;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.RDFException;
import com.hp.hpl.jena.rdf.model.RDFNode;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.Statement;
import com.hp.hpl.jena.rdf.model.StmtIterator;
import com.hp.hpl.jena.rdf.model.impl.LiteralImpl;
import com.hp.hpl.jena.rdf.model.impl.ResourceImpl;
 
class PSELOInterface {
    protected String anonDmp = "peer.dmp";	 
    protected boolean init = false;
    protected String argv[] = {anonDmp};
    protected Integer lock1 = new Integer(0);
    protected Integer lock2 = new Integer(0);
    
    //Multi-threaded execution of JAVA-C interface.
    public void initAmos(int tID){
	Date d = new Date();
	System.out.println("Thread " + tID + " entering SyncInterface.initAmos() at:" + d.toString());
	synchronized(lock1){
	    System.out.println("Inside lock1....");
	    System.out.println("Init status: " + init);	    
	    if(init == false){
		init = true;
		System.out.println("Thread " + tID + " trying to initialize Amos");
		System.out.println("Thread " + tID + " trying to create connection to PSELO");									    
		try{
		    
		    Connection.initializeAmos(argv);		
		    System.out.println("Thread " + tID + " initialized Amos");		    
		    System.out.println("Thread " + tID + " created connection to PSELO");
		    
		}catch(AmosException e){
		    System.out.println("Thread " + tID + " causing exception in SyncInterface.initAmos() -> Restarting system.");
		    System.out.println(e.getMessage());
		    e.printStackTrace();
		    System.out.println(1);
		}		 
	    }
	}
    }		  		  
    
    //Multi-threaded execution of JAVA-C interface.
    public Scan execQuery(Tuple tw, int tID){		  
	Date d = new Date();
	System.out.println("Thread " + tID + " entering SyncInterface.execQuery() in AmosNT at:" + d.toString());
	synchronized(lock2){	    
	    System.out.println("Inside lock2...");	    
	    Scan tmpScan=null;	
	    try {
		System.out.println("Trying to create connection to PSELO");
		Connection con = new Connection("PSELO");
		System.out.println("Created connection to PSELO");
		System.out.println("Trying to execute query against PSELO");
		tmpScan = con.callFunction("vector.query_handler->vector",tw);
		System.out.println("Executed query against PSELO");
		System.out.println("Trying to disconnect to PSELO");
		con.disconnect();
		System.out.println("Disconnected to PSELO");					
		
	    }catch(AmosException e){	    
		System.out.println(e.getMessage());
		e.printStackTrace();
		System.exit(1);
	    }
	    return tmpScan;
	}
	
    } 
    
}

public class AmosProviderConnection extends AbstractProviderConnection {
    protected static int tC=0;
    protected int tID=0;
    protected static PSELOInterface pInt = new PSELOInterface();
   
    
    /**
     * Class constructor initializing an anonymous Amos2 by providing provider.dmp file.
     * If the anonymous Amos2 is already initialized an AmosException is thrown an catched and 
     * corresponding error message logged to provider.log. 
     * Rationale: PSELOProvider should handle scenarios when an anonymous Amos2 is being reinitialized. 
     * This seems to be happening quite regularly in the process of Edutella SystemFactory initializing PSELO provider. 
     */
    public AmosProviderConnection(){
	Date d = new Date();		  		  
	System.out.println("Entering AmosProviderConnection() constructor method at:" + d.toString());
	System.setErr(System.out);
	tC++;
	tID=tC;
	pInt.initAmos(tID);
    }
    
    /** 
     * (non-javadoc)
     * @return
     * @see net.jxta.edutella.util.Configurable#getOptions()
     */
    public Option[] getOptions(){
	System.out.println("Hello! We are in getOptions() method.");
	return null;}
    
    /** 
     * (non-Javadoc)
     * @return
     * @see net.jxta.edutella.util.Configurable#getPropertyPrefix()
     */
    public String getPropertyPrefix(){
	System.out.println("Hello! We are in getPropertyPrefix() method.");
	return "provider";}
    
    /**
     * Method called by Edutella code upon PSELO provider startup. 
     * Probably part of provider interface in Edutella.
     * Implemented by dummy function. 
     */
    public void init() {
	System.out.println("Hello! We are in init() method.");
    }
    
    
    /** 
     *(non-Javadoc)
     * Lï¿½mna tillbaka till poolen.... kanske inget att bry sig om...
     * @see net.jxta.edutella.provider.PooledConnection#close()
     */
    public void close() {
	System.out.println("Hello! We are in close() method.");
    }
    
    /** 
     *(non-Javadoc)
     * Svara om kopplingen till AMOS ï¿½r aktiv.
     * @return
     * @see net.jxta.edutella.provider.PooledConnection#validate()
     */
    public boolean validate() {
	System.out.println("Hello! We are in validate() method.");
	return true;}
    
    /** 
     *(non-Javadoc)
     * @return
     * @see net.jxta.edutella.provider.PooledConnection#getDescription()
     */
    public String getDescription() {
	System.out.println("Hello! We are in getDescription() method.");
	return "PseloDev";}
    
    
    /**
     * Method for determine if the string representation of a node in result vector from PSELO is resource or literal. 
     * Algorithm: If the string starts with 'http://' or 'file:///' then the string is a resource, else a literal.
     * @param node
     * @return boolean
     */
    public boolean isResource(String node) {
	if ((!node.startsWith("http://")) && (!node.startsWith("file:///"))) return false;
	else return true;
    }
    
    /**
     * Method that: 
     * 1 - Parses an incoming QEL query from consumer A into RDF statements.
     * 2 - Builds a vector of parsed statements and sends to PSELO for evaluation.
     * 3 - Get back the result of the QEL query as a scan of tuples where each tuple contains RDF resources for every
     * variable in QEL query.
     * 4 - Matches variables and corresponding values(resources/literals) and builds a result set.
     * 5 - Return result set to consumer A.
     * @param query
     * @return ResultSet
     */
    public ResultSet executeQuery(Query query) {
	
	Date d1 = new Date();
	System.out.println("Entering executeQuery() method at:" + d1.toString());
	
	Object val = null;		  
	ResultSet rs = null;
	Scan resourceScan = null;
	Tuple tmp = null;
	Vector qelVars = new Vector();
	
	//There could be uncalculated AmosExceptions thrown during program execution. Program should 
	//execute with 1 and error be logged.
	//try {
	
	//init() should be called from executeQuery.
	init();
	
	//New in memory JENA model (think of a Single RDF file but in memory).  
	Model queryModel = new ModelMem();
	
	//Serialize the objectmodel of the query (from ECDM API) into a JENA model. 
	(new QELQueryFormat()).format(query, queryModel);
	
	//List all the statements in this JENA model for counting. 
	StmtIterator stmts = queryModel.listStatements();
	
	//Count number of RDF statements in QEL query.
	int nr_of_stmt = 0;
	while(stmts.hasNext()){
	    stmts.next();
	    nr_of_stmt++;
	}
	
	//Save all QEL result variables in vector qelVars.
	Query q = query;			
	List queryVars = q.getResultVariables();
	//q = null;
	Iterator resVars = queryVars.iterator();			
	while(resVars.hasNext()){
	    String s = resVars.next().toString();
	    qelVars.addElement(s);
	}
	
	//List all the RDF statements in this JENA model for creation in PSELO.  
	StmtIterator si = queryModel.listStatements();
	
	//Create wrapper datastructure for holding actual arguments (triples of triples). 
	//Think sending arguments in callout interface. 
	Tuple triple_wrapper = new Tuple(1);
	
	//Create datastructure for holding triples. 
	Tuple triples = new Tuple(nr_of_stmt);
	
	//Go trough all RDF statements in JENA model of QEL query (queryModel) and 
	//store them in Tuple triples on format {{s,p,o},....,{s,p,o}}.
	try{
	    int count = 0;
	    while (count < nr_of_stmt) {
		Statement statement = si.nextStatement();
		Resource subject = statement.getSubject();
		Resource predicate = statement.getPredicate();
		RDFNode object = statement.getObject();
		
		if (object instanceof Literal) {						  
		    triples.setElem(count,statementEmitterWithLiteralObject(subject, predicate, (Literal) object));
		    
		}
		else {
		    triples.setElem(count,statementEmitterWithResourceObject(subject, predicate, (Resource) object));  
		}														
		
		count++;	
	    }
	}catch(AmosException e){
	    System.out.println("Error when setting element to RDF statements in Tuple triples.");
	    System.out.println(e.getMessage());
	    e.printStackTrace();		 
	    System.exit(1);				
	}
	
	
	//Populate tripple_wrapper to send to PSELO as a vector of format {{{s,p,o},{s,p,o},....,{s,p,o}}}.
	try{
	    triple_wrapper.setElem(0, triples);
	}catch(AmosException e){
	    System.out.println("Error when trying to set first element of Tuple triple_wrapper to Tuple triples");
	    System.out.println(e.getMessage());
	    e.printStackTrace();		 
	    System.exit(1);				
	}
	
	//Anrop av PSELO stored procedure query_handler med argument 
	//{{{s,p,o}}{{s,p,o}}{{s,p,o}},...}.
	//query_handler bygger upp, evaluerar frågan samt returnerar en scan av {{{s,p,o}},{{s,p,o}},{{s,p,o}},...}
	//Subtelities: When we have come this far we: 
	//1 - Open a connection to PSELO from anonymous Amos2.
	//2 - Executes the QEL query against PSELO through fast-path interface i.e 
	//no overhead of dynamic parsing and executing AmosQL statements.The result is a scan.
	//3 - The connection to PSELO is set to null. Accordning to documentation Connections are automatically
	//garbage collected when deallocated by Java.
	//Should an AmosException be thrown here there is no recovery and our system should terminate with 1.
	

	    resourceScan = pInt.execQuery(triple_wrapper, tID);
	
       
	//Redundant code. Could be removed later on...
	//Check if resourceScan is either:
	//1 - Empty. Should never be the case when an empty resourceScan are defined in PSELO 
	//to be on the form {{NULL}} i.e at least one sequence in place 0. 
	//2 - Null. An error has occured in PSELO and resourceScan is initialized to NULL.
	//This case will probably also be handled in try block above.
	//In both cases there are no recovery and program should terminate with 1. 
	if(resourceScan.eos() || resourceScan == null){
	    System.out.println("ResourceScan in PSELO provider null or empty");
	    System.exit(1);
	}
	
	//ResultSet rs is intialized to the empty ResultSet.
	rs = query.createResultSet();
	
	// This while loop iterates through the rows of the resourceScan, rs, from PSELO. For
	// every element in each row of rs it binds the corresponding (due to their order)variable. 
	// Each bindning is added to the resultSet of the QEL query.
	try{
	    while (!resourceScan.eos()) {
		
		//Initialize rowWrapper to first row of resourceScan.					
		Tuple rowWrapper = resourceScan.getRow();
		
		//Create rt for holding binding. 				  		 
		Result rt = rs.createResult();
		
		//We have to check for empty ResultSet defined as {{NULL}}.
		if(rowWrapper.isTuple(0)){
		    RDFNode value;
		    int i = 0;
		    Tuple row = rowWrapper.getSeqElem(0);
		    while (i < row.getArity()) {
			
			//We fetch val as an Object when it could be NULL in outerjoin queries
			val = row.getElem(i);
			
			//If val != NULL -> create RDF resource or 
			//RDF literal of value val.								
			if(val != null){
			    String safe_val = (String)val;
			    if (isResource(safe_val)) value = new ResourceImpl(safe_val);
			    else value = new LiteralImpl(safe_val);
			    
			    //Pick out result variable of vector qelVars as a string and 
			    //create a RDF resource out of it.
			    String str = (String)qelVars.get(i);
			    Resource variable = new ResourceImpl(str);
			    
			    //Add binding to Result rt. 
			    rt.addBinding(variable, value);
			}
			
			i++;
		    }
		    
		    //Add Results to resultSet. 						  
		    rs.addResult(rt);
		}
		
		//Get next row of resourceScan.
		resourceScan.nextRow();
		
	    }
	}catch(AmosException e){
	    System.out.println("Failed going through resourceScan and creating variable-value bindings rt for ResultSet rs");
	    System.out.println(e.getMessage());
	    e.printStackTrace();		 
	    System.exit(1);
	}
	
	//Return resultSet rs to the consumer.				
	return rs;
    }
    
    
    /**
     * @param s
     * @return
     */
    /*protected String resource_parser(String s){
		String parsed = s.substring(s.indexOf("'"),s.lastIndexOf("'"));
		return parsed;
		}*/
    
    
    /**
     * This function creates an Amos II tuple <subject, predicate, object> for every 
     * RDF statement where the object is a resource value.
     * @param subj
     * @param pred
     * @param obj
     * @return
     */
    protected Tuple statementEmitterWithResourceObject(Resource subj, Resource pred, Resource obj) {
	Tuple test;
	Tuple tpl;
	String res;
	
	String subjstr, predstr, objstr;
	subjstr = resource(subj);
	predstr = resource(pred);
	objstr = resource(obj);
	
	tpl = new Tuple(3);
	
	try {
	    tpl.setElem(0, subjstr);
	    tpl.setElem(1, predstr);
	    tpl.setElem(2, objstr);
	}
	catch (AmosException e) {
	    e.printStackTrace();
	}
		return tpl;
    }
    
    /**
     *  This function creates an Amos II tuple <subject, predicate, object> for every 
     * RDF statement where the object is a literal value.
     * Literal objects can be interpreted as typed values. The literal string is 
     * considered to be a serialization of the typed value. Methods are provided 
     * for retrieving built in java types which are represented by the string produced 
     * by their toString method.
     * @param subj
     * @param pred
     * @param lit
     * @return
     */
    public Tuple statementEmitterWithLiteralObject(Resource subj, Resource pred, Literal lit) {
	Tuple test;
	Tuple tpl;
	String res;
	
	String subjstr, predstr, objstr;
	subjstr = resource(subj);
	predstr = resource(pred);
	
	tpl = new Tuple(3);
	
	try {
	    
	    objstr = lit.getString();
	    tpl.setElem(0, subjstr);
	    tpl.setElem(1, predstr);
	    tpl.setElem(2, objstr);
	}
	catch (AmosException a) {
	    a.printStackTrace();
	}
	catch (RDFException e) {
	    e.getMessage();
	}
	return tpl;
    }
    
    /**
     * This function converts a resource to a string.
     * Especially it converts file:/x to file:///x 
     * @param r
     * @return
     */
    static private String resource(Resource r) {
	
	if (r.isAnon())
	    try {
		return "_:j" + r.getId() + " ";
	    }
	catch (RDFException e) {
	    return "_:j" + r + " "; //worst case use oid in jvm.
	}
	else {
	    String uri = r.getURI();
	    if (!uri.startsWith("file:/"))
		return uri;
	    if (uri.startsWith("file:///"))
		return uri;
	    return "file:///" + uri.substring(6, uri.length());
	    
	}
    }
    
    /**
     * This function is supposed to check for typed literals but is currently not used
     * @param l
     * @return
     */
    /*static private String literal(Literal l) {
      String res = null;	
      return res;
      }*/
    
    /* (non-Javadoc)
     * @see net.jxta.edutella.provider.QueryConnection#provideMetadata()
     */
    public DescriptionModel provideMetadata() {
	// TODO Auto-generated method stub
	return new DescriptionModelImpl();
    }
    
}



