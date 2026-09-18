package Goovi;

import java.awt.*;
import java.awt.event.*;
import java.util.*;
import jclass.bwt.*;
import callin.*;
import javax.swing.*;

/**
  * Class for the function inspector dialog
  *
  * @author Kristofer Cassel
  */
public class FunctionInspector extends Inspector implements JCOutlinerListener
{
  private static final String KEYWORD = "as";
  private StringVector vars;
  private boolean editable = true;
  private String genericName = null;
  private AmosInterface conn;

/**
  * Constructor that creates a FunctionInspector object to inspect a certain function.
  *
  * @param tb     The typebrowser which this functioninspector originated from.
  * @param theOid The oid of the function to inspect.
  */
  public FunctionInspector(TypeBrowser tb, Oid theOid)
  {
    super("Function", tb, theOid);
    try
    {
      if (exists) return;
      init();
      genericName = conn.callStringFunction( "generic_name", theOid);
      String defText = conn.callStringFunction( "sourcecode", theOid );
      if (editable = (defText != null))
      {
        defText = cutSourcecode(defText);
        functionDefText.setText(defText);
      }
      else // no sourcecode available , function not editable
      {
        functionDefText.setEnabled(false);
      }
      nameText.setText(genericName);
      nameText.setEnabled(false);
      init2();

      fixOutliner( argOutliner, "argument", "arguments" );
      fixOutliner( resOutliner, "result",   "results"     );

      String kindoffunction = conn.callStringFunction( "kindoffunction", theOid );
      if (kindoffunction != null && !kindoffunction.equals(""))
      {
        kindoffunctionLabel.setText("Kind of function:");
        kindoffn.setText(kindoffunction);
      }
    }
    catch (Exception err)
    {
      closeInspector();
      Tools.showErrorDialog(this, err, "Couldn't launch FunctionInspector for function "+theOid.toString());
    }
  }

/**
  * Constructor that creates a FunctionInspector object to create a new function.
  *
  * @param tb     The typebrowser which this functioninspector originated from.
  * @param arg    The name of the argument types.
  */
  public FunctionInspector(TypeBrowser tb, StringVector arg) throws Exception
  {
    super("", tb, null);
    this.setTitle("GOOVI Function inspector: Create function");
    init();
    vars = Tools.getVariables( arg );

    init2();

    AmosTree tr = new AmosTree();
    for (int i=0; i < arg.size(); i++)
    {
      tr.addNode(new AmosNode(""+arg.get(i)+" "+vars.get(i)+" nonkey","argument") );
    }
    argOutliner.setTree(tr);
    resOutliner.setTree(new AmosTree());
  }// end constructor

  private void fixOutliner( AmosOutliner ol, String nodeType, String fname) throws AmosException
  {
    AmosTree tr = new AmosTree();
    Tuple wtp = conn.callTupleTupleFunction( fname,  oid );
    for (int i=0; i < wtp.getArity(); i++)
    {
      Tuple tp = wtp.getSeqElem(i);
      tr.addNode(new AmosNode(""+tp.getOidElem(0).getName()+" "+tp.getStringElem(1)+" "+tp.getStringElem(2),nodeType) );
    }// end for
    ol.setTree(tr);
  }

  private void init()
  {
    argOutliner = new AmosOutliner( typeBrowser, "Arguments" );
    resOutliner = new AmosOutliner( typeBrowser, "Results"   );
    argOutliner.getOutliner().addItemListener( this );
    resOutliner.getOutliner().addItemListener( this );
    conn = typeBrowser.getAMOSInterface();
  }

  private void init2() throws Exception
  {
    jbInit();
    this.packAndShow(720, 410);
  }

  private void jbInit() throws Exception
  {
    addArgButton.setText("Add arg");
    addArgButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        addArgRes("argument", argOutliner);
      }
    });
    centerPanel.setLayout( gridLayout3 );
    addResButton.setText("Add res");
    addResButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        addArgRes("result",resOutliner);
      }
    });
    gridLayout1.setColumns(3);
    gridLayout1.setRows(1);
    gridLayout1.setHgap(5);
    gridLayout1.setVgap(5);

    lowPanel.setLayout      ( borderLayout5 );
    infoPanel.setLayout     ( new GridLayout(4,1) );
    label1.setText          ("Generic functionname");
    nameText.setFont        (new Font("Courier", 0, 12));
    functionDefText.setFont (new Font("Courier", 0, 12));
    funcdefLabel.setText    ("Function definition:");

    usesWhichButton.setText ("Uses which");
    usesWhichButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        usedWhereWhich("useswhich");
      }
    });
    usedWhereButton.setText("Used where");
    deleteButton.setText("Del arg/res");
    deleteButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        deleteArgRes();
      }
    });
    editButton.setText("Edit");
    editButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        editButton_actionPerformed(e);
      }
    });

    usedWhereButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        usedWhereWhich("usedwhere");
      }
    });
    label1.setFont(new Font("Dialog", 0, 12));
    upperPanel.setLayout(gridLayout1);

    createButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        create();
      }
    });
    createButton.setText("Create");
    gridLayout3.setVgap(10);
    closeButton.setText("Cancel"); // close in inherited
    gridLayout3.setRows(2);
    gridLayout3.setColumns(1);
    gridLayout3.setHgap(10);
    this.getContentPane().add(centerPanel, BorderLayout.CENTER);
    upperPanel.add(argOutliner);
    upperPanel.add(resOutliner);
    upperPanel.add(infoPanel);
    centerPanel.add(upperPanel);
    centerPanel.add(lowPanel);

    infoPanel.add(label1);
    infoPanel.add(nameText);
    infoPanel.add(kindoffunctionLabel);
    infoPanel.add(kindoffn);

    lowPanel.add(functionDefText, BorderLayout.CENTER);
    lowPanel.add(funcdefLabel, BorderLayout.NORTH);

    if (editable)
    {
      buttonPanel.add(createButton, null);
      buttonPanel.add(addArgButton, null);
      buttonPanel.add(addResButton, null);
      buttonPanel.add(deleteButton, null);
      buttonPanel.add(editButton, null);
    }
    if (oid != null)
    {
      buttonPanel.add(usedWhereButton, null);
      buttonPanel.add(usesWhichButton, null);
    }
    buttonPanel.add( closeButton, null);
    functionDefText.setFont( new Font( "Courier", Font.PLAIN, 12 ));
  }

  JButton addArgButton        = new JButton();
  JPanel centerPanel          = new JPanel();
  BorderLayout borderLayout2  = new BorderLayout();
  JButton createButton        = new JButton();
  JButton editButton          = new JButton();
  JButton addResButton        = new JButton();
  GridLayout gridLayout1      = new GridLayout();
  GridLayout gridLayout3      = new GridLayout();
  BorderLayout borderLayout4  = new BorderLayout();
  AmosOutliner resOutliner, argOutliner;
  JPanel lowPanel             = new JPanel();
  JPanel upperPanel           = new JPanel();
  BorderLayout borderLayout5  = new BorderLayout();
  JPanel infoPanel            = new JPanel();
  JLabel label1               = new JLabel();
  JTextField nameText         = new JTextField();
  MyTextArea functionDefText  = new MyTextArea();
  JLabel funcdefLabel         = new JLabel();
  JLabel kindoffunctionLabel  = new JLabel();
  JLabel kindoffn             = new JLabel();
  JButton usesWhichButton     = new JButton();
  JButton usedWhereButton     = new JButton();
  JButton deleteButton        = new JButton();

  private String cutSourcecode(String defText) throws GooviException
  {
    String comment = "";
    // first if there is a comment cut it out
    int cs, ce;

    while ( (cs = defText.indexOf("/*")) != -1)
    {
      ce = defText.indexOf("*/");
      // save comment
      comment += defText.substring( cs, ce+2 )+ " ";
      // cut out comment
      defText = defText.substring(0, cs) + defText.substring(ce+2);
    }
    int start = defText.indexOf("->");
    if (start == -1) throw new GooviException("Function without ->");
    int i = defText.indexOf( " "+KEYWORD+" ", start );
    if (i == -1) i = defText.indexOf( "\n" + KEYWORD + " ", start );
    if (i == -1) i = defText.indexOf( " " + KEYWORD + "\n", start );
    if (i == -1) i = defText.indexOf( "\n" + KEYWORD + "\n", start );
    if (i == -1)
    {
      // function without keyword "as", maybe not a big deal?
      return comment;
    }
    defText = defText.substring( i+KEYWORD.length()+2 ).trim();
    if (!comment.equals("")) comment += "\n";
    return comment + defText;
  }

  private void create()
  {
    try
    {
      String fnText = functionDefText.getText().trim();
      if (fnText.equals("")) fnText = "stored";

      // generate amos syntax
      String stmt = "create function "+nameText.getText().toUpperCase().trim()
      + "(" + argOutliner.makeCommalist() + ")-><" + resOutliner.makeCommalist() + ">"
      + " as "+fnText;

      typeBrowser.getAMOSInterface().execute(stmt);
      closeInspector();
    }
    catch (Exception err)
    {
      Tools.showErrorDialog(this, err, "Failed to create function");
    }
  }// end create

  private void editButton_actionPerformed(ActionEvent e)
  {
    if (edited(argOutliner)) return;
    edited(resOutliner);
  }

  private boolean edited(AmosOutliner out)
  {
    JCOutlinerNode[] ar = out.getSelectedNodes();
    boolean exists = (ar != null && ar.length > 0);
    if (exists) edit((AmosNode)ar[0]);
    return exists;
  }

  private void edit(AmosNode nd)
  {
    String res =
      Tools.showInputDialog( this,
        "Enter in form:\ninteger i key", nd.getLabelString());

    if (res != null && !((res=res.trim()).equals("")))
    {
      nd.setLabel(res);
    }
  }

  private void addArgRes(String argres, AmosOutliner outliner)
  {
    String res =
      Tools.showInputDialog( this, "Enter "+argres+" in form: integer i key");

    if (res != null && !((res=res.trim()).equals("")))
    {
      JCOutlinerFolderNode rn = outliner.getAmosTree().getRoot();
      rn.addNode(new AmosNode(res, argres));
      outliner.folderChanged(rn);
    }
  }

  private void usedWhereWhich(String kind)
  {
    try
    {
      if (oid == null) return;
      AmosOutliner tempOutline =
        new AmosOutliner(typeBrowser, "Functions");
      tempOutline.display(typeBrowser.getAMOSInterface().callFunction(kind, oid));

      new AmosNodeChoser( this, typeBrowser, "Goovi "+kind+"? "+oid.getName(),tempOutline );
    }
    catch (Exception err)
    {
      Tools.showErrorDialog(this, err,
        "Error when opening used where / uses which window");
    }
  }

  private void deleteArgRes()
  {
    argOutliner.deleteSelectedNodes();
    resOutliner.deleteSelectedNodes();
  }

// interface methods

public void outlinerFolderStateChangeBegin(JCOutlinerEvent ev)
{
      AmosNode nd      = (AmosNode) ev.getNode();
      if (nd != null) edit(nd);
}// end outlinerFolderStateChangeBegin

public void outlinerFolderStateChangeEnd(JCOutlinerEvent ev) {}
public void outlinerNodeSelectBegin(JCOutlinerEvent ev) {}
public void outlinerNodeSelectEnd(JCOutlinerEvent event) {}
public void itemStateChanged(JCItemEvent ev) {}

// end interface methods

}// end FunctionInspector

