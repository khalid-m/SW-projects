package Goovi;

import java.awt.*;
import java.awt.event.*;
import java.util.*;
import jclass.bwt.*;
import javax.swing.*;

/**
  * Class for the create integration type dialog.
  *
  * @author Kristofer Cassel
  */
public class CreateIntType extends CenteredDialog {

private  String leftVar, rightVar;
private  String leftParent, rightParent;
private StringVector  nameVector        = new StringVector()
                      , typeVector      = new StringVector()
                      , caseLeftVector  = new StringVector()
                      , caseRightVector = new StringVector()
                      , caseBothVector  = new StringVector();
private String[] formLabels, mainFormLabels;
            
private static final int MY_WIDTH = 580, MY_HEIGHT = 320;
private AmosOutliner outliner, typesOutliner;
private Form mainForm;

/**
  * Constructor that creates a Create integration type dialog
  *
  * @param tb The typebrowser that opened the CreateIntType dialog
  */
public CreateIntType(TypeBrowser tb)
{
  super(tb, "GOOVI Create integration type:"+tb );
  try {
    StringVector supertypes = tb.getTheOutliner().getSelectedNames();

    outliner      = new AmosOutliner(tb, "Attributes");

    leftParent  = supertypes.at(0);
    rightParent = supertypes.at(1);
    StringVector vars = Tools.getVariables(new StringVector(leftParent, rightParent));
    leftVar  = vars.at(0);
    rightVar = vars.at(1);
    mainFormLabels = new String[] {"Name of integration type",
                                   "Key type",
                                   "Key expr. for "+leftParent+" "+leftVar+" =",
                                   "Key expr. for "+rightParent+" "+rightVar+" ="};
    mainForm = new Form( mainFormLabels );


    jbInit();



    formLabels = new String[] {"Name","Type",
      "case "+leftParent+" "+leftVar,
      "case "+rightParent+" "+rightVar,
      "case "+leftParent+" "+leftVar+", "
            +rightParent+" "+rightVar };

    outliner.getOutliner().addItemListener(new JCOutlinerListener()
    {
      public void outlinerFolderStateChangeBegin(JCOutlinerEvent ev)
      {
        if (ev == null) return;
        AmosNode nd = (AmosNode)ev.getNode();
        if (nd != null) edit(nd);
      }
      public void outlinerFolderStateChangeEnd(JCOutlinerEvent ev) {}
      public void outlinerNodeSelectBegin(JCOutlinerEvent ev) {}
      public void outlinerNodeSelectEnd(JCOutlinerEvent event) {}
      public void itemStateChanged(JCItemEvent ev) {}
    });
    this.packAndShow(MY_WIDTH, MY_HEIGHT);
  }
  catch (Exception err)
  {
     Tools.showErrorDialog(tb, err, "Failed to construct CreateIntType-dialog!");
  }
}// end constructor

  private void jbInit() throws Exception
  {
    createButton.setText("Create");
    createButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        create();
      }
    });
    
    addButton.setText("Add attribute");
    addButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        add();
      }
    });

    removeButton.setText("Delete attribute");
    removeButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        remove();
      }
    });

    editButton.setText("Edit attribute");
    editButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        edit();
      }
    });

    buttonPanel.add(createButton, null);
    buttonPanel.add(addButton,    null);
    buttonPanel.add(editButton,   null);
    buttonPanel.add(removeButton, null);
    buttonPanel.add(cancelButton, null);

    outliner.setPreferredSize(new Dimension(MY_WIDTH/2, MY_HEIGHT));
    mainForm.setPreferredSize(new Dimension(MY_WIDTH/2, MY_HEIGHT));

    splitter.add(mainForm      , null);
    splitter.add(outliner  , null);
    this.add(splitter, BorderLayout.CENTER);
}// end jbInit

private JButton createButton       = new JButton();
private JButton editButton         = new JButton();
private JButton addButton          = new JButton();
private JButton removeButton       = new JButton();
private JCSplitterWindow splitter  = new JCSplitterWindow( BWTEnum.HORIZONTAL );
 
private void create()
{
    String[] formResults = mainForm.getResult();

    String fnStmt="", caseLeftStmt="", caseRightStmt="", caseBothStmt="";

    String stmt = "create derived type "+formResults[0].toUpperCase()+"\n" +
      "key " + formResults[1] +" dummy459\nsupertype of\n" +
      leftParent  + " "+ leftVar+  " = "+ formResults[2] + ",\n" +
      rightParent + " "+ rightVar+ " = "+ formResults[3] + "\n";

    int size = nameVector.size();
    for (int i=0; i < size; i++)
    {
      fnStmt += nameVector.at(i)+" "+typeVector.at(i);
      if (i != size-1) fnStmt += ", ";
      caseLeftStmt  += nameVector.at(i)+  " = " + caseLeftVector.at(i)  + ";\n";
      caseRightStmt += nameVector.at(i)+  " = " + caseRightVector.at(i) + ";\n";
      caseBothStmt  += nameVector.at(i)+  " = " + caseBothVector.at(i)  + ";\n";
    }
    stmt += "functions( " + fnStmt + ")\n" +
            "case "+leftVar  + ":\n" + caseLeftStmt +
            "case "+rightVar + ":\n" + caseRightStmt +
            "case "+leftVar  + ", "  + rightVar+ ":\n" + caseBothStmt +
            "end functions \n";
    try
    {
      typeBrowser.getAMOSInterface().execute( stmt );
      typeBrowser.refresh();
      dispose();
    }
    catch (Exception err)
    {
      Tools.showErrorDialog(typeBrowser, err, "Failed to create integration type");
    }
}

private void edit()
{
  JCOutlinerNode[] ar = outliner.getSelectedNodes();
  if (ar == null || ar.length != 1) return;
  for ( int i=0; i<ar.length; i++ ) edit((AmosNode)ar[i]);
}

private void add()
{
  String[] res = new FormDialog(typeBrowser, formLabels).getResult();
  if (res != null)
  {
      nameVector.add      ( res[0] );
      typeVector.add      ( res[1] );
      caseLeftVector.add  ( res[2] );
      caseRightVector.add ( res[3] );
      caseBothVector.add  ( res[4] );
      refreshOutliner();
  }
}

private void edit(AmosNode nd)
{
    int i = attrIndex(nd.getLabelString());

    String[] defaults = new String[] {
      nameVector.at(i),
      typeVector.at(i),
      caseLeftVector.at(i),
      caseRightVector.at(i),
      caseBothVector.at(i) };

    String[] res = new FormDialog( typeBrowser, formLabels, defaults).getResult();

    if (res != null)
    {
      nameVector.set     ( i, res[0] );
      typeVector.set     ( i, res[1] );
      caseLeftVector.set ( i, res[2] );
      caseRightVector.set( i, res[3] );
      caseBothVector.set ( i, res[4] );
      refreshOutliner();
    }

}

private void refreshOutliner()
{
    AmosTree theTree = new AmosTree();
    for ( int i=0; i < nameVector.size(); i++ )
    {
      AmosNode nd =
        new AmosNode(""+typeVector.at(i)+" "+nameVector.at(i), "attribute");
      theTree.getRoot().addNode(nd);
    }
    outliner.setTree(theTree);

}// refreshOutliner

private String getNamePart(String str)
{
  return str.substring(str.indexOf(" ")+1);
}

private int attrIndex(String nodeName)
{
  return nameVector.indexOf(getNamePart(nodeName));
}

private void remove()
{
  StringVector names = outliner.getSelectedNames();
  outliner.deleteSelectedNodes();
  for ( int i=0; i<names.size(); i++ )
  {
    int index = attrIndex( names.at(i) );
    if (index != -1) nameVector.remove( index );
  }// for i
}/// remove

}// end CreateIntType



