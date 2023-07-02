<%@ page import="java.util.HashMap,java.io.IOException,java.net.URLDecoder,java.sql.SQLException,com.knowgate.jdc.JDCConnection,com.knowgate.dataobjs.*,com.knowgate.hipergate.DBLanguages" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/nullif.jspf" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><% 

  if (autenticateSession(GlobalDBBind, request, response)<0) return;

  final String PAGE_NAME = "newsletters_list";

  final String ID_DOMAIN = getCookie(request, "domainid", "");
  final String GU_WORKAREA = getCookie(request, "workarea", "");
  
  JDCConnection oConn = null;  
  DBSubset oMails = new DBSubset("k_pagesets",
  															 "gu_pageset,dt_created,nm_pageset,id_status,bo_urgent",
  															 "gu_workarea=? ORDER BY 2 DESC", 100);
  int iMails = 0;
  HashMap oStatus = null;
  
  try {
    oConn = GlobalDBBind.getConnection(PAGE_NAME);

    oStatus =  DBLanguages.getLookUpMap(oConn, DB.k_adhoc_mailings_lookup, GU_WORKAREA, DB.id_status, "es");
		oMails.setMaxRows(100);
    iMails = oMails.load(oConn, new Object[]{GU_WORKAREA});

    oConn.close(PAGE_NAME);
  }
  catch (Exception e) {
    if (oConn!=null)
      if (!oConn.isClosed()) {
        oConn.close(PAGE_NAME);
      }
    oConn = null;
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=" + e.getClass().getName() + "&desc=" + e.getMessage() + "&resume=_back"));
  }
  
  if (null==oConn) return;    
  oConn = null;
%>
<HTML>
  <HEAD>
    <SCRIPT TYPE="text/javascript" SRC="../javascript/cookies.js"></SCRIPT>
    <SCRIPT TYPE="text/javascript" SRC="../javascript/setskin.js"></SCRIPT>
  </HEAD>
  <BODY>
		<IMG SRC="../workareas/<%=GU_WORKAREA%>/eoi.gif" WIDTH="100" HEIGHT="38" BORDER="0" ALT="Logo">
  	<BR/>
  	<TABLE>
  	  <TR><TD><IMG SRC="../images/images/new16x16.gif" WIDTH="16" HEIGHT="16" BORDER="0" ALT="Nueva newsletter"></TD><TD><A CLASS="linkplain" TARGET="reqform" HREF="../webbuilder/microsite_lookup_f.jsp?doctype=newsletter&gu_workarea=<%=GU_WORKAREA%>&id_domain=<%=ID_DOMAIN%>&nm_table=k_microsites&doctype=newsletter&id_language=es&id_section=id_sector&tp_control=1&nm_control=gu_microsite&nm_coding=id_sector">Nueva newsletter</A></TD></TR>
  	</TABLE>
  	<BR/>
    <TABLE SUMMARY="Mailings" BORDER="0">
      <TR>
        <TD CLASS="tableheader" BACKGROUND="../skins/xp/tablehead.gif">&nbsp;<B>Nombre</B></TD>
        <TD CLASS="tableheader" BACKGROUND="../skins/xp/tablehead.gif">&nbsp;<B>Estado</B></TD>
			</TR>
<% for (int m=0; m<iMails; m++) {
    out.write("<TR><TD><A CLASS=\"linkplain\" TARGET=\"reqform\" HREF=\"newsletter_edit.jsp?gu_pageset="+oMails.getString(0,m)+"\">"+oMails.getStringNull(2,m,"n/d")+"</A></TD><TD CLASS=\"textplain\">"+nullif((String)oStatus.get(oMails.getStringNull(3,m,"")))+"<TD></TR>\n");
   }
%>
    </TABLE>
  </BODY>
</HTML>