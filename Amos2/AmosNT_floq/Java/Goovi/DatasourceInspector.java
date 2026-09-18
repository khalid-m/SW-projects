package Goovi;

import java.awt.*;
import java.awt.event.*;
import jclass.bwt.*;
import java.util.*;
import callin.*;

/**
  * Class for a Datasource inspector dialog
  *
  * @author Kristofer Cassel
  */
public class DatasourceInspector extends Inspector {

  private AmosTree    theTree;
  private JCSplitterWindow mainSplitter = new JCSplitterWindow( BWTEnum.HORIZONTAL );
  private AmosOutliner importedOutliner, typesOutliner;
  private final static int MY_WIDTH = 500, MY_HEIGHT = 400;

/**
  * Constructor that creates a Datasource inspector
  *
  * @param tb The typebrowser that opened the CreateIntType dialog
  */
public DatasourceInspector(TypeBrowser tb, Oid theOid)
{
    super("Datasource", tb, theOid);
    try
    {
      if (exists) return;
      String typeName = oid.getName();
      typesOutliner    = new AmosOutliner( tb , "Types of"       );
      importedOutliner = new AmosOutliner( tb , "Imported types" );
      jbInit();
      refresh();
      this.packAndShow(MY_WIDTH, MY_HEIGHT ); // this launches a GUI-thread so no JNI-calls after this has finished!
    }
    catch (Exception err)
    {
      closeInspector();
      Tools.showErrorDialog(tb, err);
    }

}

  public void refresh()
  {
    try
    {
    typesOutliner.display(typeBrowser.getAMOSInterface().callFunction("typesof",oid));
    importedOutliner.display(typeBrowser.getAMOSInterface().callFunction("imported_types",oid));
    }
    catch(Exception e) { Tools.showErrorDialog(this, e, "Unable to refresh datasource-inspector."); }
  }

  private void jbInit() throws Exception
  {
    buttonPanel.add(refreshButton, null);
    buttonPanel.add(closeButton, null);

    importedOutliner.setPreferredSize(new Dimension(MY_WIDTH/2, MY_HEIGHT));
    typesOutliner.setPreferredSize(new Dimension(MY_WIDTH/2, MY_HEIGHT));

    this.getContentPane().add(mainSplitter, BorderLayout.CENTER);
    mainSplitter.add(typesOutliner,        null);
    mainSplitter.add(importedOutliner,   null);
  }
}



