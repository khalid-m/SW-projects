package Goovi;

import jclass.bwt.*;
import java.util.*;
import java.awt.*;
import callin.*;

/**
  * Class to represent a tree of AmosNodes
  *
  * @author Kristofer Cassel
  * @version 1.0
  */


public class AmosTree extends AmosNode {

/**
 * Creates a AmosTree object.
 */
public AmosTree()
{
  super();
}

public AmosNode getRoot()
{
  return this;
}

public String getRootName()
{
  return this.getLabelString();
}

/**
 * Finds a named AmosNode in the tree.
 *
 * @param nodeName  The name label of the node to be find.
 */
public AmosNode findNode( String nodeName )
{
  return findNode(nodeName, this);
}

/**
 * Finds a named AmosNode in the tree.
 *
 * @param nodeName    The name label of the node to be find.
 * @param currentNode The node where to start the recursive search. 
 */
public AmosNode findNode( String nodeName, AmosNode currentNode )
{
  String name = currentNode.getLabelString();
  if ( name.equalsIgnoreCase(nodeName) ) return (AmosNode)currentNode;
  if ( currentNode.isFolder() )
  {
     Vector v = currentNode.getChildren();
     for (int i=0; i < v.size(); i++)
     {
          AmosNode n = findNode(nodeName, (AmosNode)v.elementAt(i));
          if (n != null) return n;
     }
  }
  return null;
}

/**
 * Adds a node directly to the root.
 *
 * @param nodeToAdd The node to add.
 */
public void addChild(AmosNode nodeToAdd)
{
  addChild(this, nodeToAdd);
}

/**
 * Adds a node to a specified node and opens the parent and makes
 * the parent a folder if necessary.
 *
 * @param parent    The parent node.
 * @param nodeToAdd The node to add.
 */
public void addChild(AmosNode parent, AmosNode nodeToAdd )
{
  parent.addNode( nodeToAdd );
  parent.setState( BWTEnum.FOLDER_OPEN_ALL ); // make new child visible
  if (!parent.equals(this)) parent.setToFolder( true );
  nodeChanged( parent );
}

public void nodeChanged(JCOutlinerNode n)
{
  try
  {
    if (n == null) return;
    JCOutliner o = n.getOutliner();
    if (o != null)
    {
      o.folderChanged( n );
    }
  }
  catch(Exception err)
  {
    // do nothing
  }
}

public void deleteNodes(JCOutlinerNode[] ar)
{
  for (int i=0; i<ar.length; i++) deleteAllNodes((AmosNode)ar[i]);
}

private final void deleteAllNodes(AmosNode toBeRemoved)
{
  if (toBeRemoved == null || toBeRemoved.equals(getRoot())) return; // don't delete the root
  try
  {
    // this statement goes wrong sometimes (!)
    if (!toBeRemoved.getStyle().getFont().isPlain())
    {
      // no multiple inheritance
      deleteNode(toBeRemoved);
      return;
    }
  }
  catch (Exception err) {}
  finally
  {
    // multiple inheritance
    String name = toBeRemoved.getLabelString();
    while ((toBeRemoved = findNode(name)) != null) // remove all nodes named name
    {
       deleteNode(toBeRemoved);
    }
  }
}

private void deleteNode(AmosNode toBeRemoved)
{
    AmosNode parent = (AmosNode)(toBeRemoved.getParent());
    parent.removeChild(toBeRemoved);
    if (parent.getChildren() == null ||
        parent.getChildren().isEmpty()) // parent has become a leaf!
      parent.setToFolder( false );
    nodeChanged(parent);
}

public void makeAllNodesVisibleNamed(String name)
{
  makeAllNodesVisibleNamed(name, this);
  nodeChanged(this);
}

public void makeAllNodesVisibleNamed(String name, AmosNode currentNode)
{
  if ( currentNode.getLabelString().equals(name) )
  {
    makeNodeVisible( currentNode );
  }
  Vector v = currentNode.getChildren();
  if ( v == null ) return;
  for ( int i = 0; i < v.size( ); i++ )
  {
    makeAllNodesVisibleNamed( name, (AmosNode)v.elementAt(i) );
  }
}

public void makeNodeVisible(AmosNode theNode)
{
  AmosNode nd = theNode;
  while (!( nd.equals( this ) ))
  {
    nd = (AmosNode)(nd.getParent());
    nd.setState(BWTEnum.FOLDER_OPEN_ALL);
    nodeChanged(nd);
  }
  JCOutliner o = theNode.getOutliner();
  if (o != null)
  {
    o.makeNodeVisible(theNode);
  }
}

}// end class AmosTree