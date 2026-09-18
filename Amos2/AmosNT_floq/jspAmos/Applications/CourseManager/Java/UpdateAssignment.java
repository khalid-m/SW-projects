package jspamos.course_manager;

import callin.*;

public class UpdateAssignment extends jspamos.FormManager {
  private String studentName = "";
  private int    assignmentNo = -1;
  private String assignmentStatus = "";
  private String assistantName = "";
  private String applyTo = "";

  public boolean validate() {
    boolean isValid = true;
    if (studentName.equals("")) {
      errors.put("formError",
		 "No student was selected");
      isValid = false;
    }
    if (assignmentStatus.equals("")) {
      errors.put("formError",
		 "No assignment status was selected");
      isValid = false;
    }
    if (assistantName.equals("")) {
      errors.put("formError",
		 "No assistant was selected");
      isValid = false;
    }
    if (applyTo.equals("")) {
      errors.put("formError",
		 "No ApplyTo selected");
      isValid = false;
    }
    if (assignmentNo == -1) {
      errors.put("assignmentNo",
		 "Please choose an assignment to be updated.");
      isValid = false;
    }

    return isValid;
  }

  public boolean doUpdate(Connection db)
    throws AmosException
  {
    Tuple arg = new Tuple(4);
    Scan theScan = new Scan();
    boolean result = true;

    arg.setElem(0, studentName);
    arg.setElem(1, assignmentNo);
    arg.setElem(2, assignmentStatus);
    arg.setElem(3, assistantName);

    if (applyTo.equals("student")) {
      theScan = db.callFunction("updateStudentAssignment", arg);
    } else {
      theScan = db.callFunction("updateGroupAssignment", arg);
    }

    if (theScan.eos()) { // could not create the student
      result = false;
    } else {
      result = theScan.getRow().getBooleanElem(0);
    }
	
    if (result) {
      // Connection.commit() doesn't autosave the image
      db.execute("commit;");
    }

    return result;
  }

  /**
   * Gets the value of studentName
   *
   * @return the value of studentName
   */
  public String getStudentName()  {
    return this.studentName;
  }

  /**
   * Sets the value of studentName
   *
   * @param argStudentName Value to assign to this.studentName
   */
  public void setStudentName(String argStudentName) {
    this.studentName = argStudentName;
  }

  /**
   * Gets the value of assignmentNo
   *
   * @return the value of assignmentNo
   */
  public int getAssignmentNo()  {
    return this.assignmentNo;
  }

  /**
   * Sets the value of assignmentNo
   *
   * @param argAssignmentNo Value to assign to this.assignmentNo
   */
  public void setAssignmentNo(int argAssignmentNo) {
    this.assignmentNo = argAssignmentNo;
  }

  /**
   * Gets the value of assignmentStatus
   *
   * @return the value of assignmentStatus
   */
  public String getAssignmentStatus()  {
    return this.assignmentStatus;
  }

  /**
   * Sets the value of assignmentStatus
   *
   * @param argAssignmentStatus Value to assign to this.assignmentStatus
   */
  public void setAssignmentStatus(String argAssignmentStatus) {
    this.assignmentStatus = argAssignmentStatus;
  }

  /**
   * Gets the value of assistantName
   *
   * @return the value of assistantName
   */
  public String getAssistantName()  {
    return this.assistantName;
  }

  /**
   * Sets the value of assistantName
   *
   * @param argAssistantName Value to assign to this.assistantName
   */
  public void setAssistantName(String argAssistantName) {
    this.assistantName = argAssistantName;
  }

  /**
   * Gets the value of applyTo
   *
   * @return the value of applyTo
   */
  public String getApplyTo()  {
    return this.applyTo;
  }

  /**
   * Sets the value of applyTo
   *
   * @param argApplyTo Value to assign to this.applyTo
   */
  public void setApplyTo(String argApplyTo) {
    this.applyTo = argApplyTo;
  }
}
