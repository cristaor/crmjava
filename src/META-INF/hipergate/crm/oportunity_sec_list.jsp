<%@ page import="java.net.URLDecoder,java.util.Date,java.sql.SQLException,com.knowgate.acl.*,com.knowgate.jdc.JDCConnection,com.knowgate.dataobjs.*,com.knowgate.misc.Gadgets,com.knowgate.hipergate.DBLanguages,com.knowgate.workareas.WorkArea" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/nullif.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/reqload.jspf" %><jsp:useBean id="GlobalCacheClient" scope="application" class="com.knowgate.cache.DistributedCachePeer"/><%
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

  final String PAGE_NAME = "oportunity_sec_list";
  final int CollaborativeTools=17;

  final String sLanguage = getNavigatorLanguage(request);
  final String sSkin = getCookie(request, "skin", "xp");
  final String sToday = DBBind.escape(new Date(), "shortDate");
  final int iAppMask = Integer.parseInt(getCookie(request, "appmask", "0"));
    
  final String id_domain = request.getParameter("id_domain");
  final String gu_workarea = request.getParameter("gu_workarea");
  final String gu_oportunity = request.getParameter("gu_oportunity");
  
  int iContactCount = 0;
  DBSubset oContacts = new DBSubset (DB.k_contacts+" c INNER JOIN "+DB.k_x_oportunity_contacts+" x ON c."+DB.gu_contact+"=x."+DB.gu_contact,
		  															 "c."+DB.gu_contact+",c."+DB.tx_surname+",c."+DB.tx_name+",c."+DB.sn_passport+",x."+DB.tp_relation+",c."+DB.nu_notes+",c."+DB.nu_attachs,
		  															 "x."+DB.gu_oportunity+"=? AND c."+DB.gu_workarea+"=? ORDER BY 2,3", 10);
  
  JDCConnection oConn = null;  
  
  boolean bIsGuest = true;
  boolean bIsAdmin = false;
      
  try {
    bIsGuest = isDomainGuest (GlobalCacheClient, GlobalDBBind, request, response);
    bIsAdmin = isDomainAdmin (GlobalCacheClient, GlobalDBBind, request, response);
    oConn = GlobalDBBind.getConnection(PAGE_NAME,true);	
    iContactCount = oContacts.load(oConn,new Object[]{gu_oportunity,gu_workarea});
    for (int c=0; c<iContactCount; c++) {
    	if (oContacts.isNull(4,c)) {
    		oContacts.setElementAt("",4,c);
    	} else {
    		String sTr = DBLanguages.getLookUpTranslation(oConn, DB.k_oportunities_lookup, gu_workarea, DB.tp_relation, sLanguage, oContacts.getString(4,c));
    		if (sTr!=null) oContacts.setElementAt(sTr,4,c);
    	}
    }
    oConn.close(PAGE_NAME);
    oConn = null;
  }
  catch (SQLException e) {  
    oContacts = null;
    iContactCount = 0;
    if (oConn!=null)
      if (!oConn.isClosed()) oConn.close(PAGE_NAME);
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=SQLException&desc=" + e.getLocalizedMessage() + "&resume=_back"));
  }

%><HTML LANG="<% out.write(sLanguage); %>">
<HEAD>
  <TITLE>hipergate :: List of individuals linked to the opportunity</TITLE>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/cookies.js"></SCRIPT>  
  <SCRIPT TYPE="text/javascript" SRC="../javascript/setskin.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/combobox.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/getparam.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/simplevalidations.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/dynapi3/dynapi.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" >
    dynapi.library.setPath('../javascript/dynapi3/');
    dynapi.library.include('dynapi.api.DynLayer');
  </SCRIPT>
  <SCRIPT TYPE="text/javascript" >
    var menuLayer,addrLayer;

    dynapi.onLoad(init);

		function init() { 
      menuLayer = new DynLayer();
      menuLayer.setWidth(160);
      menuLayer.setHTML(rightMenuHTML);
      
      addrLayer = new DynLayer();
      addrLayer.setWidth(300);
      addrLayer.setHeight(160);
      addrLayer.setZIndex(200);
    }
  </SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/dynapi3/rightmenu.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/dynapi3/floatdiv.js"></SCRIPT>

  <SCRIPT TYPE="text/javascript" DEFER="defer">
    <!--
        var jsContactId;
        var jsContactNm;
        var jsNotesCount;
        var jsFilesCount;        
    
        <%
          
          out.write("var jsContacts = new Array(");
            for (int i=0; i<iContactCount; i++) {
              if (i>0) out.write(","); 
              out.write("\"" + oContacts.getString(0,i) + "\"");
            }
          out.write(");\n        ");
        %>

      // ----------------------------------------------------
	
      function viewOportunities (contact_id, contact_nm) {
<% if (bIsGuest) { %>
        alert("Yoou priviledge level as guest does not allow you to perform this action");
<% } else { %>
				if (window.opener)
	        window.opener.location = "oportunity_listing.jsp?id_domain=<%=id_domain%>&n_domain=" + escape(getCookie("domainnm"))+ "&gu_contact=" + contact_id + "&where=" + escape(" AND gu_contact='" + contact_id + "'") + "&field=<%=DB.tx_contact%>&find=" + escape(contact_nm) + "&show=oportunities&skip=0&selected=2&subselected=2";
	      else
	    	  open("oportunity_listing.jsp?id_domain=<%=id_domain%>&n_domain=" + escape(getCookie("domainnm")) + "&gu_contact=" + contact_id + "&where=" + escape(" AND gu_contact='" + contact_id + "'") + "&field=<%=DB.tx_contact%>&find=" + escape(contact_nm) + "&show=oportunities&skip=0&selected=2&subselected=2");
<% } %>
      } // viewOportunities

        // ----------------------------------------------------
        	
	function createContact() {	  
<% if (bIsGuest) { %>
     alert("Yoou priviledge level as guest does not allow you to perform this action");
<% } else { %>
     document.location = "oportunity_sec_edit.jsp?id_domain<%=id_domain%>&gu_workarea=<%=gu_workarea%>&gu_oportunity=<%=gu_oportunity%>";
<% } %>
	} // createContact()

  // ----------------------------------------------------
	
	function deleteContacts() {
	  var offset = 0;
	  var frm = document.forms[0];
	  var chi = frm.checkeditems;
	  	  
	  if (window.confirm("Are you sure that you want to remove the link for the selected individuals?")) {
	    chi.value = "";
         
      while (frm.elements[offset].type!="checkbox") offset++;
                 
	    for (var i=0; i<jsContacts.length; i++)
        if (frm.elements[i+offset].checked)
          chi.value += jsContacts[i] + ",";	      
                      
	    if (chi.value.length>0) {
	      chi.value = chi.value.substr(0,chi.value.length-1);
	    
        frm.submit();
      } // fi(checkeditems)
    } // fi(confirm)
	} // deleteContacts()
	
  // ----------------------------------------------------

	function modifyContact(id) {
	  document.location = "contact_edit.jsp?id_domain=<%=id_domain%>&n_domain=" + escape(getCookie("domainnm")) + "&gu_contact=" + id;
	}	
					
        // ----------------------------------------------------

        function selectAll() {
          var frm = document.forms[0];
          
          for (var c=0; c<jsContacts.length; c++)                        
           
           eval ("frm.elements['" + jsContacts[c] + "'].click()");
    
        }
       

      // ------------------------------------------------------

      function listAddresses() {
        document.location = "../common/addr_list.jsp?linktable=k_x_contact_addr&linkfield=gu_contact&linkvalue=" + jsContactId;
      }

      // ----------------------------------------------------

      function viewAddrs(ev,gu,nm) {
        showDiv(ev,"../common/addr_layer.jsp?nm_company=" + escape(nm) + "&linktable=k_x_contact_addr&linkfield=gu_contact&linkvalue=" + gu);
      }

      // ------------------------------------------------------

      function viewNotes(gu,cm) {
        if (isRightMenuOptionEnabled(5))
          document.location = "note_listing.jsp?gu_contact=" + gu + "&nm_company=" + escape(cm), "viewnotes";
      }

      // ------------------------------------------------------

      function addNote(gu) {
<% if (bIsGuest) { %>
        alert("Yoou priviledge level as guest does not allow you to perform this action");
<% } else { %>
        document.location = "note_edit.jsp?id_domain=<%=id_domain%>&gu_contact=" + gu;
<% } %>
      } // addNote

      // ------------------------------------------------------

      function viewAttachments(gu) {
        if (isRightMenuOptionEnabled(7))
          document.location = "attach_listing.jsp?id_domain=<%=id_domain%>&gu_contact=" + gu;
      }

      // ------------------------------------------------------

      function addAttachment(gu) {
<% if (bIsGuest) { %>
        alert("Yoou priviledge level as guest does not allow you to perform this action");
<% } else { %>
        document.location = "attach_edit.jsp?gu_contact=" + gu;
<% } %>        
      } // addAttachment

      // ------------------------------------------------------

      function addPhoneCall(gu) {
<% if (bIsGuest) { %>
        alert("Yoou priviledge level as guest does not allow you to perform this action");
<% } else { %>
        document.location = "../addrbook/phonecall_edit_f.jsp?gu_workarea=<%=gu_workarea%>&gu_contact=" + gu;       
<% } %>        
      } // addPhoneCall

      // ------------------------------------------------------

      function addActivity(gu) {
<% if (bIsGuest) { %>
        alert("Yoou priviledge level as guest does not allow you to perform this action");
<% } else { %>
        document.location = "../addrbook/meeting_edit_f.htm?id_domain=<%=id_domain%>&n_domain=" + escape(getCookie("domainnm")) + "&gu_workarea=<%=gu_workarea%>&gu_fellow=" + getCookie("userid") + "&gu_contact=" + gu + "&date=<%=sToday%>";
<% } %>        
      } // addActivity

      // ------------------------------------------------------

      function configureMenu() {
        if (jsNotesCount>0)
          enableRightMenuOption(5);
        else
          disableRightMenuOption(5);
          
        if (jsFilesCount>0)
          enableRightMenuOption(8);
        else
          disableRightMenuOption(8);

      }
      // -->
      </SCRIPT>
</HEAD>
<BODY  TOPMARGIN="4" MARGINHEIGHT="4" onClick="hideRightMenu()">
  <DIV class="cxMnu1" style="width:100px"><DIV class="cxMnu2">
    <SPAN class="hmMnuOff" onMouseOver="this.className='hmMnuOn'" onMouseOut="this.className='hmMnuOff'" onClick="history.back()"><IMG src="../images/images/toolmenu/historyback.gif" width="16" style="vertical-align:middle" height="16" border="0" alt="Back"> Back</SPAN>
  </DIV></DIV>
    <FORM METHOD="post" action="oportunity_sec_delete.jsp">
      <TABLE><TR><TD  CLASS="striptitle"><FONT CLASS="title1">List of individuals linked to the opportunity</FONT></TD></TR></TABLE>  
      <INPUT TYPE="hidden" NAME="id_domain" VALUE="<%=id_domain%>">
      <INPUT TYPE="hidden" NAME="gu_workarea" VALUE="<%=gu_workarea%>">
      <INPUT TYPE="hidden" NAME="gu_oportunity" VALUE="<%=gu_oportunity%>">
      <INPUT TYPE="hidden" NAME="checkeditems">
      <TABLE CELLSPACING="2" CELLPADDING="2">
        <TR><TD COLSPAN="4" BACKGROUND="../images/images/loginfoot_med.gif" HEIGHT="3"></TD></TR>
        <TR>
        <TD>&nbsp;&nbsp;<IMG SRC="../images/images/new16x16.gif" WIDTH="16" HEIGHT="16" BORDER="0" ALT="New"></TD>
        <TD VALIGN="middle">
<% if (bIsGuest) { %>
          <A HREF="#" onclick="alert('Yoou priviledge level as guest does not allow you to perform this action')" CLASS="linkplain">New</A>
<% } else { %>
          <A HREF="#" onclick="createContact()" CLASS="linkplain">New</A>
<% } %>
        </TD>
        <TD>&nbsp;&nbsp;<IMG SRC="../images/images/crm/unlink.gif" WIDTH="16" HEIGHT="16" BORDER="0" ALT="Remove Link"></TD>
        <TD>
<% if (bIsGuest) { %>
          <A HREF="#" onclick="alert('Yoou priviledge level as guest does not allow you to perform this action')" CLASS="linkplain">Delete</A>
<% } else { %>
          <A HREF="#" onclick="deleteContacts();return false;" CLASS="linkplain">Remove Link</A>
<% } %>
        </TD>
	</TR>
        <TR><TD COLSPAN="4" BACKGROUND="../images/images/loginfoot_med.gif" HEIGHT="3"></TD></TR>
      </TABLE>
      <TABLE CELLSPACING="1" CELLPADDING="0">
        <TR>
          <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif">&nbsp;</TD>
          <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif">&nbsp;<B>Surname, Name</B></TD>
          <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif">&nbsp;<B>Id. Card.</B></TD>
          <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif">&nbsp;<B>Relationship</B></TD>
          <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif" ALIGN="center"><A HREF="#" onclick="selectAll()" TITLE="Seleccionar todos"><IMG SRC="../images/images/selall16.gif" BORDER="0" ALT="Select All"></A></TD>
        </TR>
	<%

  	String sContactId = "";
	  String sIdDoc = "";
	  String sName = "";
	  String sRelType = "";

	  for (int i=0; i<iContactCount; i++)
	  {
	  
	    sContactId = oContacts.getString(0,i);
      sName = (oContacts.getStringHtml(1,i,"")+", "+oContacts.getStringHtml(2,i,"")).trim();
      if (sName.equals(", ")) sName = "<I>(no name)</I>";
      sIdDoc = oContacts.getStringNull(3,i,"");
      sRelType = oContacts.getString(4,i);
            out.write ("        <TR HEIGHT=\"5\">\n");
            out.write ("          <TD CLASS=\"strip" + ((i%2)+1) + "\"><A HREF=\"#\" onContextMenu='return false;' onClick='hideDiv();viewAddrs(event,\"" + sContactId + "\",\"" + sName.replace((char)39,(char)32) + "\");return false'><IMG SRC=\"../images/images/theworld16.gif\" WIDTH=\"16\" HEIGHT=\"16\" BORDER=\"0\" ALT=\"Show Addreesses\"></A></TD>\n");
            out.write ("          <TD CLASS=\"strip" + ((i%2)+1) + "\">&nbsp;<A HREF=\"#\" oncontextmenu=\"jsContactId='" + sContactId + "'; jsContactNm='" + sName.replace((char)39,(char)32) + "'; jsNotesCount='" + oContacts.getInt(5,i) + "'; jsFilesCount='" + oContacts.getInt(6,i) + "'; configureMenu(); return showRightMenu(event);\" onmouseover=\"window.status='Edit Contact'; return true;\" onmouseout=\"window.status='';\" oncontextmenu=\"return false;\" onclick=\"modifyContact('" + sContactId + "'); return false;\" TITLE=\"Click right mouse button to show context menu\">" + sName  + "</A></TD>\n");
            out.write ("          <TD CLASS=\"strip" + ((i%2)+1) + "\">&nbsp;" + sIdDoc + "</TD>\n");                        
            out.write ("          <TD CLASS=\"strip" + ((i%2)+1) + "\">&nbsp;" + sRelType + "</TD>\n");
            out.write ("          <TD CLASS=\"strip" + ((i%2)+1) + "\" ALIGN=\"middle\"><INPUT VALUE=\"" + sContactId + "\" TYPE=\"checkbox\" NAME=\"" + sContactId + "\">\n");
            out.write ("        </TR>\n");        
            
          }                      
      %>          	  
      </TABLE>      
    </FORM>

    <IFRAME name="addrIFrame" src="../common/blank.htm" width="0" height="0" border="0" frameborder="0"></IFRAME>
    <SCRIPT type="text/javascript">
      <!--
      addMenuOption("Open","modifyContact(jsContactId)",1);
      addMenuSeparator();
      addMenuOption("Show Addreesses","listAddresses()",0);
      addMenuSeparator();
      addMenuOption("Show Opportunities","viewOportunities(jsContactId,jsContactNm)",0);
      addMenuSeparator();
      addMenuOption("Add Note","addNote(jsContactId)",0);
      addMenuOption("Show Notes","viewNotes(jsContactId,'')",2);
      addMenuSeparator();
      addMenuOption("Attach File","addAttachment(jsContactId)",0);
      addMenuOption("Show Files","viewAttachments(jsContactId)",2);
<% if ((iAppMask & (1<<CollaborativeTools))!=0) { %>
      addMenuSeparator();
      addMenuOption("New Call","addPhoneCall(jsContactId)",0);
      addMenuOption("New Activity","addActivity(jsContactId)",0);
<% } %>
      //-->
    </SCRIPT>
  </BODY>
</HTML>
