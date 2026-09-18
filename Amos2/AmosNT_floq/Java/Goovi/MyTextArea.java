package Goovi;


import jclass.bwt.*;
import java.awt.*;
import javax.swing.*;

/**
  * Class to handle textfields with scrollbars visible if needed
  * Extends a scrollPane and features call-through functions
  * to a composite JTextArea
  * @author Kristofer Cassel
  * @version 1.0
  */
public class MyTextArea extends JScrollPane
{
  JTextArea textArea = new JTextArea();

  public MyTextArea()
  {
    super();
    this.getViewport().add(textArea, null);
  }

  public void setText(String str)
  {
    textArea.setText(str);
  }

  public String getText()
  {
    return textArea.getText();
  }

  public void setCaretPosition(int i)
  {
    textArea.setCaretPosition(i);
  }

  public int getCaretPosition()
  {
    return textArea.getCaretPosition();
  }

  public void insert(String str)
  {
    textArea.insert(str, getCaretPosition());
  }

  public void addKeyListener(java.awt.event.KeyAdapter adapt)
  {
    textArea.addKeyListener(adapt);
  }

  public void append(String str)
  {
    textArea.append(str);
  }
}