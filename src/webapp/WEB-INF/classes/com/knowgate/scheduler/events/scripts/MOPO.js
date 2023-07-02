
import com.knowgate.dataobjs.DB;
import com.knowgate.dataobjs.DBCommand;
import com.knowgate.dataobjs.DBSubset;
import com.knowgate.training.AcademicCourseBooking;
import com.knowgate.workareas.WorkArea;
import com.knowgate.debug.DebugFile;

Integer ReturnValue = new Integer(0);
Integer ErrorCode = new Integer(0);
String  ErrorMessage = "";

if (DebugFile.trace) DebugFile.writeln("Begin mopo Event execution");

if (Parameters.containsKey(DB.id_status)) {
  final String oIdStatus = (String) Parameters.get(DB.id_status);
  final String oIdObjetive = (String) Parameters.get(DB.id_objetive);
  if (DebugFile.trace) DebugFile.writeln("Opportunity status is "+oIdStatus+" and objetive is "+oIdObjetive);
  if (oIdStatus!=null && oIdObjetive!=null) {
	if (oIdStatus.equals("GANADA") && oIdObjetive.length()==32) {
	  if (WorkArea.saveAcademicCoursesAsOportunityObjetives(JDBCConnection,(String) Parameters.get(DB.gu_workarea))) {
	    if (DebugFile.trace) DebugFile.writeln("Save opportunity contacts as academic course bookings is enabled");
	    if (DBCommand.queryExists(JDBCConnection,DB.k_academic_courses,DB.gu_acourse+"='"+oIdObjetive+"'")) {
	      DBSubset oContacts = new DBSubset(DB.k_x_oportunity_contacts,DB.gu_contact,DB.gu_oportunity+"=?",10);
	      final int nContacts = oContacts.load(JDBCConnection,new Object[]{Parameters.get(DB.gu_oportunity)});
		  if (DebugFile.trace) DebugFile.writeln(String.valueOf(nContacts)+"contacts found for opportunity");
	      for (int c=0; c<nContacts; c++) {
		    AcademicCourseBooking oBook = new AcademicCourseBooking();
		    oBook.put(DB.gu_acourse, oIdObjetive);
		    oBook.put(DB.gu_contact, oContacts.getString(0,c));
		    oBook.put(DB.bo_confirmed, (short) 0);
		    oBook.put(DB.bo_paid, (short) 0);
		    oBook.put(DB.bo_canceled, (short) 0);
		    oBook.put(DB.bo_waiting, (short) 0);
		    oBook.store(JDBCConnection);
	      }
	      if (nContacts==0 && Parameters.get(DB.gu_contact)!=null) {
			AcademicCourseBooking oBook = new AcademicCourseBooking();
		    oBook.put(DB.gu_acourse, oIdObjetive);
		    oBook.put(DB.gu_contact, (String) Parameters.get(DB.gu_contact));
		    oBook.put(DB.bo_confirmed, (short) 0);
		    oBook.put(DB.bo_paid, (short) 0);
		    oBook.put(DB.bo_canceled, (short) 0);
		    oBook.put(DB.bo_waiting, (short) 0);
		    oBook.store(JDBCConnection);	    	
	      }
	    } else {
		  if (DebugFile.trace) DebugFile.writeln("No Academic Course matches opportunity objetive");
	    }
	  } else {
		if (DebugFile.trace) DebugFile.writeln("Save opportunity contacts as academic course bookings is disabled");
	  }
	}
  }
}

if (DebugFile.trace) DebugFile.writeln("End mopo Event execution");
