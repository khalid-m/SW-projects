package Goovi;

import callin.*;

/**
  * Class for the cashing of AmosNodes used in the AmosOutliner
  *
  * @author Kristofer Cassel
  */

public class NodeCash
{

  public NodeCash()
  {
  }

private static final int CASH_SIZE = 0;

// cashes OIDs for reuse by this AmosOutliner instance only
private AmosNode[] amosNodes = new AmosNode[CASH_SIZE];

public final AmosNode get(Oid oid, boolean isFolder) throws AmosException
{
  int key = oid.getID();
  if (key >= CASH_SIZE) return new AmosNode(oid, isFolder);
  AmosNode nd = amosNodes[key];
  if (nd == null)
  {
    nd = new AmosNode( oid, isFolder );
    amosNodes[key] = nd; // don't use put 'coz to slow
    return nd;
  }
  nd.removeChildren(); // return just the node
  nd.setToFolder( isFolder );
  return nd;
}

public final void put(AmosNode nd)
{
  try
  {
    int key = nd.getOid().getID();
    if (key >= CASH_SIZE) return;
    amosNodes[key] = nd;
  }
  catch(Exception e)
  {}
}

public final void clear()
{
  int count = 0;
  for (int i = 0; i < CASH_SIZE; i++)
  {
    if (amosNodes[i] != null)
    {
      count++;
      amosNodes[i] = null;
    }
  }
  Tools.showMessageDialog(null, "" + count + " cashed AmosNodes removed from cash.");
}

}// end class NodeCash