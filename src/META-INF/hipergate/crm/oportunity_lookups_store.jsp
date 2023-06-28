<%@ page import="java.io.IOException,java.net.URLDecoder,java.util.HashMap,java.sql.SQLException,com.knowgate.jdc.JDCConnection,com.knowgate.dataobjs.*,com.knowgate.acl.*,com.knowgate.misc.Gadgets,com.knowgate.hipergate.DBLanguages" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/clientip.jspf" %><%@ include file="../methods/reqload.jspf" %><jsp:useBean id="GlobalCacheClient" scope="application" class="com.knowgate.cache.DistributedCachePeer"/><%
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

  /* Autenticate user cookie */
  if (autenticateSession(GlobalDBBind, request, response)<0) return;

  String id_language = getNavigatorLanguage(request);        
  String gu_workarea = request.getParameter("gu_workarea");
  String id_user = getCookie (request, "userid", null);
  String nu_rows = request.getParameter("nu_rows");
  String[] aCols = Gadgets.split(request.getParameter("collist"), ',');
  String pg_lookup, vl_lookup, tp_lookup, tx_comments;
  String s;
  boolean bo_active;
  
  int iRows = Integer.parseInt(nu_rows);  
  int iCols = aCols.length;
  HashMap oTr = new HashMap(43);
  JDCConnection oConn = null;
  
  try {
    oConn = GlobalDBBind.getConnection("lookups_store"); 
  
    oConn.setAutoCommit (false);

    for (int r=0; r<iRows; r++) {
      s = String.valueOf(r);
      pg_lookup = request.getParameter("pg_lookup"+s);
      vl_lookup = request.getParameter("vl_lookup"+s).toUpperCase();
      if (vl_lookup.length()>0) {
        tp_lookup = request.getParameter("tp_lookup"+s);
        tx_comments = request.getParameter("tx_comments"+s);
        if (null==request.getParameter("bo_active"+s))
          bo_active = false;
        else
          bo_active = request.getParameter("bo_active"+s).equals("1");

      	oTr.clear();
        for (int l=0; l<DBLanguages.SupportedLanguages.length; l++)      
          oTr.put(DBLanguages.SupportedLanguages[l], request.getParameter(DB.tr_+id_language+s));

        if (pg_lookup!=null) {
          if (pg_lookup.length()>0 && vl_lookup.length()==0)
            DBLanguages.deleteLookup (oConn, DB.k_oportunities_lookup, DB.k_oportunities, gu_workarea, DB.id_objetive, Integer.parseInt(pg_lookup));
          else if (vl_lookup.length()>0)
            DBLanguages.storeLookup (oConn, DB.k_oportunities_lookup, gu_workarea, DB.id_objetive, bo_active, vl_lookup, tp_lookup, tx_comments, oTr);
        } else {
          if (vl_lookup.length()>0)
            DBLanguages.storeLookup (oConn, DB.k_oportunities_lookup, gu_workarea, DB.id_objetive, bo_active, vl_lookup, tp_lookup, tx_comments, oTr);
          else
            DBLanguages.deleteLookup (oConn, DB.k_oportunities_lookup, null, gu_workarea, DB.id_objetive, "");
        }
      } // fi 
    } // next

    oConn.commit();
    oConn.close("lookups_store");
    
    GlobalCacheClient.expire(DB.k_oportunities_lookup + "." + DB.id_objetive + "[" + gu_workarea + "]");
    GlobalCacheClient.expire(DB.k_oportunities_lookup + "." + DB.id_objetive + "#" + id_language + "[" + gu_workarea + "]");
  }
  /*
  catch (SQLException e) {  
    disposeConnection(oConn,"lookups_store");
    oConn = null;
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=SQLException&desc=" + e.getLocalizedMessage() + "&resume=_back"));
  }
  */
  catch (NumberFormatException e) {
    disposeConnection(oConn,"lookups_store");
    oConn = null;
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=NumberFormatException&desc=" + e.getMessage() + "&resume=_back"));
  }
  if (null==oConn) return;
  oConn = null;
  
  response.sendRedirect (response.encodeRedirectUrl ("oportunity_lookups.jsp"));
%>