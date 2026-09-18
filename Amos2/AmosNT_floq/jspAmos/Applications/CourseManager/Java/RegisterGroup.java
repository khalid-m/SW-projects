package jspamos.course_manager;

import callin.*;

public class RegisterGroup extends jspamos.FormManager {
  String[] students;
  String[] passwords;
  Student[] studObjects;
  private int studCount = 0;
  public static final int minStudentsPerGroup = 1;
  public static final int maxStudentsPerGroup = 3;
  private String assistantFullName;
  private int groupNo;
  public static final int notInGroup = -1;

  public RegisterGroup() {
    students = new String[maxStudentsPerGroup];
    passwords = new String[maxStudentsPerGroup];
    studObjects = new Student[maxStudentsPerGroup];
    for (int i = 0; i < maxStudentsPerGroup; i++) {
      students[i] = "";
      passwords[i] = "";
      studObjects[i] = null;
    }
    assistantFullName = "";
    groupNo = notInGroup;
  }

  /**
   * Check the group registration rules.
   *
   * @param db a <code>Connection</code> value
   * @return a <code>boolean</code> value
   */
  public boolean validate(Connection db) {
    boolean isValid = true;

    // Count the students that want to register in the same group
    for (int i = 0; i < maxStudentsPerGroup; i++) {
      if (!students[i].equals("")) {
	++studCount;
      }
    }

    if (studCount < minStudentsPerGroup) {
      errors.put("formError",
		 "There must be at least one student in a group");
      return false;
    }

    // Check if all candidate student usernames are differnt
    for (int i = 0; i < maxStudentsPerGroup; i++) {
      for (int j = 0; j < maxStudentsPerGroup; j++) {
	if ((i != j) &&
	    (!students[i].equals("")) &&
	    (students[i].equals(students[j])))
	{
	  errors.put("formError",
		     "The same student can not participate " +
		     "more than once in a group");
	  return false;
	}
      }
    }

    // Authenticate the students
    try {
      boolean authenticated = false;
      for (int i = 0; i < maxStudentsPerGroup; i++) {
	if (!students[i].equals("")) {
	  studObjects[i] = Student.getStudentNamed(db, students[i]);
	  authenticated = User.authenticate(db,
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
	    errors.put("student"+(i+1),
		       "Already member of group: " +
		       currGrp);
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
  public boolean doRegister(Connection db) {
    boolean result = true;
    Scan theScan = new Scan();
    int currStudIdx = 0;

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

      theScan = db.callFunction("updateGroup", arg);

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
	db.execute("commit;");
      }
    } catch (AmosException e) {
      System.out.println(e);
      result = false;
    }

    return result;
  }

  public int getGroup() {
    return groupNo;
  }

  public String getAssistantFullName() {
    return assistantFullName;
  }

  /**
   * Gets the value of student1
   *
   * @return the value of student0
   */
  public String getStudent1()  {
    return students[0];
  }

  /**
   * Sets the value of student1
   *
   * @param argStudent1 Value to assign to this.student1
   */
  public void setStudent1(String argStudent1) {
    students[0] = argStudent1;
  }

  /**
   * Gets the value of password1
   *
   * @return the value of password1
   */
  public String getPassword1()  {
    return passwords[0];
  }

  /**
   * Sets the value of password1
   *
   * @param argPassword1 Value to assign to this.password1
   */
  public void setPassword1(String argPassword1) {
    passwords[0] = argPassword1;
  }

  /**
   * Gets the value of student2
   *
   * @return the value of student2
   */
  public String getStudent2()  {
    return students[1];
  }

  /**
   * Sets the value of student2
   *
   * @param argStudent2 Value to assign to students[1]
   */
  public void setStudent2(String argStudent2) {
    students[1] = argStudent2;
  }

  /**
   * Gets the value of password2
   *
   * @return the value of password2
   */
  public String getPassword2()  {
    return passwords[1];
  }

  /**
   * Sets the value of password2
   *
   * @param argPassword2 Value to assign to passwords[1]
   */
  public void setPassword2(String argPassword2) {
    passwords[1] = argPassword2;
  }

  /**
   * Gets the value of student3
   *
   * @return the value of student3
   */
  public String getStudent3()  {
    return students[2];
  }

  /**
   * Sets the value of student3
   *
   * @param argStudent3 Value to assign to students[2]
   */
  public void setStudent3(String argStudent3) {
    students[2] = argStudent3;
  }

  /**
   * Gets the value of password3
   *
   * @return the value of password3
   */
  public String getPassword3()  {
    return passwords[2];
  }

  /**
   * Sets the value of password3
   *
   * @param argPassword3 Value to assign to passwords[2]
   */
  public void setPassword3(String argPassword3) {
    passwords[2] = argPassword3;
  }

  /**
   * Gets the value of studObjects
   *
   * @return the value of studObjects[i]
   */
  public Student getStudObjects(int i)  {
    if ((i >= 0) || (i < maxStudentsPerGroup))
      return studObjects[i];
    else
      return null;
  }
}
