<%@ page import="java.io.IOException,java.net.URLDecoder,java.sql.SQLException,com.knowgate.jdc.*,com.knowgate.dataobjs.*,com.knowgate.acl.*,com.knowgate.hipergate.*,com.knowgate.crm.Contact" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../../methods/dbbind.jsp" %><%@ include file="../../methods/cookies.jspf" %><%@ include file="../../methods/authusrs.jspf" %><%@ include file="../../methods/clientip.jspf" %><%@ include file="../../methods/nullif.jspf" %>
<jsp:useBean id="GlobalCacheClient" scope="application" class="com.knowgate.cache.DistributedCachePeer"/><jsp:useBean id="GlobalDBLang" scope="application" class="com.knowgate.hipergate.DBLanguages"/><% 
/*
  Copyright (C) 2006  Know Gate S.L. All rights reserved.
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
  
  String gu_contact = request.getParameter("gu_contact");
  String id_domain = request.getParameter("id_domain");
  String n_domain = request.getParameter("n_domain");
  String gu_workarea = request.getParameter("gu_workarea");
    
  JDCConnection oConn = null;

  Contact oCont = new Contact();

  DBSubset oShops = new DBSubset (DB.k_shops, DB.gu_shop + "," + DB.nm_shop + "," + DB.gu_root_cat,
                                  DB.bo_active + "<>0 AND " + DB.gu_workarea + "=?", 10);
  DBSubset oCatgs = null;
  DBSubset oAddrs = null;
  StringBuffer oCatList = new StringBuffer();
  try {
    
    oConn = GlobalDBBind.getConnection("product_request_from_category");  
    
    oCont.load(oConn, gu_contact);

    oAddrs = oCont.getAddresses(oConn);
    
    int iShopCount = oShops.load (oConn, new Object[]{gu_workarea});

    if (iShopCount>0) {
      Category oRoot = new Category(oShops.getString(DB.gu_root_cat, 0));
      oCatgs = oRoot.getChilds(oConn);
      for (int c=0; c<oCatgs.getRowCount(); c++) {
        Category oChld = new Category(oConn, oCatgs.getString(0,c));
        oCatList.append("<OPTION VALUE=\""+oChld.getString(DB.gu_category)+"\">"+oChld.getLabel(oConn, sLanguage)+"</OPTION>");
      }
    }
    
    oConn.close("product_request_from_category");
  }
  catch (SQLException e) {  
    if (oConn!=null)
      if (!oConn.isClosed()) oConn.close("product_request_from_category");
    oConn = null;
    response.sendRedirect (response.encodeRedirectUrl ("../../common/errmsg.jsp?title=Error&desc=" + e.getLocalizedMessage() + "&resume=_close"));  
  }
  
  if (null==oConn) return;
  
  oConn = null;  
%>
<HTML LANG="<% out.write(sLanguage); %>">
<HEAD>
  <TITLE>hipergate :: [~Solicitar Producto~]</TITLE>
  <LINK REL="stylesheet" TYPE="text/css" HREF="../../skins/xp/styles.css">
  <SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript" SRC="../../javascript/cookies.js"></SCRIPT>
  <SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript" SRC="../../javascript/getparam.js"></SCRIPT>
  <SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript" SRC="../../javascript/usrlang.js"></SCRIPT>  
  <SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript" SRC="../../javascript/combobox.js"></SCRIPT>
  <SCRIPT LANGUAGE="JavaScript1.2" TYPE="text/javascript" DEFER="defer">
    <!--

      // ------------------------------------------------------

      function validate() {
        var frm = window.document.forms[0];

	if (frm.gu_category.selectedIndex<0) {
	  alert ("[~El producto es obligatorio~]");
	  return false;
	}

	if (frm.gu_address.selectedIndex<0) {
	  alert ("[~La direccion es obligatoria~]");
	  return false;
	}

        return true;
      } // validate;
    //-->
  </SCRIPT>
  <SCRIPT LANGUAGE="JavaScript1.2" TYPE="text/javascript">
    <!--
      function setCombos() {
        var frm = document.forms[0];

	sortCombo (frm.gu_category);

        return true;
      } // validate;
    //-->
  </SCRIPT> 
</HEAD>
<BODY  TOPMARGIN="8" MARGINHEIGHT="8" onLoad="setCombos()">
  <DIV class="cxMnu1" style="width:290px"><DIV class="cxMnu2">
    <SPAN class="hmMnuOff" onMouseOver="this.className='hmMnuOn'" onMouseOut="this.className='hmMnuOff'" onClick="history.back()"><IMG src="../../images/images/toolmenu/historyback.gif" width="16" style="vertical-align:middle" height="16" border="0" alt="[~Atras~]"> [~Atras~]</SPAN>
    <SPAN class="hmMnuOff" onMouseOver="this.className='hmMnuOn'" onMouseOut="this.className='hmMnuOff'" onClick="location.reload(true)"><IMG src="../../images/images/toolmenu/locationreload.gif" width="16" style="vertical-align:middle" height="16" border="0" alt="[~Actualizar~]"> [~Actualizar~]</SPAN>
    <SPAN class="hmMnuOff" onMouseOver="this.className='hmMnuOn'" onMouseOut="this.className='hmMnuOff'" onClick="window.print()"><IMG src="../../images/images/toolmenu/windowprint.gif" width="16" height="16" style="vertical-align:middle" border="0" alt="[~Imprimir~]"> [~Imprimir~]</SPAN>
  </DIV></DIV>
  <TABLE WIDTH="100%">
    <TR><TD><IMG SRC="../images/images/spacer.gif" HEIGHT="4" WIDTH="1" BORDER="0"></TD></TR>
    <TR><TD CLASS="striptitle"><FONT CLASS="title1">[~Solicitar Producto~]</FONT></TD></TR>
  </TABLE>  
  <FORM METHOD="post" ACTION="product_request_store.jsp" onSubmit="return validate()">
    <INPUT TYPE="hidden" NAME="id_domain" VALUE="<%=id_domain%>">
    <INPUT TYPE="hidden" NAME="n_domain" VALUE="<%=n_domain%>">
    <INPUT TYPE="hidden" NAME="gu_contact" VALUE="<%=gu_contact%>">
    <INPUT TYPE="hidden" NAME="gu_workarea" VALUE="<%=gu_workarea%>">
    <INPUT TYPE="hidden" NAME="gu_shop" VALUE="<%=oShops.getString(DB.gu_shop,0)%>">

    <TABLE CLASS="formback">
      <TR><TD>
        <TABLE WIDTH="100%" CLASS="formfront">
          <TR>
            <TD ALIGN="right" WIDTH="90"><FONT CLASS="formstrong">[~Producto~]:</FONT></TD>
            <TD ALIGN="left">
	    <SELECT NAME="gu_category"><% out.write(oCatList.toString()); %></SELECT>
            </TD>
          </TR>
          <TR>
            <TD ALIGN="right" WIDTH="90"><FONT CLASS="formstrong">[~Direcci&oacute;n~]:</FONT></TD>
            <TD ALIGN="left">
	    <SELECT NAME="gu_address"><%
	    for (int a=0; a<oAddrs.getRowCount(); a++) {
	      out.write("<OPTION VALUE=\""+oAddrs.getString(DB.gu_address,a)+"\">"+oAddrs.getStringNull(DB.tp_street,a,"")+" "+oAddrs.getStringNull(DB.nm_street,a,"")+" "+oAddrs.getStringNull(DB.nu_street,a,"")+" "+oAddrs.getStringNull(DB.mn_city,a,"")+"</OPTION>");
	    }
	  %></SELECT>
            </TD>
          </TR>
          <TR>
            <TD COLSPAN="2"><HR></TD>
          </TR>
          <TR>
    	    <TD COLSPAN="2" ALIGN="center">
              <INPUT TYPE="submit" ACCESSKEY="s" VALUE="[~Aceptar~]" CLASS="pushbutton" STYLE="width:80" TITLE="ALT+s">&nbsp;
    	      &nbsp;&nbsp;<INPUT TYPE="button" ACCESSKEY="c" VALUE="[~Cancelar~]" CLASS="closebutton" STYLE="width:80" TITLE="ALT+c" onclick="window.history.back()">
    	      <BR><BR>
    	    </TD>
    	  </TR>            
        </TABLE>
      </TD></TR>
    </TABLE>                 
  </FORM>
</BODY>
</HTML>
