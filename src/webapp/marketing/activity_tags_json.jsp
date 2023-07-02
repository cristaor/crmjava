<%@ page import="java.io.IOException,java.net.URLDecoder,java.sql.SQLException,com.knowgate.jdc.*,com.knowgate.dataobjs.*" language="java" session="false" contentType="text/json;charset=UTF-8" %><%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/clientip.jspf" %><jsp:useBean id="GlobalCacheClient" scope="application" class="com.knowgate.cache.DistributedCachePeer"/><%
/*
  Copyright (C) 2003-2012  Know Gate S.L. All rights reserved.

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

  final String sKeyword = request.getParameter("keyword").toLowerCase();
  final String gu_workarea = getCookie(request, "workarea", "");
  
  final String PAGE_NAME = "activity_tags_json";
  
  DBSubset oTags = GlobalCacheClient.getDBSubset("k_activity_tags.gu_workarea[" + gu_workarea + "]"); 
  
  if (oTags==null) {
    JDCConnection oConn = null;    
    try {
      oConn = GlobalDBBind.getConnection(PAGE_NAME);
		  oTags = new DBSubset(DB.k_activities+" a,"+DB.k_activity_tags+" t", "DISTINCT(t."+DB.nm_tag+")", "a."+DB.gu_activity+"=t."+DB.gu_activity+" AND a."+DB.gu_workarea+"=? ORDER BY 1", 100);
      oTags.load(oConn, new Object[]{gu_workarea});
			oConn.close(PAGE_NAME);
			GlobalCacheClient.putDBSubset("k_activity_tags", "k_activity_tags.gu_workarea[" + gu_workarea + "]", oTags);
    } catch (Exception e) {  
      if (oConn!=null)
        if (!oConn.isClosed()) oConn.close(PAGE_NAME);
        oConn = null;
        response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=Error&desc=" + e.getLocalizedMessage() + "&resume=_close"));  
    }

    if (null==oConn) return;
    oConn = null;
  }

  int nTags = oTags.getRowCount();
  
  out.write("[");
  boolean bFirst = true;
  for (int t=0; t<nTags; t++) {
    if (oTags.getString(0,t).toLowerCase().startsWith(sKeyword)) {
      out.write((bFirst ? "" : ",")+"{\"caption\":\""+oTags.getString(0,t)+"\",\"value\":\""+oTags.getString(0,t)+"\"}");
      bFirst = false;
    }
  }
  out.write("]");
%>