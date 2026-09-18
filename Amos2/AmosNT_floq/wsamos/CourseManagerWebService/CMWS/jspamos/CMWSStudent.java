package jspamos;

import callin.*;

public class CMWSStudent extends jspamos.FormManager {

  private String userName;
  private String password;
  
  public static final int minStudentsPerGroup = 1;
  public static final int maxStudentsPerGroup = 3;
  String[] students = new String[maxStudentsPerGroup];
  String[] passwords = new String[maxStudentsPerGroup];
  Student[] studObjects = new Student[maxStudentsPerGroup];
  private int studCount = 0;
  private String assistantFullName;
  private int groupNo;
  
  private User theUser = null;
  private Amos amosDB = new Amos();

  private void loginValidateReset() {
    userName = "";
    password = "";
  }

  // Check user and password in the database
  public String loginValidate(String usr,String pwd, String imageFileName, String serverName) {
	  boolean authenticated = false;
	  this.userName=usr;
	  this.password=pwd;
	Connection conn = amosDB.getConnection(imageFileName,serverName);
	String userType = null;
    //boolean authentic = false;
    try {
      theUser = User.getUser(conn, userName);
      if (theUser != null) {
    	  authenticated = User.authenticate(conn, theUser, password,
				      "userName", "password",
				      errors);
    	  if (authenticated == true){
    		  userType = getUserType();
    	  }
    	  else {
    		  userType = "NONE";
          }
      } else{
    	  userType = "NONE";
      }
      } catch (AmosException e) {
      errors.put("formError", e.toString());
      loginValidateReset();
      userType = "NONE";
    }
    return userType;
  }
  
  public int registerStudent(String firstName, String lastName, String userName, String email, String password1, String personalNumber,String imageFileName, String serverName){
	  if (registerStudentValidate(userName,imageFileName,serverName)){
		  if (createStudent(firstName,lastName,userName,email,password1,personalNumber,imageFileName,serverName)){
			  return 1; //create student successful
		  }
		  else return 2; //create student failed
	  }
	  else return 0;  //username already exist
  }
  
  public boolean registerStudentValidate(String usr, String imageFileName, String serverName) {
	    boolean isValid = true;
	    Connection conn = amosDB.getConnection(imageFileName,serverName);
	    // Check if there is already a user with the same username
	    try {
	      User theUser = User.getUser(conn, usr);
	      if (theUser != null) {
		//A user with the same username already exists.Please pick a different username.
		isValid = false;
	      }
	    } catch (AmosException e) {
		errors.put("formError","An error occured when checking username: " + e);
		isValid = false;
	    }
	    return isValid;
	  }
  
  public boolean createStudent(String firstName, String lastName, String userName, String email, String password1, String personalNumber,String imageFileName, String serverName) {
	    Student student = null;
	    boolean result = true;
	    Connection conn = amosDB.getConnection(imageFileName,serverName);
	    try {
	    	student = Student.createStudent(conn,
					firstName,
					lastName,
					userName,
					password1,
					email,
					personalNumber);
	      if (student != null) {
	    	  conn.execute("commit;");
	      } else {
		result = false;
	      }
	    } catch (AmosException e) {
	      result = false;
	    }
	    return result;
	  }
  
  public boolean registerGroup (String[] studentName, String[] password,String imageFileName, String serverName){
  this.students = studentName;
  this.passwords = password;
	//Count the students that want to register in the same group
	  for (int i = 0; i < maxStudentsPerGroup; i++) {
	    if (!students[i].equals("")) {
		++studCount;
	    }
	  }
	  if (registerGroupValidate(imageFileName, serverName)){
		  if (doRegister(imageFileName, serverName)){
			  return true;
		  }else {
			  return false;
		  }
	  }else{
		  return false;
	  }
  }
  /**
   * Check the group registration rules.
   *
   * @param db a <code>Connection</code> value
   * @return a <code>boolean</code> value
   */
  public boolean registerGroupValidate(String imageFileName, String serverName) {
    boolean isValid = true;
    Connection conn = amosDB.getConnection(imageFileName,serverName);
    // Authenticate the students
    try {
      boolean authenticated = false;
      for (int i = 0; i < maxStudentsPerGroup; i++) {
		if (!students[i].equals("")) {
		  studObjects[i] = Student.getStudentNamed(conn, students[i]);
		  authenticated = User.authenticate(conn,
						    studObjects[i],
						    passwords[i],
						    "student"+(i+1),
						    "password"+(i+1),
						    errors);
		  isValid = (isValid && authenticated);
		}
      }
      if (!isValid) {
    	  return false;
      }
    } catch (AmosException e) {
      errors.put("formError", e.toString());
      return false;
    }

    // Check if the students already participate in some group
    try {
      int currGrp;
      for (int i = 0; i < maxStudentsPerGroup; i++) {
		if (studObjects[i] != null) {
		  currGrp = studObjects[i].getGroup();
		  if (currGrp != -1) {
		    errors.put("student"+(i+1), "Already member of group: " + currGrp);
		    isValid = false;
		  }
		}
      }
      if (!isValid) {
    	  return false;
      }
    } catch (AmosException e) {
      errors.put("formError", e.toString());
      return false;
    }

    return isValid;
  }

  /**
   * Describe <code>doRegister</code> method here.
   *
   * @param db a <code>Connection</code> value
   * @return a <code>boolean</code> value
   * @exception AmosException if an error occurs
   */
  public boolean doRegister(String imageFileName, String serverName) {
    boolean result = true;
    Scan theScan = new Scan();
    int currStudIdx = 0;
    Connection conn = amosDB.getConnection(imageFileName,serverName);
    try {
      Tuple arg = new Tuple(1);
      Tuple vec = new Tuple(studCount);

      for (int i = 0; i < maxStudentsPerGroup; i++) {
	if (studObjects[i] != null) {
	  vec.setElem(currStudIdx, students[i]);
	  ++currStudIdx;
	}
      }

      arg.setElem(0, vec);

      theScan = conn.callFunction("updateGroup", arg);

      if (theScan.eos()) { // could not create the student
	result = false;
      } else {
	Tuple res;
	res = theScan.getRow().getSeqElem(0);
	groupNo = res.getIntElem(0);
	assistantFullName = res.getStringElem(1);
      }

      if (result) {
	// Connection.commit() doesn't autosave the image
    	  conn.execute("commit;");
      }
    } catch (AmosException e) {
      System.out.println(e);
      result = false;
    }

    return result;
  }
  
  public String listStudent(String imageFileName, String serverName){
	  String studentList = null;
	  Connection conn = amosDB.getConnection(imageFileName,serverName);
	  try {
	      Tuple arg = new Tuple(2);
	      arg.setElem(0, 3);
	      arg.setElem(1, "inc");
	      Scan theScan = conn.callFunction("INTEGER.CHARSTRING.LISTSTUDENTS->VECTOR",arg);
	      String colHeader = "<TR><TH>Name</TH><TH>e-mail</TH><TH>Group No.</TH><TR>";
	      studentList = jspamos.Utilities.resultToTable(theScan,"",colHeader);
	    } catch (Exception e ) {
	      System.out.println(e);
	      e.printStackTrace();
	    }
	  return studentList;
  }
  
  public String listLonelyStudent(String imageFileName, String serverName){
	  String studentList = null;
	  Connection conn = amosDB.getConnection(imageFileName,serverName);
	  try {
	      Tuple arg = new Tuple(2);
	      arg.setElem(0, 3);
	      arg.setElem(1, "inc");
	      Scan theScan = conn.callFunction("INTEGER.CHARSTRING.LISTLONELYSTUDENTS->VECTOR",arg);
	      String colHeader = "<TR><TH>Name</TH><TH>e-mail</TH><TH>Group No.</TH><TR>";
	      studentList = jspamos.Utilities.resultToTable(theScan,"",colHeader);
	    } catch (Exception e ) {
	      System.out.println(e);
	      e.printStackTrace();
	    }
	  return studentList;
  }

  public String listAssignmentStatus(String studentName,String imageFileName, String serverName){
	  String assignmentStatusList = null;
	  Connection conn = amosDB.getConnection(imageFileName,serverName);
	  try {
		  Scan theScan;
		  Tuple arg = new Tuple(1);

		  arg.setElem(0, studentName);
		  theScan = conn.callFunction("listGroupMembers", arg);
		  String colHeaderGroup = "<TR><TH>Name</TH><TH>e-mail</TH><TH>Group No.</TH><TR>";
		  String str1 = "Your group consists of:<br><br>";
		  String groupMemberReturn = jspamos.Utilities.resultToTable(theScan, "", colHeaderGroup);
		  String colHeaderAssignment = "<TR><TH>Assignment</TH><TH>Status</TH><TH>Assistant</TH><TR>";
		  String str2 = "<br><br>The results registered for your assignments are:<br><br>";
		  theScan = conn.callFunction("studentAssignmentStatus", arg);  
		  String assignmentStatueReturn = jspamos.Utilities.resultToTable(theScan, "", colHeaderAssignment);
		  assignmentStatusList = str1 + groupMemberReturn + str2 + assignmentStatueReturn; 
		} catch (Exception e) {
		  System.out.println(e);
		  e.printStackTrace();
		}
	  return assignmentStatusList;
  }
  
  public String getUserType() {
    if (theUser != null)
      return theUser.getTypename();
    else
      return "";
  }
}
