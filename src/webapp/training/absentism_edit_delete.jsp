<%@ page import="com.knowgate.training.Absentism,java.util.*,java.io.IOException,java.net.URLDecoder,java.sql.SQLException,com.knowgate.jdc.*,com.knowgate.dataobjs.*,com.knowgate.acl.*,com.knowgate.hipergate.*,com.knowgate.misc.Gadgets" language="java" session="false" %>
<%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/clientip.jspf" %>
<%

  response.addHeader ("Pragma", "no-cache");
  response.addHeader ("cache-control", "no-store");
  response.setIntHeader("Expires", 0);

  if (autenticateSession(GlobalDBBind, request, response)<0) return;
  
  String id_user = getCookie (request, "userid", null);

  String a_items[] = Gadgets.split(request.getParameter("checkeditems"), ',');
    
  JDCConnection oCon = null;
    
  try {
    oCon = GlobalDBBind.getConnection("absentism_delete");

    oCon.setAutoCommit (false);
  
    for (int i=0;i<a_items.length;i++) {
      Absentism.delete(oCon, a_items[i]);
    } // next ()
  
    oCon.commit();
    oCon.close("absentism_delete");
  } 
  catch(SQLException e) {
      disposeConnection(oCon,"absentism_delete");
      oCon = null; 
      response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=Error&desc=" + e.getLocalizedMessage() + "&resume=_back"));
    }
  
  if (null==oCon) return;
  
  oCon = null; 

  out.write("<HTML><HEAD><TITLE>Wait...</TITLE><" + "SCRIPT LANGUAGE='JavaScript' TYPE='text/javascript'>window.document.location='absents_listing.jsp?selected=" + request.getParameter("selected") + "&subselected=" + request.getParameter("subselected") + "'<" + "/SCRIPT" +"></HEAD></HTML>"); 
 %>