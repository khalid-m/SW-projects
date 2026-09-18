package Goovi;

import jclass.bwt.*;
import java.util.*;
import java.awt.*;

/**
  * Class for a specialized outliner used in AmosOutliner class.
  * This outliner allows multiple selections and has a range of
  * extra methods.
  *
  * @author Kristofer Cassel
  */
class MyOutliner extends JCOutliner {

/**
  * Creates a MyOutliner object.
  *
  * @param root  The node to be the root.
  */
public MyOutliner(JCOutlinerNode root)
{
  super(root);
  setOutliner(new multiselectoutliner());
  setAllowMultipleSelections(true);
  setBackground(Color.white);
  setForeground(Color.black);
  setRootVisible(false);
  getVertScrollbar().setForeground(Color.black);

  setSmartScroll(false);
  getHorizScrollbar().setForeground(Color.black);
  getVertScrollbar().setBackground(Color.lightGray);
  getHorizScrollbar().setBackground(Color.lightGray);
  setScrollbarDisplay(jclass.bwt.JCScrolledWindow.DISPLAY_AS_NEEDED);
  setAutoSelect( false );
}

public void addColumn(String str)
{
  String[] ar = getColumnLabels();
  if (ar == null || ar.length == 0)
  {
    ar = new String[] { "" };
  }
  String[] ar2 = new String[ar.length+1];
  for (int i=0; i<ar.length; i++)
  {
    ar2[i]=ar[i];
  }
  ar2[ar.length] = str;
  setHeading(ar2);
}

public void setHeading(String[] ar)
{
  setColumnLabels(ar);
  setColumnButtons(ar);
  setNumColumns(ar.length);
}

public void insertColumn(AmosNode nd, Object str)
{
  nd.addColumn(str);
  folderChanged(nd);
}

public boolean existsColumn(String str)
{
  String[] ar = getColumnLabels();
  return (Tools.indexOf(ar, str) != -1);
}
public void removeColumn(String str)
{
  int index = Tools.indexOf( getColumnLabels(), str );
  removeColumnLabel(str);

  // traverse the tree and change the nodelabels (puh!)

  removeColumn(getRootNode(), index);
}

public void removeColumnLabel(String str)
{
  String[] ar = getColumnLabels();
  if (ar == null || ar.length == 0) return;
  int i = Tools.indexOf(ar, str);
  if (i == -1) return;
  String[] ar2 = new String[ar.length-1];
  for (int j=0, k=0; j<ar.length; j++) if (j != i) ar2[k++] = ar[j];

  if (ar2.length == 1 && ar2[0].trim().equals(""))
  {
    setColumnLabels(new String[] {});
    setNumColumns(1);
  }
  else setHeading(ar2);
}

public void removeColumn(JCOutlinerNode nd, int index)
{
  Object label = nd.getLabel();
  if (label instanceof Vector)
  {
    Vector v = (Vector)label;
    if (v.size()>index) v.removeElementAt(index);
  }
  Vector children = nd.getChildren();
  if (children != null)
  {
    for (int i=0; i<children.size(); i++)
    {
      removeColumn((JCOutlinerNode)(children.elementAt(i)), index);
    }
  }
}

// inner class to handle multiple selections in different folders
class multiselectoutliner extends JCOutlinerComponent
{
  protected boolean isMultiSelectable(JCOutlinerNode AmosNode, Event ev)
  {
      boolean modifiers =
                (ev != null ? ev.controlDown() : false) ||
                (ev != null ? ev.shiftDown() : false);

      if (AmosNode == null || !(modifiers)) return false;
      else return true;
  }// end isMultiSelectable
}// end class multiselectoutliner

public void deselectNode(JCOutlinerNode nd)
{
  if (!isSelected(nd)) return;
  Event evt
     = new Event(  this, System.currentTimeMillis(), 0, 0, 0, 0,Event.CTRL_MASK );
  selectNode( nd, evt );
}

public void deselectAll()
{
  JCOutlinerNode[] ar = getSelectedNodes();
  if (ar == null) return;
  for (int i=0; i<ar.length; i++) deselectNode(ar[i]);
}

public void selectNode(JCOutlinerNode theNode, JCOutlinerEvent event)
{
  AmosOutliner theOutliner = (AmosOutliner)event.getSource();
  AmosNode n = (AmosNode)event.getNode();
  if (isSelected(n)) return;
  Object src = event.getSource();
  // undo the selection of the node !
  Event evt
     = new Event(  src, System.currentTimeMillis(), event.getID(), 0, 0, 0,Event.CTRL_MASK );
 getOutliner().selectNode( theNode, evt );
}

public void selectNodeNamed(String name)
{
  selectNode( getAmosTree().findNode(name), (java.awt.Event)null );
}

public boolean isSelected(JCOutlinerNode nd)
{
  JCOutlinerNode[] nodeArray = this.getSelectedNodes();
  if (nodeArray == null) return false;
  for (int i=0; i < nodeArray.length; i++)
  {
    if (nodeArray[i].equals(nd)) return true;
  }
  return false;
}

protected AmosTree getAmosTree()
{
  return (AmosTree)getRootNode();
}

}// end MyOutliner