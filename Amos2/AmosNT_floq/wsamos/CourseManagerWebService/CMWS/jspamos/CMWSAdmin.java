package jspamos;

import callin.*;

public class CMWSAdmin {
	private Amos amosDB = new Amos();

	public String listByPNumber(String imageFileName, String serverName) {
		String pNumberList = null;
		Connection conn = amosDB.getConnection(imageFileName, serverName);
		String rowTemplate = "<option value='&col_2;'>&col_3;, &col_0;, &col_1;, &col_4;</option>\n";
		try {
			Tuple arg = new Tuple(2);
			arg.setElem(0, 4);
			arg.setElem(1, "inc");
			Scan theScan = conn.callFunction(
					"INTEGER.CHARSTRING.LISTSTUDENTSFULL->VECTOR", arg);
			String optionList = jspamos.Utilities.resultToLayout(theScan,
					rowTemplate);
			pNumberList = "<select size='1' id='pn'><option selected value=''>None</option>"
					+ optionList + "</select>";
		} catch (Exception e) {
			System.out.println(e);
			e.printStackTrace();
			pNumberList = null;
		}
		return pNumberList;
	}

	public String listByFullName(String imageFileName, String serverName) {
		String fullNameList = null;
		Connection conn = amosDB.getConnection(imageFileName, serverName);
		String rowTemplate = "<option value='&col_2;'>&col_0;, &col_1;, &col_3;, &col_4;</option>\n";
		try {
			Tuple arg = new Tuple(2);
			arg.setElem(0, 1);
			arg.setElem(1, "inc");
			Scan theScan = conn.callFunction(
					"INTEGER.CHARSTRING.LISTSTUDENTSFULL->VECTOR", arg);
			String optionList = jspamos.Utilities.resultToLayout(theScan,
					rowTemplate);
			fullNameList = "<select size='1' id='fullName'><option selected value=''>None</option>"
					+ optionList + "</select>";
		} catch (Exception e) {
			System.out.println(e);
			e.printStackTrace();
			fullNameList = null;
		}
		return fullNameList;
	}

	public String listByEmail(String imageFileName, String serverName) {
		String emailList = null;
		Connection conn = amosDB.getConnection(imageFileName, serverName);
		String rowTemplate = "<option value='&col_2;'>&col_1;, &col_0;, &col_3;, &col_4;</option>\n";
		try {
			Tuple arg = new Tuple(2);
			arg.setElem(0, 2);
			arg.setElem(1, "inc");
			Scan theScan = conn.callFunction(
					"INTEGER.CHARSTRING.LISTSTUDENTSFULL->VECTOR", arg);
			String optionList = jspamos.Utilities.resultToLayout(theScan,
					rowTemplate);
			emailList = "<select size='1' id='email'><option selected value=''>None</option>"
					+ optionList + "</select>";
		} catch (Exception e) {
			System.out.println(e);
			e.printStackTrace();
			emailList = null;
		}
		return emailList;
	}

	public String getSelectedStudent(String studentName, String imageFileName,
			String serverName) {
		String selectStudent = null;
		Connection conn = amosDB.getConnection(imageFileName, serverName);
		if (studentName != null) {
			try {
				Tuple arg = new Tuple(1);
				arg.setElem(0, studentName);
				Scan theScan = conn.callFunction("studentInfoFull", arg);
				selectStudent = jspamos.Utilities.resultToTable(theScan, "");
				// session.setAttribute("selectedstudent", studentName);
			} catch (Exception e) {
				System.out.println(e);
				e.printStackTrace();
				selectStudent = null;
			}
		}
		return selectStudent;
	}

	public String updateAssignment(String studentName, String imageFileName,
			String serverName) {
		String updateResult = null;
		Connection conn = amosDB.getConnection(imageFileName, serverName);
		try {
			String colHeader = "<TR><TH>Name</TH><TH>e-mail</TH><TH>Group No.</TH><TR>";
			Tuple arg = new Tuple(1);
			Scan theScan;

			arg.setElem(0, studentName);
			// Print information about the current student
			theScan = conn.callFunction("studentInfoFull", arg);
			String studentObj = jspamos.Utilities.resultToTable(theScan, "");
			// Print information about the student group
			theScan = conn.callFunction("listGroupMembers", arg);
			String str1 = "<br><br>The group of this student consists of:<br><br>";
			String groupInfo = jspamos.Utilities.resultToTable(theScan, "",
					colHeader);
			updateResult = studentObj + str1 + groupInfo;
		} catch (Exception e) {
			System.out.println(e);
			e.printStackTrace();
			updateResult = null;
		}
		return updateResult;
	}

	public String listAssignment(String imageFileName, String serverName) {
		String assignmentList = null;
		Connection conn = amosDB.getConnection(imageFileName, serverName);
		String rowTemplate = "<option value='&col_0;'>&col_0;, &col_1;</option>\n";
		try {
			Scan theScan = conn.callFunction("assignmentInfo", new Tuple());
			String optionList = jspamos.Utilities.resultToLayout(theScan,
					rowTemplate);
			assignmentList = "<select size='1' id='assignmentNo'><option selected value='-1'>None</option>"
					+ optionList + "</select>";
		} catch (Exception e) {
			System.out.println(e);
			e.printStackTrace();
			assignmentList = null;
		}
		return assignmentList;
	}

	public boolean doUpdate(String studentName, int assignmentNo, String assignmentStatus, String assistantName,String applyTo,String imageFileName, String serverName){
		boolean result = true;
		Connection conn = amosDB.getConnection(imageFileName, serverName);
		try{
			Tuple arg = new Tuple(4);
			Scan theScan = new Scan();
			
			arg.setElem(0, studentName);
			arg.setElem(1, assignmentNo);
			arg.setElem(2, assignmentStatus);
			arg.setElem(3, assistantName);

			if (applyTo.equals("student")) {
				theScan = conn.callFunction("updateStudentAssignment", arg);
			} else {
				theScan = conn.callFunction("updateGroupAssignment", arg);
			}

			if (theScan.eos()) { // could not create the student
				result = false;
			} else {
				result = theScan.getRow().getBooleanElem(0);
			}

			if (result) {
				conn.execute("commit;"); // Connection.commit() doesn't autosave the image
			}
		}catch (Exception e) {
			System.out.println(e);
			e.printStackTrace();
			result = false;
		}
		return result;
	}
	
	  public String listStudentFull(String imageFileName, String serverName){
		  String studentListFull = null;
		  Connection conn = amosDB.getConnection(imageFileName,serverName);
		  try {
			  Tuple arg = new Tuple(2);
		      arg.setElem(0, 5);
		      arg.setElem(1, "inc");
		      Scan theScan = conn.callFunction("listStudentsFullAss", arg);
		      String colHeader = "<TR>"+
		                         "<TH>Name</TH><TH>e-mail</TH><TH>username</TH>"+
		                         "<TH>PN</TH><TH>Group No.</TH><TH>Assignment results</TH>"+
		                         "<TR>";
		      studentListFull = jspamos.Utilities.resultToTable(theScan,"",colHeader);
		    } catch (Exception e ) {
		      System.out.println(e);
		      e.printStackTrace();
		      studentListFull = null;
		    }
		  return studentListFull;
	  }
	  
	  public String excuteQuery(String query, String imageFileName, String serverName){
		  String queryResult = null;
		  Connection conn = amosDB.getConnection(imageFileName,serverName);
		  if ((query != null) && (query.length() > 0)) {
			  try{
			    queryResult = jspamos.Utilities.resultToTable(amosDB.jspExecute(query),"");
			  } catch (Exception e ){
				  System.out.println(e);
			      e.printStackTrace();
			      queryResult = "When executing <b>'" + query + "'</b> the following error occured : <br>\n<b>" + e.toString() + "</b><br>";
			  }
			}
		  return queryResult;
	  }
}
