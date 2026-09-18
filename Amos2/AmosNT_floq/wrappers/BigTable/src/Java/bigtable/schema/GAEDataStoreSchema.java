package bigtable.schema;

import java.util.ArrayList;
import callin.AmosException;
import callin.Tuple;
import callin.Oid;

import bigtable.ResultFormater;
import bigtable.MetaDataSaver;
import bigtable.query.valuestream.HttpResponseStream;

/**
 * Represents a data store schema definition either  
 * created locally or downloaded from an App Engine.
 */
public class GAEDataStoreSchema {
	
    private String typename = null;
    private String typeFullname = null;
    private String parentTypename = "";
    private String numOfTuples = null;
    private Number maxColVal = 0;
    private Number minColVal = 0;
    private int numOfDiffRows = 0;
    private final ArrayList<String> properties = new ArrayList<String>();
    private final ArrayList<String> propertyTypes = new ArrayList<String>();
    private final ArrayList<Integer> propertyValStat = new ArrayList<Integer>();
    private final ArrayList<String> keyProperties = new ArrayList<String>();
    private String location = null;
    private int inheritedProperties = 0;

	
    /**
     * Reset the schema
     */
    protected void resetSchema(){
	typename = null;
	parentTypename = "";
	properties.clear();
	propertyTypes.clear();
	keyProperties.clear();
	inheritedProperties = 0;
	location = null;
	numOfTuples = null;
	propertyValStat.clear();
    }

	
    /**
     * Sets schema parameters for {@link HttpValueStream} request. 
     * Inherited properties are skipped
     */
    protected void setRequestParams(HttpResponseStream valStream){
	valStream.addParameter( "entity", getTypename() ) ;
	valStream.addParameter( "parentEntity", parentTypename );
	valStream.addParameter( "keyList", ResultFormater.arrayToString(keyProperties, ",") );
	//add all none-inherited properties
	for (int i = inheritedProperties; i < properties.size(); i++) {
	    valStream.addParameter( "property", properties.get(i) );
	    // upper case by default
	    valStream.addParameter( "type",propertyTypes.get(i).toUpperCase() );
	}
    }
	
    /**
     * Loads parameters such as url, table name, attributes name, attribute type, key attribute
     * for creating GAE data store schema.
     */
    @SuppressWarnings("unchecked")
	protected void loadFromTuple(Tuple tpl) throws AmosException{
	resetSchema();
	location = tpl.getStringElem(0);
	typename = tpl.getStringElem(1);
	// inheritance if index 2 is String
	if (tpl.getElem(2) instanceof String) {
	    parentTypename = tpl.getStringElem(2);
	    // add inherited properties first
	    //addInheritedProperties();
	    // add extended properties
	    properties.addAll( tpl.getSeqElem(3).toVector() );
	    propertyTypes.addAll( tpl.getSeqElem(4).toVector() );
	    //no additional key properties!!
	} else {
	    parentTypename = "";
	    // add extended properties
	    properties.addAll( tpl.getSeqElem(2).toVector() );
	    propertyTypes.addAll( tpl.getSeqElem(3).toVector() );
	    keyProperties.addAll( tpl.getSeqElem(4).toVector() );
	}
    }
	
    /**
     * Sets a new schema for the given parameters set table information
     */
    protected void setType(String typename, String parentTypename, String numOfTuples, String uri) throws AmosException{
	resetSchema();
	this.typename = typename;
	this.numOfTuples = numOfTuples;
	this.parentTypename = parentTypename;
	this.location = uri;
	//addInheritedProperties();
    }

    protected void setTypeForStat(String typename) throws AmosException{
	resetSchema();
	this.typename = typename;			
    }
	
    /**
     * Adds inherited properties
     * @throws AmosException
     */
    private void addInheritedProperties() throws AmosException{
	if(!parentTypename.isEmpty()){
	    // load properties of parent type
	    Tuple propVector = MetaDataSaver.getTypeProperties( parentTypename );
	    inheritedProperties = propVector.getArity();
	    for (int i = 0; i < inheritedProperties; i++){
		Tuple prop = propVector.getSeqElem(i);
		addProperty( prop.getStringElem(0), 
			     prop.getStringElem(1), 
			     prop.getIntElem(3)>=0 );
	    }
	}
    }


    /**
     * Adds a property to the current schema
     * @param property
     * @param type
     * @param isKey
     * @throws AmosException
     */
    protected void addProperty(String property, String type, boolean isKey)  throws AmosException{
	if(this.getTypename()==null) {
	    throw new AmosException("Set type name first!");
	}
	this.properties.add(property);
	this.propertyTypes.add(type.toUpperCase());
	if(isKey)
	    this.keyProperties.add(property);
    }

    //colval is assume as only one value regardless property type now
    protected void addPropertyStatVal(String property, String type, String colVal)  throws AmosException{
	this.properties.add(property);
	this.propertyTypes.add(type.toUpperCase());
	this.propertyValStat.add(Integer.parseInt(colVal));
    }

       	
    /**
     * Enforces some simple conditions
     * @throws AmosException
     */
    protected void checkSchema() throws AmosException{
	if(getTypename()==null)
	    throw new AmosException("No open entity to close");
	if(properties.size()==0)
	    throw new AmosException("No properties defined for " + getTypename() + "!");
	if(properties.size() != propertyTypes.size())
	    throw new AmosException("Number of property types doesn't match the given property definition!");
    }

    public String getTypename() {
	return typename;
    }

    public String getTypeFullname() {
	return typeFullname;
    }

    public String getParentTypename() {
	return parentTypename;
    }

    public String getLocation() {
	return location;
    }

    public String getnumOfTuples() {
	return numOfTuples;
    }

    public Number getMaxColVal() {
	return maxColVal;
    }

    public Number getMinColVal() {
	return minColVal;
    }

    public Integer getnumOfDiffRows() {
	return numOfDiffRows;
    }

    public ArrayList<String> getProperties() {
	return properties;
    }

    public ArrayList<String> getPropertyTypes() {
	return propertyTypes;
    }

    public ArrayList<String> getKeyProperties() {
	return keyProperties;
    }

    public ArrayList<Integer> getPropertyValStat() {
	return propertyValStat;
    }
}
