package jspamos;

import java.util.Hashtable;

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
