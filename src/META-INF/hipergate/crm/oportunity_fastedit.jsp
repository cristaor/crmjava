<%@ page import="java.io.IOException,java.io.UnsupportedEncodingException,java.io.File,java.net.URLDecoder,java.sql.SQLException,com.oreilly.servlet.MultipartRequest,com.knowgate.jdc.JDCConnection,com.knowgate.dataobjs.*,com.knowgate.acl.*,com.knowgate.hipergate.DBLanguages,com.knowgate.misc.CSVParser,com.knowgate.misc.Environment,com.knowgate.misc.Gadgets" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/nullif.jspf" %><jsp:useBean id="GlobalCacheClient" scope="application" class="com.knowgate.cache.DistributedCachePeer"/><jsp:useBean id="GlobalDBLang" scope="application" class="com.knowgate.hipergate.DBLanguages"/><%!
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

  public static String getField (CSVParser oCsv, int iCol, int iRow)
    throws IllegalStateException, ArrayIndexOutOfBoundsException,
           StringIndexOutOfBoundsException, UnsupportedEncodingException {
    String sRetVal;
    if (null==oCsv) {
      sRetVal = "";
    } else {
      String sFld = oCsv.getField(iCol, iRow);
      if (sFld.indexOf(34)>=0) {
        StringBuffer oFld = new StringBuffer(sFld.length());
        int q = 1;
        for (int c=0; c<sFld.length(); c++) {
          if (sFld.charAt(c)=='"') {
            oFld.append(1==q ? "«" : "»");
            q *= -1;
          } // fi
        } // next
        sRetVal = oFld.toString().trim().toUpperCase();
      } else {
        sRetVal = sFld.trim().toUpperCase();
      } // fi ()
    } // fi (sFld.indexOf('"')>=0)
    if (15==iCol) sRetVal = sRetVal.toLowerCase(); 
    return sRetVal;
  } // getField
%><% 
  
  if (autenticateSession(GlobalDBBind, request, response)<0) return;

  String sTmpDir = Environment.getProfileVar(GlobalDBBind.getProfileName(), "temp", Environment.getTempDir());
  sTmpDir = Gadgets.chomp(sTmpDir,File.separator);
  MultipartRequest oReq = null;
  
  try {
    oReq = new MultipartRequest(request, sTmpDir, "UTF-8");
  } catch (IOException ignore) { }

  String D, sRow, sStrip;
  int iRows = Integer.parseInt(nullif(request.getParameter("rows"),"10"));
  String sSkin = getCookie(request, "skin", "xp");
  String sLanguage = getNavigatorLanguage(request);  

  String gu_workarea = getCookie(request,"workarea","");
  String gu_user = getCookie(request,"userid","");

  File oCsvFile = null;
  
  if (null!=oReq) {
    oCsvFile = oReq.getFile(0);
    D = oReq.getParameter("sel_delim").replace('T','\t');
  } else {
    D = "|";
  }

  String sDescriptor = "id_contact_ref"+D+"tx_name"+D+"tx_surname"+D+"nm_legal"+D+"tx_email"+D+"direct_phone"+D+"id_sector"+D+"de_title"+D+"sn_passport"+D+"tp_passport"+D+"dt_birth"+D+"ny_age"+D+"tp_street"+D+"nm_street"+D+"nu_street"+D+"tx_addr1"+D+"tx_addr2"+D+"id_country"+D+"id_state"+D+"mn_city"+D+"zipcode"+D+"id_objetive";
  CSVParser oCsv = null;
  JDCConnection oConn = null;  
  String sObjectiveLookUp="", sStreetsLookUp="", sCountriesLookUp="";
	StringBuffer oActivitiesLookUp = new StringBuffer();

  if (oCsvFile!=null) {
    oCsv = new CSVParser(oReq.getParameter("sel_encoding"));
    try {
      oCsv.parseFile(oCsvFile, sDescriptor);
      iRows = oCsv.getLineCount();
    } catch (ArrayIndexOutOfBoundsException aiob) {
      response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=ArrayIndexOutOfBoundsException&desc=" + aiob.getMessage() + "&resume=_back"));
      oCsv = null;
    } finally {
      if (null!=oCsvFile) oCsvFile.delete();
    }
    if (null==oCsv) return;
  } // fi

	DBSubset oCampaigns = new DBSubset (DB.k_campaigns,DB.gu_campaign+","+DB.nm_campaign+","+DB.dt_created,
																			DB.gu_workarea+"=? AND "+DB.bo_active+"<>0 ORDER BY "+DB.dt_created+" DESC",100);
  DBSubset oActivities = new DBSubset (DB.k_activities+" a,"+DB.k_campaigns+" c",
  																		 "a."+DB.gu_activity+",a."+DB.gu_campaign+",a."+DB.tl_activity+",a."+DB.dt_start+",a."+DB.dt_created,
																			 "a."+DB.gu_campaign+"=c."+DB.gu_campaign+" AND c."+DB.bo_active+"<>0 AND "+
																			 "a."+DB.gu_workarea+"=? AND a."+DB.bo_active+"<>0", 100);
  int iCampaings = 0, iActivities = 0;
  try {
    oConn = GlobalDBBind.getConnection("contact_fastedit");
    iActivities = oActivities.load(oConn, new Object[]{gu_workarea});
    for (int a=0; a<iActivities; a++) if (oActivities.isNull(2,a)) oActivities.setElementAt(oActivities.getDate(3,a),2,a);
    oActivities.sortByDesc(2);
    iCampaings = oCampaigns.load(oConn, new Object[]{gu_workarea});
		for (int c=0; c<iCampaings; c++) {
		  oActivitiesLookUp.append("<OPTION VALUE=\""+oCampaigns.getString(0,c)+",\">"+oCampaigns.getString(1,c)+"</OPTION>");
		  for (int a=0; a<iActivities; a++) {
		    if (oActivities.getDate(4,a).compareTo(oCampaigns.getDate(2,c))<0) break;
		    if (oActivities.getString(1,a).equals(oCampaigns.getString(0,c)))
		      oActivitiesLookUp.append("<OPTION VALUE=\""+oCampaigns.getString(0,c)+","+oActivities.getString(0,a)+"\">&nbsp;&nbsp;&nbsp;&nbsp;"+oActivities.getString(2,a)+"</OPTION>");
		  }
		}

    sObjectiveLookUp = GlobalDBLang.getHTMLSelectLookUp (GlobalCacheClient, oConn, DB.k_oportunities_lookup, gu_workarea, DB.id_objetive, sLanguage);
    sStreetsLookUp = GlobalDBLang.getHTMLSelectLookUp (GlobalCacheClient, oConn, DB.k_addresses_lookup, gu_workarea, DB.tp_street, sLanguage);
    sCountriesLookUp = GlobalDBLang.getHTMLCountrySelect(oConn, sLanguage);

    oConn.close("contact_fastedit");
  }
  catch (SQLException e) {  
    if (oConn!=null)
      if (!oConn.isClosed()) {
        oConn.close("contact_fastedit");
      }
    oConn = null;
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=SQLException&desc=" + e.getLocalizedMessage() + "&resume=_back"));
  }
  if (null==oConn) return;    
  oConn = null;
  
%><HTML LANG="<% out.write(sLanguage); %>">
<HEAD>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/trim.js"></SCRIPT>  
  <SCRIPT TYPE="text/javascript" SRC="../javascript/cookies.js"></SCRIPT>  
  <SCRIPT TYPE="text/javascript" SRC="../javascript/setskin.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/combobox.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/usrlang.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/datefuncs.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/simplevalidations.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/xmlhttprequest.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/email.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/autosuggest20.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript">
    <!--

      var nrows = <%=String.valueOf(iRows)%>;

      // ------------------------------------------------------

      function loadstates(sel_country, sel_state, setval) {
	      var frm = window.document.forms[0];

        clearCombo(frm.elements[sel_state]);
        
        if (frm.elements[sel_country].options.selectedIndex>0) {
          if (setval==null)
            parent.frames[1].location = "../common/addr_load.jsp?id_language=" + getUserLanguage() + "&gu_workarea=" + getCookie("workarea") + "&id_section=" + getCombo(frm.elements[sel_country]) + "&control="+sel_state+"&onload=fillStates";
          else
            parent.frames[1].location = "../common/addr_load.jsp?id_language=" + getUserLanguage() + "&gu_workarea=" + getCookie("workarea") + "&id_section=" + getCombo(frm.elements[sel_country]) + "&control="+sel_state+"&set_value=" + setval+"&onload=fillStates";
        } // fi
      } // loadstates

      // ------------------------------------------------------
      
      function fillStates() {
        var frm = document.forms[0];
	      var opt = frm.id_state0.options;
	      var len = opt.length;
			  for (var r=1; r<nrows; r++) {
			    var cnt = frm.elements["id_state"+String(r)];
			    for (var s=0; s<len; s++) {			      	
			      comboPush (cnt, opt[s].text, opt[s].value, null, null); 
			    } // next
			  } // next
      } // fillStates

      // ------------------------------------------------------

			function propagateFirstStateSelection(idx) {
        var frm = document.forms[0];
			  for (var r=1; r<nrows; r++) {
			    if (frm.id_country0.selectedIndex==frm.elements["id_country"+String(r)].selectedIndex) {
			      if (frm.elements["id_state"+String(r)].selectedIndex<=0) {
			        frm.elements["id_state"+String(r)].options[idx].selected = true;
			      }
			    }
			  }				
		  } // propagateFirstStateSelection

      // ------------------------------------------------------

			function propagateFirstObjetiveSelection(idx) {
        var frm = document.forms[0];
			  for (var r=1; r<nrows; r++) {
			    if (frm.elements["id_objetive"+String(r)].selectedIndex<=0) {
			        frm.elements["id_objetive"+String(r)].options[idx].selected = true;
			    }
			  }
			  frm.id_objetive0.focus();
		  } // propagateFirstObjetiveSelection

      // ------------------------------------------------------

			function propagateFirstCitySelection(nm) {
        var frm = document.forms[0];
			  for (var r=1; r<nrows; r++) {
			    if (frm.elements["mn_city"+String(r)].value.length==0) {
			        frm.elements["mn_city"+String(r)].value = nm;
			    }
			  }				
			  frm.mn_city0.focus();
		  } // propagateFirstCitySelection

      // ------------------------------------------------------

			var addrreq = null;

      function lookupEmail(forrow) {
      	var frw = String(forrow);
	      var frm = window.document.forms[0];
	      var txt = ltrim(rtrim(frm.elements["tx_email"+frw].value));
	      if (txt.length>0) {
	      if (!check_email(txt)) {
	        alert ("The contact email address is not valid");
	        return false;
        } else {
            var addrreq = createXMLHttpRequest();
            if (addrreq) {
              addrreq.open("GET", "../common/memberaddress_xmlfeed.jsp?email="+frm.elements["tx_email"+frw].value+"&workarea="+frm.gu_workarea.value+"&writer="+frm.gu_writer.value, false);
              addrreq.send(null);              
    	        var adrxml = addrreq.responseXML.getElementsByTagName("MemberAddress");
	            if (adrxml) {
      	        adrxml = adrxml[0];
      	        frm.elements["tx_name"+frw].value = nullif(getElementText(adrxml, "tx_name"));
      	        frm.elements["tx_surname"+frw].value = nullif(getElementText(adrxml, "tx_surname"));
      	        if (nullif(getElementText(adrxml, "id_country")).length>0) {
      	          frm.elements["nm_country"+frw].value = nullif(getElementText(adrxml, "nm_country"));      	        
  		            setCombo(frm.elements["id_country"+frw], nullif(getElementText(adrxml, "id_country")));
      	        }
      	        if (nullif(getElementText(adrxml, "id_state")).length>0) {
      	          frm.elements["nm_state"+frw].value = nullif(getElementText(adrxml, "nm_state"));
  		            setCombo(frm.elements["id_state"+frw], nullif(getElementText(adrxml, "id_state")));
      	        }
      	        frm.elements["mn_city"+frw].value = nullif(getElementText(adrxml, "mn_city"));
  		          setCombo(frm.elements["tp_street"+frw], frm.elements["tp_street"+frw].value);
      	        frm.elements["nm_street"+frw].value = nullif(getElementText(adrxml, "nm_street"));
      	        frm.elements["nu_street"+frw].value = nullif(getElementText(adrxml, "nu_street"));
      	        frm.elements["tx_addr1"+frw].value = nullif(getElementText(adrxml, "tx_addr1"));
      	        frm.elements["tx_addr2"+frw].value = nullif(getElementText(adrxml, "tx_addr2"));
      	        frm.elements["zipcode"+frw].value = nullif(getElementText(adrxml, "zipcode"));
      	        frm.elements["direct_phone"+frw].value = nullif(getElementText(adrxml, "direct_phone"));
  	            addrreq = false;
	            } // fi (adrxml)
            }
          }
        }
      } // loadContactData

      function validate() {
        var frm = document.forms[0];
	      var txt;
	
	      for (var r=0; r<nrows; r++) {
	  		  txt = frm.elements["tx_email"+String(r)].value.toLowerCase();
	  			if (txt.length>0 && !check_email(txt)) {
	    		  alert ("Row "+String(r+1)+" The email address is not valid");
	    			return false;
	  			}
	  			frm.elements["tx_email"+String(r)].value = txt;

	  			if ((frm.elements["tx_name"+String(r)].value.length==0  && frm.elements["tx_surname"+String(r)].value.length==0) &&
	            (frm.elements["direct_phone"+String(r)].value.length >0 || frm.elements["tx_email"+String(r)].value.length >0 ||
	       			 frm.elements["nm_street"+String(r)].value.length>0)) {
	    		  alert ("Row "+String(r+1)+" The name or surname are required");
	    		  frm.elements["tx_name"+String(r)].focus();
	    		return false;
	        }  

	  			if ((frm.elements["tx_name"+String(r)].value.length>0  || frm.elements["tx_surname"+String(r)].value.length>0) &&
	            (frm.elements["direct_phone"+String(r)].value.length==0 && frm.elements["tx_email"+String(r)].value.length==0)) {
	    		  alert ("Row "+String(r+1)+" The e-mail or telephone is required");
	    		  frm.elements["tx_email"+String(r)].focus();
	    		return false;
	        }  
			  } // next
	
				frm.id_mode.value = (frm.rad_ins_updt[0].checked ? "append" : "appendupdate");

				transformCase();
				
				return true;
      } // validate

      // ------------------------------------------------------

      function setCombos() {
        var frm = document.forms[0];
	      var opt = frm.id_country0.options;
	      var len = opt.length; 
	      var cnt;
	      for (var r=0; r<nrows; r++) {
	        cnt = frm.elements["id_country"+String(r)].options;
	        for (var o=0; o<len; o++) {
	          cnt[o] = new Option(opt[o].text, opt[o].value, false, false);
	        }
	      } // next (r)
<%
	if (oCsv==null) {
	  if (sLanguage.equals("es")) {
	    for (int r=0; r<iRows; r++) out.write("        setCombo(frm.id_country"+String.valueOf(r)+",\"es\");\n");
	    for (int r=0; r<iRows; r++) out.write("        setCombo(frm.tp_street"+String.valueOf(r)+",\"CALLE\");\n");
	  }
	  else if (sLanguage.equals("en"))
	    for (int r=0; r<iRows; r++) out.write("        setCombo(frm.id_country"+String.valueOf(r)+",\"us\");\n");
	  else if (sLanguage.equals("en")  || sLanguage.equalsIgnoreCase("en_GB"))
	    for (int r=0; r<iRows; r++) out.write("        setCombo(frm.id_country"+String.valueOf(r)+",\"gb\");\n");
	  else if (sLanguage.equals("fr"))
	    for (int r=0; r<iRows; r++) out.write("        setCombo(frm.id_country"+String.valueOf(r)+",\"fr\");\n");
	  else if (sLanguage.equals("de"))
	    for (int r=0; r<iRows; r++) out.write("        setCombo(frm.id_country"+String.valueOf(r)+",\"de\");\n");
	  else if (sLanguage.equals("it"))
	    for (int r=0; r<iRows; r++) out.write("        setCombo(frm.id_country"+String.valueOf(r)+",\"it\");\n");
	  else if (sLanguage.equals("cn") || sLanguage.equalsIgnoreCase("zh_CN"))
	    for (int r=0; r<iRows; r++) out.write("        setCombo(frm.id_country"+String.valueOf(r)+",\"cn\");\n");
	  else if (sLanguage.equals("tw") || sLanguage.equalsIgnoreCase("zh_TW"))
	    for (int r=0; r<iRows; r++) out.write("        setCombo(frm.id_country"+String.valueOf(r)+",\"tw\");\n");
	} else {
	  for (int r=0; r<iRows; r++) {
	    sRow = String.valueOf(r);
	    out.write("        setCombo(frm.tp_street"+sRow+",\""+oCsv.getField(12,r)+"\");\n");
	    out.write("        setCombo(frm.id_country"+sRow+",\""+oCsv.getField(17,r)+"\");\n");
	    out.write("        setCombo(frm.id_state"+sRow+",\""+oCsv.getField(18,r)+"\");\n");
	  } // next
	} // fi
%>
	      if (frm.id_country0.selectedIndex>0 && frm.id_state0.options.length==0)
			    loadstates("id_country0", "id_state0", null);
      } // setCombos()
    // -->
  </SCRIPT>
  <TITLE>hipergate :: Opportunities Fast Entry</TITLE>
</HEAD>
<BODY MARGINWIDTH="8" LEFTMARGIN="8" TOPMARGIN="8" MARGINHEIGHT="8" onload="setCombos()">
  <%@ include file="../common/header.jspf" %>
  <TABLE>
    <TR>
      <TD>
        <DIV class="cxMnu1" style="width:220px"><DIV class="cxMnu2">
          <SPAN class="hmMnuOff" onMouseOver="this.className='hmMnuOn'" onMouseOut="this.className='hmMnuOff'" onClick="window.parent.location='crmhome.jsp?selected=2&subselected=-1'"><IMG src="../images/images/toolmenu/historyback.gif" width="16" style="vertical-align:middle" height="16" border="0" alt="Back"> Back</SPAN>
          <SPAN class="hmMnuOff" onMouseOver="this.className='hmMnuOn'" onMouseOut="this.className='hmMnuOff'" onClick="window.print()"><IMG src="../images/images/toolmenu/windowprint.gif" width="16" height="16" style="vertical-align:middle" border="0" alt="Print"> Print</SPAN>
        </DIV></DIV>
      </TD>
      <TD CLASS="striptitle"><FONT CLASS="title1">Opportunities Fast Edit</FONT></TD>
    </TR>
  </TABLE>  
  <FORM METHOD="post" ACTION="contact_fastedit_store.jsp" onsubmit="return validate()">
    <INPUT TYPE="hidden" NAME="tx_descriptor" VALUE="<%=sDescriptor%>">
    <INPUT TYPE="hidden" NAME="nu_rows" VALUE="<%=String.valueOf(iRows)%>">
    <INPUT TYPE="hidden" NAME="gu_workarea" VALUE="<%=gu_workarea%>">
    <INPUT TYPE="hidden" NAME="gu_writer" VALUE="<%=gu_user%>">
    <INPUT TYPE="hidden" NAME="id_mode" VALUE="">
    <DIV STYLE="display:none">
    <INPUT TYPE="radio" NAME="rad_ins_updt">&nbsp;<FONT CLASS="textplain">Insert</FONT>&nbsp;&nbsp;<INPUT TYPE="radio" NAME="rad_ins_updt" CHECKED>&nbsp;<FONT CLASS="textplain">Insert and Update</FONT>
    <BR>
    <INPUT TYPE="checkbox" NAME="chk_dup_emails" VALUE="1" CHECKED>&nbsp;<FONT CLASS="textplain">Without duplicated e-mails</FONT>
	  </DIV>
		<BR>
		<FONT CLASS="textplain">Campaign or Activity</FONT>&nbsp;<SELECT NAME="sel_activity"><OPTION VALUE=""></OPTION><%=oActivitiesLookUp%></SELECT>
    <TABLE CELLSPACING="1" CELLPADDING="0">
      <TR>
        <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif"></TD>
        <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif" NOWRAP>&nbsp;<B>e-mail</B></TD>
        <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif" NOWRAP>&nbsp;<B>Name</B></TD>
        <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif" NOWRAP>&nbsp;<B>Surname</B></TD>

        <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif" NOWRAP>&nbsp;<B>Street Type</B></TD>
        <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif" NOWRAP>&nbsp;<B>Street Name</B></TD>
        <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif" NOWRAP>&nbsp;<B>Num.</B></TD>
        <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif" NOWRAP>&nbsp;<B>Flat</B></TD>
        <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif" NOWRAP>&nbsp;<B>Rest of Address</B></TD>
        <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif" NOWRAP>&nbsp;<B>Country</B></TD>
        <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif" NOWRAP>&nbsp;<B>State</B></TD>
        <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif" NOWRAP>&nbsp;<B>City</B></TD>
        <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif" NOWRAP>&nbsp;<B>Zipcode</B></TD>

        <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif" NOWRAP>&nbsp;<B>Telephone</B></TD>
      </TR>
<%
   for (int r=0; r<iRows; r++) {
     sRow = String.valueOf(r);
     sStrip = String.valueOf((r%2)+1);
%>
      <TR>
        <TD CLASS="strip<% out.write (sStrip); %>" ALIGN="right"><A HREF="row<%=sRow%>"></A><FONT CLASS="textsmall"><%=String.valueOf(r+1)%>&nbsp;</FONT></TD>
        <TD CLASS="strip<% out.write (sStrip); %>"><INPUT TYPE="text" CLASS="combomini ttl" NAME="tx_email<%=sRow%>" SIZE="20" MAXLENGTH="100" VALUE="<%=getField(oCsv,4,r)%>" onblur="lookupEmail(<%=sRow%>)"></TD>
        <TD CLASS="strip<% out.write (sStrip); %>"><INPUT TYPE="text" CLASS="combomini ttu" NAME="tx_name<%=sRow%>" SIZE="12" MAXLENGTH="100" VALUE="<%=getField(oCsv,1,r)%>"></TD>
        <TD CLASS="strip<% out.write (sStrip); %>"><INPUT TYPE="text" CLASS="combomini ttu" NAME="tx_surname<%=sRow%>" SIZE="20" MAXLENGTH="100" VALUE="<%=getField(oCsv,2,r)%>"></TD>
        <TD CLASS="strip<% out.write (sStrip); %>"><SELECT STYLE="WIDTH:90px" CLASS="combomini" NAME="tp_street<%=sRow%>"><OPTION VALUE=""></OPTION><%=sStreetsLookUp%></SELECT></TD>
        <TD CLASS="strip<% out.write (sStrip); %>"><INPUT TYPE="text" CLASS="combomini ttu" NAME="nm_street<%=sRow%>" SIZE="20" MAXLENGTH="100" VALUE="<%=getField(oCsv,13,r)%>"></TD>
        <TD CLASS="strip<% out.write (sStrip); %>"><INPUT TYPE="text" CLASS="combomini ttu" NAME="nu_street<%=sRow%>" SIZE="4" MAXLENGTH="16" VALUE="<%=getField(oCsv,14,r)%>"></TD>
        <TD CLASS="strip<% out.write (sStrip); %>"><INPUT TYPE="text" CLASS="combomini ttu" NAME="tx_addr1<%=sRow%>" SIZE="10" MAXLENGTH="100" VALUE="<%=getField(oCsv,15,r)%>"></TD>
        <TD CLASS="strip<% out.write (sStrip); %>"><INPUT TYPE="text" CLASS="combomini ttu" NAME="tx_addr2<%=sRow%>" SIZE="10" MAXLENGTH="100" VALUE="<%=getField(oCsv,16,r)%>"></TD>
        <TD>
          <INPUT TYPE="hidden" NAME="nm_country<%=sRow%>">
          <SELECT CLASS="combomini" STYLE="width:100px" NAME="id_country<%=sRow%>" onchange="loadstates('id_country<%=sRow%>','id_state<%=sRow%>',null)"><OPTION VALUE=""></OPTION><% if (0==r) out.write(sCountriesLookUp); %></SELECT>
        </TD>
        <TD CLASS="strip<% out.write (sStrip); %>">
          <INPUT TYPE="hidden" NAME="nm_state<%=sRow%>">
          <SELECT STYLE="width:120px" CLASS="combomini" NAME="id_state<%=sRow%>" <% if (0==r) out.write("onchange=\"propagateFirstStateSelection(this.selectedIndex)\""); %>></SELECT>
        </TD>
        <TD CLASS="strip<% out.write (sStrip); %>" NOWRAP>
        	<INPUT TYPE="text" CLASS="combomini ttu" NAME="mn_city<%=sRow%>" SIZE="25" MAXLENGTH="50" VALUE="<%=getField(oCsv,19,r)%>">
          <% if (0==r) out.write("<A HREF=\"#\" TITLE=\"Select the same city for everyone\" onclick=\"propagateFirstCitySelection(document.forms[0].mn_city0.value)\"><IMG SRC=\"../images/images/downarrow16.gif\" WIDTH=\"16\" HEIGHT=\"16\" BORDER=\"0\" ALT=\"Down Arrow\"></A>&nbsp;\n"); %>
        </TD>
        <TD CLASS="strip<% out.write (sStrip); %>"><INPUT TYPE="text" CLASS="combomini" NAME="zipcode<%=sRow%>" SIZE="8" MAXLENGTH="30" VALUE="<%=getField(oCsv,20,r)%>"></TD>
        <TD CLASS="strip<% out.write (sStrip); %>"><INPUT TYPE="text" CLASS="combomini" NAME="direct_phone<%=sRow%>" SIZE="10" MAXLENGTH="16" VALUE="<%=getField(oCsv,5,r)%>"></TD>
      </TR>
			<TR>
				<TD CLASS="strip<% out.write (sStrip); %>"></TD>
				<TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif" ALIGN="right" NOWRAP><B>Interest Area</B>&nbsp;</TD>
        <TD COLSPAN="12" CLASS="strip<% out.write (sStrip); %>" ALIGN="left">
          <SELECT ID="id_objetive<%=sRow%>" NAME="id_objetive<%=sRow%>"><OPTION VALUE=""></OPTION><%=sObjectiveLookUp%></SELECT>
          <% if (0==r) out.write("&nbsp;<A HREF=\"#\" TITLE=\"Select the same objetive for everyone\" onclick=\"propagateFirstObjetiveSelection(document.forms[0].id_objetive0.selectedIndex)\"><IMG SRC=\"../images/images/downarrow16.gif\" WIDTH=\"16\" HEIGHT=\"16\" BORDER=\"0\" ALT=\"Down Arrow\"></A>\n"); %>
        </TD>
		  </TR>
			<TR>
				<TD COLSPAN="14" HEIGHT="8"></TD>
		  </TR>
<% } %>
    </TABLE>
    <BR>
    <INPUT TYPE="submit" VALUE="Save" CLASS="pushbutton">
  </FORM>
</BODY>
<SCRIPT TYPE="text/javascript">
    <!--  
<% 	for (int r=0; r<iRows; r++) {
	    sRow = String.valueOf(r); %>
      
      var AutoSuggestCityOptions<%=sRow%> = { script:"String('../common/autocomplete.jsp?nm_table=k_lu_cities&nm_valuecolumn=mn_city&nm_textcolumn=mn_city&nm_infocolumn=zipcode&nm_wrkacolumn=id_country&gu_workarea=')+getCombo(document.forms[0].id_country<%=sRow%>)+String('&tx_where=id_state%3D%27')+getCombo(document.forms[0].id_state<%=sRow%>)+String('%27%20AND%20mn_city&')", varname:"tx_like",minchars:3,form:0, callback: function (obj) { if (document.forms[0].zipcode<%=sRow%>.value.length==0) document.forms[0].zipcode<%=sRow%>.value=obj.info; } };

      var AutoSuggest<%=sRow%> = new AutoSuggest("mn_city<%=sRow%>", AutoSuggestCityOptions<%=sRow%>);
<% } %>
    //-->
</SCRIPT>
</HTML>