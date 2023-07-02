<%@ page import="java.io.IOException,java.net.URLDecoder,java.sql.SQLException,com.knowgate.jdc.*,com.knowgate.dataobjs.*,com.knowgate.acl.*,com.knowgate.misc.Gadgets,com.knowgate.training.AcademicCourse,com.knowgate.workareas.WorkArea" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/clientip.jspf" %><%@ include file="../methods/nullif.jspf" %>
<jsp:useBean id="GlobalCacheClient" scope="application" class="com.knowgate.cache.DistributedCachePeer"/><jsp:useBean id="GlobalDBLang" scope="application" class="com.knowgate.hipergate.DBLanguages"/><% 
/*
  Copyright (C) 2006  Know Gate S.L. All rights reserved.
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
    
  if (autenticateSession(GlobalDBBind, request, response)<0) return;
  
  response.addHeader ("Pragma", "no-cache");
  response.addHeader ("cache-control", "no-store");
  response.setIntHeader("Expires", 0);

  String sSkin = getCookie(request, "skin", "xp");
  String sLanguage = getNavigatorLanguage(request);

  String id_domain = request.getParameter("id_domain");
  String gu_workarea = request.getParameter("gu_workarea");
  String gu_acourse = request.getParameter("gu_acourse");
  String id_user = getCookie (request, "userid", null);

  JDCConnection oConn = null;
  AcademicCourse oAcrs = new AcademicCourse();
  DBSubset oAllUsers = new DBSubset(DB.k_users,DB.gu_user+","+DB.nm_user+","+DB.tx_surname1+","+DB.tx_surname2+","+DB.tx_main_email,DB.bo_active+"<>0 AND "+DB.gu_workarea+"=? ORDER BY 2,3,4", 500);
  DBSubset oACourseU = new DBSubset(DB.k_x_user_acourse,DB.gu_user+","+DB.bo_admin+","+DB.bo_user,DB.gu_acourse+"=?",10);
  DBSubset oWrkAdmin = new DBSubset(DB.k_x_group_user+" x, "+DB.k_x_app_workarea+" w",DB.gu_user,"x."+DB.gu_acl_group+"=w."+DB.gu_admins+" AND w."+DB.gu_workarea+"=?", 10);
  
  int nAllUsers = 0;
  boolean bAllow;
  boolean bWadmin;

  try {
    oConn = GlobalDBBind.getConnection("acourse_users_edit");  

    oAcrs.load(oConn, new Object[]{gu_acourse});
    
    nAllUsers = oAllUsers.load(oConn, new Object[]{gu_workarea});
    oACourseU.load(oConn, new Object[]{gu_acourse});
    oACourseU.sortBy(0);

		oWrkAdmin.load(oConn, new Object[]{gu_workarea});
    oWrkAdmin.sortBy(0);
		
		if (!WorkArea.isAdmin(oConn, gu_workarea, id_user))
		  throw new SQLException("Must have administrator rol in order to edit academic course permissions");
		  
    oConn.close("acourse_users_edit");
  }
  catch (SQLException e) {  
    if (oConn!=null)
      if (!oConn.isClosed()) oConn.close("acourse_users_edit");
    oConn = null;
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=SQLException&desc=" + e.getMessage() + "&resume=_close"));  
  }
  
  if (null==oConn) return;  
  oConn = null;  

%><HTML LANG="<% out.write(sLanguage); %>">
<HEAD>
  <TITLE>hipergate :: Edit permissions for this course</TITLE>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/cookies.js"></SCRIPT>  
  <SCRIPT TYPE="text/javascript" SRC="../javascript/setskin.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/combobox.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript">
    <!--

      // ------------------------------------------------------

			function allowAll(ballow) {
			  var frm = document.forms[0];
			  
<%      for (int u=0; u<nAllUsers; u++) {
				  out.write("			  setCheckedValue(frm.elements[\""+oAllUsers.getString(0,u)+"\"],ballow);\n");
        } %>
	    }
		
    //-->
  </SCRIPT>
</HEAD>
<BODY TOPMARGIN="8" MARGINHEIGHT="8">
  <TABLE WIDTH="100%">
    <TR><TD><IMG SRC="../images/images/spacer.gif" HEIGHT="4" WIDTH="1" BORDER="0"></TD></TR>
    <TR><TD CLASS="striptitle"><FONT CLASS="title1">Edit permissions for this course&nbsp;<%=oAcrs.getString(DB.nm_course)%></FONT></TD></TR>
  </TABLE>
  <FORM METHOD="post" ACTION="acourse_users_store.jsp">
    <INPUT TYPE="hidden" NAME="id_domain" VALUE="<%=id_domain%>">
    <INPUT TYPE="hidden" NAME="gu_workarea" VALUE="<%=gu_workarea%>">
    <INPUT TYPE="hidden" NAME="gu_acourse" VALUE="<%=gu_acourse%>">
    <TABLE SUMMARY="Permissions">
      <TR>
        <TD CLASS="tableheader" NOWRAP><B>Name and Surname</B></TD>
        <TD CLASS="tableheader" NOWRAP><B>e-Mail</B></TD>
        <TD CLASS="tableheader"><B>Allow</B></TD>
        <TD CLASS="tableheader"><B>Deny</B></TD>
      </TR>
      <TR>
        <TD COLSPAN="2"></TD>
        <TD ALIGN="center"><A HREF="#" onclick="allowAll('1')"><IMG SRC="../images/images/selall16.gif" WIDTH="16" HEIGHT="16" BORDER="0" ALT="Allow All"></A></TD>
        <TD ALIGN="center"><A HREF="#" onclick="allowAll('0')"><IMG SRC="../images/images/selall16.gif" WIDTH="16" HEIGHT="16" BORDER="0" ALT="Deny All"></A></TD>
      </TR>
<% for (int u=0; u<nAllUsers; u++) {
     String sGuUser = oAllUsers.getString(0,u);
     int iUsr = oACourseU.find(0,sGuUser);
     if (iUsr<0)
       bAllow = true;
     else if (oACourseU.isNull(DB.bo_user,iUsr))
       bAllow = true;
     else
     	bAllow = (oACourseU.getShort(DB.bo_user,iUsr)!=(short)0);
     
     int iWad = oWrkAdmin.find(0,sGuUser);
     bWadmin = (iWad>=0);
     
     out.write("<TR CLASS=\"strip"+String.valueOf((u%2)+1)+"\">\n");
     
     out.write("<TD NOWRAP>"+oAllUsers.getStringNull(DB.nm_user,u,"")+" "+oAllUsers.getStringNull(DB.tx_surname1,u,"")+" "+oAllUsers.getStringNull(DB.tx_surname2,u,"")+"</TD>\n");
     out.write("<TD NOWRAP>"+oAllUsers.getStringNull(DB.tx_main_email,u,"")+"</TD>\n");
     out.write("<TD ALIGN=\"center\"><INPUT TYPE=\"radio\" NAME=\""+sGuUser+"\" VALUE=\"1\" "+(bAllow || bWadmin ? "CHECKED" : "")+"></TD>\n");
     out.write("<TD ALIGN=\"center\">");
     if (!bWadmin) out.write("<INPUT TYPE=\"radio\" NAME=\""+sGuUser+"\" VALUE=\"0\" "+(bAllow ? "" : "CHECKED")+">");
     out.write("</TD>\n");
     out.write("</TR>\n");
   } //next
%>
      <TR><TD COLSPAN="5"><HR></TD></TR>
      <TR>
        <TD COLSPAN="8" ALIGN="center">
          <INPUT TYPE="submit" ACCESSKEY="s" VALUE="Save" CLASS="pushbutton" STYLE="width:80" TITLE="ALT+s">&nbsp;
    	    &nbsp;&nbsp;<INPUT TYPE="button" ACCESSKEY="c" VALUE="Close" CLASS="closebutton" STYLE="width:80" TITLE="ALT+c" onclick="window.close()">
    	</TD>
      </TR>
    </TABLE> 
  </FORM>
</BODY>
</HTML>
