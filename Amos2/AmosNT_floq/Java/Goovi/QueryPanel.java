package Goovi;

import java.awt.*;
import java.awt.event.*;
import java.util.*;
import callin.*;
import jclass.bwt.*;
import com.borland.jbcl.control.*;
import javax.swing.*;

/**
  * Class for the Query editors panel.
  *
  * @author Kristofer Cassel
  * @see Goovi.QueryWindow
  */
public class QueryPanel extends JPanel
{
  private int            queryPos     = 0;
  private StringVector   queries      = new StringVector();
  private AmosOutliner   resultOutline;
  public TypeBrowser     typeBrowser;

  public static Vector queryPanels = new Vector();

  JLabel queryLabel           = new JLabel();
  JPanel upperPanel           = new JPanel();
  JPanel buttonPanel          = new JPanel();
  BorderLayout upperBorderLayout = new BorderLayout();
  MyTextArea queryText        = new MyTextArea();
  JCSplitterWindow splitter   = new JCSplitterWindow( BWTEnum.VERTICAL );
  JButton backButton          = new JButton();
  JButton forwardButton       = new JButton();
  JButton clearButton         = new JButton();
  JButton helpButton          = new JButton();
  GridLayout gridLayout1     = new GridLayout();
  GridLayout mainGridLayout  = new GridLayout(1,1);
  JButton execButton = new JButton();

  public QueryPanel(TypeBrowser tb)
  {
    super();
    try
    {
      typeBrowser = tb;
      resultOutline = new AmosOutliner( tb, true );
      jbInit();
      updateQueryLabel();
      disableForward();
      disableBack();
      queryPanels.add(this);
      queries.add("");
    }
    catch(Exception err)
    {
      Tools.showErrorDialog(this, err, "Failed to open QueryPanel!");
    }
  }

  public void jbInit() throws Exception
  {
    this.setBackground(Color.lightGray);
    resultOutline.setBounds(new Rectangle(10, 10, 14, 14));
    gridLayout1.setColumns(4);

    execButton.setText("Execute");
    execButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        executeQuery();
      }
    });

    backButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        historyBack();
      }
    });

    forwardButton.setEnabled(false);
    forwardButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        historyForward();;
      }
    });
    helpButton.setText("Help");
    helpButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        help();
      }
    });

    clearButton.setText("Clear");
    clearButton.addActionListener(new java.awt.event.ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        clearText();
      }
    });
    queryText.addKeyListener(new java.awt.event.KeyAdapter()
    {
        public void keyPressed(KeyEvent e)
        {
          queryText_keyPressed(e);
        }
     });
    queryText.setFont( new Font( "Courier", Font.PLAIN, 12 ));


    backButton.setFont( new Font( "Dialog", 1, 17 ));
    upperPanel.setBounds  ( new Rectangle( 0, 0, 0, 0 ));

    backButton.setEnabled(false);
    backButton.setText("<");
    forwardButton.setFont(new Font("Dialog", 1, 17));
    forwardButton.setText(">");
    queryLabel.setText("Enter query:");

    upperPanel.setLayout(upperBorderLayout);
    buttonPanel.setLayout(new FlowLayout());
    buttonPanel.add(queryLabel, null);
    buttonPanel.add(backButton, null);
    buttonPanel.add(forwardButton, null);
    buttonPanel.add(helpButton,null);
    buttonPanel.add(clearButton, null);
    buttonPanel.add(execButton, null);
    upperPanel.setPreferredSize(new Dimension(500,100));
    upperPanel.add(buttonPanel,  BorderLayout.SOUTH);
    upperPanel.add(queryText, BorderLayout.CENTER);
    splitter.add(upperPanel, null);
    splitter.add(resultOutline, null);

    // splitter.setDividerLocation(0.5);
    splitter.setMinChildSize(80);

    this.setLayout(mainGridLayout);
    this.add(splitter);
  }

  public AmosOutliner getTheOutliner()
  {
    return resultOutline;
  }


  public static Vector getSelectedNodes()
  {
    Vector result = new Vector();
    for ( int i=0; i < queryPanels.size(); i++ )
    {
      QueryPanel qp = (QueryPanel)(queryPanels.elementAt(i));
      AmosOutliner ol = qp.resultOutline;
      if (ol != null)
      {
        JCOutlinerNode[] ar = ol.getSelectedNodes();
        if (ar != null)
        {
          for (int j=0; j<ar.length; j++)
          {
            result.addElement(ar[j]);
          }// end for j
        }// end if
      }// end if
    }// end for i
    return result;
  }

  public static Vector getSelectedNames()
  {
    Vector result = new Vector();
    for ( int i=0; i < queryPanels.size(); i++ )
    {
      QueryPanel qp = (QueryPanel)(queryPanels.elementAt(i));
      AmosOutliner ol = qp.resultOutline;
      if (ol != null)
      {
        JCOutlinerNode[] ar = ol.getSelectedNodes();
        if (ar != null)
        {
          for (int j=0; j < ar.length; j++)
          {
           result.addElement(ar[j].getLabelString());
          }// end for j
        }// end if
      }// end if
    }// end for i
    return result;
  }

  public void closeScan() throws AmosException
  {
    resultOutline.closeScan();
  }

  public void cleanUp() throws AmosException
  {
    resultOutline.closeAndSaveCashed(typeBrowser.getResultsOutliner());
  }

  private void historyForward()
  {
    if ( queryPos < queries.size() )
    {
      incQueryPos();
      enableBack();
      if (queryPos >= queries.size()-1) disableForward();
      queryRefresh();
    }
  }

  void clearText()
  {
    queryText.setText( "" );
    queryText.setCaretPosition( 0 );
  }

  private void historyBack()
  {
    if ( queryPos > 0 )
    {
      decQueryPos();
      if (queryPos == 0) disableBack();
      enableForward();
      queryRefresh();
    }
  }

  private final void incQueryPos()
  {
    queryPos++;
    updateQueryLabel();
  }

  private final void updateQueryLabel()
  {
    queryLabel.setText("Query # "+queryPos);
  }

  private final void decQueryPos()
  {
    queryPos--;
    updateQueryLabel();
  }

  private void enableBack()
  {
    backButton.setEnabled(true);
  }

  private void disableBack()
  {
    backButton.setEnabled(false);
  }

  private void enableForward()
  {
    forwardButton.setEnabled(true);
  }

  private void disableForward()
  {
    forwardButton.setEnabled(false);
  }


  void queryText_actionPerformed(ActionEvent e)
  {
  }// end queryTextActionPerformed

  private void queryRefresh()
  {
    try
    {
      if (queryPos == queries.size() )
      // empty editable query
      {
        queryText.setText("");
      }
      else
      {
        String querystr = (String)( queries.at(queryPos) );
        queryText.setText( querystr );
      }
    }
    catch (Exception err)
    {
      Tools.showErrorDialog(this, err, "Failed to do queryRefresh!");
    }
  }// end queryRefresh;

  private void executeQuery()
  {
    try
    {
      String querystr = queryText.getText().trim();

      if (querystr.equals("")) return;
      if (querystr.charAt(querystr.length()-1) != ';') querystr += ";";
      queries.set( queryPos, querystr );

      resultOutline.display(typeBrowser.getAMOSInterface().execute( querystr ));
      incQueryPos();
      if (queryPos == queries.size())
      {
        queries.add("");
        clearText();
        enableBack();
      }
    }
    catch (Exception err)
    {
      resultOutline.makeErrorIcon(err);
    }

  }

  private void queryTextPaste()
  {
    Vector v = typeBrowser.getTheOutliner().getSelectedNodesAsVector();
    if (pasteFromVector(v)) return;

    v = QueryPanel.getSelectedNodes();
    if (pasteFromVector(v)) return;
  }

  private boolean pasteFromVector(Vector v)
  {
    if (v != null && v.size() > 0)
    {
      AmosNode nd = (AmosNode)( v.elementAt(v.size()-1) );
      queryText.insert( nd.getLabelString() );
      return true;
    }
    else return false;
  }

  void queryText_keyPressed(KeyEvent e)
  {
    switch(e.getKeyCode())
    {
      case(KeyEvent.VK_ENTER):
        if (e.isControlDown()) executeQuery();
        break;
      case(KeyEvent.VK_F1):
        help();
        break;
      case(KeyEvent.VK_Y):
        if (e.isControlDown()) queryTextPaste();
        break;
      case(KeyEvent.VK_LEFT):
        if (e.isAltDown() && backButton.isEnabled()) historyBack();
        break;
      case(KeyEvent.VK_RIGHT):
        if (e.isAltDown() && forwardButton.isEnabled()) historyForward();
        break;
    }// end switch
  }

  void help()
  {
    String msg = "Shortcuts in the query textfield:\n";
    msg += "\nCTRL-ENTER   - execute";
    msg += "\nENTER        - new line";
    msg += "\nCTRL-y       - paste the label of marked node";
    msg += "\nF1           - help";
    msg += "\nALT-CUR.LEFT - history back";
    msg += "\nALT-CUR.RIGHT- history forward";
    msg += "\nCTRL-c       - copy to system clipboard";
    msg += "\nCTRL-v       - paste from system clipboard";
    msg += "\nCTRL-a       - select all";

    Tools.showMessageDialog( typeBrowser, msg );
  }

}