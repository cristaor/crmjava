<%@ page import="java.io.IOException,java.net.URLDecoder,java.sql.SQLException,com.knowgate.jdc.*,com.knowgate.dataobjs.*,com.knowgate.acl.*,com.knowgate.hipergate.*,com.knowgate.workareas.WorkArea" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/clientip.jspf" %><%@ include file="../methods/nullif.jspf" %>
<jsp:useBean id="GlobalCacheClient" scope="application" class="com.knowgate.cache.DistributedCachePeer"/><jsp:useBean id="GlobalDBLang" scope="application" class="com.knowgate.hipergate.DBLanguages"/><% 
/*

  Copyright (C) 2012  Know Gate S.L. All rights reserved.

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
  
  String id_domain = request.getParameter("id_domain");
  String gu_workarea = request.getParameter("gu_workarea");
  String gu_oportunity = request.getParameter("gu_oportunity");
  String gu_writer = getCookie (request, "userid", null);

  String sRelTypeLookUp = "", sLocationLookUp = "", sStreetLookUp = "", sCountriesLookUp = "";

  JDCConnection oConn = null;
  boolean bAllCaps = false;
    
  try {    
    oConn = GlobalDBBind.getConnection("oportunity_sec_edit",true);  

    bAllCaps = WorkArea.allCaps(oConn, gu_workarea);
    
    sRelTypeLookUp = DBLanguages.getHTMLSelectLookUp (oConn, DB.k_oportunities_lookup, gu_workarea, DB.tp_relation, sLanguage);
    sLocationLookUp = DBLanguages.getHTMLSelectLookUp (oConn, DB.k_addresses_lookup, gu_workarea, DB.tp_location, sLanguage);
    sStreetLookUp = DBLanguages.getHTMLSelectLookUp (oConn, DB.k_addresses_lookup, gu_workarea, DB.tp_street, sLanguage);
    sCountriesLookUp = GlobalDBLang.getHTMLCountrySelect(oConn, sLanguage);

    oConn.close("oportunity_sec_edit");
  }
  catch (SQLException e) {  
    if (oConn!=null)
      if (!oConn.isClosed()) oConn.close("oportunity_sec_edit");
    oConn = null;
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=Error&desc=" + e.getLocalizedMessage() + "&resume=_close"));  
  }
  
  if (null==oConn) return;  
  oConn = null;  
%>
<HTML LANG="<% out.write(sLanguage); %>">
<HEAD>
  <TITLE>hipergate :: New Contact for the Opportunity</TITLE>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/cookies.js"></SCRIPT>  
  <SCRIPT TYPE="text/javascript" SRC="../javascript/setskin.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/getparam.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/usrlang.js"></SCRIPT>  
  <SCRIPT TYPE="text/javascript" SRC="../javascript/combobox.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/trim.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/datefuncs.js"></SCRIPT>  
  <SCRIPT TYPE="text/javascript" SRC="../javascript/email.js"></SCRIPT>  
  <SCRIPT TYPE="text/javascript" SRC="../javascript/xmlhttprequest.js"></SCRIPT>  
  <SCRIPT TYPE="text/javascript" SRC="../javascript/simplevalidations.js"></SCRIPT>  
  <SCRIPT TYPE="text/javascript">
    <!--
    
    var allcaps = <%=String.valueOf(bAllCaps)%>;

      function setCombos() {
        var frm = document.forms[0];
        if (frm.gu_address.value.length==0) {
          if (getUserLanguage()=="en")
            setCombo(frm.sel_country, "us");
          else
            setCombo(frm.sel_country, getUserLanguage());
	        loadstates();
        }
      }
      
    //-->
  </SCRIPT>
  <SCRIPT TYPE="text/javascript" DEFER="defer">
    <!--

      // ------------------------------------------------------
      
      var httpreq = null;

      function processStatesList() {
        if (httpreq.readyState == 4) {
          if (httpreq.status == 200) {
	          var vl,lb;
	          var scmb = document.forms[0].sel_state;
    	      var lkup = httpreq.responseXML.getElementsByTagName("lookup");
	          if (lkup) {
    	        for (var l = 0; l < lkup.length; l++) {
    	          vl = getElementText(lkup[l], "value");
    	          lb = getElementText(lkup[l], "label");
		            comboPush (scmb, lb, vl, false, false);
	            } // next (l)
	            httpreq = false;
	            sortCombo(scmb);
	          } // fi (lkup)
          } // fi (status == 200)
	      } // fi (readyState == 4)
      } // processStatesList

      function loadstates() {
	      var frm = window.document.forms[0];

        clearCombo(frm.sel_state);
        
        if (frm.sel_country.options.selectedIndex>0) {
          httpreq = createXMLHttpRequest();
          if (httpreq) {
	          httpreq.onreadystatechange = processStatesList;            
            httpreq.open("GET", "../common/addr_xmlfeed.jsp?id_language=" + getUserLanguage() + "&gu_workarea=" + getCookie("workarea") + "&id_section=" + getCombo(frm.sel_country), true);
            httpreq.send(null);
          }
        }  
      } // loadstates

      // ------------------------------------------------------

      var addrreq = null;

      function loadContactData() {
	      var frm = window.document.forms[0];
	      var txt = frm.tx_email.value.trim();
	      if (txt.length>0) {
	      if (!check_email(txt)) {
	        alert ("The email address is not valid");
	        return false;
        } else {
            var addrreq = createXMLHttpRequest();
            if (addrreq) {
              addrreq.open("GET", "../common/memberaddress_xmlfeed.jsp?email="+frm.tx_email.value+"&workarea="+frm.gu_workarea.value+"&writer="+frm.gu_writer.value, false);
              addrreq.send(null);              
    	        var adrxml = addrreq.responseXML.getElementsByTagName("MemberAddress");
	            if (adrxml) {
      	        adrxml = adrxml[0];
      	        frm.gu_address.value = nullif(getElementText(adrxml, "gu_address"));
      	        frm.ix_address.value = nullif(getElementText(adrxml, "ix_address"),"1");
      	        frm.gu_contact.value = nullif(getElementText(adrxml, "gu_contact"));
      	        frm.gu_company.value = nullif(getElementText(adrxml, "gu_company"));
      	        frm.nm_legal.value = nullif(getElementText(adrxml, "nm_legal"));
      	        frm.tx_name.value = nullif(getElementText(adrxml, "tx_name"));
      	        frm.tx_surname.value = nullif(getElementText(adrxml, "tx_surname"));
      	        frm.sn_passport.value = nullif(getElementText(adrxml, "sn_passport"));
      	        frm.nm_country.value = nullif(getElementText(adrxml, "nm_country"));
      	        frm.id_country.value = nullif(getElementText(adrxml, "id_country"));
  		          setCombo(frm.sel_country, frm.id_country.value);
      	        frm.nm_state.value = nullif(getElementText(adrxml, "nm_state"));
      	        frm.id_state.value = nullif(getElementText(adrxml, "id_state"));
  		          setCombo(frm.sel_state, frm.id_state.value);
      	        frm.mn_city.value = nullif(getElementText(adrxml, "mn_city"));
      	        frm.tp_street.value = nullif(getElementText(adrxml, "tp_street"));
  		          setCombo(frm.sel_street, frm.tp_street.value);
      	        frm.nm_street.value = nullif(getElementText(adrxml, "nm_street"));
      	        frm.nu_street.value = nullif(getElementText(adrxml, "nu_street"));
      	        frm.zipcode.value = nullif(getElementText(adrxml, "zipcode"));
      	        frm.work_phone.value = nullif(getElementText(adrxml, "work_phone"));
      	        frm.direct_phone.value = nullif(getElementText(adrxml, "direct_phone"));
      	        frm.home_phone.value = nullif(getElementText(adrxml, "home_phone"));
      	        frm.mov_phone.value = nullif(getElementText(adrxml, "mov_phone"));
  	            addrreq = false;
	            } // fi (adrxml)
            }
	          document.getElementById("continue").style.display = "none";
	          document.getElementById("contactdata").style.visibility = "visible";
          }
        } else {
	        alert ("You must enter an email address before continuing");
	        return false;        
        }
      } // loadContactData

      // ------------------------------------------------------

      function showCalendar(ctrl) {       
        var dtnw = new Date();

        window.open("../common/calendar.jsp?a=" + (dtnw.getFullYear()) + "&m=" + dtnw.getMonth() + "&c=" + ctrl, "", "toolbar=no,directories=no,menubar=no,resizable=no,width=171,height=195");
      } // showCalendar()
      
      // ------------------------------------------------------

      function reference(odctrl) {
        var frm = document.forms[0];
        var c1,c2,c12;
        
        switch(parseInt(odctrl)) {
          case 1:
            if (frm.nm_legal.value.indexOf("'")>=0)
              alert("The company name contains invalid characters");
            else {
              window.open("../common/reference.jsp?ix_form=0&nm_table=k_companies&tp_control=1&nm_control=nm_legal&nm_coding=gu_company"+(frm.nm_legal.value.length==0 ? "" : "&where=" + escape(" <%=DB.nm_legal%> LIKE '"+frm.nm_legal.value+"%' ")), "", "scrollbars=yes,toolbar=no,directories=no,menubar=no,resizable=no,width=480,height=520");
            }
            break;            
        } // end switch
      } // reference()

      // ------------------------------------------------------
              
      function lookup(odctrl) {
	      var frm = window.document.forms[0];
        
        switch(parseInt(odctrl)) {
          case 2:
            window.open("../common/lookup_f.jsp?nm_table=k_oportunities_lookup&id_language=" + getUserLanguage() + "&id_section=tp_relation&tp_control=2&nm_control=sel_relation&nm_coding=tp_relation", "lookupreltype", "toolbar=no,directories=no,menubar=no,resizable=no,width=480,height=520");
            break;
          case 3:
            window.open("../common/lookup_f.jsp?nm_table=k_addresses_lookup&id_language=" + getUserLanguage() + "&id_section=tp_street&tp_control=2&nm_control=sel_street&nm_coding=tp_street", "lookupaddrstreet", "toolbar=no,directories=no,menubar=no,resizable=no,width=480,height=520");
            break;
          case 4:
            if (frm.sel_country.options.selectedIndex>0)
              window.open("../common/lookup_f.jsp?nm_table=k_addresses_lookup&id_language=" + getUserLanguage() + "&id_section=" + getCombo(frm.sel_country) + "&tp_control=2&nm_control=sel_state&nm_coding=id_state", "lookupaddrstate", "toolbar=no,directories=no,menubar=no,resizable=no,width=480,height=520");
            else
              alert ("You must choose a country before picking a state");
            break;
        } // end switch()
      } // lookup()
      
      // ------------------------------------------------------

      function validate() {
        var frm = window.document.forms[0];
        
        if (document.getElementById("contactdata").style.visibility != "visible") return false;

      	if (frm.tx_name.value.length==0) {
      	  alert ("The name of the contact person is required");
      	  return false;
      	} else if (allcaps) {
      	  frm.tx_name.value	= frm.tx_name.value.toUpperCase();
      	}
      
      	if (frm.tx_surname.value.length==0) {
      	  alert ("Person last name is required");
      	  return false;
      	} else if (allcaps) {
      	  frm.tx_surname.value	= frm.tx_surname.value.toUpperCase();
      	}
	
      	txt = frm.tx_email.value.trim();
      	if (txt.length>0)
      	  if (!check_email(txt)) {
      	    alert ("The email address is not valid");
      	    return false;
                }
      	frm.tx_email.value = txt.toLowerCase();
      
      	frm.nm_legal.value = frm.nm_legal.value.toUpperCase();
      	frm.tp_relation.value = getCombo(frm.sel_relation);

      	if (frm.ix_address.value.length==0) frm.ix_address.value="1";

				frm.tp_street.value = getCombo(frm.sel_street);
      	
        return true;
      } // validate;
    //-->
  </SCRIPT>
</HEAD>
<BODY TOPMARGIN="8" MARGINHEIGHT="8" onload="setCombos()">
  <DIV class="cxMnu1" style="width:100px"><DIV class="cxMnu2">
    <SPAN class="hmMnuOff" onMouseOver="this.className='hmMnuOn'" onMouseOut="this.className='hmMnuOff'" onClick="history.back()"><IMG src="../images/images/toolmenu/historyback.gif" width="16" style="vertical-align:middle" height="16" border="0" alt="Back"> Back</SPAN>
  </DIV></DIV>
  <TABLE WIDTH="100%">
    <TR><TD><IMG SRC="../images/images/spacer.gif" HEIGHT="4" WIDTH="1" BORDER="0"></TD></TR>
    <TR><TD CLASS="striptitle"><FONT CLASS="title1">New Contact for the Opportunity</FONT></TD></TR>
  </TABLE>  
  <FORM METHOD="post" ACTION="contact_new_store.jsp" onSubmit="return validate()">
    <INPUT TYPE="hidden" NAME="id_domain" VALUE="<%=id_domain%>">
    <INPUT TYPE="hidden" NAME="gu_workarea" VALUE="<%=gu_workarea%>">
    <INPUT TYPE="hidden" NAME="gu_oportunity" VALUE="<%=gu_oportunity%>">
    <INPUT TYPE="hidden" NAME="gu_writer" VALUE="<%=gu_writer%>">
    <INPUT TYPE="hidden" NAME="gu_user" VALUE="<%=gu_writer%>">
    <INPUT TYPE="hidden" NAME="bo_private" VALUE="0">
    <INPUT TYPE="hidden" NAME="bo_restricted" VALUE="0">
    <INPUT TYPE="hidden" NAME="nu_notes" VALUE="0">
    <INPUT TYPE="hidden" NAME="nu_attachs" VALUE="0">
    <INPUT TYPE="hidden" NAME="gu_address">
    <INPUT TYPE="hidden" NAME="ix_address" VALUE="1">
    <INPUT TYPE="hidden" NAME="gu_contact">
    <INPUT TYPE="hidden" NAME="gu_company">
    <INPUT TYPE="hidden" NAME="nm_company">

    <TABLE CLASS="formback">
      <TR><TD>
        <TABLE WIDTH="100%" CLASS="formfront">
          <TR>
            <TD ALIGN="right" WIDTH="140"><FONT CLASS="formplain">Relationship</FONT></TD>
            <TD ALIGN="left" WIDTH="460">
               <INPUT TYPE="hidden" NAME="tp_relation">
               <SELECT NAME="sel_relation"><OPTION VALUE="" SELECTED="selected"></OPTION><%=sRelTypeLookUp%></SELECT>&nbsp;
               <A HREF="javascript:lookup(2)"><IMG SRC="../images/images/find16.gif" HEIGHT="16" BORDER="0" ALT="Show Relationship Types"></A>
            </TD>
          </TR>
          <TR>
            <TD ALIGN="right" WIDTH="140"><FONT CLASS="formplain">e-mail</FONT></TD>
            <TD ALIGN="left" WIDTH="460">
               <INPUT TYPE="text" NAME="tx_email" STYLE="text-tansform:lowercase" MAXLENGTH="100" SIZE="42" onchange="document.forms[0].gu_address.value=''">
            </TD>
          </TR>
          <TR>
            <TD ALIGN="right" WIDTH="140"><FONT CLASS="formplain">Id. Card.</FONT></TD>
            <TD ALIGN="left" WIDTH="460">
               <INPUT TYPE="text" NAME="sn_passport" MAXLENGTH="16" SIZE="16" <%=bAllCaps ? "STYLE=\"text-transform:uppercase\"" : ""%> onchange="document.forms[0].gu_address.value=''">
            </TD>
          </TR>
          <TR>
            <TD ALIGN="right" WIDTH="140"><FONT CLASS="formplain">Telephone</FONT></TD>
            <TD ALIGN="left" WIDTH="460">
              <INPUT TYPE="text" NAME="tx_phone" MAXLENGTH="16" SIZE="16">
            </TD>
          </TR>
	      </TABLE>
	    </TD></TR>
	</TABLE>
	<DIV ALIGN="center" ID="continue" STYLE="display:block">
	  <A HREF="#" CLASS="linkplain" onclick="loadContactData()">Continue</A>
	</DIV>
	<DIV ID="contactdata" STYLE="visibility:hidden">
	<TABLE WIDTH="100%" CLASS="formfront">
          <TR>
            <TD ALIGN="right"><FONT CLASS="formstrong">Company</FONT></TD>
            <TD ALIGN="left">
              <INPUT TYPE="text" NAME="nm_legal" MAXLENGTH="50" SIZE="40" STYLE="text-transform:uppercase" onChange="document.forms[0].gu_company.value='';">
              &nbsp;&nbsp;<A HREF="javascript:reference(1)"><IMG SRC="../images/images/find16.gif" HEIGHT="16" BORDER="0" ALT="Show Company Listing"></A>
            
            </TD>
          </TR>
          <TR>
            <TD ALIGN="right"><FONT CLASS="formstrong">Name</FONT></TD>
            <TD ALIGN="left">
              <INPUT TYPE="text" NAME="tx_name" MAXLENGTH="50" SIZE="40" <%=bAllCaps ? "STYLE=\"text-transform:uppercase\"" : ""%> onchange="document.forms[0].gu_contact.value=''">
            </TD>
          </TR>
          <TR>
            <TD ALIGN="right"><FONT CLASS="formstrong">Surname</FONT></TD>
            <TD ALIGN="left">
              <INPUT TYPE="hidden" NAME="tx_contact">
              <INPUT TYPE="text" NAME="tx_surname" MAXLENGTH="50" SIZE="40" <%=bAllCaps ? "STYLE=\"text-transform:uppercase\"" : ""%> onchange="document.forms[0].gu_contact.value=''">
            </TD>
          </TR>
          <TR>
            <TD ALIGN="right" WIDTH="140">
              <FONT CLASS="formplain">Telephones</FONT>
            </TD>
            <TD ALIGN="left" WIDTH="460">
              <TABLE CLASS="formback">
                <TR>
                  <TD><FONT CLASS="textsmall">Office</FONT></TD>
                  <TD><INPUT TYPE="text" NAME="work_phone" MAXLENGTH="16" SIZE="10"></TD>
                  <TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD>
                  <TD><FONT CLASS="textsmall">Direct</FONT></TD>
                  <TD><INPUT TYPE="text" NAME="direct_phone" MAXLENGTH="16" SIZE="10"></TD>
                </TR>
                <TR>
                  <TD><FONT CLASS="textsmall">Personal</FONT></TD>
                  <TD><INPUT TYPE="text" NAME="home_phone" MAXLENGTH="16" SIZE="10"></TD>              
                  <TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD>
                  <TD><FONT CLASS="textsmall">Cell Phone</FONT></TD>
                  <TD><INPUT TYPE="text" NAME="mov_phone" MAXLENGTH="16" SIZE="10"></TD>
                  <TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD>
                </TR>
              </TABLE>
            </TD>
          </TR>
          <TR>
            <TD ALIGN="right" WIDTH="140"></TD>
            <TD ALIGN="left" WIDTH="460">
              <TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0" BORDER="0"><TR>
                <TD ALIGN="left">
                  <!--<SELECT CLASS="combomini" NAME="sel_location"><OPTION VALUE=""></OPTION><%=sLocationLookUp%></SELECT>-->
                  <INPUT TYPE="hidden" NAME="tp_location">
                </TD>
                <TD></TD>
              </TR></TABLE>
            </TD>
          </TR>
<% if (sLanguage.equalsIgnoreCase("es")) { %>
          <TR>
            <TD ALIGN="right" WIDTH="140">
              <!--<A HREF="javascript:lookup(3)"><IMG SRC="../images/images/find16.gif" HEIGHT="16" BORDER="0" ALT="Show Street Types"></A>&nbsp;-->
              <SELECT CLASS="combomini" NAME="sel_street"><OPTION VALUE=""></OPTION><%=sStreetLookUp%></SELECT>
            </TD>
            <TD ALIGN="left" WIDTH="460">
              <INPUT TYPE="hidden" NAME="tp_street" VALUE="">
              <INPUT TYPE="text" NAME="nm_street" MAXLENGTH="100" SIZE="40" <%=bAllCaps ? "STYLE=\"text-transform:uppercase\"" : ""%> VALUE="" onchange="document.forms[0].gu_address.value=''">
              &nbsp;&nbsp;
              <FONT CLASS="formplain">Num.</FONT>&nbsp;<INPUT TYPE="text" NAME="nu_street" MAXLENGTH="16" SIZE="4" VALUE="" <%=bAllCaps ? "STYLE=\"text-transform:uppercase\"" : ""%>>
            </TD>
          </TR>
<% } else { %>
          <TR>
            <TD ALIGN="right" WIDTH="140">
	      <FONT CLASS="formplain">Num.</FONT>&nbsp;
            </TD>
            <TD ALIGN="left" WIDTH="460">
              <INPUT TYPE="text" NAME="nu_street" MAXLENGTH="16" SIZE="4" VALUE="">
              <INPUT TYPE="text" NAME="nm_street" MAXLENGTH="100" SIZE="40" VALUE="">
              <INPUT TYPE="hidden" NAME="tp_street" VALUE="">
              <SELECT CLASS="combomini" NAME="sel_street"><OPTION VALUE=""></OPTION><%=sStreetLookUp%></SELECT>
              <!--<A HREF="javascript:lookup(3)"><IMG SRC="../images/images/find16.gif" HEIGHT="16" BORDER="0" ALT="Show Street Types"></A>-->
            </TD>
          </TR>
<% } %>
          <TR>
            <TD ALIGN="right" WIDTH="140"><FONT CLASS="formplain">Flat</FONT></TD>
            <TD ALIGN="left" WIDTH="460">
              <INPUT TYPE="text" NAME="tx_addr1" MAXLENGTH="100" SIZE="10" <%=bAllCaps ? "STYLE=\"text-transform:uppercase\"" : ""%>>
              &nbsp;&nbsp;
              <FONT CLASS="formplain">Rest</FONT>&nbsp;
              <INPUT TYPE="text" NAME="tx_addr2" MAXLENGTH="100" SIZE="32" <%=bAllCaps ? "STYLE=\"text-transform:uppercase\"" : ""%>>
            </TD>
          </TR>
          <TR>
            <TD ALIGN="right" WIDTH="140"><FONT CLASS="formplain">Country</FONT></TD>
            <TD ALIGN="left" WIDTH="460">
	      <SELECT CLASS="combomini" NAME="sel_country" onchange="loadstates()"><OPTION VALUE=""></OPTION><%=sCountriesLookUp%></SELECT>
              <INPUT TYPE="hidden" NAME="id_country" VALUE="">
              <INPUT TYPE="hidden" NAME="nm_country" VALUE="">
            </TD>
          </TR>
          <TR>
            <TD ALIGN="right" WIDTH="140"><FONT CLASS="formplain">State</FONT></TD>
            <TD ALIGN="left" WIDTH="460">
              <A HREF="javascript:lookup(4)"><IMG SRC="../images/images/find16.gif" HEIGHT="16" BORDER="0" ALT="Show States"></A>&nbsp;<SELECT CLASS="combomini" NAME="sel_state"></SELECT>
              <INPUT TYPE="hidden" NAME="id_state" MAXLENGTH="16" VALUE="">
              <INPUT TYPE="hidden" NAME="nm_state" MAXLENGTH="30" VALUE="">
            </TD>
          </TR>
          <TR>
            <TD ALIGN="right" WIDTH="140"><FONT CLASS="formplain">City</FONT></TD>
            <TD ALIGN="left" WIDTH="460">
              <INPUT TYPE="text" NAME="mn_city" STYLE="text-transform:uppercase" MAXLENGTH="50" SIZE="30" VALUE="" onchange="document.forms[0].gu_address.value=''">
              &nbsp;&nbsp;
              <FONT CLASS="formplain">Zipcode</FONT>
              &nbsp;
              <INPUT TYPE="text" NAME="zipcode" MAXLENGTH="30" SIZE="5" VALUE="" onchange="document.forms[0].gu_address.value=''">
            </TD>
          </TR>
          <TR>
            <TD COLSPAN="2"><HR></TD>
          </TR>
          <TR>
    	    <TD COLSPAN="2" ALIGN="center">
              <INPUT TYPE="submit" ACCESSKEY="s" VALUE="Save" CLASS="pushbutton" STYLE="width:80" TITLE="ALT+s">&nbsp;
    	      &nbsp;&nbsp;<INPUT TYPE="button" ACCESSKEY="c" VALUE="Cancel" CLASS="closebutton" STYLE="width:80" TITLE="ALT+c" onclick="window.close()">
    	      <BR><BR>
    	    </TD>
    	  </TR>
        </TABLE>
        </DIV>
      </TD></TR>
    </TABLE>                 
  </FORM>
</BODY>
</HTML>
