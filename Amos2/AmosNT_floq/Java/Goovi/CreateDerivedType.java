package Goovi;

import java.awt.*;
import java.awt.event.*;
import java.util.*;
import callin.*;
import javax.swing.*;

/**
  * Class for the create derived type dialog
  *
  * @author Kristofer Cassel
  */
public class CreateDerivedType extends CenteredDialog {

String supertypeList = "";
JPanel centerPanel         = new JPanel();
MyTextArea whereText       = new MyTextArea();
BorderLayout borderLayout1 = new BorderLayout();
BorderLayout borderLayout2 = new BorderLayout();
BorderLayout borderLayout3 = new BorderLayout();
JTextField nameText        = new JTextField();
JPanel panel2   = new JPanel();
JPanel panel3   = new JPanel();
JLabel label1   = new JLabel();
JLabel label2   = new JLabel();
JButton button1 = new JButton();

StringVector supertypes;

/**
  * Constructor that creates a Create derived type dialog
  *
  * @param tb The typebrowser that opened this dialog.
  */
public CreateDerivedType(TypeBrowser tb)
{
    super( tb, "GOOVI Create derived type" );
    try
    {
      jbInit();

      supertypes = typeBrowser.getTheOutliner().getSelectedNames();

      StringVector variables = Tools.getVariables(supertypes);
      for (int i=0; i<supertypes.size(); i++)
      {
        supertypeList += supertypes.at(i)+" "+variables.at(i);
        if (i != supertypes.size()-1) supertypeList += ", ";
      }
      label2.setText("subtype of "+supertypeList+" where ");
      this.packAndShow(400,300);
    }
    catch (Exception err)
    {
      Tools.showErrorDialog(tb, err, "Failed to construct CreateDerivedType-Dialog!");
    }
}// end constructor

private void jbInit() throws Exception {

  button1.setText("Create");
  button1.addActionListener(new java.awt.event.ActionListener()
  {
    public void actionPerformed(ActionEvent e)
    {
      create();
    }
  });

  panel2.setLayout(borderLayout1);
  panel3.setLayout(borderLayout2);
  label1.setText("Name of derived type:");
  label2.setText("subtype of");
  centerPanel.setLayout(borderLayout3);
  add(centerPanel       , BorderLayout.CENTER);
  centerPanel.add(panel2, BorderLayout.NORTH);
  panel2.add(nameText   , BorderLayout.CENTER);
  panel2.add(label1     , BorderLayout.WEST);
  centerPanel.add(panel3, BorderLayout.CENTER);
  panel3.add(whereText  , BorderLayout.CENTER);
  panel3.add(label2     , BorderLayout.NORTH);
  buttonPanel.add(button1     , null);
  buttonPanel.add(cancelButton, null);
}

private void create()
{
    try
    {
     Oid newObj = typeBrowser.getAMOSInterface().createDerivedType
      (
        supertypeList,
        nameText.getText().trim().toUpperCase(),
        whereText.getText().trim()
      );
     typeBrowser.getTheOutliner().addToExpanded(supertypes);
     typeBrowser.refresh();
     dispose();
    }
    catch (Exception err)
    {
      Tools.showErrorDialog(this, err, "Failed to create derived type");
    }
  }
}// end class CreateDerivedType



