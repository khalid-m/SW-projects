package jspamos.course_manager;

import java.util.Hashtable;
import callin.*;

public class RegisterStudent extends jspamos.FormManager {

  private String firstName;
  private String lastName;
  private String personalNumber;
  private String email;
  private String userName;
  private String password1;
  private String password2;

  public RegisterStudent() {
    firstName = "";
    lastName = "";
    personalNumber = "";
    email = "";
    userName = "";
    password1 = "";
    password2 = "";
  }

  public boolean validate(Connection db) {
    boolean isValid = true;

    if (firstName.equals("")) {
      errors.put("firstName", "Please enter your first name");
      isValid = false;
    }

    if (lastName.equals("")) {
      errors.put("lastName", "Please enter your last name");
      isValid = false;
    }

    if (personalNumber.length() != 10) {
      if (! personalNumber.equals("none")) {
	errors.put("personalNumber",
		   "Please enter the ten digits of your personal number,<br> " +
		   "or 'none' if you don't have one");
	isValid = false;
      }
    } else {
      try {
	Long.parseLong(personalNumber);
      } catch (NumberFormatException e) {
	errors.put("personalNumber",
		   "Your personal number must contain only digits " +
		   "without any separators");
	isValid = false;
      }
    }
	
    if (email.equals("") || email.indexOf('@') < 2) {
      errors.put("email", "Please enter a valid e-mail address");
      isValid = false;
    }

    if (userName.length() < 3) {
      errors.put("userName",
		 "Please enter a username with at least 3 characters");
      isValid = false;
    }

    if (password1.length() < 3) {
      errors.put("password1",
		 "Please enter a password with at least 3 characters");
      isValid = false;
    }
	
    if (!password1.equals(password2)) {
      errors.put("password2", "Please confirm your password");
      isValid = false;
    }

    // Check if there is already a user with the same username
    try {
      User theUser = User.getUser(db, userName);
      if (theUser != null) {
	errors.put("userName",
		   "A user with the same username already exists. "+
		   "Please pick a different username.");
	isValid = false;
      }
    } catch (AmosException e) {
	errors.put("formError",
		   "An error occured when checking username: " + e);
	isValid = false;
    }

    return isValid;
  }

  public boolean createStudent(Connection db) {
    Student s = null;
    boolean result = true;

    try {
      s = Student.createStudent(db,
				firstName,
				lastName,
				userName,
				password1,
				email,
				personalNumber);
      if (s != null) {
	db.execute("commit;");
      } else {
	result = false;
      }
    } catch (AmosException e) {
      result = false;
    }

    return result;
  }

  /**
   * Gets the value of firstName
   *
   * @return the value of firstName
   */
  public String getFirstName()  {
    return this.firstName;
  }

  /**
   * Sets the value of firstName
   *
   * @param argFirstName Value to assign to this.firstName
   */
  public void setFirstName(String argFirstName) {
    this.firstName = argFirstName;
  }

  /**
   * Gets the value of lastName
   *
   * @return the value of lastName
   */
  public String getLastName()  {
    return this.lastName;
  }

  /**
   * Sets the value of lastName
   *
   * @param argLastName Value to assign to this.lastName
   */
  public void setLastName(String argLastName) {
    this.lastName = argLastName;
  }

  /**
   * Gets the value of personalNumber
   *
   * @return the value of personalNumber
   */
  public String getPersonalNumber()  {
    return this.personalNumber;
  }

  /**
   * Sets the value of personalNumber
   *
   * @param argPersonalNumber Value to assign to this.personalNumber
   */
  public void setPersonalNumber(String argPersonalNumber) {
    this.personalNumber = argPersonalNumber;
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
   * @param argEMail Value to assign to this.email
   */
  public void setEmail(String argEmail) {
    this.email = argEmail;
  }

  /**
   * Gets the value of userName
   *
   * @return the value of userName
   */
  public String getUserName()  {
    return this.userName;
  }

  /**
   * Sets the value of userName
   *
   * @param argUserName Value to assign to this.userName
   */
  public void setUserName(String argUserName) {
    this.userName = argUserName;
  }

  /**
   * Gets the value of password1
   *
   * @return the value of password1
   */
  public String getPassword1()  {
    return this.password1;
  }

  /**
   * Sets the value of password1
   *
   * @param argPassword1 Value to assign to this.password1
   */
  public void setPassword1(String argPassword1) {
    this.password1 = argPassword1;
  }

  /**
   * Gets the value of password2
   *
   * @return the value of password2
   */
  public String getPassword2()  {
    return this.password2;
  }

  /**
   * Sets the value of password2
   *
   * @param argPassword2 Value to assign to this.password2
   */
  public void setPassword2(String argPassword2) {
    this.password2 = argPassword2;
  }
}
