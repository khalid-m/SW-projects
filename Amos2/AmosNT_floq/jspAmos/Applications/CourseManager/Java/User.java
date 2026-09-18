package jspamos.course_manager;

import java.util.Hashtable;
import callin.*;

public class User extends Oid {

  protected User() {
  }

  private User(Connection c) throws AmosException{
    super(c.getType("User"));
  }

  public static boolean authenticate(Connection db,
				     User theUser,
				     String password,
				     String userField,
				     String passField,
				     Hashtable err)
  {
    boolean isValid = true;
    try {
      if (theUser != null) {
	String pass = theUser.getPassword();
	if (pass == null) {
	  err.put(passField,
		  "This user has no password. Contact your administrator.");
	  isValid = false;
	} else if (! pass.equals(password)) {
	  err.put(passField, "Invalid password");
	  isValid = false;
	}
      } else {
	err.put(userField, "Invalid username");
	isValid = false;
      }
    } catch (AmosException e) {
      err.put("exception", e.toString());
      isValid = false;
    }

    return isValid;
  }

  /* Get a user by his name */
  public static User getUser(Connection c, String name)
    throws AmosException
  {
    Scan theScan;
    theScan = c.callFunction("CHARSTRING.USERNAMED->USER",
				  new Tuple(name));
    if(!theScan.eos()){
      Oid o = theScan.getRow().getOidElem(0);
      User u = new User();
      u.CopyProps(o);
      return u;
    } else {
      return null;
    }
  }

  private String getPassword() throws AmosException {
    Scan theScan;
    theScan = this.getConnection().callFunction("USER.PASSWORD->CHARSTRING", this);

    if(!theScan.eos()) {
      return theScan.getRow().getStringElem(0);
    } else {
      return null;
    }
  }

  // This method is unnecessary
  public static User getUserElem(int i, Connection c)
    throws AmosException
  {
    User retType = new User();
    Oid o = c.getObjectNumbered(i);
    retType.CopyProps(o);
    return retType;
  }

  public String getFullname() throws AmosException{
    Scan theScan;
    theScan = this.getConnection().callFunction("USER.FULLNAME->CHARSTRING", this);
    if(!theScan.eos()) {
      return theScan.getRow().getStringElem(0);
    } else {
      return null;
    }
  }


  // This method is very deceiving: the object 'o' must be a TYPE object!
  public User(Connection c, Oid o) throws AmosException{
    super(o);
  }

  public StringScan getLastname() throws AmosException{
    Connection con = this.getConnection();
    return new StringScan(con.callFunction("USER.LASTNAME->CHARSTRING", this), con);
  }

  /*****************************************************************************
   * Generated code below. Move modified methods above this comment.
   *****************************************************************************/
  
  // What is this for?
  protected static void downCastConnect(Connection c){
    //con = c;
  }

  public void setLastname(String a0) throws AmosException{
    Connection con = this.getConnection();

    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.setFunction("Lastname",arg,res);
  }

  public void addLastname(String a0) throws AmosException{
    Connection con = this.getConnection();

    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.addFunction("Lastname",arg,res);
  }

  public void removeLastname(String a0) throws AmosException{
    Connection con = this.getConnection();

    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.remFunction("Lastname",arg,res);
  }

  public void setPassword(String a0) throws AmosException{
    Connection con = this.getConnection();

    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.setFunction("Password",arg,res);
  }

  public void addPassword(String a0) throws AmosException{
    Connection con = this.getConnection();

    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.addFunction("Password",arg,res);
  }

  public void removePassword(String a0) throws AmosException{
    Connection con = this.getConnection();

    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.remFunction("Password",arg,res);
  }

  public void setName(String a0) throws AmosException{
    Connection con = this.getConnection();

    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.setFunction("Name",arg,res);
  }

  public void addName(String a0) throws AmosException{
    Connection con = this.getConnection();

    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.addFunction("Name",arg,res);
  }

  public void removeName(String a0) throws AmosException{
    Connection con = this.getConnection();

    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.remFunction("Name",arg,res);
  }

  public StringScan getEmail() throws AmosException{
    Connection con = this.getConnection();

    return new StringScan(con.callFunction("USER.EMAIL->CHARSTRING", this), con);
  }

  public void setEmail(String a0) throws AmosException{
    Connection con = this.getConnection();

    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.setFunction("Email",arg,res);
  }

  public void addEmail(String a0) throws AmosException{
    Connection con = this.getConnection();

    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.addFunction("Email",arg,res);
  }

  public void removeEmail(String a0) throws AmosException{
    Connection con = this.getConnection();

    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.remFunction("Email",arg,res);
  }

  public StringScan getFirstname() throws AmosException{
    Connection con = this.getConnection();

    return new StringScan(con.callFunction("USER.FIRSTNAME->CHARSTRING", this), con);
  }

  public void setFirstname(String a0) throws AmosException{
    Connection con = this.getConnection();

    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.setFunction("Firstname",arg,res);
  }

  public void addFirstname(String a0) throws AmosException{
    Connection con = this.getConnection();

    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.addFunction("Firstname",arg,res);
  }

  public void removeFirstname(String a0) throws AmosException{
    Connection con = this.getConnection();

    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.remFunction("Firstname",arg,res);
  }

  public void delete() throws AmosException{
    Connection con = this.getConnection();

    con.deleteObject(this);
  }

}
