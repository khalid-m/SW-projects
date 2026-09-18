package jspamos;

import java.util.Hashtable;

/**
 * Base class for all bean-like classes that represent forms.
 *
 * <DL><DT><B>CVS Info:</B><DD>
 * $RCSfile: FormManager.java,v $
 * $State: Exp $ $Locker:  $
 * </DD></DT></DL>
 * @author  (c) 2003 Timour Katchaounov, UDBL
 * @version $Revision: 1.1 $, $Date: 2003/12/05 11:50:48 $
 */
 
public class FormManager {
  protected Hashtable errors;

  public FormManager() {
    errors = new Hashtable();	
  }

  public String getError(String field) {
    String errorMsg = (String) errors.get(field.trim());
    return (errorMsg == null) ? "" : errorMsg;
  }
}
