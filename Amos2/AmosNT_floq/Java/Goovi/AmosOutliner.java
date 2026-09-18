package Goovi;

import java.awt.*;
import java.util.*;
import java.awt.event.*;
import callin.*;
import jclass.bwt.*;
import java.awt.datatransfer.*;
import com.borland.jbcl.control.*;
import javax.swing.*;

/**
  * Class for displaying a tree or table structure
  * of AmosNodes most often representing a database scan.
  * Each AmosOutliner remembers which typebrowser window it was started from,
  * especially important when executing Amos II Functions. (The AmosInterface
  * instance is needed). If the scan displayed in the outliner is streamed.
  * This is remembered with a boolean attribute and the scan is saved with
  * a scan attribute.
  *
  * @author Kristofer Cassel
  */
public class AmosOutliner extends JPanel {

private TypeBrowser typeBrowser;
private Scan scan;
private MyOutliner outliner;
private boolean streamed      = false;
private boolean typeHierarchy = false;
private NodeCash nodeCash;

/**
 * Creates an unstreamed AmosOutliner object from a typebrowser
 * object.
 *
 * @param tb   The typebrowser that this AmosOutliner originated from.
 */
public AmosOutliner(TypeBrowser tb)
{
  super();
  init(tb, false);
}

/**
 * Creates an AmosOutliner object from a typebrowser
 * object and a boolean for the streaming property.
 *
 * @param tb          The typebrowser that this AmosOutliner originated from.
 * @param isStreamed  A boolean to set if this AmosOutliner should be streamed.
 */
public AmosOutliner(TypeBrowser tb, boolean isStreamed)
{
  super();
  init(tb, isStreamed);
}

/**
 *   creates an unstreamed AmosOutliner object from a typebrowser
 * object and a String array of column headings.
 *
 * @param tb          The typebrowser that this AmosOutliner originated from.
 * @param columns     A String array of column headings.
 */
public AmosOutliner(TypeBrowser tb, String[] columns)
{
  super();
  init(tb, false);
  setHeading(columns);
}

/**
 * Creates an AmosOutliner object from a typebrowser
 * object and a String for the first column heading. The streaming property
 * is set with a boolean parameter.
 *
 * @param tb          The typebrowser that this AmosOutliner originated from.
 * @param isStreamed  A boolean to set if this AmosOutliner should be streamed.
 * @param column      A String to represent first column heading.
 */
public AmosOutliner(TypeBrowser tb, boolean isStreamed, String column)
{
  super();
  init(tb, isStreamed);
  setHeading(column);
}

/**
 * Creates an unstreamed AmosOutliner object from a typebrowser
 * object and a String for the first column.
 *
 * @param tb          The typebrowser that this AmosOutliner originated from.
 * @param column      A String to represent first column heading.
 */
public AmosOutliner(TypeBrowser tb, String column)
{
  this(tb, false, column);
}

/**
 * Creates an AmosOutliner object to display
 * a certain exception.
 *
 * @param tb          The typebrowser that this AmosOutliner originated from.
 * @param err         The exception that occurred.
 */
public AmosOutliner(TypeBrowser tb, Exception err)
{
  super();
  init(tb, false);
  makeErrorIcon(err);
}

// master initializer
private final void init(TypeBrowser tb, boolean isStreamed)
{
    try
    {
      outliner = new MyOutliner(new AmosTree());
      typeBrowser = tb;

      jbInit();

      streamed = isStreamed;
      if (streamed) this.add(buttonPanel, BorderLayout.SOUTH);
      nodeCash = new NodeCash();
    }
    catch(Exception err)
    {
      makeErrorIcon(err);
    }
}

  JPopupMenu popmenu           = new JPopupMenu();
  MyMenuItem expandAllMI       = new MyMenuItem();
  MyMenuItem collapseAllMI     = new MyMenuItem();
  MyMenuItem viewSubtreeMI     = new MyMenuItem();
  MyMenuItem viewWholetreeMI   = new MyMenuItem();
  MyMenuItem showTypesMI       = new MyMenuItem();
  MyMenuItem showOidsMI        = new MyMenuItem();
  GridLayout gridLayout1       = new GridLayout();
  MyMenuItem inspectMI         = new MyMenuItem();
  MyMenuItem inspectoMI        = new MyMenuItem();
  MyMenuItem deleteMI          = new MyMenuItem();
  MyMenuItem copyMI            = new MyMenuItem();
  MyMenuItem sortMI            = new MyMenuItem();
  MyMenuItem findMI            = new MyMenuItem();
  MyMenuItem showDatasourceMI  = new MyMenuItem();
  MyMenuItem connectMI         = new MyMenuItem();
  MyMenuItem clearCashMI       = new MyMenuItem();
  BorderLayout borderLayout1   = new BorderLayout();
  JPanel buttonPanel           = new JPanel();
  JButton fwdButton            = new JButton();

  private void jbInit() throws Exception
  {
    outliner.getOutliner().addKeyListener(new java.awt.event.KeyListener()
    {
      public void keyTyped(KeyEvent e) {}
      public void keyReleased(KeyEvent e) {}
      public void keyPressed(KeyEvent e)
      {
        outlinerKeyPressed(e);
      }
    });

    expandAllMI.setText("Expand all");
    expandAllMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        expandAll();
      }
    });

    inspectoMI.setText("Inspect as object");
    inspectoMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        inspectAsObject();
      }
    });

    showTypesMI.setText("Show/hide types");
    showTypesMI.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_T, java.awt.Event.CTRL_MASK));
    showTypesMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        toggleTypeColumn();
      }
    });

    showOidsMI.setText("Show/hide OIDs");
    showOidsMI.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_O, java.awt.Event.CTRL_MASK));
    showOidsMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        toggleOidsColumn();
      }
    });

    deleteMI.setText("Delete");
    // deleteMI.setIcon(new ImageIcon(TypeBrowser.class.getResource("delete.gif")));
    deleteMI.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_DELETE, 0));
    deleteMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        deleteChosen();
      }
    });

    copyMI.setText("Copy");
    copyMI.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_C, Event.CTRL_MASK));
    copyMI.setIcon(new ImageIcon(TypeBrowser.class.getResource("copy.gif")));
    copyMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        copyChosen();
      }
    });

    collapseAllMI.setText("Collapse all");
    collapseAllMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        collapseAll();
      }
    });

    connectMI.setText("Connect to");
    connectMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        connectChosen();
      }
    });

    findMI.setText("Find");
    findMI.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_F, Event.CTRL_MASK));
    findMI.setIcon(new ImageIcon(TypeBrowser.class.getResource("find.gif")));
    findMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        find();
      }
    });

    sortMI.setText("Sort");
    sortMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        sort();
      }
    });

    clearCashMI.setText("Clear cash");
    clearCashMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        nodeCash.clear();
      }
    });

    viewSubtreeMI.setText("Set as root");
    viewSubtreeMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        viewOnlySubTree();
      }
    });

    fwdButton.setText("Next");
    fwdButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
         if (scan != null) display(scan);
      }
    });

    inspectMI.setText("Inspect");
    inspectMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        inspectChosen();
      }
    });

    viewWholetreeMI.setText("View whole tree");
    viewWholetreeMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        viewEntireTree();
      }
    });

    this.setLayout(borderLayout1);

    showDatasourceMI.setText("Show datasource");
    showDatasourceMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        showDatasource();
      }
    });
    this.add(outliner, BorderLayout.CENTER);
    buttonPanel.add(fwdButton, null);

    outliner.addItemListener( new JCOutlinerListener()
    {
      public void outlinerFolderStateChangeBegin(JCOutlinerEvent ev)
      {
        folderStateChangeBegin(ev);
      }
      public void outlinerFolderStateChangeEnd(JCOutlinerEvent ev) {}
      public void outlinerNodeSelectBegin(JCOutlinerEvent ev){}
      public void itemStateChanged(JCItemEvent ev) {}
      public void outlinerNodeSelectEnd(JCOutlinerEvent event)
      {
        nodeSelectEnd(event);
      }
    });

    outliner.getOutliner().addMouseListener( new MouseListener()
    {
      public void mouseClicked ( MouseEvent event ) {}
      public void mouseReleased( MouseEvent event ) {}
      public void mouseEntered ( MouseEvent event ) {}
      public void mouseExited  ( MouseEvent event ) {}
      public void mousePressed ( MouseEvent event )
      {
        mousePressedHandler(event);
      }
    });

    fwdButton.setEnabled( false );
    outliner.getOutliner().add(popmenu);

}// end JBInit

public void addToLowerPanel(Component c)
{
  buttonPanel.add(c);
}

public void setHeading(String str)
{
  outliner.setHeading(new String[] { str } );
}

private void setHeading(String[] ar)
{
  outliner.setHeading(ar);
}

/* typeColumn functions */

private static final String TP = "Type", OID = "OID#";

public void toggleTypeColumn()
{
  try {
   if (outliner.existsColumn(TP)) outliner.removeColumn(TP);
   else
   {
    outliner.addColumn(TP);
    displayTypes(getRoot());
   }
  }
  catch (Exception err) { Tools.showErrorDialog( this, err); }
}

private void displayTypes(AmosNode nd)
{
  String str = "** error **";
  try
  {
    str = nd.getType();
  }
  catch (Exception e) {}
  outliner.insertColumn(nd, str);

  Vector children = nd.getChildren();
  if (children != null)
  {
    for (int i=0; i<children.size(); i++)
    {
     displayTypes((AmosNode)(children.elementAt(i)));
    }
  }
}

/* oidColumn functions */

/**
 * Method to refresh the info columns (Oid and type column.)
 */
public void refreshInfoColumns()
{
  if (outliner.existsColumn(OID)) displayOids ( getRoot() );
  if (outliner.existsColumn(TP))  displayTypes( getRoot() );
}

private void toggleOidsColumn()
{
  try {
  if (outliner.existsColumn(OID)) outliner.removeColumn(OID);
  else
  {
    outliner.addColumn(OID);
    displayOids(getRoot());
  }
  } catch(Exception err) { Tools.showErrorDialog( this, err ); }
}

private void showDatasource()
{
  AmosNode nd = getSelectedNode();
  try {
          AmosOutliner tempOutline =
            new AmosOutliner(typeBrowser);
          tempOutline.display(typeBrowser.getAMOSInterface().callFunction("datasource", nd.getOid()));

          new AmosNodeChoser
            (typeBrowser, typeBrowser, "Goovi datasource of " + nd + " " + nd.getOid(),
            tempOutline);
  } catch (Exception err) { Tools.showErrorDialog(this, err, "Error when trying to display datasource of "+nd);}
}

private void displayOids(AmosNode nd)
{
  Object str = "-";
  try
  {
    str = (new Integer(nd.getOid().getID()));
  }
  catch(Exception e) {}
  outliner.insertColumn(nd, str);
  Vector children = nd.getChildren(); // static variable for performance
  if (children != null)
  {
    for (int i=0; i<children.size(); i++)
    {
     displayOids((AmosNode)(children.elementAt(i)));
    }
  }
}

private void find()
{
  String res = Tools.showInputDialog( this, "Enter name of type to find.");
  res = res.toUpperCase().trim();
  if ( res == null || res.equals("")) return;
  getAmosTree().makeAllNodesVisibleNamed(res);
  outliner.selectNodeNamed(res);
}

public void folderChanged(JCOutlinerNode nd)
{
  outliner.folderChanged(nd);
}

public void setTree(AmosTree tr)
{
  outliner.setRootNode(tr);
}

private void copyChosen()
{
    Clipboard cb = getToolkit().getSystemClipboard();
    Transferable contents =
      new StringSelection(getSelectedNode().getOid().toString());
    cb.setContents(contents, new ClipboardOwner()
    {
      // Notifies this object that it is no longer the owner of the contents of the clipboard.
      public void lostOwnership(Clipboard clipboard,
                                    Transferable contents)
                                    {}
    });
}

// generical delete functions for all Goovi AmosNodes...
private void deleteChosen()
{
  try
  {
    JCOutlinerNode[] ar = getSelectedNodes();
    if ( ar != null && ar.length > 0 )
    {
      String type = (((AmosNode)ar[0]).getType());
      if (type.equalsIgnoreCase("argument") || type.equalsIgnoreCase("result"))
      {
        // inside function inspector
        deleteSelectedNodes();
        outliner.deselectAll();
        return;
      }
      if ( surrogateInSelected(ar) ) 
      {
          if (Tools.showConfirmDialog(null,
          "Are you sure you want to\ndelete "+getSelectedNodes().length+" objects?"))
          {
            typeBrowser.getAMOSInterface().delete( ar );
            deleteSelectedNodes();
            outliner.deselectAll();
          }
      }// end if found
    }
  }// end try
  catch(Exception err)
  {
    Tools.showErrorDialog(this, err, "Error when trying to delete");
  }
}// end deleteChosen

private final boolean surrogateInSelected(JCOutlinerNode[] ar)
{
  for ( int i=0; i < ar.length; i++ )
  {
    if (((AmosNode)ar[i]).getOid() != null) return true;
  }
  return false;
}

public void viewEntireTree()
{
  if (typeBrowser != null)
  {
    typeBrowser.refresh("OBJECT");
  }
}

public void viewOnlySubTree()
{
  if (typeBrowser != null)
  {
    AmosNode nd = getSelectedNode();
    if (nd != null)
    {
      typeBrowser.refresh(""+nd);
    }
  }
}

public boolean isAnyNodeSelected()
{
  return (outliner.getSelectedNode() == null);
}

// call-through-function
public final JCOutlinerNode[] getSelectedNodes()
{
  return outliner.getSelectedNodes();
}

public Vector getSelectedNodesAsVector()
{
  JCOutlinerNode[] nodeArray = this.getSelectedNodes();
  Vector res = new Vector(nodeArray.length+5);
  if ( nodeArray == null ) return res;
  for (int i=0; i<nodeArray.length; i++)
  {
    res.addElement(nodeArray[i]);
  }
  return res;
}

public AmosNode getSelectedNode()
{
  return (AmosNode)(outliner.getSelectedNode());
}

public StringVector getSelectedNames()
{
  JCOutlinerNode[] nodeArray = this.getSelectedNodes();
  StringVector nodeNames = new StringVector();
  if ( nodeArray == null ) return nodeNames;
  for ( int i=0; i < nodeArray.length; i++ ) 
  {
    nodeNames.add( nodeArray[i].getLabelString() );
  }
  return nodeNames;
}

public int numberOfSelected()
{
  JCOutlinerNode[] ar = getSelectedNodes();
  if (ar == null) return 0; else return ar.length;
}

public void deleteSelectedNodes()
{
  JCOutlinerNode[] ar = getSelectedNodes();
  getAmosTree().deleteNodes(ar);
  for (int i=0; i<ar.length; i++) removeFromExpanded(ar[i]);
}

/* by some reason the shortcuts in the menu items doesn't work
  in this class so the next listener is necessary...*/
private void outlinerKeyPressed(KeyEvent e)
{
  int c = e.getKeyCode();
  if (c == KeyEvent.VK_DELETE) deleteChosen();
  if (e.isControlDown())
  {
    switch (c)
    {
      case KeyEvent.VK_T:
        toggleTypeColumn();
        break;
      case KeyEvent.VK_O:
        toggleOidsColumn();
        break;
      case KeyEvent.VK_C:
        copyChosen();
        break;
      case KeyEvent.VK_F:
        find();
        break;
    }
  }
}

private void mousePressedHandler(MouseEvent event)
{

      // What to do if user clicks a right mouse click
      //
      // event.getModifiers()    => returns the modifiers flag for this event
      // InputEvent.BUTTON3_MASK => the mouse button3 modifier constant.
      //
      if (event.getModifiers() == InputEvent.BUTTON3_MASK)
      {
        popmenu.removeAll();

        JCOutlinerNode[] ar = getSelectedNodes();
        boolean selected = (ar != null && ar.length>0);

        if (selected)
        {
          popmenu.add(inspectMI);
          popmenu.add(inspectoMI);

          if (Tools.isDatasource(((AmosNode)ar[0]).getType())) popmenu.add(connectMI);

          popmenu.addSeparator();
          popmenu.add(copyMI);
          popmenu.add(deleteMI);
          popmenu.addSeparator();
          popmenu.add( showDatasourceMI );
          popmenu.addSeparator();
          popmenu.add( viewSubtreeMI );
        }
        if (typeHierarchy && (!typeBrowser.getCurrentRoot().equalsIgnoreCase("object")))
        {
          popmenu.add(viewWholetreeMI);
        }
        if (selected) popmenu.addSeparator();

        popmenu.add( findMI );
        popmenu.addSeparator();
        popmenu.add( showTypesMI );
        popmenu.add( showOidsMI  );
        popmenu.addSeparator();
        popmenu.add( expandAllMI   );
        popmenu.add( collapseAllMI );
        popmenu.addSeparator();
        popmenu.add(sortMI);
        popmenu.add(clearCashMI);
        popmenu.show(event.getComponent(), event.getX(), event.getY());
    }
}

public void expandAll()
{
  expandAll(getAmosTree().getRoot());
}

public void expandAll(AmosNode nd)
{
  if (!nd.isFolder()) return;

  if (nd.getState() == BWTEnum.FOLDER_CLOSED)
  {
    nd.setState(BWTEnum.FOLDER_OPEN_ALL);
    expanded.add ( nd.getLabelString() );
  }
  Vector v = nd.getChildren();
  for (int i=0; i < v.size(); i++)  expandAll((AmosNode)v.elementAt(i));
  folderChanged(nd);
}

private void inspectAsObject()
{
    try
    {
      JCOutlinerNode[] nodeArray = getSelectedNodes();
      for (int i=0; i<nodeArray.length; i++)
      {
        new ObjectInspector(typeBrowser, ((AmosNode)nodeArray[i]).getOid());
      }
    }
    catch(Exception err)
    {
      Tools.showErrorDialog(this, err, "Error when inspecting node");
    }
}

private void inspectChosen()
{
    try
    {
      JCOutlinerNode[] nodeArray = getSelectedNodes();
      if (nodeArray == null) return;
      for (int i=0; i<nodeArray.length; i++)
      {
        Tools.inspectNode((AmosNode)nodeArray[i], typeBrowser);
      }
    }
    catch(Exception err)
    {
      Tools.showErrorDialog(this, err, "Error when inspecting node");
    }
}


private void connectChosen()
{
    AmosNode nd = getSelectedNode();
    try
    {
      if ( !Tools.isDatasource( nd.getType() ) )
      {
        Tools.showErrorDialog(this, "Not a datasource.");
        return;
      }
      String amosName = nd.getLabelString();
      TypeBrowser tb = TypeBrowser.getOpenBrowserNamed( amosName );
      if (tb != null)
      {
        tb.toFront();
        tb.requestFocus();
      }
      else
      {
        new TypeBrowser(amosName);
      }
    }
    catch(Exception e)
    {
      Tools.showErrorDialog(this, e, "Unable to connect to datasource "+nd+".");
    }
}

private void addToExpanded(String str)
{
  if (expanded == null) return;
  expanded.add( str.toUpperCase() );
}

public void addToExpanded(StringVector v)
{
  if (expanded == null) return;
  for(int i=0; i<v.size(); i++) addToExpanded(v.at(i));
}

public void removeFromExpanded(Object obj)
{
  if (expanded == null) return;
  expanded.remove(obj.toString());
}

public void collapseAll()
{
  Vector v = getAmosTree().getRoot().getChildren();
  while (v.size() == 1) v=((AmosNode)(v.elementAt(0))).getChildren();
  for (int i=0; i < v.size(); i++)
  {
    collapseAll( (AmosNode)(v.elementAt(i)));
  }
  expanded.clear();
}

private void collapseAll(AmosNode nd)
{
  if (!nd.isFolder()) return;

  nd.setState(BWTEnum.FOLDER_CLOSED);
  Vector v = nd.getChildren();
  for (int i=0; i < v.size(); i++) collapseAll((AmosNode)v.elementAt(i));
  nd.getOutliner().folderChanged(nd);
}

// getters
public AmosTree getAmosTree()
{
  return outliner.getAmosTree();
}

public AmosNode getRoot()
{
  return (AmosNode)(outliner.getRootNode());
}

public final MyOutliner getOutliner()
{
  return outliner;
}

public final NodeCash getNodeCash()
{
  return nodeCash;
}
// end getters ....


public void closeScan() throws AmosException
{
  if (scan != null) scan.closeScan();
}

/**
 * Method to close the scan and transfer the cashed AmosNodes into
 * another open AmosOutliner.
 */
public void closeAndSaveCashed(AmosOutliner dest) throws AmosException
{
  closeScan();
  saveCashed(this.getRoot(), dest);
}

private final void saveCashed(AmosNode nd, AmosOutliner dest)
{
  if ( nd.getOid() != null ) dest.getNodeCash().put(nd);
  Vector v = nd.getChildren();
  for (int i=0; v != null && i<v.size(); i++)
  {
    saveCashed((AmosNode)(v.elementAt(i)), dest);
  }
}

/**
 * Method to make a list separated by commas from the first level
 * of nodes in the tree structure.
 * @returns  A string with the nodenames separated by commas.
 */
public final String makeCommalist()
{
  return Tools.makeCommalist(getRoot().getChildren().toArray());
}

/**
 * Method to set the tree in this AmosOutliner to visualize
 * an Exception.
 * @param err  The exception to visualize
 */
public void makeErrorIcon(Exception err)
{
      AmosTree theTree = new AmosTree();
      setTree(theTree);

      String es = err.getMessage();

      if (es == null || es.equals("")) es = "Error";

      es = es.trim();
      int i;
      String iconType = "error", first;
      while ( (i = es.indexOf('\n')) != -1 )
      {
        first = es.substring(0,i).trim();
        es = es.substring(i+1).trim();
        theTree.addChild( new AmosNode( first, iconType ) );
        iconType = "noicon";
      }
      theTree.addChild(new AmosNode(es, iconType));
      // err.printStackTrace(); // remove later!!!
}

private void folderStateChangeBegin(JCOutlinerEvent ev)
{
    try
    {
      AmosNode nd      = (AmosNode) ev.getNode();

      if (nd.getChildren() == null || nd.getChildren().size() == 0)
      {
        Tools.inspectNode(nd, typeBrowser);
        return;
      }

      JCOutliner out = (JCOutliner)(ev.getSource());

      if (ev.getNewState() == BWTEnum.FOLDER_OPEN_ALL)
      {
        Vector v;
        AmosNode nnd;
        addToExpanded(nd.toString());
        if ((v = nd.getChildren()) != null)
        {
           for (int i=0; i<v.size(); i++)
           {
             nnd = (AmosNode)v.elementAt(i);
             Font f = nnd.getStyle().getFont();

             // suport for multiple inheritance , always makes all nodes with
             // same name visible...
             if (f != null) if (f.isBold() || f.isItalic())
             {
               AmosNode nod = (AmosNode)(out.getRootNode());
               ((AmosTree)nod).makeAllNodesVisibleNamed(nnd.getLabelString());
             }
            }// end for
        }// end if
      }// end if
      else if (ev.getNewState() == BWTEnum.FOLDER_CLOSED)
      {
        removeFromExpanded(nd);
      }
    }// end try
    catch(Exception err)
    {
      Tools.showErrorDialog(typeBrowser, err, "Error in statechangebegin");
    }
}// end folderStateChangeBegin

private void nodeSelectEnd(JCOutlinerEvent event)
{
  if (typeHierarchy) typeBrowser.nodeSelectEnd(event);

  try {
  AmosNode nd = (AmosNode) event.getNode();
  if (nd.getStyle().getFont().isItalic())
  {
    // deselect, find main node and show and select that one instead
    outliner.deselectNode(nd);
    String name = nd.getLabelString();
    getAmosTree().makeAllNodesVisibleNamed(name);
    outliner.selectNodeNamed(name);
  }

  } catch(Exception e) {} // never mind exceptions here
}

/**
  * Creates a tree with one visible NIL-node
  */
public void makeNilTree()
{
  AmosTree theTree = new AmosTree();
  setTree(theTree);
  theTree.addChild( new AmosNode( "NIL","NIL" ) );
}

private static final int MAX_SCAN_LENGTH = 100;
private static java.util.HashSet typenameTable;
private java.util.HashSet expanded;
private static com.objectspace.jgl.OrderedSet multInher;
private static final String HIERARCHYTAG = "*hierarchy*";

/**
 * Displays a tuple from the callin interface
 * @param tp  Tuple to be displayed.
 */
public void displayTuple(Tuple tp) throws Exception
{
  typeHierarchy = false;
  AmosTree theTree    = new AmosTree();
  if (tp != null) addTuple( theTree.getRoot(), tp );
  setTree( theTree );
}

/**
 * Sort the nodes in the tree.
 */
public void sort()
{
  outliner.sortByColumn(0, null);
}

/**
 * Displays an arbitary scan in the outliner.
 * @param theScan  The scan to be displayed
 */
public void display(Scan theScan)
{
try {

  outliner.removeColumnLabel(TP);
  outliner.removeColumnLabel(OID);

  if ( theScan == null || theScan.eos() )
  {
    makeNilTree();
    theScan.closeScan();
    return;
  }

  Tools.changeCursor(new Cursor(Cursor.WAIT_CURSOR), this);

  outliner.deselectAll();

  typeHierarchy  = false;
  AmosTree tree = new AmosTree();
  setTree(tree);

  if ( scan != null && !theScan.equals(scan) )
  {
    scan.closeScan(); // close old scan
  }
  int count = 0;

  while ( !theScan.eos() && (count < MAX_SCAN_LENGTH || !streamed) )
  {
    Tuple tp = theScan.getRow();
    theScan.nextRow();
    if ( theScan.eos() && count == 0 ) // scan consists of only one tuple...
    {
      // first remove tuple with one tuple inside...
      while( tp.getArity() == 1 && tp.isTuple( 0 ) ) tp = tp.getSeqElem(0);
      // then add the tuple directly to the root
      addTupleElements(getRoot(), tp, 0);
    }
    else
    {
      if ( tp.getArity() == 1 ) addElem(getRoot(), tp, 0);
      else addTuple(getRoot(), tp);
    }
    count ++;
  }
  ((AmosNode)(getRoot().getChildren().elementAt(0))).setState(BWTEnum.FOLDER_OPEN_ALL);

  if ( typeHierarchy )
  {
    Enumeration it = multInher.elements();
    while (it.hasMoreElements())
    {
      AmosNode nodeToChange = tree.findNode( it.nextElement().toString() );
      nodeToChange.makeMultInher();
      outliner.folderChanged( nodeToChange );
    }
  }
  if (count == MAX_SCAN_LENGTH && streamed)
  {
    // first call for this outliner
    scan = theScan;
    fwdButton.setEnabled(true);
  }
  else
  {
    theScan.closeScan();
    scan = null;
    fwdButton.setEnabled(false);
  }

  outliner.folderChanged(getRoot());
  }
  catch(Exception err)
  {
    makeErrorIcon(err);
  }
  finally
  {
    Tools.changeCursor(Cursor.getDefaultCursor(), this);
  }
}// end scanToTree

private final void addTuple(AmosNode n, Tuple tp) throws Exception
{
  AmosNode collectionNode;
  if ( typeHierarchy )
  // special AmosTree with parent as first element in sequence !
  {
    n.addNode( collectionNode = makeNodeInternalTypestruct(tp, 0) );
    addTupleElements( collectionNode, tp, 1 );
  }
  else
  {
    // anonymous placeholder for sequences in Amos
    n.addNode(collectionNode = new AmosNode("","collection", true));
    addTupleElements( collectionNode, tp, 0 );
  }
}// end addTuple

private final void addTupleElements(AmosNode nd, Tuple tp, int i) throws Exception
{
  for (int arity = tp.getArity(); i < arity; i++) addElem(nd, tp, i);
}

private final void addElem(AmosNode n, Tuple tp, int i) throws Exception
{
  if ( tp.isTuple(i) )
  {
    addTuple(n, tp.getSeqElem(i) );
  }
  else
  {
    AmosNode nn = makeNodeInternal( tp, i );
    if (nn != null) n.addNode(nn);
  }
}

public AmosNode makeNode(Tuple tp, int i) throws Exception
{
  typeHierarchy = false;
  return makeNodeInternal(tp, i);
}

private final AmosNode makeNodeInternalTypestruct(Tuple tp, int i) throws Exception
{
      AmosNode newNode;
      Oid      elemOid = tp.getOidElem(i);
      String   name    = elemOid.getName();

      if (typenameTable.contains(name))
      // multiple inheritance, real AmosTree is elsewhere
      {
        // cannot use cashed node when changing appearance!
        newNode = new AmosNode( elemOid, (i==0 && tp.getArity() > 1));
        newNode.makeStub();
        multInher.add( name );
      }
      else
      {
        typenameTable.add( name );
        newNode = nodeCash.get( elemOid, (i==0 && tp.getArity() > 1));
      }
      if (expanded.contains(name)) newNode.setState(BWTEnum.FOLDER_OPEN_ALL);
      return newNode;
}

private final AmosNode makeNodeInternal(Tuple tp, int i) throws Exception
{
  if (tp.isObject(i))
  {
    // performance critical code here ...
    return nodeCash.get(tp.getOidElem(i), false);
  }// end if object

  if ( tp.isInteger(i) )
  {
    return new AmosNode(""+tp.getIntElem(i),"integer");
  }
  if ( tp.isDouble(i) )
  {
    return new AmosNode(""+tp.getDoubleElem(i),"double");
  }
  if ( tp.isString(i) )
  {
    String theString = tp.getStringElem(i);
    if (theString.equalsIgnoreCase( HIERARCHYTAG ))
    {
      typeHierarchy = true;
      if (typenameTable == null) typenameTable   = new java.util.HashSet();
      else typenameTable.clear();
      if (multInher == null) multInher = new com.objectspace.jgl.OrderedSet();
      else multInher.clear();
      if (expanded == null)
      {
        expanded = new java.util.HashSet();
        expanded.add("USEROBJECT");
      }
      return null;
    }
    return new AmosNode( "\""+tp.getStringElem(i)+"\"", "charstring" );
  }
  else throw new GooviException( "strange tuple in addElem!" );
}
}// end class outliner
