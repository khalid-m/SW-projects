package jspamos.course_manager;

import java.util.Hashtable;
import callin.*;

public class SelectStudent extends jspamos.FormManager {
  private String pn = "";
  private String fullName = "";
  private String email = "";

  public String getSelectedStudent() {
    String selected = null;
    if (! pn.equals("")) {
      selected = pn;
    } else if (! fullName.equals("")) {
      selected = fullName;
    } else if (! email.equals("")) {
      selected = email;
    }
    return selected;
  }

  /**
   * Gets the value of pn
   *
   * @return the value of pn
   */
  public String getPn()  {
    return this.pn;
  }

  /**
   * Sets the value of pn
   *
   * @param argPn Value to assign to this.pn
   */
  public void setPn(String argPn) {
    this.pn = argPn;
  }

  /**
   * Gets the value of fullName
   *
   * @return the value of fullName
   */
  public String getFullName()  {
    return this.fullName;
  }

  /**
   * Sets the value of fullName
   *
   * @param argFullName Value to assign to this.fullName
   */
  public void setFullName(String argFullName) {
    this.fullName = argFullName;
  }

  /**
   * Gets the value of email
   *
   * @return the value of email
   */
  public String getEmail()  {
    return this.email;
  }

  /**
   * Sets the value of email
   *
   * @param argEmail Value to assign to this.email
   */
  public void setEmail(String argEmail) {
    this.email = argEmail;
  }
}
