<%@ page language="java" session="false" contentType="text/html;charset=UTF-8" %><%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%
if (autenticateSession(GlobalDBBind, request, response)<0) return;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 FRAMESET//EN" "http://www.w3.org/TR/REC-html40/FRAMESET.dtd">
<HTML>
  <HEAD>
    <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
    <META NAME="robots" CONTENT="noindex, nofollow">
    <TITLE>EOI :: Newsletters</TITLE>
  </HEAD>
    <FRAMESET COLS="30%,*" BORDER="0" FRAMEBORDER="0">
      <FRAME FRAMEBORDER="no" MARGINWIDTH="16" MARGINHEIGHT="0" NORESIZE SRC="newsletters_list.jsp">
      <FRAME NAME="reqform" FRAMEBORDER="no" MARGINWIDTH="0 MARGINHEIGHT=" NORESIZE SRC="../common/blank.htm">
    </FRAMESET>
    <NOFRAMES>
      <BODY>
	    <P>Esta p&aacute;gina usa marcos, pero su explorador no los admite.</P>
      </BODY>
    </NOFRAMES>
</HTML>
