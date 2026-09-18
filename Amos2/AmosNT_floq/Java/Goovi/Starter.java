package Goovi;

import callin.*;
import callout.*;
import java.awt.*;
import javax.swing.*;

/**
  * Class for initializing and starting Goovi
  * also conatins entry point for AMOS-callout
  * function goovi()
  *
  * @author Kristofer Cassel
  */
public class Starter
{

  public Starter() {}

  // GOOVI main program
  public static void main(String[] args) throws AmosException
  { 
    TypeBrowser.callout = false;
    try
    {
      AmosInterface.initializeAmos(args);  // only do once!!
      init();
    }
    catch (Exception e)
    {
      System.out.println("Image file (.dmp) not found.");
    }
  }

  private static void init() throws Exception
  {     
    try
    {
      // UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
    }
    catch (Exception e) {} // only cosmetic stuff ... if it fails - who cares?
    IconHandler.init();
    new TypeBrowser("");
  }

  public void calloutMain(CallContext cxt, Tuple tpl) throws Exception
  {
    TypeBrowser.callout = true;
    init(); // no AmosInterface.initialize here !

    /* Scan tmpScan;
    Tuple t;

    // Pick up the argument
    String query = tpl.getStringElem(0);

    // Execute the query
    Connection tmpConnection = new Connection("");
    tmpScan = tmpConnection.execute(query);

    while (!tmpScan.eos()) {
      t = tmpScan.getRow();
      tpl.setElem(1, t.getElem(0));
      cxt.emit(tpl);
      tmpScan.nextRow();
    }  */

  }
}
