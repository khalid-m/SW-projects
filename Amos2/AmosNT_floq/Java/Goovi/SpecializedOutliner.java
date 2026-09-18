package Goovi;

import javax.swing.*;
import java.awt.event.*;
import callin.*;
import java.awt.*;

/**
  * BaseClass for the specialized outliners containing attributes
  * and refresh functionallity.
  *
  * @author Kristofer Cassel
  */
public abstract class SpecializedOutliner extends AmosOutliner
{
  protected Oid currOid;
  protected TypeBrowser typeBrowser;

  public SpecializedOutliner(TypeBrowser tb)
  {
    super(tb, true);
    typeBrowser = tb;
  }

  public void refresh()
  {
    if (currOid == null) return; else refresh(currOid);
  }

   public void refresh(Oid oid)
  {
    if (oid != null) currOid = oid;
    else
    {
      if (currOid != null) oid = currOid; // try this!
      else return; // only nulls !!
    }
    refreshInternal(oid);
  }

  protected abstract void refreshInternal(Oid oid);
}
