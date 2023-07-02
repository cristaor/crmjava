<%@ page import="java.text.DecimalFormat,java.util.Vector,java.io.IOException,java.net.URLDecoder,java.sql.PreparedStatement,java.sql.ResultSet,java.sql.SQLException,com.knowgate.jdc.*,com.knowgate.dataobjs.*,com.knowgate.acl.*,com.knowgate.hipergate.Address,com.knowgate.misc.Gadgets,com.knowgate.hipergate.*,com.knowgate.training.AcademicCourse" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/clientip.jspf" %><%@ include file="../methods/nullif.jspf" %><% 
/*  
  Copyright (C) 2004-2011  Know Gate S.L. All rights reserved.

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
    
  if (autenticateSession(GlobalDBBind, request, response)<0) return;
  
  response.addHeader ("Pragma", "no-cache");
  response.addHeader ("cache-control", "no-store");
  response.setIntHeader("Expires", 0);

  String sSkin = getCookie(request, "skin", "xp");
  String sLanguage = getNavigatorLanguage(request);

  String id_user = getCookie (request, "userid", null);
  String gu_acourse = request.getParameter("gu_acourse");

  JDCConnection oConn = null;
  AcademicCourse oCur = new AcademicCourse();
  DBSubset oAlm = new DBSubset(DB.k_x_course_alumni+" a,"+DB.k_contacts+" c", DB.tx_name+","+DB.tx_surname+","+DB.sn_passport,
  														 "a."+DB.gu_acourse+"=? AND a."+DB.gu_alumni+"=c."+DB.gu_contact+" ORDER BY 1,2", 100);
  int iAlm = 0;
  Address oAdr = new Address();

  try {
    
    oConn = GlobalDBBind.getConnection("acourse_edit", true);  
        
    oCur.load(oConn, new Object[]{gu_acourse});
    if (!oCur.isNull(DB.gu_address)) {
      oAdr.load(oConn, new Object[]{oCur.getString(DB.gu_address)});
    }

		iAlm = oAlm.load(oConn, new Object[]{gu_acourse});
		
    oConn.close("acourse_edit");
  }
  catch (SQLException e) {  
    if (oConn!=null)
      if (!oConn.isClosed()) oConn.close("acourse_edit");
    oConn = null;
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=SQLException&desc=" + e.getLocalizedMessage() + "&resume=_close"));  
  }

  if (null==oConn) return;  
  oConn = null;  

%><HTML LANG="<% out.write(sLanguage); %>">
<HEAD>
  <TITLE>Print Call</TITLE>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/cookies.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/setskin.js"></SCRIPT>
</HEAD>
<BODY TOPMARGIN="8" MARGINHEIGHT="8">
  <div id="printme">
  <a class="linkplain" onclick="window.history.back()" href="#">Atras</a>&nbsp;&nbsp;<a class="linkplain" onclick="document.getElementById('printme').style.display='none'; window.print()" href="#">
  <b>Print</b>
  </a>
  <br/><br/>
  </div>
  <%=oCur.getStringNull(DB.id_course,"")%>
  <BR/><B><%=oCur.getStringNull(DB.nm_course,"")%></B>
  <% if (!oCur.isNull(DB.tx_start) || !oCur.isNull(DB.tx_end)) { %><BR/><%=oCur.getStringNull(DB.tx_start,"")%>&nbsp;<%=oCur.getStringNull(DB.tx_end,"")%><% } %>
  <BR/><%=oAdr.toLocaleString()%>
	<% if (!oCur.isNull(DB.nm_tutor)) { %><BR/><% out.write(oCur.getString(DB.nm_tutor)); } %>
	<% if (!oCur.isNull(DB.de_course)) { %><BR/><% out.write(oCur.getString(DB.de_course)); } %>
	<BR/>
	<HR/>
	<B>Alumnos</B>
<% for (int a=0; a<iAlm; a++) {
	   out.write("<BR/><BR/>"+oAlm.getStringNull(DB.tx_name,a,"")+" "+oAlm.getStringNull(DB.tx_surname,a,""));
	   if (!oAlm.isNull(DB.sn_passport,a)) out.write(" ("+oAlm.getString(DB.sn_passport,a)+")");
   } %>
</BODY>
</HTML>
