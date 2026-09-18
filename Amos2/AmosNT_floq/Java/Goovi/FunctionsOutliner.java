package Goovi;

import javax.swing.*;
import java.awt.event.*;
import callin.*;
import java.awt.*;

/**
  * Class for a specialized outliner which is used for displaying
  * functions/methods in the type browser and type inspector.
  *
  * @author Kristofer Cassel
  */
public class FunctionsOutliner extends SpecializedOutliner
{
  private JCheckBox showInherited = new JCheckBox("Show inherited", false);
  private JButton button          = new JButton("Show functions");

/**
  * Creates a FunctionsOutliner object.
  *
  * @param tb     The typebrowser which this object originated from.
  */
  public FunctionsOutliner(TypeBrowser tb)
  {
    super(tb);
    this.setHeading( getComboMode() );
    this.addToLowerPanel( showInherited );
    this.addToLowerPanel( button        );
    showInherited.addItemListener(new java.awt.event.ItemListener()
    {
      public void itemStateChanged(ItemEvent e)
      {
        refresh(currOid);
      }
    });
    button.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        button.setText("Show "+getComboMode());
        refresh(currOid);
      }
    });
  }

  private String getComboMode()
  {
    return ( button.getText().equals("Show functions") ? "methods" : "functions" );
  }

  protected void refreshInternal(Oid oid)
  {
    try
    {
       String functionsDisplay = getComboMode();
       this.setHeading(functionsDisplay);
       if (oid == null) return;
       String fname =
          (functionsDisplay.equalsIgnoreCase("Functions") ? "all" : "")
          + functionsDisplay.toLowerCase()
          + ((showInherited.isSelected()) ? "_inherited" : "");

       this.display
       (typeBrowser.getAMOSInterface().callFunction( fname, oid ));

    }
    catch(AmosException err)
    {
      this.makeErrorIcon(err);
    }
  }
}