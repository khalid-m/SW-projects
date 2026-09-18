package Goovi;

import java.awt.*;
import java.awt.event.*;
import com.borland.jbcl.layout.*;
import com.borland.jbcl.control.*;
import javax.swing.*;

/**
  * Class that is a baseclass for all Goovi-dialogs
  * it centers the dialog corresponding to the parentframe.
  * The dialog has a borderlayout and a button panel at the bottom
  * with a standard cancel button that closes the dialog.
  * @author Kristofer Cassel
  */
public class CenteredDialog extends Dialog {

protected BorderLayout mainBorderLayout  = new BorderLayout();
protected JPanel   buttonPanel           = new JPanel();
protected JButton cancelButton           = new JButton("Cancel");
protected TypeBrowser typeBrowser;

/**
 * Creates a CenteredDialog object with a specified parent, title
 * and modal property.
 *
 * @param frame  Parent frame.
 * @param title  Title of window.
 * @param modal  If the dialog is modal or not.
 */
public CenteredDialog(JFrame frame, String title, boolean modal)
{
  super(frame, title, modal);
  try
  {
      if (frame instanceof TypeBrowser) typeBrowser = (TypeBrowser)frame;
      parent = frame;
      jbInit();
  }
  catch(Exception e)
  {
    Tools.showErrorDialog(frame, e);
  }
}

/**
 * Creates a CenteredDialog object with a specified parent and title.
 *
 * @param frame  Parent frame.
 * @param title  Title of window.
 */
public CenteredDialog(JFrame frame, String title)
{
  this(frame, title, false);
}

private void jbInit() throws Exception
{
    this.addWindowListener(new CenteredDialog_this_windowAdapter(this));
    this.setBackground(Color.lightGray);
    this.setLayout(mainBorderLayout);
    this.add(buttonPanel, BorderLayout.SOUTH);
    cancelButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        dispose();
      }
    });
}

private Frame parent;

/**
 * Packs the dialog, center it over parent and make
 * sets the size to x,y.
 *
 * @param x  Window x size.
 * @param y  Window y size.
 */
public void packAndShow(int x, int y)
{
    mySize = new Dimension(x,y);
    pack();
    setVisible(true);
}

public void pack(int x, int y)
{
    mySize = new Dimension(x,y);
    pack();
}

private Dimension mySize;

public void pack()
{
    Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
    Dimension parentSize = parent.getSize();
    Point parentLocation;
    parentLocation = parent.getLocation();
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

    myLocation = new Point(parentLocation.x + 30 +
			   (parentSize.width - mySize.width)/2,
			   parentLocation.y + 30 +
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

class CenteredDialog_this_windowAdapter extends WindowAdapter
{
  CenteredDialog adaptee;

  CenteredDialog_this_windowAdapter(CenteredDialog adaptee)
  {
    this.adaptee = adaptee;
  }

  public void windowClosing(WindowEvent e)
  {
    adaptee.dispose();
  }
}// end windowadapter

}// end CenteredDialog

