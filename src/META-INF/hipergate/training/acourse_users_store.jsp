<%@ page import="java.sql.PreparedStatement,java.sql.SQLException,com.knowgate.jdc.JDCConnection,com.knowgate.dataobjs.*,com.knowgate.workareas.WorkArea" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/nullif.jspf" %><% 
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

  final String PAGE_NAME = "acourse_users_store";

  if (autenticateSession(GlobalDBBind, request, response)<0) return;

  String gu_workarea = request.getParameter("gu_workarea");
  String gu_acourse = request.getParameter("gu_acourse");
  String id_user = getCookie (request, "userid", null);

  JDCConnection oConn = null;
  PreparedStatement oStmt = null;  
  DBSubset oAllUsers = new DBSubset(DB.k_users,DB.gu_user,DB.bo_active+"<>0 AND "+DB.gu_workarea+"=?", 500);
    
  try {
    oConn = GlobalDBBind.getConnection(PAGE_NAME);

		if (!WorkArea.isAdmin(oConn, gu_workarea, id_user))
		  throw new SQLException("Must have administrator rol in order to store academic course permissions");

    int nAllUsers = oAllUsers.load(oConn, new Object[]{gu_workarea});

    oConn.setAutoCommit(false);

		oStmt = oConn.prepareStatement("DELETE FROM "+DB.k_x_user_acourse+" WHERE "+DB.gu_acourse+"=?");		
		oStmt.setString(1, gu_acourse);
		oStmt.executeUpdate();
		oStmt.close();

		oStmt = oConn.prepareStatement("INSERT INTO "+DB.k_x_user_acourse+" (gu_user,gu_acourse,bo_user,bo_admin) VALUES (?,?,?,0)");
		
		for (int u=0; u<nAllUsers; u++) {
		  oStmt.setString(1, oAllUsers.getString(0,u));
		  oStmt.setString(2, gu_acourse);
		  oStmt.setShort (3, Short.parseShort(nullif(request.getParameter(oAllUsers.getString(0,u)),"1")));
		  oStmt.executeUpdate();
		}

		oStmt.close();
		
    oConn.commit();
      
    oConn.close(PAGE_NAME);
  }
  catch (Exception e) {  
    disposeConnection(oConn,PAGE_NAME);
    oConn = null;
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=Error&"+e.getClass().getName()+"&desc=" + e.getMessage() + "&resume=_close"));  
  }
  
  if (null==oConn) return;    
  oConn = null;

  out.write ("<HTML><HEAD><TITLE>Wait...</TITLE><" + "SCRIPT LANGUAGE='JavaScript' TYPE='text/javascript'>self.close();<" + "/SCRIPT" +"></HEAD></HTML>");

%>