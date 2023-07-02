<%@ page import="java.util.*,java.io.IOException,java.net.URLDecoder,java.sql.PreparedStatement,java.sql.SQLException,com.knowgate.jdc.*,com.knowgate.dataobjs.DB,com.knowgate.acl.*,com.knowgate.misc.Gadgets" language="java" session="false" %>
<%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/clientip.jspf" %><%
  response.addHeader ("Pragma", "no-cache");
  response.addHeader ("cache-control", "no-store");
  response.setIntHeader("Expires", 0);

  if (autenticateSession(GlobalDBBind, request, response)<0) return;
  
  final String gu_oportunity = request.getParameter("gu_oportunity");

  String a_items[] = Gadgets.split(request.getParameter("checkeditems"), ',');
    
  JDCConnection oCon = null;
  PreparedStatement oDlt = null;
    
  try {
    oCon = GlobalDBBind.getConnection("oportunity_sec_delete");
    oDlt = oCon.prepareStatement("DELETE FROM "+DB.k_x_oportunity_contacts+" WHERE "+DB.gu_oportunity+"=? AND "+DB.gu_contact+"=?");
    oCon.setAutoCommit (false);
  
    for (int i=0;i<a_items.length;i++) {
		  oDlt.setString(1, gu_oportunity);
		  oDlt.setString(2, a_items[i]);
		  oDlt.executeUpdate();
    } // next ()
    oDlt.close();
    
    oCon.commit();
    oCon.close("object_delete");
  } 
  catch(SQLException e) {
      disposeConnection(oCon,"oportunity_sec_delete");
      oCon = null; 
      response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=Error&desc=" + e.getLocalizedMessage() + "&resume=_back"));
    }
  
  if (null==oCon) return;
  
  oCon = null; 

  out.write("<HTML><HEAD><TITLE>Wait...</TITLE><" + "SCRIPT TYPE='text/javascript'>window.document.location='oportunity_sec_list.jsp?id_domain="+request.getParameter("id_domain")+"&gu_workarea="+request.getParameter("gu_workarea")+"&gu_oportunity="+gu_oportunity+"'<" + "/SCRIPT" +"></HEAD></HTML>"); 
 %>