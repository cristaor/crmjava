<%@ page import="java.util.Date,java.io.IOException,java.net.URLDecoder,java.sql.SQLException,com.knowgate.jdc.*,com.knowgate.dataobjs.DB,com.knowgate.dataobjs.*,com.knowgate.acl.*,com.knowgate.misc.Gadgets,com.knowgate.misc.Environment,com.knowgate.hipergate.DBLanguages,com.knowgate.workareas.WorkArea" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../methods/page_prolog.jspf" %><%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/nullif.jspf" %>
<jsp:useBean id="GlobalCacheClient" scope="application" class="com.knowgate.cache.DistributedCachePeer"/><%
/*
  Copyright (C) 2010  Know Gate S.L. All rights reserved.
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

  String sLanguage = getNavigatorLanguage(request);
  String sSkin = getCookie(request, "skin", "xp");
  String sFace = nullif(request.getParameter("face"),getCookie(request,"face","crm"));

  String gu_user = getCookie(request, "userid", "");
  String id_domain = getCookie(request, "domainid", "");
  String gu_workarea = getCookie(request, "workarea", "");

  JDCConnection oConn = null;
  DBSubset oACourses = null;
  int iACourses = 0;
  int iDBMS = 0;
  
  try {
    oConn = GlobalDBBind.getConnection("traininghome");
		
		iDBMS = oConn.getDataBaseProduct();
		
    if (sFace.equals("edu")) {
      if (WorkArea.isAdmin(oConn, gu_workarea, gu_user)) {
        oACourses = new DBSubset(DB.k_academic_courses+" a",
      			         DB.gu_acourse+","+DB.nm_course+","+DB.id_course,
      			         DB.bo_active+"=1 AND EXISTS (SELECT "+DB.gu_course+" FROM "+DB.k_courses+" c WHERE a."+DB.gu_course+"=c."+DB.gu_course+" AND c."+DB.gu_workarea+"=?) ORDER BY 2", 50);
        iACourses = oACourses.load(oConn, new Object[]{gu_workarea});
      } else {
        oACourses = new DBSubset(DB.k_academic_courses+" a",
      			         DB.gu_acourse+","+DB.nm_course+","+DB.id_course,
      							 " (  EXISTS (SELECT u."+DB.gu_acourse+" FROM "+DB.k_x_user_acourse+" u WHERE u."+DB.gu_acourse+"=a."+DB.gu_acourse+" AND u."+DB.gu_user+"=? AND u."+DB.bo_user+"<>0) OR "+
                     "NOT EXISTS (SELECT u."+DB.gu_acourse+" FROM "+DB.k_x_user_acourse+" u WHERE u."+DB.gu_acourse+"=a."+DB.gu_acourse+" AND u."+DB.gu_user+"=?)) AND "+
      			         DB.bo_active+"=1 AND EXISTS (SELECT "+DB.gu_course+" FROM "+DB.k_courses+" c WHERE a."+DB.gu_course+"=c."+DB.gu_course+" AND c."+DB.gu_workarea+"=?) ORDER BY 2", 50);
        iACourses = oACourses.load(oConn, new Object[]{gu_user,gu_user,gu_workarea});      
      }
    }
    
    oConn.close("traininghome");
  }
  catch (SQLException e) {
      if (oConn!=null)
        if (!oConn.isClosed()) oConn.close("traininghome");
      oConn = null;

      if (com.knowgate.debug.DebugFile.trace) {
        com.knowgate.dataobjs.DBAudit.log ((short)0, "CJSP", sUserIdCookiePrologValue, request.getServletPath(), "", 0, request.getRemoteAddr(), "SQLException", e.getMessage());
      }

      response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=Error&desc=" + e.getMessage() + "&resume=_back"));
  }
  if (null==oConn) return;
  oConn = null;
%>
<HTML LANG="<% out.write(sLanguage); %>">
<HEAD>
  <TITLE>hipergate :: Training Management</TITLE>
  <SCRIPT SRC="../javascript/cookies.js" TYPE="text/javascript"></SCRIPT>
  <SCRIPT SRC="../javascript/setskin.js" TYPE="text/javascript"></SCRIPT>
  <SCRIPT SRC="../javascript/combobox.js" TYPE="text/javascript"></SCRIPT>
  <SCRIPT TYPE="text/javascript" DEFER="defer">
  <!--

    function accentsToPosixRegEx(sText) {
      var aSets = new Array("aáàäâaåaaaã","eéèëêeeeee","iíìïîiiiiii","oóòöôoooøõō","uúùüûuuuuuuuuu","yýyÿy");
      
      if (null==sText) return null;
      var nSets = aSets.length;
      var lText = sText.length;
      var sLext = sText.toLowerCase();
      var oText = "";
      for (var n=0; n<lText; n++) {
        var c = sLext.charAt(n);
        var iMatch = -1;
        for (var s=0; s<nSets && -1==iMatch; s++) {
          if (aSets[s].indexOf(c)>=0) iMatch=s;
        } // next(s)
        
        if (iMatch!=-1)
        	oText += "["+(sText.charAt(n)==c ? aSets[iMatch] : aSets[iMatch].toUpperCase())+"]";
        else
        	oText += sText.charAt(n);
      } // next (n)
      return oText;
    } // AccentsToPosixRegEx

    // ------------------------------------------------------

    function addStudents() {
      var frm = document.forms[0];
    	if (frm.sel_acourse.selectedIndex==0) {
    	  alert("You must select a call first");
    	  frm.sel_acourse.focus();
    	  return false;
    	} else {
    		document.location="alumni_fastedit_f.jsp?gu_acourse="+getCombo(frm.sel_acourse);
			  return true;
			}
    }

    // ----------------------------------------------------

    function confirmStudents() {
      var frm = document.forms[0];
    	if (frm.sel_acourse.selectedIndex==0) {
    	  alert("You must select a call first");
    	  frm.sel_acourse.focus();
    	  return false;
    	} else {
    		document.location="bookings_edit.jsp?id_domain=<%=id_domain%>&gu_workarea=<%=gu_workarea%>&gu_acourse="+getCombo(frm.sel_acourse);
			  return true;
			}
    }

    // ----------------------------------------------------

    function searchStudent() {
      var frm = document.forms[0];
      var nmc = frm.nm_contact.value;

      if (nmc.length==0) {
        alert ("Enter name or surname of student to be found");
        window.location = window.location.href;
        return false;
      }

      if (nmc.indexOf("'")>0 || nmc.indexOf('"')>0 || nmc.indexOf("?")>0 || nmc.indexOf("%")>0 || nmc.indexOf("*")>0 || nmc.indexOf("&")>0 || nmc.indexOf("/")>0) {
			  alert ("The name contains invalid characters");
				return false;
      }
      else {
      	<% if (iDBMS==JDCConnection.DBMS_POSTGRESQL) { %>
        window.location = "alumni_listing_f.jsp?selected=8&subselected=3&queryspec=contacts&where=" + escape(" AND (<%=DB.tx_name%> ~* '" + accentsToPosixRegEx(nmc) + ".*' OR <%=DB.tx_surname%> ~* '.*" + accentsToPosixRegEx(nmc) + ".*')");
        <% } else { %>
        window.location = "alumni_listing_f.jsp?selected=8&subselected=3&queryspec=contacts&where=" + escape(" AND (<%=DB.tx_name%> <%=DBBind.Functions.ILIKE%> '" + nmc + "%' OR <%=DB.tx_surname%> <%=DBBind.Functions.ILIKE%> '%" + nmc + "%')");
        <% } %>
      }
    }


  //-->
  </SCRIPT>
</HEAD>
<BODY  TOPMARGIN="0" MARGINHEIGHT="0">
<%@ include file="../common/tabmenu.jspf" %>
<BR>
<TABLE><TR><TD WIDTH="<%=iTabWidth*iActive%>" CLASS="striptitle"><FONT CLASS="title1">Training Management</FONT></TD></TR></TABLE>
<FORM NAME="loginForm" METHOD="POST" ACTION="" TARGET="_blank">
  <TABLE>
  <TR>
  <TD>
  <TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0">
    <!-- Pestaña superior -->
    <TR>
      <TD WIDTH="2px" CLASS="subtitle" BACKGROUND="../images/images/graylineleftcorner.gif"><IMG style="display:block" SRC="../images/images/spacer.gif" WIDTH="2" HEIGHT="1" BORDER="0"></TD>
      <TD BACKGROUND="../images/images/graylinebottom.gif">
        <TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0">
          <TR>
            <TD COLSPAN="2" CLASS="subtitle" BACKGROUND="../images/images/graylinetop.gif"><IMG style="display:block" SRC="../images/images/spacer.gif" HEIGHT="2" BORDER="0"></TD>
	          <TD ROWSPAN="2" CLASS="subtitle" ALIGN="right"><IMG SRC="../skins/<%=sSkin%>/tab/angle45_24x24.gif" style="display:block" WIDTH="24" HEIGHT="24" BORDER="0"></TD>
	        </TR>
          <TR>
            <TD BACKGROUND="../skins/<%=sSkin%>/tab/tabback.gif" COLSPAN="2" CLASS="subtitle" ALIGN="left" VALIGN="middle"><IMG SRC="../images/images/spacer.gif" WIDTH="4" BORDER="0"><IMG SRC="../images/images/3x3puntos.gif" WIDTH="18" HEIGHT="10" ALT="3x3" BORDER="0">Call</TD>
          </TR>
        </TABLE>
      </TD>
      <TD VALIGN="bottom" ALIGN="right" WIDTH="3px" ><IMG style="display:block" SRC="../images/images/graylinerightcornertop.gif" WIDTH="3" BORDER="0"></TD>
    </TR>
    <!-- Línea gris y roja -->
    <TR>
      <TD WIDTH="2px" CLASS="subtitle" BACKGROUND="../images/images/graylineleft.gif"><IMG style="display:block" SRC="../images/images/spacer.gif" WIDTH="2" HEIGHT="1" BORDER="0"></TD>
      <TD CLASS="subtitle"><IMG style="display:block" SRC="../images/images/spacer.gif" HEIGHT="1" BORDER="0"></TD>
      <TD WIDTH="3px" ALIGN="right"><IMG style="display:block" SRC="../images/images/graylineright.gif" WIDTH="3" HEIGHT="1" BORDER="0"></TD>
    </TR>
    <!-- Cuerpo de Correo-->
    <TR>
      <TD WIDTH="2px" CLASS="subtitle" BACKGROUND="../images/images/graylineleft.gif"><IMG SRC="../images/images/spacer.gif" WIDTH="2" HEIGHT="1" BORDER="0"></TD>
      <TD CLASS="menu1">
        <TABLE CELLSPACING="8" BORDER="0">
          <TR>
            <TD ROWSPAN="2" ALIGN="center">
              <IMG SRC="../images/images/training/course48.gif" WIDTH="48" HEIGHT="48" BORDER="0" ALT="Courses">
            </TD>
            <TD>
              <TABLE SUMMARY="Academic Course Actions">
              	<TR><TD CLASS="textplain">Seleccione una convocatoria y a continuaci&oacute;n la acci&oacute;n que desea realizar sobre ella</TD></TR>
              	<TR><TD>
              		<SELECT NAME="sel_acourse" CLASS="combomini"><OPTION VALUE=""></OPTION>
	        			  <% for (int a=0; a<iACourses; a++) {
	                     out.write("<OPTION VALUE=\"" + oACourses.getString(0,a) + "\">" + oACourses.getString(1,a));
	                     if (!oACourses.isNull(2,a)) out.write(" ("+oACourses.getString(2,a)+")");
	                     out.write("</OPTION>");
	                   } %></SELECT>
	              </TD></TR>
              	<TR><TD><A HREF="#" onclick="addStudents()" CLASS="linkplain">Pre-register students at an already existing call</A></TD></TR>
                <TR><TD><A HREF="#" onclick="confirmStudents()" CLASS="linkplain">Convert pre-registration into confirmed students</A></TD></TR>
              	<TR><TD><A HREF="#" onclick="confirmStudents()" CLASS="linkplain">Cancel registrations os students for a call</A></TD></TR>
              </TABLE>
            </TD>
          </TR>
    	  <TR>
      	    <TD COLSPAN="2">
            </TD>
          </TR>
        </TABLE>
      </TD>
      <TD WIDTH="3px" ALIGN="right" BACKGROUND="../images/images/graylineright.gif"><IMG style="display:block" SRC="../images/images/spacer.gif" WIDTH="3" BORDER="0"></TD>
    </TR>
    <TR>
      <TD WIDTH="2px" CLASS="subtitle" BACKGROUND="../images/images/graylineleft.gif"><IMG style="display:block" SRC="../images/images/spacer.gif" WIDTH="2" HEIGHT="1" BORDER="0"></TD>
      <TD CLASS="subtitle"><IMG style="display:block" SRC="../images/images/spacer.gif" HEIGHT="1" BORDER="0"></TD>
      <TD WIDTH="3px" ALIGN="right"><IMG style="display:block" SRC="../images/images/graylineright.gif" WIDTH="3" HEIGHT="1" BORDER="0"></TD>
    </TR>
    <TR>
      <TD WIDTH="2px" CLASS="subtitle" BACKGROUND="../images/images/graylineleft.gif"><IMG style="display:block" SRC="../images/images/spacer.gif" WIDTH="2" HEIGHT="12" BORDER="0"></TD>
      <TD ><IMG style="display:block" SRC="../images/images/spacer.gif" HEIGHT="12" BORDER="0"></TD>
      <TD WIDTH="3px" ALIGN="right"><IMG style="display:block" SRC="../images/images/graylineright.gif" WIDTH="3" HEIGHT="12" BORDER="0"></TD>
    </TR>
    <!-- Pestaña media -->
    <TR>
      <TD WIDTH="2px" CLASS="subtitle" BACKGROUND="../images/images/graylineleft.gif"><IMG style="display:block" SRC="../images/images/spacer.gif" WIDTH="2" HEIGHT="1" BORDER="0"></TD>
      <TD>
        <TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0">
          <TR>
            <TD COLSPAN="2" CLASS="subtitle"><IMG style="display:block" SRC="../images/images/spacer.gif" HEIGHT="2" BORDER="0"></TD>
	    <TD ROWSPAN="2" CLASS="subtitle" ALIGN="right"><IMG  style="display:block"SRC="../skins/<%=sSkin%>/tab/angle45_22x22.gif" WIDTH="22" HEIGHT="22" BORDER="0"></TD>
	  </TR>
          <TR>
      	    <TD COLSPAN="2" BACKGROUND="../skins/<%=sSkin%>/tab/tabback.gif" CLASS="subtitle" ALIGN="left" VALIGN="middle"><IMG SRC="../images/images/3x3puntos.gif" BORDER="0">Students</TD>
          </TR>
        </TABLE>
      </TD>
      <TD ALIGN="right" WIDTH="3px"  BACKGROUND="../images/images/graylineright.gif"><IMG style="display:block" SRC="../images/images/spacer.gif" WIDTH="3" BORDER="0"></TD>
    </TR>
    <!-- Línea roja -->
    <TR>
      <TD WIDTH="2px" CLASS="subtitle" BACKGROUND="../images/images/graylineleft.gif"><IMG style="display:block" SRC="../images/images/spacer.gif" WIDTH="2" HEIGHT="1" BORDER="0"></TD>
      <TD CLASS="subtitle"><IMG style="display:block" SRC="../images/images/spacer.gif" HEIGHT="1" BORDER="0"></TD>
      <TD WIDTH="3px" ALIGN="right"><IMG style="display:block" SRC="../images/images/graylineright.gif" WIDTH="3" HEIGHT="1" BORDER="0"></TD>
    </TR>
    <!-- Cuerpo de Calendario -->
    <TR>
      <TD WIDTH="2px" CLASS="subtitle" BACKGROUND="../images/images/graylineleft.gif"><IMG style="display:block" SRC="../images/images/spacer.gif" WIDTH="2" HEIGHT="1" BORDER="0"></TD>
      <TD CLASS="menu1">
        <TABLE CELLSPACING="8" BORDER="0">
          <TR>
            <TD ROWSPAN="2" ALIGN="center">
              <IMG SRC="../images/images/training/student48.gif" WIDTH="48" HEIGHT="48" BORDER="0" ALT="Students"></A>
            </TD>
            <TD VALIGN="top">
            	<INPUT TYPE="text" NAME="nm_contact">&nbsp;<A HREF="#" onclick="searchStudent()" CLASS="linkplain">Search Student</A>
            </TD>
	        </TR>
        </TABLE>
      </TD>
      <TD WIDTH="3px" ALIGN="right" BACKGROUND="../images/images/graylineright.gif"><IMG style="display:block" SRC="../images/images/spacer.gif" WIDTH="3" BORDER="0"></TD>
    </TR>

    <TR>
      <TD WIDTH="2px" CLASS="subtitle" BACKGROUND="../images/images/graylineleft.gif"><IMG style="display:block" SRC="../images/images/spacer.gif" WIDTH="2" HEIGHT="1" BORDER="0"></TD>
      <TD CLASS="subtitle"><IMG style="display:block" SRC="../images/images/spacer.gif" HEIGHT="1" BORDER="0"></TD>
      <TD WIDTH="3px" ALIGN="right"><IMG style="display:block" SRC="../images/images/graylineright.gif" WIDTH="3" HEIGHT="1" BORDER="0"></TD>
    </TR>
    <TR>
      <TD WIDTH="2px" CLASS="subtitle" BACKGROUND="../images/images/graylineleft.gif"><IMG style="display:block" SRC="../images/images/spacer.gif" WIDTH="2" HEIGHT="12" BORDER="0"></TD>
      <TD ><IMG style="display:block" SRC="../images/images/spacer.gif" HEIGHT="12" BORDER="0"></TD>
      <TD WIDTH="3px" ALIGN="right"><IMG style="display:block" SRC="../images/images/graylineright.gif" WIDTH="3" HEIGHT="12" BORDER="0"></TD>
    </TR>
    
    <!--
    <TR>
      <TD WIDTH="2px" CLASS="subtitle" BACKGROUND="../images/images/graylineleft.gif"><IMG style="display:block" SRC="../images/images/spacer.gif" WIDTH="2" HEIGHT="1" BORDER="0"></TD>
      <TD>
        <TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0">
          <TR>
            <TD COLSPAN="2" CLASS="subtitle"><IMG style="display:block" SRC="../images/images/spacer.gif" HEIGHT="2" BORDER="0"></TD>
	    <TD ROWSPAN="2" CLASS="subtitle" ALIGN="right"><IMG style="display:block" SRC="../skins/<%=sSkin%>/tab/angle45_22x22.gif" WIDTH="22" HEIGHT="22" BORDER="0"></TD>
	  </TR>
          <TR>
      	    <TD COLSPAN="2" BACKGROUND="../skins/<%=sSkin%>/tab/tabback.gif" CLASS="subtitle" ALIGN="left" VALIGN="middle"><IMG SRC="../images/images/3x3puntos.gif" BORDER="0">Directory</TD>
          </TR>
        </TABLE>
      </TD>
      <TD ALIGN="right" WIDTH="3px"  BACKGROUND="../images/images/graylineright.gif"><IMG style="display:block" SRC="../images/images/spacer.gif" WIDTH="3" BORDER="0"></TD>
    </TR>
    <TR>
      <TD WIDTH="2px" CLASS="subtitle" BACKGROUND="../images/images/graylineleft.gif"><IMG style="display:block" SRC="../images/images/spacer.gif" WIDTH="2" HEIGHT="1" BORDER="0"></TD>
      <TD CLASS="subtitle"><IMG style="display:block" SRC="../images/images/spacer.gif" HEIGHT="1" BORDER="0"></TD>
      <TD WIDTH="3px" ALIGN="right"><IMG style="display:block" SRC="../images/images/graylineright.gif" WIDTH="3" HEIGHT="1" BORDER="0"></TD>
    </TR>
    <TR>
      <TD WIDTH="2px" CLASS="subtitle" BACKGROUND="../images/images/graylineleft.gif"><IMG style="display:block" SRC="../images/images/spacer.gif" WIDTH="2" HEIGHT="1" BORDER="0"></TD>
      <TD CLASS="menu1">
        <TABLE CELLSPACING="8" BORDER="0">
          <TR>
            <TD ROWSPAN="2" ALIGN="center">
              <A HREF="fellow_listing.jsp?selected=1&subselected=3" TITLE="Personnel Directory"><IMG SRC="../images/images/addrbook/employee_card.gif" BORDER="0" ALT="Personnel Directory"></A>
            </TD>
            <TD>
              <INPUT TYPE="text" NAME="full_name" MAXLENGTH="50">
            </TD>
            <TD>
              <A HREF="#" onClick="searchfellow();return false" CLASS="linkplain">Search Person</A>
            </TD>
          </TR>
        </TABLE>
      </TD>
      <TD WIDTH="3px" ALIGN="right" BACKGROUND="../images/images/graylineright.gif"><IMG style="display:block" SRC="../images/images/spacer.gif" WIDTH="3" BORDER="0"></TD>
    </TR>
    <TR>
      <TD WIDTH="2px" CLASS="subtitle" BACKGROUND="../images/images/graylineleft.gif"><IMG style="display:block" SRC="../images/images/spacer.gif" WIDTH="2" HEIGHT="1" BORDER="0"></TD>
      <TD CLASS="subtitle"><IMG style="display:block" SRC="../images/images/spacer.gif" HEIGHT="1" BORDER="0"></TD>
      <TD WIDTH="3px" ALIGN="right"><IMG style="display:block" SRC="../images/images/graylineright.gif" WIDTH="3" HEIGHT="1" BORDER="0"></TD>
    </TR>
    -->
    <!-- Línea gris -->
    <TR>
      <TD WIDTH="2px" CLASS="subtitle"><IMG style="display:block" SRC="../images/images/graylineleftcornerbottom.gif" WIDTH="2" HEIGHT="3" BORDER="0"></TD>
      <TD  BACKGROUND="../images/images/graylinefloor.gif"></TD>
      <TD WIDTH="3px" ALIGN="right"><IMG style="display:block" SRC="../images/images/graylinerightcornerbottom.gif" WIDTH="3" HEIGHT="3" BORDER="0"></TD>
    </TR>
  </TABLE>
  </TD>
  </TR>
  </TABLE>
</FORM>
</BODY>
</HTML>
<%@ include file="../methods/page_epilog.jspf" %>
