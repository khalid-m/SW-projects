package Goovi;

import java.awt.*;
import java.awt.event.*;
import jclass.bwt.*;
import java.util.*;
import callin.*;
import javax.swing.*;

/**
  * Class for a Type inspector dialog
  *
  * @author Kristofer Cassel
  */
public class TypeInspector extends Inspector  {

private AmosTree    theTree;
private JButton addFunctionButton = new JButton();
private JCSplitterWindow
            mainSplitter = new JCSplitterWindow( BWTEnum.HORIZONTAL ),
            leftSplitter = new JCSplitterWindow( BWTEnum.VERTICAL   );
private AmosOutliner supertypesOutliner, datasourceOutliner;
private FunctionsOutliner functionsOutliner;
private InstancesOutliner instancesOutliner;

private final static int MY_WIDTH = 710, MY_HEIGHT = 420;

public TypeInspector(TypeBrowser tb, Oid theTypeOid)
{
    super("Type", tb, theTypeOid);

    try
    {
      if (exists) return;

      String typeName    = oid.getName();
      functionsOutliner  = new FunctionsOutliner( tb );
      supertypesOutliner = new AmosOutliner( tb , "Supertypes");
      instancesOutliner  = new InstancesOutliner( tb );
      datasourceOutliner = new AmosOutliner( tb, "Datasource");

      jbInit();

      refresh();

      this.packAndShow(MY_WIDTH, MY_HEIGHT); // this launches a GUI-thread so no JNI-calls after this has finished!
    }
    catch (Exception err)
    {
      closeInspector();
      Tools.showErrorDialog(tb, err);
    }
}

  private void refreshDatasources() throws AmosException
  {
    datasourceOutliner.display(typeBrowser.getAMOSInterface().callFunction("datasource", oid));
  }

  private void refreshSupertypes()
  {
     try
      {
        supertypesOutliner.display
          (typeBrowser.getAMOSInterface().callFunction("real_supertypes", oid));
      }
      catch(Exception err)
      {
        supertypesOutliner.makeErrorIcon(err);
      }
  }

  private void jbInit() throws Exception
  {
    addFunctionButton.setText("Add method");
    addFunctionButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        addFunctionButton_actionPerformed(e);
      }
    });

    buttonPanel.add( addFunctionButton   );
    buttonPanel.add( refreshButton       );
    buttonPanel.add( closeButton        );

    /* leftSplitter.setPreferredSize(new Dimension(MY_WIDTH/4, MY_HEIGHT));
    instancesOutliner.setPreferredSize(new Dimension(MY_WIDTH/4, MY_HEIGHT));
    supertypesOutliner.setPreferredSize(new Dimension(MY_WIDTH/4, MY_HEIGHT/2));
    functionsOutliner.setPreferredSize(new Dimension(MY_WIDTH/2, MY_HEIGHT)); */

    this.getContentPane().add(mainSplitter, BorderLayout.CENTER);
    mainSplitter.add(leftSplitter,          null);
    leftSplitter.add(supertypesOutliner,    null);
    leftSplitter.add(datasourceOutliner,    null);
    mainSplitter.add(instancesOutliner,     null);
    mainSplitter.add(functionsOutliner   ,  null);
  }

  /**
    * Close inspector and save cashed nodes to the type browser outliners.
    */
  public void closeInspector()
  {
    try
    {
      instancesOutliner.closeAndSaveCashed(typeBrowser.getInstancesOutliner());
      functionsOutliner.closeAndSaveCashed(typeBrowser.getFunctionsOutliner());
      super.closeInspector();
    }
    catch(Exception e) { Tools.showErrorDialog(this, e, "Couldn't close Typeinspector."); }
  }

  private void addFunctionButton_actionPerformed(ActionEvent e)
  {
    try
    {
      new FunctionInspector(typeBrowser, new StringVector(oid.getName()));
    }
    catch (Exception err) { Tools.showErrorDialog( typeBrowser, err ); }
  }

  /**
    * Refresh the outliners in the type inspector.
    * Called when pressing the refresh button or by opening
    * an old inspector again.
    */
  public void refresh()
  {
   try
   {
    functionsOutliner.refresh(oid);
    instancesOutliner.refresh(oid);
    refreshDatasources();
    refreshSupertypes();
   }
   catch (Exception e)
   {
    Tools.showErrorDialog(this, e, "Failed to refresh");
   }
  }
}// end TypeInspector



