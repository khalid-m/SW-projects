package Goovi;

import java.awt.*;
import jclass.bwt.*;
import java.util.*;
import javax.swing.*;
import callin.*;

/**
  * Class with utility methods. All static
  *
  * @author Kristofer Cassel
  */
public abstract class Tools {

private static final String[] metaTypes =
  new String[] { "TYPE", "DERIVEDTYPE", "STOREDTYPE", "PROXYTYPE", "IUT"};

private static final String[] dataSources =
  new String[] { "AMOS", "STEP", "DTD", "ODBC_DS", "JDBC", "RELATIONAL"};

public static final int indexOf(String[] ar, String s)
{
  if (ar == null) return -1;
  for (int i=0; i < ar.length; i++)
    if ( ar[i].equalsIgnoreCase(s) ) return i;
  return -1;
}

public static final String makeCommalist(Object[] list)
{
  String res = "";
  for (int i=0; i < list.length; i++)
  {
    res += list[i];
    if (i != list.length-1) res += ", ";
  }
  return res;
}

public static final StringVector getVariables(StringVector v)
{
    int count = 2;
    StringVector result = new StringVector();
    for (int i=0; i < v.size(); i++)
    {
      int j=0;
      String name = v.at(i), tempvar;

      do
      {
        tempvar = name.toLowerCase().substring(0,j+1);
        j++;
      }
      while (result.indexOf(tempvar) >= 0 && j < name.length() && j<4);

      if (j == name.length()) // add counter suffix since nothing else worked
      {
        tempvar = tempvar + count;
        count++;
      }
      result.add(tempvar);
    }
    return result;
}

public static final boolean showConfirmDialog(Frame frame, String text)
{
  return (JOptionPane.showConfirmDialog(frame, text, "Goovi Confirm dialog", JOptionPane.YES_NO_OPTION) ==
          JOptionPane.YES_OPTION);
}

public static final void showMessageDialog(Component c, String text)
{
  JOptionPane.showMessageDialog(c, text, "Goovi Message dialog", JOptionPane.INFORMATION_MESSAGE);
}

public static final void showErrorDialog(Component c, Exception err)
{
  showErrorDialog(c, err, "");
}

public static final void showErrorDialog(Exception err)
{
  showErrorDialog(null, err, "");
}

public static final void showErrorDialog(Component c, Exception err, String msg)
{
  if (msg == null) msg = "";
  msg = msg.trim();
  msg = "Error: \n" + msg + "\n" + err;
  showErrorDialog( c, msg );
  err.printStackTrace(); // !!!!! remove later
}

public static final void showErrorDialog(Component c, String text)
{
  if (text == null) text = "";
  text = text.trim();
  if (text.equals("")) text = "Error";
  JOptionPane.showMessageDialog(c, text, "Goovi Error message", JOptionPane.ERROR_MESSAGE);
}

public static final String showInputDialog(Component c, String text, String defText)
{
  return (String)(JOptionPane.showInputDialog(
    c, text, "Goovi Input dialog", JOptionPane.PLAIN_MESSAGE, null, null, defText
    ));
}

public static final String showInputDialog(Component c, String text)
{
  return showInputDialog(c, text, "");
}

public static final void changeCursor(Cursor cur, Container c)
{
  do c.setCursor(cur);
  while ((c = c.getParent()) != null);
}// end changeCursor

public static final boolean isDatasource(String typename)
{
  return (indexOf(dataSources, typename) != -1);
}

public static final void inspectNode(AmosNode nd, TypeBrowser typeBrowser) throws Exception
{
    try
    {
      if (typeBrowser == null) throw new GooviException("Lost connection to TypeBrowser");
      String typename = nd.getType();
      Oid oid = nd.getOid();
      if (isDatasource(typename))
      {
        new DatasourceInspector(typeBrowser, oid);
        return;
      }
      else if (indexOf(metaTypes, typename) != -1)
      {
        new TypeInspector( typeBrowser, oid );
        return;
      }
      else if ( typename.equalsIgnoreCase("FUNCTION") )
      {
        inspectFunction(nd, typeBrowser);
        return;
      }
      // open an object inspector for other objects
      else if (oid != null) new ObjectInspector(typeBrowser, oid);
    }
    catch( Exception err )
    {
      showErrorDialog(typeBrowser, err, "Failed to inspectNode "+nd);
    }
}// end inspectNode

private static final void inspectFunction(AmosNode nd, TypeBrowser typeBrowser) throws Exception
{
     Oid funcOid = nd.getOid();
     String answer =
     typeBrowser.getAMOSInterface().callStringFunction("kindoffunction", funcOid);
     if ( answer.equalsIgnoreCase("generic") || answer.equalsIgnoreCase("overloaded") )
     {
          // launch overloadedFunctionInspector
          AmosOutliner tempOutline =
            new AmosOutliner(typeBrowser, "Resolvents");
          tempOutline.display(typeBrowser.getAMOSInterface().callFunction("resolvents", nd.getOid()));

          new AmosNodeChoser
            (typeBrowser, typeBrowser, "Goovi overloaded function inspector: " + nd + " " + nd.getOid(),
            tempOutline);
     }
     else // answer = stored
     {
        new FunctionInspector( typeBrowser, funcOid);
     }
}// end inspectFunction

}// end GooviTools
