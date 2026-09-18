package Goovi;

import javax.swing.*;
import java.awt.event.*;
import callin.*;
import java.awt.*;

/**
  * Class for a specialized outliner which is used for displaying
  * instances in the type browser and type inspector.
  *
  * @author Kristofer Cassel
  */
public class InstancesOutliner extends SpecializedOutliner
{
  private static final String STOP_AFTER_STR = "20";
  private static int STOP_AFTER;
  private JButton button  = new JButton("Show all instances");
  private JPanel lowerPanel = new JPanel();

/**
  * Creates an InstancesOutliner object.
  *
  * @param tb     The typebrowser which this object originated from.
  */
  public InstancesOutliner(TypeBrowser tb)
  {
    super(tb);
    try {
    STOP_AFTER = Integer.parseInt(STOP_AFTER_STR);
    this.setHeading(getToggled());
    this.addToLowerPanel( button );
    button.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        buttonPressed();
      }
    }
    );
     } catch (Exception e) { Tools.showErrorDialog(this, e, "Failed to construct InstancesOut."); }
  }

  private void buttonPressed()
  {
    button.setText("Show "+getToggled());
    this.setHeading(getToggled());
    refresh(currOid);
  }

  private String getToggled()
  {
    return (button.getText().equals("Show all instances") ? STOP_AFTER_STR : "all" )
            +" instances";
  }


   /* Since the streaming of scans is not implemented in Amos
    this is a temporary solution to not cramp performance retrieving big
    extents. */
  private void refreshSomeInstances() throws AmosException
  {
     Oid methodOid = typeBrowser.getAMOSInterface().getFunction("deep_extent");
     this.display
      (typeBrowser.getAMOSInterface().callFunction( methodOid, new Tuple(currOid) , STOP_AFTER));
  }

private void refreshAllInstances()
{
  try
  {
    this.display
      (typeBrowser.getAMOSInterface().callFunction("deep_extent", currOid));
  }
  catch(Exception err)
  {
    this.makeErrorIcon(err);
  }
}

protected void refreshInternal(Oid oid)
{
  try
  {
    currOid = oid;
    setHeading(getToggled());
    if (oid == null) return;
    if (button.getText().equals("Show all instances"))
    {
      refreshSomeInstances();
    }
    else
    {
      refreshAllInstances();
    }
  }
  catch (Exception e)
  {
    Tools.showErrorDialog(this, e, "Failed to construct InstancesOut.");
  }
}

}// end class InstancesOutliner
