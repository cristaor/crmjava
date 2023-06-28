<%@ page import="java.io.IOException,java.net.URLDecoder,java.sql.PreparedStatement,java.sql.SQLException,com.knowgate.jdc.*,com.knowgate.dataobjs.*,com.knowgate.acl.*,com.knowgate.crm.DistributionList,com.knowgate.hipergate.Category,com.knowgate.misc.Gadgets" language="java" session="false" %>
<%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/clientip.jspf" %><%
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
  
  if (autenticateSession(GlobalDBBind, request, response)<0) return;
  
  String a_items[] = Gadgets.split(request.getParameter("checkeditems"), ',');
  String sCateg = request.getParameter("sel_category_move");
  String sFormer = request.getParameter("gu_category");
  String sFormerTr = null;
  
  PreparedStatement oDlte, oInsr;
  JDCConnection oCon = GlobalDBBind.getConnection("list_move");
  
  try {
	if (sFormer.length()>0) {
	  Category oCateg = new Category(sFormer);
	  sFormerTr = oCateg.getLabel(oCon, getNavigatorLanguage(request));
	}
	oDlte = oCon.prepareStatement("DELETE FROM "+DB.k_x_cat_objs+" WHERE "+DB.gu_object+"=? AND "+DB.id_class+"="+String.valueOf(DistributionList.ClassId));
	oInsr = oCon.prepareStatement("INSERT INTO "+DB.k_x_cat_objs+" ("+DB.gu_category+","+DB.gu_object+","+DB.id_class+") VALUES(?,?,"+String.valueOf(DistributionList.ClassId)+")");
    oCon.setAutoCommit (false);    
    for (int i=0;i<a_items.length;i++) {
	  oDlte.setString(1, a_items[i]);
	  oDlte.executeUpdate();
	  oInsr.setString(1, sCateg);
	  oInsr.setString(2, a_items[i]);
	  oInsr.executeUpdate();
    } // next ()
    oInsr.close();
    oDlte.close();
    oCon.commit();
    oCon.close("list_move");
  } 
  catch(SQLException e) {
      disposeConnection(oCon,"list_move");
      response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=Error&desc=" + e.getLocalizedMessage() + "&resume=_back"));
  }
    
  oCon = null; 
%>
<HTML>
<HEAD>
<TITLE>Wait...</TITLE>
<SCRIPT TYPE='text/javascript'>
  if ("<%=sFormer%>"=="")
    window.document.location='list_listing.jsp?selected=<%=request.getParameter("selected")%>&subselected=<%=request.getParameter("subselected")%>';
  else
	window.document.location='list_list.jsp?gu_category=<%=sFormer%>&tr_category=<%=Gadgets.URLEncode(sFormerTr)%>';
</SCRIPT>
</HEAD>
</HTML>

