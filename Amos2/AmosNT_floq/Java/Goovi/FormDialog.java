package Goovi;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

/**
  * General class for a modal dialog that contains
  * a from of textstrings to be input on different labels for example
  * Name, address, phone etc.
  *
  * @see Goovi.Form
  * @author Kristofer Cassel
  */

public class FormDialog extends CenteredDialog {

  private static final int MY_WIDTH = 500;
  private int myHeight;
  private String[] result;
  private Form form;

  private JButton finishButton = new JButton("Finish");

 /**
  * Constructor that creates a Form dialog from a string array of field labels.
  *
  * @param parent  The parent frame.
  * @param labels  The field labels to descibe the textfields.
  */
  public FormDialog(JFrame parent, String[] labels)
  {
    super(parent, "GOOVI form", true);
    form = new Form(labels);
    init();
  }

  /**
  * Constructor that creates a Form dialog from string arrays of field labels
  * and of defaults.
  *
  * @param parent    The parent frame.
  * @param labels    The field labels to descibe the textfields.
  * @param defaults  The default texts to put in the textfields.
  */
  public FormDialog(JFrame parent, String[] labels, String[] defaults)
  {
    super( parent, "GOOVI form", true );
    form = new Form( labels, defaults );
    init();
  }

 /**
  * Gets the result. If null the dialog was closed or cancelled.
  *
  * @returns The resulting inputed strings or null.
  */
  public String[] getResult()
  {
    return result;
  }

  private void init()
  {
    myHeight = 32*(form.getNoRows()*2+2); // title bar and buttonpanel takes approx two lines
    try
    {
      finishButton.addActionListener(new java.awt.event.ActionListener()
      {
        public void actionPerformed(ActionEvent e)
        {
          result = form.getResult();
          dispose();
        }
      });
      buttonPanel.add( finishButton, null );
      buttonPanel.add( cancelButton, null );
      this.add( form, BorderLayout.CENTER );
      this.packAndShow( MY_WIDTH, myHeight );
    }
    catch (Exception err)
    {
      Tools.showErrorDialog(this, err, "Failed to construct Form");
    }
  }
}// end Form