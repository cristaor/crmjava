<%@ page import="com.knowgate.dataxslt.*,com.knowgate.dataxslt.db.*,java.io.IOException,java.net.URLDecoder,java.sql.SQLException,com.knowgate.jdc.*,com.knowgate.dataobjs.*,com.knowgate.acl.*,com.knowgate.hipergate.DBLanguages,com.knowgate.misc.Environment" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../methods/page_prolog.jspf" %><%@ include file="../methods/dbbind.jsp" %>
<jsp:useBean id="GlobalCacheClient" scope="application" class="com.knowgate.cache.DistributedCachePeer"/>
<jsp:useBean id="GlobalDBLang" scope="application" class="com.knowgate.hipergate.DBLanguages"/>
<%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/nullif.jspf" %><%@ include file="../methods/clientip.jspf" %>
<% 
/*
  Copyright (C) 2003  Know Gate S.L. All rights reserved.
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
  
  response.addHeader ("Pragma", "no-cache");
  response.addHeader ("cache-control", "no-store");
  response.setIntHeader("Expires", 0);

  String sSkin = getCookie(request, "skin", "xp");
  String sLanguage = getNavigatorLanguage(request);
  int iAppMask = Integer.parseInt(getCookie(request, "appmask", "0"));
  
  String id_domain = nullif(request.getParameter("id_domain"), getCookie(request,"domainid",""));
  String gu_workarea = nullif(request.getParameter("gu_workarea"),getCookie(request,"workarea",""));
  String gu_pageset = request.getParameter("gu_pageset");

  String sDocType = nullif(request.getParameter("doctype"),"newsletter");
  String sPage = nullif(request.getParameter("page"));
  
  String sStorage = Environment.getProfilePath(GlobalDBBind.getProfileName(),"storage");

  PageDB oPage = null;
  PageDB[] aPages = null;
  PageSetDB oPagSet = null;
  MicrositeDB oMSite = null;
  
  String sStatusLookUp = "", sPathPublish = "";  
  String sSelLang = null;
  String sHtmlPage = null;
  
  JDCConnection oConn = null;  
  boolean bIsGuest = true;
    
  try {
    bIsGuest = isDomainGuest (GlobalCacheClient, GlobalDBBind, request, response);
    
    oConn = GlobalDBBind.getConnection("newsletter_edit");  
     
    oPagSet = new PageSetDB();
    if (!oPagSet.load(oConn, new Object[]{gu_pageset})) throw new SQLException("PageSet "+gu_pageset+" not found");
    
    oMSite = new MicrositeDB();
	  if (!oMSite.load(oConn, new Object[]{oPagSet.getString(DB.gu_microsite)})) throw new SQLException("Microsite "+oPagSet.getString(DB.gu_microsite)+" not found");

		if (oMSite.isNull(DB.tp_microsite)) {
	    oPage = oPagSet.getFirstPage(oConn);
	  } else if (oMSite.getShort(DB.tp_microsite)==MicrositeDB.TYPE_XSL) {
	    oPage = oPagSet.getFirstPage(oConn);
	    if (null!=oPage) sPathPublish = oPage.getStringNull(DB.path_publish,"");
	  } else if (oMSite.getShort(DB.tp_microsite)==MicrositeDB.TYPE_HTML) {
	  	aPages = oPagSet.getPages(oConn);
	  }

    sStatusLookUp = DBLanguages.getHTMLSelectLookUp (GlobalCacheClient, oConn, "k_pagesets_lookup", gu_workarea, DB.id_status, sLanguage);

    sSelLang = GlobalDBLang.toHTMLSelect(oConn, sLanguage);

		PageSet oPgSt = new PageSet (sStorage + oPagSet.getString(DB.path_metadata), sStorage + oPagSet.getString(DB.path_data), true);
		sHtmlPage = ((Page) oPgSt.pages().firstElement()).getTitle().replace(' ', '_') + ".html";
		
    oConn.close("newsletter_edit");
  }
  catch (SQLException e) {  
    if (oConn!=null)
      if (!oConn.isClosed()) oConn.close("newsletter_edit");

    if (com.knowgate.debug.DebugFile.trace) {
      com.knowgate.dataobjs.DBAudit.log ((short)0, "CJSP", sUserIdCookiePrologValue, request.getServletPath(), "", 0, request.getRemoteAddr(), "SQLException", e.getMessage());
    }
    
    oConn = null;
    
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=Error&desc=" + e.getLocalizedMessage() + "&resume=_close"));  
  }
  
  if (null==oConn) return;
  
  oConn = null;  
%>

<HTML LANG="<% out.write(sLanguage); %>">
<HEAD>
  <TITLE>hipergate :: Edit document properties</TITLE>
  <SCRIPT SRC="../javascript/cookies.js"></SCRIPT>  
  <SCRIPT SRC="../javascript/setskin.js"></SCRIPT>
  <SCRIPT SRC="../javascript/getparam.js"></SCRIPT>
  <SCRIPT SRC="../javascript/usrlang.js"></SCRIPT>  
  <SCRIPT SRC="../javascript/combobox.js"></SCRIPT>
  <SCRIPT SRC="../javascript/trim.js"></SCRIPT>
  <SCRIPT SRC="../javascript/datefuncs.js"></SCRIPT>  
  <SCRIPT LANGUAGE="JavaScript1.2" TYPE="text/javascript" DEFER="defer">
    <!--

      // ------------------------------------------------------
              
      function lookup(odctrl) {
        
        switch(parseInt(odctrl)) {
          case 1:
            window.open("../common/lookup_f.jsp?nm_table=k_pagesets_lookup&id_language=" + getUserLanguage() + "&id_section=id_status&tp_control=2&nm_control=sel_status&nm_coding=id_status", "lookup", "toolbar=no,directories=no,menubar=no,resizable=no,width=480,height=520");
            break;
        } // end switch()
      } // lookup()
      
      // ------------------------------------------------------

      function validate() {
        var frm = window.document.forms[0];

      	if (frm.nm_pageset.value.length==0) {
      	  alert ("El nombre es obligatrio");
      	  return false;
      	}
      	
      	if (frm.tx_comments.value.length>255) {
      	  alert ("Los comentarios no pueden superar los 254 caracteres");
      	  return false;
      	}
	      
	      frm.id_status.value = getCombo(frm.sel_status);

        return true;
      } // validate;
    //-->
  </SCRIPT>
  <SCRIPT TYPE="text/javascript">
    <!--
      function setCombos() {
        var frm = document.forms[0];
        
        setCombo(frm.sel_language,"<% out.write(oPagSet.getString(DB.id_language)); %>");
        setCombo(frm.sel_status,"<% out.write(oPagSet.getStringNull(DB.id_status,"")); %>");
        
        return true;
      } // validate;
    //-->
  </SCRIPT>    
</HEAD>
<BODY  TOPMARGIN="8" MARGINHEIGHT="8" onLoad="setCombos()">
  <DIV class="cxMnu1" style="width:300px"><DIV class="cxMnu2">
    <SPAN class="hmMnuOff" onMouseOver="this.className='hmMnuOn'" onMouseOut="this.className='hmMnuOff'" onClick="history.back()"><IMG src="../images/images/toolmenu/historyback.gif" width="16" style="vertical-align:middle" height="16" border="0" alt="Back"> Back</SPAN>
    <SPAN class="hmMnuOff" onMouseOver="this.className='hmMnuOn'" onMouseOut="this.className='hmMnuOff'" onClick="location.reload(true)"><IMG src="../images/images/toolmenu/locationreload.gif" width="16" style="vertical-align:middle" height="16" border="0" alt="Refresh"> Refresh</SPAN>
    <SPAN class="hmMnuOff" onMouseOver="this.className='hmMnuOn'" onMouseOut="this.className='hmMnuOff'" onClick="window.print()"><IMG src="../images/images/toolmenu/windowprint.gif" width="16" height="16" style="vertical-align:middle" border="0" alt="Print"> Print</SPAN>
  </DIV></DIV>
  <TABLE WIDTH="100%">
    <TR><TD><IMG SRC="../images/images/spacer.gif" HEIGHT="4" WIDTH="1" BORDER="0"></TD></TR>
    <TR><TD CLASS="striptitle"><FONT CLASS="title1">Edit document properties</FONT></TD></TR>
  </TABLE>  
  <FORM NAME="" METHOD="post" ACTION="newsletter_edit_store.jsp" onSubmit="return validate()">
    <INPUT TYPE="hidden" NAME="bo_edit" VALUE="0">
    <INPUT TYPE="hidden" NAME="bo_send" VALUE="0">
    <INPUT TYPE="hidden" NAME="id_domain" VALUE="<%=id_domain%>">
    <INPUT TYPE="hidden" NAME="gu_workarea" VALUE="<%=gu_workarea%>">
    <INPUT TYPE="hidden" NAME="gu_pageset" VALUE="<%=gu_pageset%>">
    <INPUT TYPE="hidden" NAME="gu_page" VALUE="<%=(oPage==null ? "" : oPage.getString(DB.gu_page))%>">
    <INPUT TYPE="hidden" NAME="gu_microsite" VALUE="<%=oMSite.getString(DB.gu_microsite)%>">
    <INPUT TYPE="hidden" NAME="path_data" VALUE="<%=oPagSet.getString(DB.path_data)%>">

    <TABLE CLASS="formback">
      <TR><TD>
        <TABLE WIDTH="100%" CLASS="formfront">
          <TR>
            <TD WIDTH="150"></TD>
            <TD ALIGN="left" WIDTH="400">
              <IMG SRC="../images/images/viewtxt.gif" WIDTH="16" HEIGHT="16" BORDER="0" ALT="Preview">
              <A HREF="../webbuilder/wb_preview.jsp?id_domain=<%=id_domain%>&gu_workarea=<%=gu_workarea%>&gu_pageset=<%=gu_pageset%>&doctype=newsletter" CLASS="linkplain">Vista Previa</A>
              <IMG SRC="../images/images/spacer.gif" WIDTH="8" HEIGHT="1" BORDER="0" ALT="">
              <IMG SRC="../images/images/mailto16x16.gif" WIDTH="16" HEIGHT="16" BORDER="0" ALT="Test">
              <A HREF="../webbuilder/adhoc_mailing_test.jsp?id_domain=<%=id_domain%>&gu_workarea=<%=gu_workarea%>&gu_mailing=<%=gu_pageset%>&nm_html=<%=sHtmlPage%>" CLASS="linkplain">Probar Env&iacute;o</A>
            </TD>
          </TR>
          <TR>
            <TD ALIGN="right" WIDTH="150"><FONT CLASS="formstrong">Name:</FONT></TD>
            <TD ALIGN="left" WIDTH="400"><INPUT TYPE="text" NAME="nm_pageset" MAXLENGTH="100" SIZE="50" VALUE="<%=oPagSet.getString(DB.nm_pageset)%>"></TD>
          </TR>
          <TR>
            <TD ALIGN="right" WIDTH="150"><FONT CLASS="formstrong">Document Type:</FONT></TD>
            <TD ALIGN="left" WIDTH="400"><FONT CLASS="formplain"><%=oMSite.getString(DB.nm_microsite)%></FONT></TD>
          </TR>
          <TR>
            <TD ALIGN="right" WIDTH="150"><FONT CLASS="formplain">Status:</FONT></TD>
            <TD ALIGN="left" WIDTH="400">
              <INPUT TYPE="hidden" NAME="id_status" MAXLENGTH="30" VALUE="<%=oPagSet.getStringNull(DB.id_status,"")%>">
              <SELECT NAME="sel_status"><OPTION VALUE=""></OPTION><%=sStatusLookUp%></SELECT>&nbsp;
              <A HREF="javascript:lookup(1)"><IMG SRC="../images/images/find16.gif" HEIGHT="16" BORDER="0" ALT="Show status list"></A>
            </TD>
          </TR>                    
          <TR>
            <TD ALIGN="right" WIDTH="150"><FONT CLASS="formplain">Version:</FONT></TD>
            <TD ALIGN="left" WIDTH="400"><INPUT TYPE="text" NAME="vs_stamp" MAXLENGTH="16" SIZE="16" VALUE="<%=oPagSet.getStringNull(DB.vs_stamp,"")%>"></TD>
          </TR>
          <TR>
            <TD ALIGN="right" WIDTH="150"><FONT CLASS="formplain">Language:</FONT></TD>
            <TD ALIGN="left" WIDTH="400">
              <INPUT TYPE="hidden" NAME="id_language" VALUE="<%=oPagSet.getString(DB.id_language)%>">
              <SELECT NAME="sel_language"><% out.write(sSelLang); %></SELECT>
            </TD>
          </TR>
<% if (oMSite.isNull(DB.tp_microsite)) { %>
          <TR>
            <TD ALIGN="right" WIDTH="150"><FONT CLASS="formplain">Publish at:</FONT></TD>
            <TD ALIGN="left" WIDTH="400">
              <INPUT TYPE="text" NAME="path_publish" SIZE="50" MAXLENGTH="254" VALUE="<%=sPathPublish%>">
            </TD>
          </TR>
<% } else if (oMSite.getShort(DB.tp_microsite)==MicrositeDB.TYPE_XSL) { %>
          <TR>
            <TD ALIGN="right" WIDTH="150"><FONT CLASS="formplain">Publish at:</FONT></TD>
            <TD ALIGN="left" WIDTH="400">
              <INPUT TYPE="text" NAME="path_publish" SIZE="50" MAXLENGTH="254" VALUE="<%=sPathPublish%>">
            </TD>
          </TR>
<% } else if (oMSite.getShort(DB.tp_microsite)==MicrositeDB.TYPE_HTML && aPages!=null) { %>
          <TR>
            <TD ALIGN="right" WIDTH="150" CLASS="formstrong">Publich:</TD>
            <TD ALIGN="left" WIDTH="400"></TD>
          </TR>
<% for (int p=0; p<aPages.length; p++) { %>
          <TR>
            <TD ALIGN="right" WIDTH="150" CLASS="textsmall"><%=aPages[p].getStringNull(DB.tl_page,String.valueOf(p+1))%></TD>
            <TD ALIGN="left" WIDTH="400" CLASS="formplain"><INPUT TYPE="text" NAME="path_publish_<% out.write(String.valueOf(aPages[p].getInt(DB.pg_page))); %>" SIZE="50" MAXLENGTH="254" VALUE="<%=aPages[p].getStringNull(DB.path_publish,"")%>"></TD>
          </TR>
<% } } %>

          <TR>
            <TD ALIGN="right" WIDTH="150"><FONT CLASS="formplain">Description:</FONT></TD>
            <TD ALIGN="left" WIDTH="400">
              <TEXTAREA ROWS="4" COLS="38" NAME="tx_comments"><% if (!oPagSet.isNull(DB.tx_comments)) out.write(oPagSet.getString(DB.tx_comments)); %></TEXTAREA>
            </TD>
          </TR>
          <TR>
            <TD COLSPAN="2"><HR></TD>
          </TR>
          <TR>
    	    <TD COLSPAN="2" ALIGN="center">
<% if (bIsGuest) { %>
              <INPUT TYPE="button" ACCESSKEY="s" VALUE="Save" CLASS="pushbutton" STYLE="width:80" TITLE="ALT+s" onclick="alert('Your priviledge level as guest does not allow you to perform this action')">
<% } else { %>              
              <INPUT TYPE="submit" ACCESSKEY="s" VALUE="Save" CLASS="pushbutton" STYLE="width:80" TITLE="ALT+s">
              &nbsp;&nbsp;&nbsp;
              <INPUT TYPE="submit" ACCESSKEY="e" VALUE="Edit" CLASS="pushbutton" STYLE="width:80" TITLE="ALT+e" onclick="document.forms[0].bo_edit.value='1'">
              &nbsp;&nbsp;&nbsp;
              <INPUT TYPE="submit" ACCESSKEY="m" VALUE="Send" CLASS="pushbutton" STYLE="width:80" TITLE="ALT+m" onclick="document.forms[0].bo_send.value='1'">
<% } %>
    	      &nbsp;&nbsp;&nbsp;<INPUT TYPE="button" ACCESSKEY="c" VALUE="Cancel" CLASS="closebutton" STYLE="width:80" TITLE="ALT+c" onclick="window.close()">
    	      <BR><BR>
    	    </TD>	            
        </TABLE>
      </TD></TR>
    </TABLE>                 
  </FORM>
</BODY>
</HTML>
<%@ include file="../methods/page_epilog.jspf" %>