package Goovi;

import javax.swing.*;
import java.awt.*;

/**
  * Class for all Goovi menu items. The icon is automatically
  * set to an empty icon to avoid intendation problems of the menutext.
  *
  * @author Kristofer Cassel
  */
public class MyMenuItem extends JMenuItem
{
  /**
    * Constructor that creates a menu item.
    */
  public MyMenuItem()
  {
    super("");
    this.setIcon(new ImageIcon(IconHandler.getIcon("NOICON")));
    //this.setMargin(new Insets(2,0,2,2));
    //this.setAlignmentX(0);
  }
} 