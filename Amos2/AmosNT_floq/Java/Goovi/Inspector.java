package Goovi;

import java.awt.*;
import java.awt.event.*;
import callin.*;
import javax.swing.*;

/**
  * Class that is an abstract baseclass for all Goovi-inspectors
  * it is centered corresponding to the parentframe and holds a cancel
  * and refresh button in a borderlayout JFrame with a buttonpanel in
  * the south.
  *
  * @author Kristofer Cassel
  */
public abstract class Inspector extends JFrame {

protected JButton refreshButton = new JButton( "Refresh" );
protected JButton closeButton   = new JButton( "Close"   );
protected JPanel  buttonPanel   = new JPanel();
protected Oid     oid;
/**
  * A boolean to tell if the inspector was allready
  * open. The superclass knows through this boolean
  * if it should dispose itself.
  */
protected boolean exists;
/**
  * To hold the type browser object that this
  * class originated from.
  */
protected TypeBrowser typeBrowser;

public Inspector(String title, TypeBrowser tb, Oid theOid)
{
  super( title.equals("") ?  "" : "GOOVI " + title + " inspector:" + tb + " " + theOid );
  try
  {
    oid = theOid;
    if (oid != null)
    {
      if (tb.existInspector(theOid))
      {
        exists = true;
        // bring the old inspector alive...
        Inspector i = tb.getInspector(theOid);
        i.toFront();
        i.requestFocus();
        i.refresh();
        this.dispose();
        return;
      }
      else
      {
        tb.registerInspector(this);
      }
    }
    typeBrowser = tb;
    jbInit();
  }
  catch( Exception e )
  {
    Tools.showErrorDialog(tb, e, "Failed in Inspector superconstructor.");
  }
}

private void jbInit() throws Exception
{
    this.getContentPane().setLayout( new BorderLayout() );
    this.getContentPane().add(buttonPanel, BorderLayout.SOUTH);

    refreshButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        refresh();
      }
    });

    closeButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        closeInspector();
      }
    });
}

/**
  * Empty method that will be overriden to
  * perform specific inspector refresh.
  */
public void refresh() {}

public Oid getOid()
{
  return oid;
}

public void packAndShow(int x, int y)
{
  mySize = new Dimension(x,y);
  pack();
  this.setVisible(true);
}

private Dimension mySize;


/**
  * Overridden to center window over parent.
  */
public void pack() {

    Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
    Dimension parentSize = typeBrowser.getSize();
    Point parentLocation = typeBrowser.getLocation();
    Point myLocation;

    // if frame larger than screen -> adjust
    if (mySize.height > screenSize.height)
    {
      mySize.height = screenSize.height;
    }
    if (mySize.width > screenSize.width)
    {
      mySize.width = screenSize.width;
    }

    super.pack();
    this.setSize(mySize);

    // Center the dialog over parent

    myLocation = new Point(parentLocation.x + 80 +
			   (parentSize.width - mySize.width)/2,
			   parentLocation.y + 50 +
			   (parentSize.height - mySize.height)/2);

    if ((parentLocation.x == 0 && parentLocation.y ==0) ||
        (myLocation.x + mySize.width > screenSize.width) ||
        (myLocation.y + mySize.height > screenSize.height))
    {
      // center dialog on screen instead

      myLocation = new Point(    (screenSize.width- mySize.width)    / 2,
                                 (screenSize.height - mySize.height) / 2 );
    }
    this.setLocation(myLocation);
}

/**
  * Dispose of window and remove inspector
  * from the type browsers list of open inspectors.
  * This method is called from overriden implementations in
  * the actual inspectors.
  */
public void closeInspector()
{
  typeBrowser.removeInspector(this);
  dispose();
}

/**
  * Overriden to call closeInspector() when user closes window.
  */
protected void processWindowEvent(WindowEvent e)
{
  super.processWindowEvent(e);
  if(e.getID() == WindowEvent.WINDOW_CLOSING)
  {
    closeInspector();
  }
}

}// end Inspector

