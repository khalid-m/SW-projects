package Goovi;

import java.awt.*;

/**
  * Class for the Amos Console textwindow
  *
  * @author Kristofer Cassel
  */
public class AmosConsole extends CenteredDialog {

private MyTextArea textArea = new MyTextArea();

/**
 * Constructor that creates an AmosConsole window
 *
 * @param tb The typebrowser that this window belongs to.
 */
public AmosConsole(TypeBrowser tb)
{
  super(tb, "GOOVI Amos Console:"+tb);
  try
  {
    jbInit();
    this.pack(400,400);
  }
  catch (Exception err)
  {
    Tools.showErrorDialog(this, err, "Failed to construct AmosConsole!");
  }
}

/**
* @param str The text to be added to the console-window.
*/
public void addText(String str)
{
  textArea.append(str);
}

/**
  * Make the window visible. The user closes it by clicking later.
  */
public void makeVisible()
{
  this.setVisible(true);
}

private void jbInit() throws Exception
{
  add(textArea, BorderLayout.CENTER);
}

}// end class AmosConsole


