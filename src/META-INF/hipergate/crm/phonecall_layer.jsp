<%@ page import="java.text.SimpleDateFormat,java.net.URLDecoder,com.knowgate.jdc.*,com.knowgate.acl.*,com.knowgate.dataobjs.*,com.knowgate.misc.Gadgets" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/nullif.jspf" %><%@ include file="../methods/cookies.jspf" %><%
/*
  Copyright (C) 2003-2011  Know Gate S.L. All rights reserved.

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
 
  response.addHeader ("Pragma", "no-cache");
  response.addHeader ("cache-control", "no-store");
  response.setIntHeader("Expires", 0);

  String sResult = "";
  SimpleDateFormat oFmt = new SimpleDateFormat("MMM dd HH:mm");
  
  String sLanguage = getNavigatorLanguage(request);

  String gu_workarea = getCookie(request,"workarea",null); 
  String gu_oportunity = request.getParameter("gu_oportunity");

  int iPhoneCallCount = 0;
  DBSubset oPhoneCalls = null;        
  int iMaxRows = 4;
    
  JDCConnection oConn = GlobalDBBind.getConnection("phonecallspopup");  
    
  try {
    oPhoneCalls = new DBSubset (DB.k_phone_calls, DB.dt_start+","+DB.tp_phonecall+","+DB.tx_phone+","+DB.tx_comments,
    													 DB.gu_workarea+"=? AND "+DB.gu_oportunity+"=? ORDER BY 1 DESC", iMaxRows);
    oPhoneCalls.setMaxRows(iMaxRows);
    iPhoneCallCount = oPhoneCalls.load (oConn, new Object[]{gu_workarea, gu_oportunity});
    for (int c=0; c<iPhoneCallCount; c++) {
      sResult += oPhoneCalls.getDateFormated(0,c,oFmt)+" "+oPhoneCalls.getStringNull(2,c,"")+" "+oPhoneCalls.getStringHtml(3,c,"").toLowerCase().replace('\n',' ')+"<BR/>";
    }
    oConn.close("phonecallspopup"); 
  }
  catch (Exception e) {  
    if (oConn!=null)
      if (!oConn.isClosed())
        oConn.close("phonecallspopup");
    sResult = e.getClass().getName()+" "+e.getMessage();
  }
  oConn = null;  
%>
<HTML>
<HEAD>
  <LINK REL="stylesheet" TYPE="text/css" HREF="../skins/xp/styles.css" />
</HEAD>
<BODY marginheight="0" marginwidth="0" topmargin="0" leftmargin="0" class="textsmall">
  <SCRIPT language="JavaScript" type="text/javascript">
  	<!--
    parent.addrLayer.setHTML('<table bgcolor="floralwhite" cellpadding="4" cellspacing="0" width="200" border="1"><tr height="100"><td valign="top" class="textsmall"><%=sResult%></td></tr></table>');
    parent.addrLayer.setVisible(true);
    parent.document.body.style.cursor = "default";    
    -->
  </SCRIPT>
</BODY>
</HTML>