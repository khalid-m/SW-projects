package Goovi;

import java.awt.*;
import java.awt.event.*;
import jclass.bwt.*;
import java.util.*;
import callin.*;
import javax.swing.*;

/**
  * Class for the Object Inspector dialog
  *
  * @author Kristofer Cassel
  */
public class ObjectInspector extends Inspector implements JCOutlinerListener {

  // GUI-components...
  private JButton addButton           = new JButton();
  private JButton removeButton        = new JButton();
  private Panel leftPanel            = new Panel();
  private BorderLayout borderLayout4 = new BorderLayout();
  private JCSplitterWindow centreSplit = new JCSplitterWindow( BWTEnum.HORIZONTAL   );
  private Panel panel1               = new Panel();
  private TextField textField        = new TextField();
  private BorderLayout borderLayout1 = new BorderLayout();
  private JLabel label1               = new JLabel();
  private JButton setButton           = new JButton();
  private JCheckBox showInherited     = new JCheckBox("Show inherited",false);

  // other attributes...
  private AmosOutliner outliner, methodsOutliner;
  private Vector       methods;
  private StringVector genericNames, results;
  private Scan scan;
  private String currentFnName = null;
  private final static String[] columnLabels = { "Attribute value", "Attribute name" };
  private final static int MY_HEIGHT = 420, MY_WIDTH = 620;

  public ObjectInspector(TypeBrowser tb, Oid theOid)
  {
    super("Object", tb, theOid);
    try
    {
      if (exists) return;

      outliner = new AmosOutliner(tb, true, "Aggregate contents");
      methodsOutliner = new AmosOutliner(tb, columnLabels);
      refresh();
      jbInit();
      this.packAndShow(MY_WIDTH, MY_HEIGHT);
    }
    catch (Exception err)
    {
      closeInspector();
      Tools.showErrorDialog(this, err);
    }
  }

  public void refresh()
  {
    refresh(showInherited.isSelected());
  }

  private void refresh(boolean showInher)
  {
    try
    {
      initVectors(showInher);
      initFields();
    }
    catch (Exception e) { Tools.showErrorDialog(this, e, "Unable to refresh objectinspector."); }
  }

  private void jbInit() throws Exception
  {
    methodsOutliner.getOutliner().addItemListener(this);
    outliner.getOutliner().addItemListener(this);

    leftPanel.setLayout ( borderLayout4 );
    panel1.setLayout(borderLayout1);
    label1.setText("Enter/edit value (\"\" around strings):");

    textField.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        add();
      }
    });

    setButton.setText("Set");
    setButton.addActionListener(new java.awt.event.ActionListener()
    {

      public void actionPerformed(ActionEvent e)
      {
        set();
      }
    });
    leftPanel.add( methodsOutliner, BorderLayout.CENTER );
    leftPanel.add( panel1, BorderLayout.SOUTH);
    panel1.add( textField, BorderLayout.CENTER);
    panel1.add( label1, BorderLayout.NORTH);

    addButton.setText("Add");
    addButton.addActionListener(new java.awt.event.ActionListener()
    {

      public void actionPerformed(ActionEvent e)
      {
        add();
      }
    });

    removeButton.setText("Remove");
    removeButton.addActionListener(new java.awt.event.ActionListener()
    {

      public void actionPerformed(ActionEvent e)
      {
        remove();
      }
    });

    showInherited.addItemListener(new java.awt.event.ItemListener()
    {
      public void itemStateChanged(ItemEvent e)
      {
        refresh((e.getStateChange() == ItemEvent.SELECTED));
      }
    });

    buttonPanel.add( showInherited );
    buttonPanel.add( setButton     );
    buttonPanel.add( addButton     );
    buttonPanel.add( removeButton  );
    buttonPanel.add( refreshButton );
    buttonPanel.add( closeButton  );

    this.getContentPane().add( centreSplit, BorderLayout.CENTER );
    methodsOutliner.getOutliner().setPreferredSize(MY_WIDTH * 57/100, MY_HEIGHT);
    centreSplit.add( leftPanel, null );
    centreSplit.add( outliner,     null );
  }

  private Oid getMethod(int i)
  {
    return (Oid)(methods.elementAt(i));
  }

  private void initVectors(boolean showInher) throws AmosException
  {
    methods      = new Vector(40);
    genericNames = new StringVector(40);
    results      = new StringVector(40);

    scan = typeBrowser.getAMOSInterface().callFunction
        ("methods_gen_inherited"+(showInher ? "" : "2"), oid);
    while (!scan.eos())
    {
      Tuple tp = scan.getRow();
      methods.addElement( tp.getOidElem(0) );
      genericNames.add ( tp.getStringElem(1) );
      results.add (tp.getStringElem(2) );
      scan.nextRow();
    }
    scan.closeScan();
  }

  private void initFields() throws Exception
  {
    AmosTree tr = new AmosTree();
    for (int i=0; i < methods.size(); i++)
    {
      tr.addNode( makeNode( getMethod(i), genericNames.at(i), results.at(i)));
    }// end for
   methodsOutliner.setTree(tr);
  }

  private AmosNode makeNode(Oid methodOid, String label, String typename)
  {
      AmosNode node;
      try {
      /*
       * Changed the call to Connection.callFunction() to use the stopAfter
       * feature of Scans. This is a significant performance-enhancement when
       * the "Attribute" is a large "Collection" of elements since we are
       * only using the first two anyway.
       */
      scan = typeBrowser.getAMOSInterface().callFunction(methodOid,
                                                         new Tuple(oid), 2);
      if (scan.eos())
      {
        node = new AmosNode("NIL", typename);
      }
      else
      {
        Tuple tp = scan.getRow();
        scan.nextRow();

        if (scan.eos() && tp.getArity() == 1 && !tp.isTuple(0))
        {
          node = methodsOutliner.makeNode(tp, 0);
        }
        else
        {
          node = new AmosNode( "", "collection" );
        }// end else
      }// end else
  }// end try
  catch(Exception err)
  {
    node = new AmosNode("** EXCEPTION **", typename);
  }
  try
  {
    if (scan != null) scan.closeScan();
  }
  catch (Exception e)
  {
    System.out.println("Couldn't close scan!"); e.printStackTrace();
  }
  node.addColumn(label);
  return node;
}

  public void closeInspector()
  {
    try
    {
      outliner.closeScan();
      super.closeInspector();
    }
    catch(Exception e) { Tools.showErrorDialog(this, e, "Couldn't close objectinspector."); }
  }

private final int getCurrentIndex()
{
  return genericNames.indexOf(currentFnName);
}

private void refreshRightOutliner() throws Exception
{
  int i;
  if ((i = getCurrentIndex()) >= 0)
  {
    outliner.setHeading( currentFnName );
    outliner.display( typeBrowser.getAMOSInterface().callFunction( getMethod(i), oid ) );
  }// end if
}


private void edit(AmosNode nd)
{
  try
  {
    Object label = nd.getLabel();
    if (label instanceof Vector) // otherwise in expansionoutliner
    {
      currentFnName = ((Vector)label).elementAt(1).toString();
    }
    String labelstr = nd.getLabelString();
    Oid attrOid = nd.getOid();
    String defText = labelstr;
    if (attrOid != null)
    {
      defText = attrOid.toString();
    }
    else if (labelstr.equalsIgnoreCase("nil"))
    {
      defText = "";
    }
    textField.setText(defText);
  }
  catch(Exception err)
  {
    Tools.showErrorDialog(this, err, "Failed to edit attribute");
  }
}// end edit

private void set()
{
  launchOSQL("set");
}

private void launchOSQL(String str)
{
   try {
    if (currentFnName == null || currentFnName.equals(""))
    {
      Tools.showMessageDialog(this, "You have to mark an attribute first.");
      return;
    }
    String res = textField.getText().trim();
    if (!res.equals(""))
    {
      String stmt = str+" "+currentFnName+"("+oid+")="+res;
      typeBrowser.getAMOSInterface().execute(stmt);
      updateCurrentNode();
      refreshRightOutliner();
    }
  }
  catch(Exception err)
  {
    Tools.showErrorDialog(this, err, "Failed to edit attribute");
  }
}

private void updateCurrentNode()
{
  int ind = getCurrentIndex();
  AmosNode updatedNode = makeNode(getMethod(ind), currentFnName, results.at(ind));
  Vector children = methodsOutliner.getRoot().getChildren();
  AmosTree tr = new AmosTree();
  for (int i=0; i<children.size();)
  {
    AmosNode nn = (AmosNode)(children.elementAt(i));
    if (((Vector)(nn.getLabel())).elementAt(1).equals(currentFnName))
    {
      tr.addChild(updatedNode);
      i++;
    }
    else
    {
      // i++ not needed here because children shrinks by one (very strange!)
      tr.addChild(nn);
    }
  }// end for
  methodsOutliner.setTree(tr);
}// end updateCurrentNode

private void add()
{
  launchOSQL("add");
}

private void remove()
{
  launchOSQL("remove");
}

// interface methods
public void outlinerFolderStateChangeBegin(JCOutlinerEvent ev) {}
public void outlinerFolderStateChangeEnd(JCOutlinerEvent ev) {}
public void outlinerNodeSelectBegin(JCOutlinerEvent ev)
{
   try
    {
      AmosNode nd      = (AmosNode) ev.getNode();
      if (nd.getType().equalsIgnoreCase("collection"))
      {
        currentFnName = ((Vector)nd.getLabel()).elementAt(1).toString();
        refreshRightOutliner();
      }// end if
      else edit(nd);
    }// end try
    catch(Exception err)
    {
      Tools.showErrorDialog(typeBrowser, err, "Error in statechangebegin");
    }
}
public void outlinerNodeSelectEnd(JCOutlinerEvent event) {}
public void itemStateChanged(JCItemEvent ev) {}
// end interface methods

}// end class objectinspector


