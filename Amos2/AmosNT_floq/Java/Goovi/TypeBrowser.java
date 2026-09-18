package Goovi;

import java.awt.*;
import java.util.*;
import java.awt.event.*;
import callin.*;
import jclass.bwt.*;
import com.borland.jbcl.control.*;
import com.borland.jbcl.model.*;
import javax.swing.*;
import javax.swing.event.*;

/**
  * Class for a Goovi typebrowser window.
  *
  * @author Kristofer Cassel
  */
public class TypeBrowser extends JFrame {

// TypeBrowsers attributes declared by me ...
private AmosInterface   conn;
private String          amosID;
private static Vector   openBrowsers  = new Vector();
private static String   sourceDB = "";
private static StringVector copiedTypes, copiedFunctions;

private String          currentRoot = "object";
private AmosConsole amosConsole;
private static final int HEIGHT = 450;
private static final int WIDTH  = 710;
public static boolean callout;
private static boolean initAmosDone;
private Vector          inspectors = new Vector();
private String[] tabCurrentType = { "", "", "", "" };
private AmosOutliner
        outliner, datasourceOutliner;
private FunctionsOutliner functionsOutliner;
private InstancesOutliner instancesOutliner;
private QueryPanel queryPanel;
// ... end my attributes

  // GUI objects ...
  JMenuBar mBar                     = new JMenuBar();
  JMenu fileMI                      = new JMenu();
  JMenu editMenu                    = new JMenu();
  JMenu viewMenu                    = new JMenu();
  MyMenuItem expandAllMI            = new MyMenuItem();
  MyMenuItem collapseAllMI          = new MyMenuItem();
  MyMenuItem showConsoleMI          = new MyMenuItem();
  MyMenuItem closeMI                = new MyMenuItem();
  JMenu     newMI                   = new JMenu();
  MyMenuItem saveMI                 = new MyMenuItem();
  MyMenuItem saveAsMI               = new MyMenuItem();
  MyMenuItem newTypeMI              = new MyMenuItem();
  MyMenuItem newObjMI               = new MyMenuItem();
  MyMenuItem registerMI             = new MyMenuItem();
  MyMenuItem newDerivedTypeMI       = new MyMenuItem();

  GridLayout gridLayout2            = new GridLayout();
  MyMenuItem newIntTypeMI           = new MyMenuItem();
  JCSplitterWindow mainSplitter     = new JCSplitterWindow( BWTEnum.HORIZONTAL  );

  JMenu helpMenu                    = new JMenu();
  MyMenuItem helpMI                 = new MyMenuItem();
  MyMenuItem aboutGooviMI           = new MyMenuItem();
  MyMenuItem newFunctionMI          = new MyMenuItem();
  MyMenuItem importMI               = new MyMenuItem();
  MyMenuItem exportMI               = new MyMenuItem();
  MyMenuItem findServersMI          = new MyMenuItem();
  MyMenuItem newqueryPanelMI        = new MyMenuItem();
  JTabbedPane jTabbedPane           = new JTabbedPane();
  JCheckBoxMenuItem showInternalMI  = new JCheckBoxMenuItem();


  MyMenuItem menuItem2 = new MyMenuItem();
// ... end GUI objects

public TypeBrowser() { super(); }  // parameterless for JBuilder-designer

public TypeBrowser(String dbName) throws Exception
{
  try
  {
    outliner            = new AmosOutliner      ( this );
    instancesOutliner   = new InstancesOutliner ( this );
    functionsOutliner   = new FunctionsOutliner ( this );
    queryPanel          = new QueryPanel        ( this );

    amosID = dbName;
    amosConsole         = new AmosConsole     ( this );
    conn                = new AmosInterface   ( this, amosID );
    queryPanel          = new QueryPanel      ( this );

    datasourceOutliner = new AmosOutliner ( this , "Mediators");

    enableEvents(AWTEvent.WINDOW_EVENT_MASK);
    jbInit();

    refresh("object");
    // important to do refresh, which calls JNI-interface to C-code
    // before launching GUI-threads with this.pack().

    openBrowsers.addElement(this);
    int numberOfBrowsers = openBrowsers.size();
    this.setLocation( numberOfBrowsers*50, numberOfBrowsers*50 );

    this.pack();
    this.setSize(new Dimension( WIDTH, HEIGHT ) );
    this.setVisible(true);
   }
   catch(Exception err)
   {
      Tools.showErrorDialog(this, err, "Failed to open typebrowser!");
   }
  }

  //Component initialization from JBuilders GUI-builder
  private void jbInit() throws Exception
  {
    this.getContentPane().setLayout(gridLayout2);
    gridLayout2.setColumns(1);

    newIntTypeMI.setText("Integration type");
    newObjMI.setText("Object");
    helpMenu.setText("Help");
    helpMenu.setMnemonic('H');

    helpMI.setText("Help");
    helpMI.setIcon(new ImageIcon(TypeBrowser.class.getResource("help.gif")));
    helpMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        helpMI_actionPerformed(e);
      }
    });
    aboutGooviMI.setText("About GOOVI");
    aboutGooviMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e) { about(); }
    });
    newFunctionMI.setText("Function");

    importMI.setText("Import");
    importMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        importMI_actionPerformed(e);
      }
    });

    newqueryPanelMI.setText("Query Window");
    newqueryPanelMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        newQueryWindow();
      }
    });

    findServersMI.setText("Get servers");
    findServersMI.setIcon(new ImageIcon(IconHandler.getIcon("AMOS")));
    findServersMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        findServersChosen();
      }
    });

    exportMI.setText("Export");
    exportMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        exportMI_actionPerformed(e);
      }
    });

    newObjMI.setIcon(new ImageIcon(IconHandler.getIcon("%other%")));
    newObjMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        newObjMI_actionPerformed(e);
      }
    });

    newFunctionMI.setIcon(new ImageIcon(IconHandler.getIcon("FUNCTION")));
    newFunctionMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        newFunctionMI_actionPerformed(e);
      }
    });

    newIntTypeMI.setIcon(new ImageIcon(IconHandler.getIcon("IUT")));
    newIntTypeMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        newIntTypeChosen(e);
      }
    });

    newDerivedTypeMI.setIcon(new ImageIcon(IconHandler.getIcon("DERIVEDTYPE")));
    newDerivedTypeMI.setText("Derived type");
    newDerivedTypeMI.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        newDerivedTypeChosen(e);
      }
    });

    jTabbedPane.addChangeListener(new javax.swing.event.ChangeListener()
    {
      public void stateChanged(javax.swing.event.ChangeEvent e)
      {
        selectionChanged(e);      
      }
    });

    showInternalMI.setText("Show internal types");
    showInternalMI.setIcon(new ImageIcon(IconHandler.getIcon("NOICON")));
    showInternalMI.addItemListener(new java.awt.event.ItemListener()
    {
      public void itemStateChanged(ItemEvent e)
      {
        refreshTypeTree();
      }
    });

    menuItem2.setText("Register");
    menuItem2.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        registerChosen();
      }
    });

    newMI.add(newTypeMI);
    newMI.add(newDerivedTypeMI);
    newMI.add(newIntTypeMI);
    newMI.add(newFunctionMI);
    newMI.add(newObjMI);
    newMI.add(newqueryPanelMI);

    fileMI.setText("File");
    fileMI.setMnemonic('F');

    editMenu.setText("Edit");
    editMenu.setMnemonic('E');

    viewMenu.setText("View");
    viewMenu.setMnemonic('V');

    expandAllMI.setText("Expand all");
    expandAllMI.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(ActionEvent e) {
        outliner.expandAll();
      }
    });
    collapseAllMI.setText("Collapse all");
    collapseAllMI.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(ActionEvent e) {
        outliner.collapseAll();
      }
    });

    showConsoleMI.setText("Amos console");
    showConsoleMI.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(ActionEvent e) {
        amosConsole.makeVisible ();
      }
    });

    closeMI.setText("Close");
    closeMI.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_W, java.awt.Event.CTRL_MASK));
    closeMI.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(ActionEvent e) { closeBrowser(); }
    });

    newMI.setText("New");
    newMI.setIcon(new ImageIcon(TypeBrowser.class.getResource("new.gif")));

    saveMI.setText("Save");
    saveMI.setIcon(new ImageIcon(TypeBrowser.class.getResource("save.gif")));
    saveMI.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_S, java.awt.Event.CTRL_MASK));
    saveMI.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(ActionEvent e) { saveChosen(); }
    });

    saveAsMI.setText("Save As");
    saveAsMI.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(ActionEvent e) { saveAsChosen(); }
    });

    newTypeMI.setIcon(new ImageIcon(IconHandler.getIcon("STOREDTYPE")));
    newTypeMI.setText("Type");
    newTypeMI.addActionListener( new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        newTypeChosen();
      }
    });

    registerMI.setText("Refresh");
    registerMI.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_R, java.awt.Event.CTRL_MASK));
    registerMI.addActionListener( new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        refresh();
      }
    });

    this.setJMenuBar(mBar);

    mBar.add(fileMI);
    mBar.add(editMenu);
    mBar.add(viewMenu);
    mBar.add(newMI);
    mBar.add(helpMenu);

    editMenu.add(expandAllMI);
    editMenu.add(collapseAllMI);
    viewMenu.add(showConsoleMI);
    viewMenu.addSeparator();
    viewMenu.add(registerMI);
    viewMenu.addSeparator();
    viewMenu.add(showInternalMI);

    fileMI.add(newMI);
    fileMI.addSeparator();
    fileMI.add(saveMI);
    fileMI.add(saveAsMI);
    fileMI.addSeparator();
    fileMI.add(importMI);
    fileMI.add(exportMI);
    fileMI.addSeparator();
    fileMI.add(findServersMI);
    fileMI.add(menuItem2);
    fileMI.addSeparator();
    fileMI.add(closeMI);

    this.getContentPane().add(mainSplitter, null);
    outliner.getOutliner().setPreferredSize( WIDTH*39/100, HEIGHT );
    mainSplitter.add(outliner    , null);
    mainSplitter.add(jTabbedPane, null);

    jTabbedPane.add(queryPanel,         "Queries"     );
    jTabbedPane.add(instancesOutliner,  "Instances"   );
    jTabbedPane.add(functionsOutliner,    "Methods"     );
    jTabbedPane.add(datasourceOutliner, "Mediators" );
    jTabbedPane.setIconAt(1, new ImageIcon(IconHandler.getIcon("%other%")));
    jTabbedPane.setIconAt(2, new ImageIcon(IconHandler.getIcon("FUNCTION")));
    jTabbedPane.setIconAt(3, new ImageIcon(IconHandler.getIcon("AMOS")));
    jTabbedPane.setSelectedIndex(0);

    helpMenu.add(helpMI);
    helpMenu.add(aboutGooviMI);
}// ... end jbInit

public String toString()
{
  return amosID;
}

/**
  * Checks if there is a type browser open for the Amos server
  * with the specified name.
  *
  * @param name  The name of the Amos server
  * @returns     A boolean that is true if it exists an open type browser
  */
public static TypeBrowser getOpenBrowserNamed(String name)
{
  for (int i=0; i < openBrowsers.size(); i++)
  {
    TypeBrowser tb = (TypeBrowser)openBrowsers.elementAt(i);
    if (tb.toString().equalsIgnoreCase(name)) return tb;
  }
  return null;
}

/**
  * Close all inspectors and scans that this browser openened.
  * Also disconnect the connection to Amos and dispose
  * the Amos console window.
  */
public void closeBrowser()
{
  try {

    closeInspectors();
    queryPanel.closeScan();
    instancesOutliner.closeScan();
    functionsOutliner.closeScan();
    datasourceOutliner.closeScan();
    amosConsole.dispose();
    conn.disconnect();
    if (openBrowsers.size() == 1 && !callout) System.exit(0);
  }
    catch(Exception err)
    {
        if (!Tools.showConfirmDialog(this, "Failed to disconnect.\nClose window anyway?"))
          return;
    }
    finally
    {
      dispose();
      openBrowsers.removeElement( this );
    }
}
// getters ...

public AmosOutliner getTheOutliner()       { return outliner; }

public AmosInterface getAMOSInterface()    { return conn; }

public String getCurrentRoot()             { return currentRoot; }

public AmosConsole getAmosConsole()        { return amosConsole; }

public AmosOutliner getInstancesOutliner() { return instancesOutliner; }

public AmosOutliner getFunctionsOutliner() { return functionsOutliner; }

public AmosOutliner getResultsOutliner()   { return queryPanel.getTheOutliner(); }

// ... end getters

public boolean existInspector(Oid oid)
{
  try
  {
    Oid inspectorOid;
    for (int i=0; i<inspectors.size(); i++)
    {
      inspectorOid = ((Inspector)inspectors.elementAt(i)).getOid();
      if (inspectorOid != null)
      {
        if (inspectorOid.getID() == oid.getID()) return true;
      }
    }
    return false;
  }
  catch(Exception err)
  {
    Tools.showErrorDialog(this, err, "Error in TypeBrowser.existInspector");
    return false;
  }
}

public Inspector getInspector(Oid oid)
{
  try
  {
    Oid inspectorOid;
    for (int i=0; i<inspectors.size(); i++)
    {
      Inspector insp = (Inspector)(inspectors.elementAt(i));
      inspectorOid = insp.getOid();
      if (inspectorOid != null)
      {
        if (inspectorOid.getID() == oid.getID()) return insp;
      }
    }
    return null;
  }
  catch(Exception err)
  {
    Tools.showErrorDialog(this, err, "Error in TypeBrowser.existInspector");
    return null;
  }
}

public void registerInspector(Inspector f)
{
  inspectors.addElement(f);
}

public void removeInspector(Inspector f)
{
  inspectors.removeElement(f);
}

public void closeInspectors()
{
  for (int i=0; i<inspectors.size(); i++)
  {
    ((Inspector)inspectors.elementAt(i)).dispose();
  }
}

private void about()
{
  Tools.showMessageDialog(this,
    "GOOVI was programmed by\nKristofer Cassel\nstoffe@usa.com\nEDSLAB, IDA\nLinkoping University");
}

private void newQueryWindow()
{
  new QueryWindow( this );
}

public void refresh()
{
  try
  {
    refreshTypeTree();
    refreshDatasources();
  }
  catch(Exception e) { Tools.showErrorDialog(this, e, "Failed to refresh in typebrowser."); }
}

private void refreshTypeTree()
{
  refresh(currentRoot);
}

public void refresh(String rootName)
{
  try
  {
      currentRoot = rootName;

      outliner.display(conn.callFunction(
              "get_type_structure"+(showInternalMI.getState() ? "2" : ""),
              rootName));
      amosID = conn.callStringFunction( "this_AmosID" );
      if ( amosID == null || amosID.equalsIgnoreCase("NIL") )
      {
        amosID = ( "*UNNAMED LOCAL*" );
      }
      setTitle( "GOOVI Typebrowser:"+amosID);
      outliner.refreshInfoColumns();
      instancesOutliner.refresh();
      functionsOutliner.refresh();
  }
  catch (Exception err)
  {
    outliner = new AmosOutliner(this, err);
  }
}

private void newDerivedTypeChosen(ActionEvent e)
{
    if (outliner.numberOfSelected() == 0)
    {
      Tools.showMessageDialog(this,
      "You must mark at least one type in the typetree as supertype.");
      return;
    }
    new CreateDerivedType(this);
}// end newDerivedTypeChosen



private boolean checkNoSelected( int i )
{
    if ( outliner.numberOfSelected() != i )
    {
      Tools.showMessageDialog(this,
      "You must mark exactly " + i + " types in the typetree to perform this operation!");
      return false;
    }
    else return true;
}

private void newIntTypeChosen(ActionEvent e)
{
    if (!checkNoSelected(2)) return;
    new CreateIntType(this);
}// end newIntTypeChosen


private void newFunctionMI_actionPerformed(ActionEvent e)
{
    try
    {
      StringVector v =  outliner.getSelectedNames();
      if ( v == null || v.size() == 0 ) return;
      new FunctionInspector( this, v );
    }
    catch (Exception err)
    {
      Tools.showErrorDialog(this, err, "Error when opening functioncreator");
    }
}

private void newObjMI_actionPerformed(ActionEvent e)
{
    if ( !checkNoSelected( 1 ) ) return;
    try
    {
      Oid oid = conn.createObject( outliner.getSelectedNode().getOid() );
      new ObjectInspector(this, oid);
    }
    catch (Exception err)
    {
       Tools.showErrorDialog(this, err, "Error when creating instance");
    }
}

private void exportMI_actionPerformed(ActionEvent e)
{
  try
  {
    String msg = "";
    StringVector v = outliner.getSelectedNames();
    if ( v != null && v.size() > 0 )
    {
      sourceDB = this.toString();
      copiedTypes = v;
      msg += "Types ready for export: (Old exportations will be replaced):\n"+v+"\n";

    }
    v = new StringVector();
    Vector nodeArray = queryPanel.getSelectedNodes();
    if ( nodeArray != null )
    {
      for ( int i=0; i < nodeArray.size(); i++ )
      {
        AmosNode nd = (AmosNode)(nodeArray.elementAt(i));
        if ( nd.getType().equalsIgnoreCase("FUNCTION") )
        {
          String kind = conn.callStringFunction("kindoffunction", nd.getOid() );
          if (kind != null && !kind.equalsIgnoreCase("generic") &&
            !kind.equalsIgnoreCase("overloaded"))
          {
             v.add(nd.getLabelString());
          }// end if
        }// end if
      }// end for
    }// end if
    if ( v.size() > 0 )
    {
        copiedFunctions = v;
        msg += "\nFunctions ready for export: (Old exportations will be replaced):\n"+v+"\n";
        sourceDB = this.toString();
    }

    Tools.showMessageDialog( this, msg );
  }
  catch (Exception err)
  {
     Tools.showErrorDialog(this, err, "Failed to copy!");
  }
}

private void findServersChosen()
{
  try
  {
    conn.callFunction("amos_servers");
    refreshDatasources();
    Tools.showMessageDialog(this, "Amos servers information \n found and updated.");
  }
  catch (Exception err) { Tools.showErrorDialog(this, err, "No nameserver found."); }
}

void importMI_actionPerformed(ActionEvent e)
{
   try
    {
      if ( sourceDB.equals("") || sourceDB.equals( this.toString() ) ) return;

      if (copiedTypes != null )
        conn.importTypes    ( copiedTypes,     sourceDB );
      if (copiedFunctions != null )
        conn.importFunctions( copiedFunctions, sourceDB );
      refresh();
      String msg = "";
      if (copiedTypes != null)     msg += "Imported types:\n"       + copiedTypes;
      if (copiedFunctions != null) msg += "\n\nImported functions:\n" + copiedFunctions;
      msg += "\nFrom "+sourceDB;
      Tools.showMessageDialog( this, msg );
      sourceDB = "";
      copiedTypes     = null;
      copiedFunctions = null;
    }
    catch (Exception err) { Tools.showErrorDialog(this, err, "Failed to import types"); }
}

void helpMI_actionPerformed(ActionEvent e) {}

public void nodeSelectEnd(JCOutlinerEvent ev)
{
  refreshCurrentTabIfTypeChanged();
}

// *** JCOutlinerListener interface methods end ****

private void refreshCurrentTabIfTypeChanged()
{
  int index = jTabbedPane.getSelectedIndex();
  if (index == -1) return;
  AmosNode nd = outliner.getSelectedNode();
  if (nd == null) return;
  if (!tabCurrentType[index].equalsIgnoreCase(nd.getLabelString()))
  {
    forceRefreshTab(index, nd);
  }
}

private void forceRefreshCurrentTab()
{
  AmosNode nd = outliner.getSelectedNode();
  int index = jTabbedPane.getSelectedIndex();
  forceRefreshTab(index, nd);
}

private void forceRefreshTab(int index, AmosNode nd)
{
  Oid oid = null;
  if (nd != null)
  {
    oid = nd.getOid();
    tabCurrentType[index] = nd.getLabelString();
  }
  String tab = jTabbedPane.getTitleAt(index);
  if (tab.equalsIgnoreCase("instances"))    instancesOutliner.refresh(oid);
  else if (tab.equalsIgnoreCase("methods")) functionsOutliner.refresh(oid);
}

/**
  * Overriden to call closeBrowser if the user closes the window.
  */
protected void processWindowEvent(WindowEvent e)
{
    super.processWindowEvent(e);
    if(e.getID() == WindowEvent.WINDOW_CLOSING)
    {
      closeBrowser();
    }
}

public void selectionChanged(javax.swing.event.ChangeEvent e)
{
  try
  {
    refreshCurrentTabIfTypeChanged();
  }
  catch (Exception err)
  {
    Tools.showErrorDialog(this, err, "Error when trying to change tab!");
  }
}


private void refreshDatasources() throws AmosException
{
  datasourceOutliner.display(conn.execute("select x from datasource x"));
  datasourceOutliner.toggleTypeColumn();
}


void registerChosen()
{
  try
  {
    String answ = Tools.showInputDialog(this, "Register this server with name:");
    if (answ == null || answ.equals("")) return;
    conn.callFunction("register", answ);
    amosID = answ;
    setTitle( "GOOVI TypeBrowser:"+amosID);
  }
  catch (Exception e) { Tools.showErrorDialog(this, e, "Failed to register this server"); }
}

private void newTypeChosen()
{
    try
    {
      StringVector v = outliner.getSelectedNames();
      String result = Tools.showInputDialog(this, "Enter name of new type "+(v.size() != 0 ? "with supertypes:\n"+v+":" : ":"));
      if (result != null) if (!result.equals(""))
      {
        Oid newNode = conn.createType(v.toArray(), result.trim().toUpperCase() );
        if (v != null) outliner.addToExpanded(v);
        refresh();
      }
    }
    catch (Exception err)
    {
      Tools.showErrorDialog(this, err, "Failed in create type");
    }
}// end NewType

private String currFilename = null;

private void saveChosen()
{
  if (currFilename == null)
  {
    saveAsChosen();
  }
  saveAs();
}

private void saveAsChosen()
{
   try {
  long l = System.currentTimeMillis();
  for (int i=0; i<30; i++)
  {
    outliner.display(conn.callFunction("allfunctions"));
    outliner.display(conn.callFunction("get_type_structure","object"));
  }
  Tools.showMessageDialog(this, "Performance time "+(float)(System.currentTimeMillis ()-l)/1000);
  } catch (Exception err) {}
  //*/
  /*
  Filer filer = new Filer(this, "Goovi save database image as", FileDialog.SAVE);
  filer.show();
  if (filer.getFile() != null)
  currFilename = filer.getDirectory()+filer.getFile();
  saveAs();
  //*/
}

private void saveAs()
{
  try
  {
    conn.execute("save \""+currFilename+"\"");
  }
  catch(Exception e) { Tools.showErrorDialog(this, e, "Unable to save image"); }
}

}// end class TypeBrowser


