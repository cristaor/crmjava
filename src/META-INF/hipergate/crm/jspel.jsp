<%@ page import="java.io.IOException,java.net.URLDecoder,java.sql.PreparedStatement,java.sql.ResultSet,java.sql.SQLException,com.knowgate.jdc.*,com.knowgate.dataobjs.*,com.knowgate.acl.*,com.knowgate.hipergate.DBLanguages,com.knowgate.misc.Gadgets" language="java" isELIgnored="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/nullif.jspf" %>
<jsp:useBean id="oCont" scope="request" class="com.knowgate.crm.Contact"/><%

  JDCConnection oConn = GlobalDBBind.getConnection("EL");
    
  oCont.put("gu_contact","c0a8010a136c6743514100000c07da89");
  
  oConn.close("EL");
  
%>

<h1>Hello ${GlobalDBBind.profileName}</h1>
Contacto: ${oCont["gu_contact"]}
