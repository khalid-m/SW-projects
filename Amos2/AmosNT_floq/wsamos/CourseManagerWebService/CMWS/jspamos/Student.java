package jspamos;

import callin.*;

public class Student extends User{

  protected Student() {
  }

  public int getGroup()
    throws AmosException
  {
    Connection con = this.getConnection();
    Scan theScan;
    theScan = con.callFunction("STUDENT.GROUP->INTEGER", this);
    if(!theScan.eos()){
      return theScan.getRow().getIntElem(0);
    } else {
      return -1;
    }
  }

  public boolean getHasdbaccount()
    throws AmosException
  {
    Connection con = this.getConnection();
    Scan theScan;
    theScan = con.callFunction("STUDENT.HASDBACCOUNT->BOOLEAN", this);
    if(!theScan.eos()){
      return theScan.getRow().getBooleanElem(0);
    } else {
      return false;
    }
  }

  public Student(Oid o)
    throws AmosException
  {
    this.CopyProps(o);
  }

  /* Create a new student in the database */
  public static Student createStudent(Connection c,
				      String firstName,
				      String lastName,
				      String userName,
				      String password,
				      String email,
				      String personalNumber)
    throws AmosException
  {
    Tuple arg = new Tuple(6);
    Scan theScan = new Scan();

    arg.setElem(0, firstName);
    arg.setElem(1, lastName);
    arg.setElem(2, userName);
    arg.setElem(3, password);
    arg.setElem(4, email);
    arg.setElem(5, personalNumber);

    theScan = c.callFunction("student", arg);

    if (theScan.eos()) {
      return null;
    } else {
      Oid o = theScan.getRow().getOidElem(0);
      return new Student(o);
    }
  }

  /* Get a student by his name */
  public static Student getStudentNamed(Connection c, String name)
    throws AmosException
  {
    Scan theScan;
    theScan = c.callFunction("CHARSTRING.STUDENTNAMED->STUDENT",
			     new Tuple(name));
    if(!theScan.eos()) {
      Oid o = theScan.getRow().getOidElem(0);
      return new Student(o);
    } else {
      return null;
    }
  }

  public static Student getStudentElem(int i, Connection c)
    throws AmosException
  {
    Oid o = c.getObjectNumbered(i);
    return new Student(o);
  }


  /*****************************************************************************
   * Generated code below. Move modified methods above this comment.
   *****************************************************************************/

  // Instead use the Connection object of Oid
  //private static Connection con;

  public Student(Connection c) throws AmosException{
    super(c, c.getType("Student"));
    //con = c;
  }

  public StringScan getStatus() throws AmosException{
    Connection con = this.getConnection();
    return new StringScan(con.callFunction("STUDENT.STATUS->CHARSTRING", this), con);
  }

  public TupleScan getStudentinfo() throws AmosException{
    Connection con = this.getConnection();

    return new TupleScan(con.callFunction("STUDENT.STUDENTINFO->CHARSTRING.CHARSTRING.CHARSTRING.INTEGER.CHARSTRING", this), con);
  }

  public void setHasdbaccount(boolean a0) throws AmosException{
    Connection con = this.getConnection();
    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.setFunction("Hasdbaccount",arg,res);
  }

  public void addHasdbaccount(boolean a0) throws AmosException{
    Connection con = this.getConnection();
    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.addFunction("Hasdbaccount",arg,res);
  }

  public void removeHasdbaccount(boolean a0) throws AmosException{
    Connection con = this.getConnection();
    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.remFunction("Hasdbaccount",arg,res);
  }

  public StringScan getPn() throws AmosException{
    Connection con = this.getConnection();
    return new StringScan(con.callFunction("STUDENT.PN->CHARSTRING", this), con);
  }

  public void setPn(String a0) throws AmosException{
    Connection con = this.getConnection();
    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.setFunction("Pn",arg,res);
  }

  public void addPn(String a0) throws AmosException{
    Connection con = this.getConnection();
    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.addFunction("Pn",arg,res);
  }

  public void removePn(String a0) throws AmosException{
    Connection con = this.getConnection();
    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.remFunction("Pn",arg,res);
  }

  public TupleScan getAssignmentstatus() throws AmosException{
    Connection con = this.getConnection();
    return new TupleScan(con.callFunction("STUDENT.ASSIGNMENTSTATUS->INTEGER.CHARSTRING.CHARSTRING", this), con);
  }

  public void setGroup(int a0) throws AmosException{
    Connection con = this.getConnection();
    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.setFunction("Group",arg,res);
  }

  public void addGroup(int a0) throws AmosException{
    Connection con = this.getConnection();
    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.addFunction("Group",arg,res);
  }

  public void removeGroup(int a0) throws AmosException{
    Connection con = this.getConnection();
    Tuple arg = new Tuple(1);
    Tuple res = new Tuple(1);

    arg.setElem(0,this);
    res.setElem(0,a0);
    con.remFunction("Group",arg,res);
  }

  public void delete() throws AmosException{
    Connection con = this.getConnection();
    con.deleteObject(this);
  }
}
