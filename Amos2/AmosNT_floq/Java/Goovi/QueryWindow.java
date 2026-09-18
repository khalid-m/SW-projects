package Goovi;

import java.awt.*;
import java.awt.event.*;
import java.util.*;

/**
  * Class for the Query window
  * this class launches a window with a query panel inside.
  * @see Goovi.QueryPanel
  * @author Kristofer Cassel
  */
public class QueryWindow extends CenteredDialog {

private QueryPanel queryPanel;

public QueryWindow(TypeBrowser tb)
{
    super(tb, "GOOVI Query window:"+tb );
    queryPanel = new QueryPanel(tb);
    this.add(queryPanel);
    this.packAndShow(400, 400);
}

void this_windowClosing(WindowEvent e)  // overrides windowclosing in CenteredDialog!
{
    QueryPanel.queryPanels.removeElement(queryPanel);
    try
    {
      queryPanel.cleanUp();
    }
    catch(Exception err) {}
    dispose();
}

}// end QueryWindow