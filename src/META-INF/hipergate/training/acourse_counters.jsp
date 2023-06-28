<%@ page import="java.sql.SQLException,java.sql.PreparedStatement,com.knowgate.jdc.JDCConnection,com.knowgate.dataobjs.*" language="java" session="false" contentType="text/plain;charset=UTF-8" %>
<%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><% 
/*
  Copyright (C) 2003-2010  Know Gate S.L. All rights reserved.
                           C/Oña, 107 1º2 28050 Madrid (Spain)

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:

  1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.

  2. The end-user documentation included with the redistribution,
     if any, must include the following acknowledgment:
     "This product includes software parts from hipergate
     (http://www.hipergate.org/)."
     Alternately, this acknowledgment may appear in the software itself,
     if and wherever such third-party acknowledgments normally appear.

  3. The name hipergate must not be used to endorse or promote products
     derived from this software without prior written permission.
     Products derived from this software may not be called hipergate,
     nor may hipergate appear in their name, without prior written
     permission.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  You should have received a copy of hipergate License with this code;
  if not, visit http://www.hipergate.org or mail to info@hipergate.org
*/

  final String PAGE_NAME = "acourse_counters";
    
  final short iStatus = autenticateCookie(GlobalDBBind, request, response);

  if (iStatus<0) return;

  final String gu_workarea = getCookie(request,"workarea","");

  JDCConnection oConn = null;
  PreparedStatement oStmt = null; 
    
  try {
    oConn = GlobalDBBind.getConnection(PAGE_NAME);

    oStmt = oConn.prepareStatement("UPDATE k_academic_courses SET nu_booked=(SELECT COUNT(*) FROM k_x_course_bookings WHERE k_academic_courses.gu_acourse=k_x_course_bookings.gu_acourse AND k_x_course_bookings.bo_paid=0 AND k_x_course_bookings.bo_canceled=0 AND k_x_course_bookings.bo_confirmed=0) WHERE gu_course IN (SELECT gu_course FROM k_courses WHERE gu_workarea=?)");
		oStmt.setString(1, gu_workarea);
		oStmt.executeUpdate();
		oStmt.close();

    oStmt = oConn.prepareStatement("UPDATE k_academic_courses SET nu_confirmed=(SELECT COUNT(*) FROM k_x_course_bookings WHERE k_academic_courses.gu_acourse=k_x_course_bookings.gu_acourse AND k_x_course_bookings.bo_canceled=0 AND k_x_course_bookings.bo_confirmed=1) WHERE gu_course IN (SELECT gu_course FROM k_courses WHERE gu_workarea=?)");
		oStmt.setString(1, gu_workarea);
		oStmt.executeUpdate();
		oStmt.close();

    oStmt = oConn.prepareStatement("UPDATE k_academic_courses SET nu_alumni=(SELECT COUNT(*) FROM k_x_course_alumni WHERE k_academic_courses.gu_acourse=k_x_course_alumni.gu_acourse) WHERE gu_course IN (SELECT gu_course FROM k_courses WHERE gu_workarea=?)");
		oStmt.setString(1, gu_workarea);
		oStmt.executeUpdate();
		oStmt.close();
		
    oStmt = oConn.prepareStatement("UPDATE k_x_course_bookings SET bo_confirmed=1 WHERE EXISTS (SELECT NULL FROM k_x_course_alumni a WHERE a.gu_acourse=k_x_course_bookings.gu_acourse AND a.gu_alumni=k_x_course_bookings.gu_contact)");
		oStmt.executeUpdate();
		oStmt.close();
      
    oConn.close(PAGE_NAME);
  }
  catch (Exception e) {  
    disposeConnection(oConn,PAGE_NAME);
    oConn = null;
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=Error&"+e.getClass().getName()+"=" + e.getMessage() + "&resume=_close"));  
  }
  
  if (null==oConn) return;    
  oConn = null;

  out.write("1.0:OK");
%>