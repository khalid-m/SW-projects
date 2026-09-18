package Goovi;

import jclass.bwt.*;
import java.awt.*;
import callin.*;
import java.util.*;

/**
  * Class for the AmosNode which is a graphical object corresponding to an Amos II object.
  * AmosNode class extends the JCOutlinerFolderNode class,
  * which means that AmosNode objects can be put in a JCOutliner-tree both as a parent node and as
  * a leaf node.
  * (Really a foldernode without any shortcut button.)
  * The AmosNode inherits an icon from the JCOutlinerFolderNode,
  * which in Goovi is used to determine the type. This is the same approach used
  * for files in most windowing operating systems. Another attribute inherited from the
  * JCOutlinerFolderNode is the label, which in it simplest form is a textstring
  * displayed immediately to the right of the icon. In windowing operating systems this is used for
  * the filename of the specific file.
  * In Goovi it is used for the result of the name function applied to the object or if the name
  * function is not defined the string #[OID nn] where nn is the oid number. This is the same approach
  * as in Jasmine [CF96].
  * The setting of a correct icon of an AmosNode is done by calling the static method getIcon in
  * the class IconHandler, which takes a type-name as a string and returns an object of type
  * java.awt.Image which can be set to the JCOutlinerNodeStyle-attribute with the methods setItemIcon,
  * setFolderOpenIcon an setFolderClosedIcon.
  *
  * <br><br><h2>
  * Attributes
  * </h2><br><br>
  *
  * AmosNode objects have three important attributes: The oid-reference is only
  * set if this AmosNode visualizes a surrogate Amos II object. The node-style
  * holds the style of this nodes appearance, specialized compared to the base-class
  * and types-name is cashed after either being supplied in the constructor or fetched
  * from the AMOS II-kernel.
  *
  * @author Kristofer Cassel
  */
public class AmosNode extends JCOutlinerFolderNode {

// attributes
private Oid                 oid;
private JCOutlinerNodeStyle style = new JCOutlinerNodeStyle();
private String              type;  // cashed for speed!

/**
 * Empty contructor for dummy nodes. Useful for invisible roots. *
 */
public AmosNode()
{
  this("","",false);
}

/**
 * Constructor that creates an AmosNode object from two strings.
 * This is used for special Goovi nodes which has no correspondance to
 * any Amos object. For example collection-nodes nil-nodes etc.
 *
 * @param name     The name of the node stated next to the icon.
 * @param typename The name of the type of the icon.
 */
public AmosNode(String name, String typename)
{
  super( name );
  type = typename;
  init();
}

/**
 * Constructor that creates an AmosNode object from two strings and
 * a boolean flag to make it a folder or not.
 * This is used for special Goovi nodes which has no correspondance to
 * any Amos object. For example collection-nodes nil-nodes etc.
 *
 * @param name     The name of the node stated next to the icon.
 * @param typename The name of the type of the icon.
 * @param isFolder boolean to determine if this node is a folder or a leaf.
 */
public AmosNode(String name, String typename, boolean isFolder)
{
  super( name );
  style.setShortcut(isFolder);
  type = typename;
  init();
}

/**
 * Constructor that creates an AmosNode object from an Amos oid and
 * a string to be put in the first column on the right side of the node.
 *
 * @param oid     The name of the node stated next to the icon.
 * @param column  The object to be put in the first column.
 */
public AmosNode(Oid theOid, Object column) throws AmosException
{
  super("");
  oid = theOid;
  type = theOid.getType().getName();

  // don't use addColumn here for performance reasons
  Vector v = new Vector();
  v.addElement(theOid.getName());
  v.addElement(column);
  this.setLabel(v);

  init();
}

/**
 * Constructor that creates an AmosNode object from an Amos oid.
 *
 * @param oid     The name of the node stated next to the icon.
 */
public AmosNode(Oid theOid) throws AmosException
{
  super(theOid.getName());
  oid = theOid;
  type = theOid.getTypename();
  this.setState( BWTEnum.FOLDER_CLOSED );
  init();
}

/**
 * Constructor that creates an AmosNode object from an Amos oid and
 * a string to be put in the first column on the right side of the node.
 *
 * @param theOid   The name of the node stated next to the icon.
 * @param typename The name of the type of the icon.
 */
public AmosNode(Oid theOid, boolean isFolder) throws AmosException
{
  super(theOid.getName());
  oid = theOid;
  type = theOid.getTypename();
  style.setShortcut( isFolder );
  this.setState( BWTEnum.FOLDER_CLOSED );
  init();
}

// common init code
private final void init()
{
    Image im = IconHandler.getIcon(type);
    style.setItemIcon        ( im );
    style.setFolderOpenIcon  ( im );
    style.setFolderClosedIcon( im );
    this.setStyle(style);
}
// end constructors

  // public methods

/**
 * Method to set the shortcut of this node. True means that it represents
 * a folder node and false means it is a leaf node.
 */
public void setToFolder(boolean isFolder)
{
  style.setShortcut(isFolder);
}

/**
 * Method to see if this node has children or not.
 *
 * @returns a boolean which is true only when the node has children.
 */
public boolean isFolder() { return this.getChildren() != null ;  }

/**
 * Method to make the node a stub node. Used in display
 * of multiple inheritance. The stub nodes are all parents
 * after the first one which is the main node.
 */
public void makeStub()
{
  style.setFont(new Font( "Dialog", Font.ITALIC, 12 ));
}

/**
 * Method to make the node a main node. Used in display
 * of multiple inheritance. The main node is the first
 * parent node.
 */
public void makeMultInher()
{
  style.setFont(new Font( "Dialog",Font.BOLD, 12 ));
}

/**
 * Method to retrieve the oid of the corresponding Amos object.
 *
 * @returns the oid of the corresponding Amos object.
 */
public final Oid getOid()
{
  return oid;
}

/**
 * Method to retrieve the name of the type of this AmosNode as a string.
 * Either an Amos type or a Goovi AmosNode type such as collection, nil etc.
 *
 * @returns the name of the type as a string
 */
public final String getType()
{
  return type;
}

/**
 * Method to retrieve the label of this AmosNode. The string stated
 * next to the icon.
 *
 * @returns the label as a string
 */
public final String getLabelString()
{
  Object obj = getLabel();
  if (obj instanceof String) return obj.toString();
  return ((Vector)obj).elementAt(0).toString();
}

/**
 * Method to retrieve the label of this AmosNode. The string stated
 * next to the icon.
 *
 * @returns the label as a string
 */
public final String toString()
{
  return getLabelString();
}

/**
 * Method to add a column to this node.
 *
 * @param obj The object to be put in the new column.
 */
public final void addColumn(Object obj)
{
    Object label = getLabel();
    Vector newLabel;
    if (label instanceof Vector)
    {
      newLabel = (Vector)label;
    }
    else
    {
      newLabel = new Vector();
      setLabel(newLabel);
      newLabel.add(label);
    }
    newLabel.add(obj);
}

}// end class AmosNode
