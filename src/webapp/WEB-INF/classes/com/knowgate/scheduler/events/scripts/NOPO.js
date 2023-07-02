
import com.knowgate.dataobjs.DB;
import com.knowgate.dataobjs.DBCommand;
import com.knowgate.dataobjs.DBSubset;
import com.knowgate.training.AcademicCourseBooking;
import com.knowgate.workareas.WorkArea;

Integer ReturnValue = new Integer(0);
Integer ErrorCode = new Integer(0);
String  ErrorMessage = "";

if (Parameters.containsKey(DB.id_status)) {
  final String oIdStatus = (String) Parameters.get(DB.id_status);
  final String oIdObjetive = (String) Parameters.get(DB.id_objetive);
  if (oIdStatus!=null && oIdObjetive!=null) {
	if (oIdStatus.equals("GANADA") && oIdObjetive.length()==32) {
	  if (WorkArea.saveAcademicCoursesAsOportunityObjetives(JDBCConnection,(String) Parameters.get(DB.gu_workarea))) {
	    if (DBCommand.queryExists(JDBCConnection,DB.k_academic_courses,DB.gu_acourse+"='"+oIdObjetive+"'")) {
	      DBSubset oContacts = new DBSubset(DB.k_x_oportunity_contacts,DB.gu_contact,DB.gu_oportunity+"=?",10);
	      final int nContacts = oContacts.load(JDBCConnection,new Object[]{Parameters.get(DB.gu_oportunity)});
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
	    }
	  }
	}
  }
}
