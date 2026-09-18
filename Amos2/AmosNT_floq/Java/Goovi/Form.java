package Goovi;

import javax.swing.*;
import java.awt.*;

/**
  * Class that represents a form of fields to fill in for the user
  * Each field has a label to describe it to the user. The form is
  * packaged in a JPanel.
  *
  * @author Kristofer Cassel
  */
public class Form extends JPanel {

  private GridLayout gridLayout2  = new GridLayout();
  private JTextField[] textFields;
  private int rows;

/**
  * Constructor that creates a Form panel from a string array of field labels.
  *
  * @param labels  The field labels to descibe the textfields.
  */
  public Form(String[] labels)
  {
    super();
    rows = labels.length;
    String[] defaults = new String[rows];
    for (int i=0; i < rows; i++) defaults[i]="";
    init(labels, defaults);
  }

/**
  * Constructor that creates a Form panel from string arrays of field labels
  * and of defaults.
  *
  * @param labels    The field labels to descibe the textfields.
  * @param defaults  The default texts to put in the textfields.
  */
  public Form(String[] labels, String[] defaults)
  {
    super();
    rows = labels.length;
    init(labels,defaults);
  }

/**
  * Get the number of rows (textfields) in this form.
  */
  public int getNoRows()
  {
    return rows;
  }

  private void init(String[] labels, String[] defaults)
  {
    gridLayout2.setRows(rows*2);
    gridLayout2.setHgap(2);
    gridLayout2.setColumns(1);
    gridLayout2.setVgap(2);
    this.setLayout(gridLayout2);
    textFields = new JTextField[rows];
    for (int i=0; i<rows; i++)
    {
      this.add(new JLabel(labels[i]));
      this.add(textFields[i] = new JTextField(defaults[i]));
    }
  }

/**
  * Get the users input in all the fields.
  *
  * @return  The inputed strings.
  */
  public String[] getResult()
  {
    String[] result = new String[rows];
    for (int i=0; i<rows; i++)
    {
      result[i] = textFields[i].getText();
    }
    return result;
  }

}// end class Form