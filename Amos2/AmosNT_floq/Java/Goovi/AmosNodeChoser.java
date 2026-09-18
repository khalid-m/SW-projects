package Goovi;

import java.awt.*;
import java.awt.event.*;
import java.util.*;
import jclass.bwt.*;
import javax.swing.*;

/**
  * Class for AmosNode choser dialog
  * used to present a list of AmosNodes in an AmosOutliner.
  * Used to launch overloaded function inspector, new connection choice etc.
  * @author Kristofer Cassel
  */
public class AmosNodeChoser extends CenteredDialog {

// GUI objects ...
protected AmosOutliner theOutliner;
private  JButton inspectButton   = new JButton();

/**
 * Constructor that creates an AmosNodeChoser object from a parent frame,
 * a typebrowser, a title and an AmosOutliner.
 *
 * @param parent   The parent of this dialog.
 * @param tb       The typebrowser that this dialog originated from.
 * @param title    The title of this dialog.
 * @param outline  The AmosOutliner to be displayed.
 */
public AmosNodeChoser( JFrame parent, TypeBrowser tb, String title, AmosOutliner outline )
{
    super( parent, title );
    try
    {
      typeBrowser = tb;
      theOutliner = outline;
      jbInit();
      this.packAndShow(320, 280);
    }
    catch(Exception err)
    {
      Tools.showErrorDialog( tb, err, "error when initializing AmosNodeChoser" );
    }
}

  // JBuilders code from the designer ...
  private void jbInit() throws Exception
  {
    inspectButton.setText("Inspect");
    inspectButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        inspect();
      }
    });
    this.add(theOutliner, BorderLayout.CENTER);
    buttonPanel.add(inspectButton, null);
    buttonPanel.add(cancelButton, null);
  }// end JBInit

  private void inspect()
  {
    try
    {
      JCOutlinerNode[] ar = theOutliner.getSelectedNodes();
      if (ar == null) return;
      for (int i=0; i < ar.length ; i++) Tools.inspectNode((AmosNode)ar[i], typeBrowser);
      dispose();
    }
    catch( Exception err )
    {
      Tools.showErrorDialog( typeBrowser, err, "Error when inspecting node");
    }
  }// end inspect

}// end AmosNodeChoser


