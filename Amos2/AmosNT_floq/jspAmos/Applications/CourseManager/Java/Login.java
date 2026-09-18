/**
 * Describe class <code>Login</code> here.
 *
 * @author <a href="mailto:Timour.Katchaounov@it.uu.se"></a>
 * @version 1.0
 */

package jspamos.course_manager;

import callin.*;

public class Login extends jspamos.FormManager {

  private String userName;
  private String password;
  private User   theUser;

  public Login() {
    userName = "";
    password = "";
  }

  private void reset() {
    userName = "";
    password = "";
  }

  // Check user and password in the database
  public boolean validate(Connection db) {
    boolean authentic = false;
    try {
      theUser = User.getUser(db, userName);
      if (theUser != null) {
	authentic = User.authenticate(db, theUser, password,
				      "userName", "password",
				      errors);
      } else {
	authentic = false;
      }
    } catch (AmosException e) {
      errors.put("formError", e.toString());
      authentic = false;
      reset();
    }
    return authentic;
  }

  public String getUserType() {
    if (theUser != null)
      return theUser.getTypename();
    else
      return "";
  }

  /**
   * Get the userName value.
   * @return the userName value.
   */
  public String getUserName() {
    return userName;
  }

  /**
   * Set the userName value.
   * @param newUserName The new userName value.
   */
  public void setUserName(String newUserName) {
    this.userName = newUserName;
  }

  /**
   * Get the Password value.
   * @return the Password value.
   */
  public String getPassword() {
    return password;
  }

  /**
   * Set the Password value.
   * @param newPassword The new Password value.
   */
  public void setPassword(String newPassword) {
    this.password = newPassword;
  }
}
