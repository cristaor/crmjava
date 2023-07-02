<%@ page import="java.util.ArrayList,java.net.URLDecoder,java.sql.Statement,java.sql.ResultSet,java.sql.ResultSetMetaData,java.sql.SQLException,com.knowgate.jdc.JDCConnection,com.knowgate.dataobjs.*,com.knowgate.acl.*,com.knowgate.hipergate.DBLanguages,com.knowgate.misc.Environment,com.knowgate.misc.Gadgets,com.knowgate.hipergate.datamodel.ModelManager" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/nullif.jspf" %>
<jsp:useBean id="GlobalCacheClient" scope="application" class="com.knowgate.cache.DistributedCachePeer"/><jsp:useBean id="GlobalDBLang" scope="application" class="com.knowgate.hipergate.DBLanguages"/><%
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

  String sSkin = getCookie(request, "skin", "xp");
  String sLanguage = getNavigatorLanguage(request);  
  int iRows = Integer.parseInt(nullif(request.getParameter("rows"),"10"));

  String gu_workarea = getCookie(request,"workarea","");
  String nm_referer = nullif(request.getParameter("nm_referer"));
  String tx_search = nullif(request.getParameter("tx_search"));
  String tp_lookup = nullif(request.getParameter("tp_lookup"));
  String bo_active = nullif(request.getParameter("bo_active"));

  String sTypesLookUp = "<OPTION VALUE=\"\"></OPTION>";
  String sCountryList = "id_country,tr_country_en,tr_country_es,tr_country_fr,tr_country_de,tr_country_it,tr_country_pt,tr_country_ca,tr_country_eu,tr_country_ja,tr_country_cn,tr_country_tw,tr_country_fi,tr_country_ru,tr_country_pl,tr_country_nl,tr_country_th,tr_country_cs,tr_country_uk,tr_country_no";
  DBSubset oCountries = new DBSubset(DB.k_lu_countries, sCountryList, null, 250);
  int iCountries = 0;
  DBSubset oLookups = null;
  int iLookups = 0;  
  int iColPos = -1;
  String sColList = "pg_lookup,vl_lookup,tp_lookup,"+DBBind.Functions.ISNULL+"(bo_active,1),tx_comments,"+DBLanguages.getLookupTranslationsColumnList();
  String sMaxVlLen = "255", sMaxTrLen = "50";
  
  JDCConnection oConn = null;
  
  try {
    oConn = GlobalDBBind.getConnection("oportunity_lookups");  
    iCountries = oCountries.load(oConn);
    sTypesLookUp += DBLanguages.getHTMLSelectLookUp (GlobalCacheClient, oConn, DB.k_oportunities_lookup, gu_workarea, DB.tp_lookup, sLanguage);
    ArrayList<Object> aParams = new ArrayList<Object>();
    aParams.add(gu_workarea);
    String sWhere = DB.gu_owner+"=? AND "+DB.id_section+"='"+DB.id_objetive+"'";
    if (tx_search.length()>0) {
      sWhere += " AND ("+DB.vl_lookup+" "+DBBind.Functions.ILIKE+" ? OR "+DB.tr_+sLanguage+" "+DBBind.Functions.ILIKE+" ? OR "+DB.tx_comments+" "+DBBind.Functions.ILIKE+" ?)";
      aParams.add("%"+tx_search+"%");
      aParams.add("%"+tx_search+"%");      
      aParams.add("%"+tx_search+"%");      
    }
    if (tp_lookup.length()>0) {
      sWhere += " AND "+DB.tp_lookup+"=?";
      aParams.add(tp_lookup);
    }
    if (bo_active.length()>0) {
      sWhere += " AND "+DB.bo_active+"=?";
      aParams.add(new Short((short) (bo_active.equals("1") ? 1 : 0)));
    }
    oLookups = new DBSubset (DB.k_oportunities_lookup, sColList, sWhere, 100);
    iLookups = oLookups.load(oConn, aParams.toArray());
    Statement oStmt = oConn.createStatement();
    ResultSet oRSet = oStmt.executeQuery("SELECT vl_lookup,tr_en FROM "+DB.k_oportunities_lookup+" WHERE 1=0");
    ResultSetMetaData oMDat = oRSet.getMetaData();
    if (oConn.getDataBaseProduct()==JDCConnection.DBMS_POSTGRESQL) {
      sMaxVlLen = String.valueOf(oMDat.getColumnDisplaySize(1));
      sMaxTrLen = String.valueOf(oMDat.getColumnDisplaySize(2));
    } else {
      sMaxVlLen = String.valueOf(oMDat.getPrecision(1));
      sMaxTrLen = String.valueOf(oMDat.getPrecision(2));
    }
    oRSet.close();
    oRSet=null;
    oStmt.close();
    oStmt=null;
    oConn.close("oportunity_lookups");

  } catch (SQLException e) {
    if (oConn!=null)
      if (!oConn.isClosed()) {
        oConn.close("oportunity_lookups");
      }
    oConn = null;
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=SQLException&desc=" + e.getLocalizedMessage() + "&resume=_back"));
  }

  iColPos = oCountries.getColumnPosition("tr_country_"+sLanguage);
  oCountries.sortBy(iColPos);
  
  if (-1==iColPos) iColPos = 1;
%><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//en">
<HTML LANG="<% out.write(sLanguage); %>">
<HEAD>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/cookies.js"></SCRIPT>  
  <SCRIPT TYPE="text/javascript" SRC="../javascript/setskin.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/combobox.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/usrlang.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/getparam.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/trim.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/simplevalidations.js"></SCRIPT>
  <TITLE>hipergate :: Sales Objetives Fast Edit</TITLE>
  <SCRIPT TYPE="text/javascript" DEFER="defer">
    <!--      

      function lookup(odctrl) {
        
        switch(parseInt(odctrl)) {
          case 1:
            window.open("../common/lookup_f.jsp?nm_table=k_oportunities_lookup&id_language=" + getUserLanguage() + "&id_section=tp_lookup&tp_control=2&nm_control=tp_lookup<%=String.valueOf(iLookups)%>&nm_coding=tp_lookup", "lookupobjetivetype", "toolbar=no,directories=no,menubar=no,resizable=no,width=480,height=520");
            break;
        }
      } // lookup()
    
      function deleteValues() {
        var frm = document.forms[0];
        var lok = <%=String.valueOf(iLookups)%>;
        var doit = false;
        
        for (var l=0; l<lok; l++) {
          if (frm.elements["chk"+String(l)].checked) {          	
            doit = true;
            frm.elements["vl_lookup"+String(l)].value="";
          }
        } // next
	      if (doit) {
	        frm.submit();
	      } else {
	        alert ("You must select at least one value to be deleted");
	      }
      } // deleteValues()

      function setCombos() {
        var frm = document.forms[0];
<%	    for (int l=0; l<iLookups; l++) { %>
				  setCombo(frm.tp_lookup<%=String.valueOf(l)%>, "<%=oLookups.getStringNull(2,l,"")%>");
<%      } %>
				setCombo(frm.tp_lookup, "<%=tp_lookup%>");
				setCheckedValue(frm.bo_active, "<%=bo_active%>");
      }

			function filterObjetives() {
				var frm = document.forms[0];
			  document.location = "oportunity_lookups.jsp?tx_search="+escape(frm.tx_search.value)+"&tp_lookup="+escape(frm.tp_lookup.value)+"&bo_active="+getCheckedValue(frm.bo_active);
			}

      function validate() {
        var frm = document.forms[0];
        var s;
        
        for (var r=0; r<<%=String.valueOf(iLookups+iRows)%>; r++) {
          s = String(r);
          if (ltrim(frm.elements["vl_lookup"+s].value).length==0 &&
              frm.elements["tr_<%=sLanguage%>"+s].value.length>0) {
            alert ("Row "+ s +" The internal value is requiered");
            return false;
          } else {
            frm.elements["vl_lookup"+s].value = rtrim(frm.elements["vl_lookup"+s].value.toUpperCase());
          }
          if (hasForbiddenChars(frm.elements["vl_lookup"+s].value)) {
            alert ("Row "+ s +" The internal value contains forbidden characters");
            return false;          
          }
        } // next
      } // validate
    // -->
  </SCRIPT>
</HEAD>
<BODY MARGINWIDTH="8" LEFTMARGIN="8" TOPMARGIN="8" MARGINHEIGHT="8" onload="setCombos()">
  <TABLE>
    <TR>
      <TD>
        <DIV class="cxMnu1" style="width:120px"><DIV class="cxMnu2">
          <SPAN class="hmMnuOff" onMouseOver="this.className='hmMnuOn'" onMouseOut="this.className='hmMnuOff'" onClick="window.print()"><IMG src="../images/images/toolmenu/windowprint.gif" width="16" height="16" style="vertical-align:middle" border="0" alt="Print"> Print</SPAN>
        </DIV></DIV>
      </TD>
      <TD CLASS="striptitle"><FONT CLASS="title1">Sales Objetives Fast Edit</FONT></TD>
    </TR>
  </TABLE>
  <FORM METHOD="post" ACTION="oportunity_lookups_store.jsp" onsubmit="return validate()">
    <INPUT TYPE="hidden" NAME="nu_rows" VALUE="<%=String.valueOf(iLookups+iRows)%>">
    <INPUT TYPE="hidden" NAME="gu_workarea" VALUE="<%=gu_workarea%>">
    <INPUT TYPE="hidden" NAME="collist" VALUE="<%=sColList%>">
    <INPUT TYPE="hidden" NAME="tp_lookup" >
    <SELECT NAME="sel_section" STYLE="display:none"><OPTION VALUE="id_objetive" SELECTED="selected">id_objetive</OPTION></SELECT>
    <SELECT NAME="sel_table" STYLE="display:none"><OPTION VALUE="k_oportunities_lookup" SELECTED="selected">k_oportunities_lookup</OPTION></SELECT>
		<TABLE SUMMARY="Controls">
		  <TR><TD COLSPAN="6" BACKGROUND="../images/images/loginfoot_med.gif" HEIGHT="3"></TD></TR>
        <TD><A HREF="#" TITLE="Search" onclick="filterObjetives()"><IMG SRC="../images/images/find16.gif" HEIGHT="16" BORDER="0" ALT="Search"></A></TD>
	      <TD><INPUT TYPE="text" NAME="tx_search" VALUE="<%=Gadgets.HTMLEncode(tx_search)%>"></TD>
	      <TD><SELECT NAME="tp_lookup" CLASS="combomini"><OPTGROUP LABEL="Type"><%=sTypesLookUp%></OPTGROUP></SELECT></TD>
	      <TD CLASS="formplain"><INPUT TYPE="radio" NAME="bo_active" VALUE="" CHECKED>&nbsp;All&nbsp;&nbsp;&nbsp;&nbsp;<INPUT TYPE="radio" NAME="bo_active" VALUE="1">&nbsp;Only Active&nbsp;&nbsp;&nbsp;&nbsp;<INPUT TYPE="radio" NAME="bo_active" VALUE="0">&nbsp;Only Inactive</TD>
	      <TD CLASS="formplain"><A HREF="#" onclick="filterObjetives()" CLASS="linkplain" TITLE="Search">Search</A></TD>
	      <TD CLASS="formplain"><A HREF="oportunity_lookups.jsp" CLASS="linkplain" TITLE="Discard Search">Discard</A></TD>
			</TR>
		  <TR><TD COLSPAN="6" BACKGROUND="../images/images/loginfoot_med.gif" HEIGHT="3"></TD></TR>
      <TR><TD COLSPAN="6"><INPUT TYPE="submit" CLASS="pushbutton" VALUE="Save"></TD></TR>
		  <TR><TD COLSPAN="7" BACKGROUND="../images/images/loginfoot_med.gif" HEIGHT="3"></TD></TR>
    </TABLE>

    <TABLE SUMMARY="Values">
<%	out.write("      <TR>\n");
	String[] aColList = Gadgets.split(sColList,',');
	int iListLen = aColList.length;
	out.write("<TD CLASS=\"tableheader\" BACKGROUND=\"../skins/"+sSkin+"/tablehead.gif\"></TD>");
	for (int c=1; c<iListLen; c++) {
	  if (aColList[c].equals(DB.tr_+sLanguage))
	    out.write("<TD CLASS=\"tableheader\" BACKGROUND=\"../skins/"+sSkin+"/tablehead.gif\">&nbsp;<B>Label Shown</B>&nbsp;</TD>");
	  if (aColList[c].equals(DB.vl_lookup))
	    out.write("<TD CLASS=\"tableheader\" BACKGROUND=\"../skins/"+sSkin+"/tablehead.gif\">&nbsp;<B>Internal Value</B>&nbsp;</TD>");
	}
	out.write("      <TD CLASS=\"tableheader\" BACKGROUND=\"../skins/"+sSkin+"/tablehead.gif\">&nbsp;<B>Active</B>&nbsp;</TD><TD CLASS=\"tableheader\" BACKGROUND=\"../skins/"+sSkin+"/tablehead.gif\">&nbsp;<B>Type</B>&nbsp;</TD><TD CLASS=\"tableheader\" BACKGROUND=\"../skins/"+sSkin+"/tablehead.gif\">&nbsp;<B>Comments</B>&nbsp;</TD></TR>\n");
	for (int l=0; l<iLookups; l++) {
	  out.write("      <TR>\n");
	  out.write("<TD align=\"right\" CLASS=\"textplain\">"+String.valueOf(l+1)+"&nbsp;<INPUT TYPE=\"hidden\" NAME=\"pg_lookup"+String.valueOf(l)+"\" VALUE=\""+String.valueOf(oLookups.getInt(0,l))+"\"></TD>");
	  out.write("<TD CLASS=\"strip"+String.valueOf((l%2)+1)+"\"><INPUT TYPE=\"text\" NAME=\"vl_lookup"+String.valueOf(l)+"\" CLASS=\"combomini\" VALUE=\""+oLookups.getStringNull(1,l,"")+"\" SIZE=\"30\" MAXLENGTH=\""+sMaxVlLen+"\" STYLE=\"background:lightgray\" onkeypress=\"return false;\"></TD>");
	  for (int c=2; c<iListLen; c++) {
	    if (aColList[c].equals(DB.tr_+sLanguage) || aColList[c].equals(DB.vl_lookup))
	      out.write("<TD CLASS=\"strip"+String.valueOf((l%2)+1)+"\"><INPUT TYPE=\"text\" NAME=\""+aColList[c]+String.valueOf(l)+"\" SIZE=\""+sMaxTrLen+"\" MAXLENGTH=\""+sMaxTrLen+"\" CLASS=\"combomini\" VALUE=\""+oLookups.getStringNull(aColList[c],l,"")+"\"></TD>");
	  }
	  out.write("      <TD ALIGN=\"center\"><INPUT TYPE=\"checkbox\" VALUE=\"1\" NAME=\"bo_active"+String.valueOf(l)+"\" "+(oLookups.getShort(3,l)==1 ? "CHECKED=\"checked\"" : "")+"></TD><TD><SELECT NAME=\"tp_lookup"+String.valueOf(l)+"\">"+sTypesLookUp+"</SELECT></TD><TD><INPUT TYPE=\"text\" NAME=\"tx_comments"+String.valueOf(l)+"\" SIZE=\"48\" MAXLENGTH=\"254\" CLASS=\"combomini\" VALUE=\""+oLookups.getStringNull(4,l,"")+"\"></TD></TR>\n");
	}
	for (int r=0; r<iRows; r++) {
	  out.write("      <TR>\n");
	  out.write("<TD align=\"right\" CLASS=\"textplain\">"+String.valueOf(r+1+iLookups)+"&nbsp;</TD>");	  
	  out.write("<TD CLASS=\"strip"+String.valueOf((r%2)+1)+"\"><INPUT TYPE=\"text\" NAME=\"vl_lookup"+String.valueOf(r+iLookups)+"\" SIZE=\"30\" MAXLENGTH=\""+sMaxVlLen+"\" CLASS=\"combomini\" STYLE=\"text-transform:uppercase\"></TD>");
	  for (int c=2; c<iListLen; c++) {
	    if (aColList[c].equals(DB.tr_+sLanguage) || aColList[c].equals(DB.vl_lookup))
	      out.write("<TD CLASS=\"strip"+String.valueOf((r%2)+1)+"\"><INPUT TYPE=\"text\" NAME=\""+aColList[c]+String.valueOf(r+iLookups)+"\" SIZE=\""+sMaxTrLen+"\" MAXLENGTH=\""+sMaxTrLen+"\" CLASS=\"combomini\"></TD>");
	  }
	  out.write("      <TD ALIGN=\"center\"><INPUT TYPE=\"checkbox\" NAME=\"bo_active"+String.valueOf(r+iLookups)+"\" VALUE=\"1\" CHECKED=\"checked\"></TD><TD><SELECT NAME=\"tp_lookup"+String.valueOf(r+iLookups)+"\" onchange=\"if (this.options[this.selectedIndex].value=='__ADDNEWTYPE__') lookup(1);\">"+sTypesLookUp+"<OPTION VALUE=\"__ADDNEWTYPE__\">Add New Type</OPTION></SELECT></TD><TD><INPUT TYPE=\"text\" NAME=\"tx_comments"+String.valueOf(r+iLookups)+"\" SIZE=\"48\" MAXLENGTH=\"254\" CLASS=\"combomini\" VALUE=\"\"></TD></TR>\n");
	}
%>
    </TABLE>
  </FORM>
</HTML> 