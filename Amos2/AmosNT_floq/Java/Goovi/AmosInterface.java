package Goovi;

import callin.*;
import jclass.bwt.*;
import java.util.*;
import java.awt.*;

/**
  * Class for that specializes callin.Connection class
  * with extra functionallity needed by Goovi.
  *
  * @author Kristofer Cassel
  * @see callin.Connection
  */
public class AmosInterface extends Connection
{

private TypeBrowser typeBrowser;

// to avoid doing import_db twice on the same DB
private Vector imported = new Vector();

/**
 * Constructor that creates an AmosInterface object
 *
 * @param tb The typebrowser that this AmosInterface belongs to.
 * @param dbName The name of the AMOS server to connect to.
 */
public AmosInterface(TypeBrowser tb, String dbName) throws AmosException
{
  super(dbName);
  typeBrowser = tb;
  callFunction("setup_mdb");
}

/**
 * Call-through function overrides Connection#execute
 * Adds a semicolon to the statement if not present.
 * Adds the statement text to the AmosConsole. While performing the
 * query the cursor is changed into a wait cursor.
 *
 * @param stmt The statement to execute, possibly without ending semicolon.
 * @see callin.Connection#execute
 * @see Goovi.AmosConsole
 */
public Scan execute(String stmt) throws AmosException
{
  try
  {
    if (stmt == null || stmt.length()==0) return null;
    Tools.changeCursor(new Cursor(Cursor.WAIT_CURSOR), typeBrowser);
    if (stmt.charAt(stmt.length()-1) != ';') stmt += ";";
    if (typeBrowser != null)
    {
      typeBrowser.getAmosConsole().addText(stmt + "\n");
    }
    Scan scan = super.execute(stmt);
    Tools.changeCursor(Cursor.getDefaultCursor(), typeBrowser);
    return scan;
  }
  catch(AmosException e)
  {
    Tools.changeCursor(Cursor.getDefaultCursor(), typeBrowser);
    throw e;
  }
}

/**
 * Function for creating a derived type
 *
 * @param superTypeList List of form <supertype> <variable>, <supertype> <variable>, ...
 * @param name          Name of the derived type to be created.
 * @param whereClause   The where-clause of the derived type to be created.
 * @return              The oid of the created derived type.
 * @exception Thrown if the creation failed.
 */
public Oid createDerivedType(String superTypeList, String name, String whereClause)
    throws AmosException
{
    String stmt = "create derived type "+name+" subtype of "+superTypeList;
    stmt += " where " + whereClause;
    Scan theScan = execute(stmt);
    Tuple tp     = theScan.getRow();
    theScan.closeScan();
    return tp.getOidElem(0);
}

/**
 * Function for creating a type
 *
 * @param supertypes    A String array containing the names of the supertypes as strings.
 * @param typename      Name of the type to be created.
 * @return              The oid of the created type.
 * @exception           Thrown if the creation failed.
 * @see Goovi.StringVector
 */
public Oid createType(Object[] supertypes, String typename) throws AmosException
{
    String stmt = "create type "+typename;
    if (supertypes != null && supertypes.length > 0)
    {
      stmt += " subtype of " + Tools. makeCommalist(supertypes);
    }
    Scan theScan = execute(stmt);
    Tuple tp     = theScan.getRow();
    theScan.closeScan();
    return tp.getOidElem(0);
}

/**
  * Function for deleting a list of objects.
  *
  * @param nodes         An array of AmosNodes corresponding to the objects to be deleted.
  * @exception           Thrown if the deletion failed.
  * @see callin.Connection#deleteObject
  */
public void delete(JCOutlinerNode[] nodes) throws Exception
{
  for (int i=0; i<nodes.length; i++)
  {
    AmosNode nd = (AmosNode)(nodes[i]);
    if (nd.getOid() != null)
    {
      deleteObject(nd.getOid());
    }
  }
}

/**
  * Function for importing types. The database is imported if
  * necesarry.
  *
  * @param typeNames  A vector with the name of the types as strings.
  * @param dbName     The name of the database to import the types from.
  * @exception        Thrown if the importation failed.
  * @see callin.Connection#delete
  */
public void importTypes(StringVector typeNames, String dbName) throws Exception
{
  importInternal(typeNames, dbName, "type");
}

/**
  * Function for importing functions. The database is imported if
  * necessary.
  *
  * @param typeNames  A vector with the name of the functions as strings.
  * @param dbName     The name of the database to import the functions from.
  * @exception        Thrown if the importation failed.
  */
public void importFunctions(StringVector names, String dbName) throws Exception
{
  importInternal(names, dbName, "func");
}

private String importdb(String str)
{
  String importdb = "";
  if (!imported.contains(str))
  {
      importdb = "import_db(\""+str+"\");";
      imported.addElement(str);
  }
  return importdb;
}

private void importInternal(StringVector names, String dbName, String importCommand)
  throws Exception
{
  if (names == null || names.isEmpty()) return;
  String stmt = importdb(dbName);
  for (int i=0; i < names.size(); i++)
  {
    stmt += "import_"+importCommand+"(\""+names.at(i)+"\",\""+dbName+"\");";
  }
  execute(stmt);
}

}// end AmosInterface