<%@ page import="java.text.SimpleDateFormat,java.util.Arrays,java.util.Iterator,java.util.TreeMap,java.util.ArrayList,java.util.Date,java.net.URLDecoder,java.io.File,java.sql.SQLException,java.sql.Timestamp,com.knowgate.acl.*,com.knowgate.jdc.JDCConnection,com.knowgate.dataobjs.DB,com.knowgate.dataobjs.DBBind,com.knowgate.dataobjs.DBSubset,com.knowgate.dataobjs.DBSubset.DBSubsetDateGroup,com.knowgate.misc.Calendar,com.knowgate.misc.Gadgets,com.knowgate.misc.NameValuePair,com.knowgate.hipergate.DBLanguages" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/nullif.jspf" %><jsp:useBean id="GlobalCacheClient" scope="application" class="com.knowgate.cache.DistributedCachePeer"/><jsp:useBean id="GlobalDBLang" scope="application" class="com.knowgate.hipergate.DBLanguages"/><%!

  private static Date[] getDateRange(String dt_interval, int i1stDay) {
    final Date dtToday = new Date();
    Date[] aDateRange;
    if (dt_interval.equals("thisweek")) {
      aDateRange = Calendar.ThisWeek(i1stDay);
    } else if (dt_interval.equals("lastweek")) {
      aDateRange = Calendar.LastWeek(i1stDay);
    } else if (dt_interval.equals("thismonth")) {
      aDateRange = Calendar.ThisMonth();
    } else if (dt_interval.equals("lastmonth")) {
      aDateRange = Calendar.LastMonth();
    } else if (dt_interval.equals("thisquarter") || dt_interval.equals("lastquarter")) {
      if (dtToday.getMonth()<3)
        aDateRange = new Date[]{new Date(dtToday.getYear(),0,1,0,0,0),new Date(dtToday.getYear(),2,31,23,59,59)};
      else if (dtToday.getMonth()<6)
        aDateRange = new Date[]{new Date(dtToday.getYear(),3,1,0,0,0),new Date(dtToday.getYear(),5,30,23,59,59)};
      else if (dtToday.getMonth()<9)
        aDateRange = new Date[]{new Date(dtToday.getYear(),6,1,0,0,0),new Date(dtToday.getYear(),8,30,23,59,59)};
      else 
        aDateRange = new Date[]{new Date(dtToday.getYear(),9,1,0,0,0),new Date(dtToday.getYear(),11,31,23,59,59)};
      if (dt_interval.equals("lastquarter"))
        aDateRange = new Date[]{Calendar.addMonths(-3, aDateRange[0]), Calendar.addMonths(-3, aDateRange[1])};
    } else if (dt_interval.equals("thisyear")) {
      aDateRange = new Date[]{new Date(dtToday.getYear(),0,1,0,0,0),new Date(dtToday.getYear(),11,31,23,59,59)};  	
	  } else if (dt_interval.equals("lastyear")) {
      aDateRange = new Date[]{new Date(dtToday.getYear()-1,0,1,0,0,0),new Date(dtToday.getYear()-1,11,31,23,59,59)};  	
	  } else if (dt_interval.equals("last2years")) {
      aDateRange = new Date[]{new Date(dtToday.getYear()-1,0,1,0,0,0),new Date(dtToday.getYear(),11,31,23,59,59)};  	
	  } else {
      aDateRange = Calendar.ThisMonth();	
	  }
	  return aDateRange;
  }
%><%
/*
  Oportunities Dashboard
  
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

  response.addHeader ("Pragma", "no-cache");
  response.addHeader ("cache-control", "no-store");
  response.setIntHeader("Expires", 0);

  final String GU_ADMISIONES = "ac1263a41237f7076a3100003c8939ba";

  final String PAGE_NAME = "oportunity_dashboard";

  final String sLanguage = getNavigatorLanguage(request);  
  final String sSkin = getCookie(request, "skin", "xp");
  final int i1stDay = sLanguage.equals("es") ? Calendar.MONDAY : Calendar.SUNDAY;

  final String id_domain = getCookie(request,"domainid","2052");
  final String gu_workarea = getCookie(request,"workarea","ac1263a41237f7076a3100003c8939ba");

  final String selected = nullif(request.getParameter("selected"),"2");
  final String subselected = nullif(request.getParameter("subselected"),"2");
  final String tp_info = nullif(request.getParameter("tp_info"),"newoportunities");
  final String dt_interval = nullif(request.getParameter("dt_interval"),"lastquarter");
  final String id_status = nullif(request.getParameter("id_status"));
  final String id_objetive = nullif(request.getParameter("id_objetive"));
  final String gu_geozone = nullif(request.getParameter("gu_geozone"));
  final String gu_salesman = nullif(request.getParameter("gu_salesman"));
  final String gu_campaign = nullif(request.getParameter("gu_campaign"));
  String screen_width = nullif(request.getParameter("screen_width"),"1024");

  final int iScreenWidth = (screen_width.length()==0 ? 1024 : Integer.parseInt(screen_width));

  SimpleDateFormat oFmt = new SimpleDateFormat("yyyy-MM-dd");
  SimpleDateFormat oLbf = new SimpleDateFormat("dd-MMM");
  Date[] aDateRange = getDateRange(dt_interval,i1stDay);
 
	int a;
	int iYIndex = 0, iOIndex = 0;
	int[] aSeries1 = null;
	int[] aSeries2 = null;
	int[] aSeries3 = null;
	int[] aSeries4 = null;
	int[] aSeries5 = null;
	int[] aSeries6 = null;
	int[] aSeries7 = null;
	int[] aSeries8 = null;
	
  ArrayList<Object> aParams = new ArrayList<Object>();
	String sWhere = "o." + DB.gu_workarea + "=? ";
  aParams.add(gu_workarea);

  if (tp_info.equals("newoportunities")) {
    sWhere += " AND o." + DB.dt_created + " BETWEEN ? AND ? ";
    aParams.add(new Timestamp(aDateRange[0].getTime()));
    aParams.add(new Timestamp(aDateRange[1].getTime()));
  }

  if (tp_info.equals("modifiedoportunities")) {
    sWhere += " AND "+DBBind.Functions.ISNULL+"(o." + DB.dt_modified + ",o.dt_created) BETWEEN ? AND ? ";
    aParams.add(new Timestamp(aDateRange[0].getTime()));
    aParams.add(new Timestamp(aDateRange[1].getTime()));
  }

  String[] aStatuses = null;
	if (id_status.length()>0) {
	  aStatuses = Gadgets.split(id_status,',');
	  sWhere += " AND o."+DB.id_status+" IN (?"+Gadgets.repeat(",?", aStatuses.length-1)+")";
	  for (int s=0; s<aStatuses.length; s++) aParams.add(aStatuses[s]);
	}

	String[] aObjetives = null;
	if (id_objetive.length()>0) {
	  aObjetives = Gadgets.split(id_objetive,',');
	  sWhere += " AND "+DB.id_objetive+" IN (?"+Gadgets.repeat(",?", aObjetives.length-1)+")";
	  for (int o=0; o<aObjetives.length; o++) aParams.add(aObjetives[o]);
	}

	String[] aZones = null;
	if (gu_geozone.length()>0) {
	  aZones = Gadgets.split(gu_geozone,',');
	  sWhere += " AND c."+DB.gu_geozone+" IN (?"+Gadgets.repeat(",?", aZones.length-1)+")";
	  for (int z=0; z<aZones.length; z++) aParams.add(aZones[z]);
	}

	if (gu_campaign.length()>0) {
	  sWhere += " AND o."+DB.gu_campaign+"=?";
	  aParams.add(gu_campaign);
	}

  DBSubset oCampaigns = new DBSubset (DB.k_campaigns, DB.gu_campaign+","+DB.nm_campaign, DB.gu_workarea+"=? AND "+DB.bo_active+"<>0 ORDER BY "+DB.dt_created+" DESC",100);
	String sStatusLookUp="", sOriginLookUp="", sObjectiveLookUp="", sCauseLookUp="", sSalesMenLookUp="", sCampaignsLookUp="", sTerms="";
  DBSubset oOprts = new DBSubset(DB.k_oportunities + " o," + DB.k_contacts + " c",
    		                         "o." + DB.tl_oportunity + ",o." + DB.id_objetive + ",o." + DB.id_status + ",o." + DB.tx_cause +
    		                         ",o." + DB.dt_created + "," + DBBind.Functions.ISNULL+"(o." + DB.dt_modified + ",o." + DB.dt_created+ ")" +
    		                         ",o." + DB.gu_writer + ",c." + DB.gu_geozone,
    			                       "o." + DB.gu_contact + "=c." + DB.gu_contact + " AND " + sWhere, 1000);
  int iOprts = 0;
  DBSubset oHistry = new DBSubset(DB.k_oportunities+" o",DB.dt_created+","+DB.id_objetive+","+DB.id_status,DB.id_objetive+" IS NOT NULL AND "+sWhere+" ORDER BY 1",1000);
  int iHistry = 0;
  Date dtMin = null;
  Date dtMax = null;
  int[][] aOprtsByYearAndObjetive = null;
  int[][] aSalesByYearAndObjetive = null;
  TreeMap<Integer,Integer> mYears = new TreeMap<Integer,Integer>();
  TreeMap<String,Integer> mObjetives = new TreeMap<String,Integer>();
	ArrayList<DBSubsetDateGroup> aDateGrouping = null;
	ArrayList<DBSubsetDateGroup> aYearGrouping = null;
  JDCConnection oConn = null;  
  
  try {

    oConn = GlobalDBBind.getConnection(PAGE_NAME);  

    sStatusLookUp = DBLanguages.getHTMLSelectLookUp (GlobalCacheClient, oConn, DB.k_oportunities_lookup, gu_workarea, DB.id_status, sLanguage);
    sOriginLookUp = DBLanguages.getHTMLSelectLookUp (GlobalCacheClient, oConn, DB.k_oportunities_lookup, gu_workarea, DB.tp_origin, sLanguage);
    sCauseLookUp = DBLanguages.getHTMLSelectLookUp (GlobalCacheClient, oConn, DB.k_oportunities_lookup, gu_workarea, DB.tx_cause, sLanguage);
    sObjectiveLookUp = GlobalDBLang.getHTMLSelectLookUp (GlobalCacheClient, oConn, DB.k_oportunities_lookup, gu_workarea, DB.id_objetive, sLanguage);

    sSalesMenLookUp = GlobalCacheClient.getString("k_sales_men["+gu_workarea+"]");
    if (null==sSalesMenLookUp) {
      DBSubset oSalesMen = new DBSubset(DB.k_sales_men+" m,"+DB.k_users+" u","m."+DB.gu_sales_man+",u."+DB.nm_user+",u."+DB.tx_surname1+",u."+DB.tx_surname2,
      																	"m."+DB.gu_sales_man+"=u."+DB.gu_user+" AND m."+DB.gu_workarea+"=? ORDER BY 2,3,4", 100);
      int nSalesMen = oSalesMen.load(oConn,new Object[]{gu_workarea});
      StringBuffer oMenBuff = new StringBuffer(100*(nSalesMen+1));
      for (int m=0; m<nSalesMen; m++) {
        oMenBuff.append("<OPTION VALUE=\"");
        oMenBuff.append(oSalesMen.getString(0,m));
        oMenBuff.append("\">");
        oMenBuff.append(oSalesMen.getStringNull(1,m,""));
        oMenBuff.append(" ");
        oMenBuff.append(oSalesMen.getStringNull(2,m,""));
        oMenBuff.append(" ");
        oMenBuff.append(oSalesMen.getStringNull(3,m,""));
        oMenBuff.append("</OPTION>");
      } // next
      sSalesMenLookUp = oMenBuff.toString();
      GlobalCacheClient.put("k_sales_men["+gu_workarea+"]", sSalesMenLookUp);
      oMenBuff = null;
      oSalesMen = null;
    } // fi

    int nCampaigns = oCampaigns.load(oConn, new Object[]{gu_workarea});
    for (int c=0; c<nCampaigns; c++) {
      sCampaignsLookUp += "<OPTION VALUE=\"" + oCampaigns.getString(0,c) + "\">" + oCampaigns.getString(1,c) + "</OPTION>";
    } // next

    sTerms = GlobalCacheClient.getString("[" + id_domain + "," + gu_workarea + ",geozone,thesauri]");
    
    if (null==sTerms) {
      sTerms = GlobalDBLang.getHTMLTermSelect(oConn, Integer.parseInt(id_domain), gu_workarea);
      GlobalCacheClient.put ("[" + id_domain + "," + gu_workarea + ",geozone,thesauri]", sTerms);      
    } // fi (sTerms)

		iOprts = oOprts.load(oConn, aParams.toArray());

		aParams.set(1,new Timestamp(new Date(100,0,1,0,0,0).getTime()));

		iHistry = oHistry.load(oConn, aParams.toArray());

    oConn.close(PAGE_NAME); 
		
    if (tp_info.equals("newoportunities")) {
		  dtMin = (Date) oOprts.min(4);
      dtMax = (Date) oOprts.max(4);
    } else {
		  dtMin = (Date) oOprts.min(5);
      dtMax = (Date) oOprts.max(5);    
    }
    if (dtMin!=null && dtMax!=null) {
      if (dt_interval.equals("thisweek") || dt_interval.equals("lastweek") ||
    	    dt_interval.equals("thismonth") || dt_interval.equals("lastmonth"))
        aDateGrouping = oOprts.groupByDay(tp_info.equals("newoportunities") ? 4 : 5);
      else
        aDateGrouping = oOprts.groupByWeek(tp_info.equals("newoportunities") ? 4 : 5, i1stDay);
      aYearGrouping = oOprts.groupByYear(4);
    }
  }
  catch (SQLException e) {  
    if (oConn!=null)
      if (!oConn.isClosed())
        oConn.close(PAGE_NAME);
    oConn = null;
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title="+e.getClass().getName()+"&desc=" + e.getMessage() + "&resume=_back"));
  }
  
  if (null==oConn) return;
  oConn = null;

	if (dtMin!=null && dtMax!=null) {
	  if (id_objetive.length()>0) {
	    aSeries1 = new int[aDateGrouping.size()]; Arrays.fill(aSeries1,0);
	    aSeries2 = new int[aDateGrouping.size()]; Arrays.fill(aSeries2,0);
	    aSeries3 = new int[aDateGrouping.size()]; Arrays.fill(aSeries3,0);
	    aSeries4 = new int[aDateGrouping.size()]; Arrays.fill(aSeries4,0);
	    aSeries5 = new int[aDateGrouping.size()]; Arrays.fill(aSeries5,0);
	    aSeries6 = new int[aDateGrouping.size()]; Arrays.fill(aSeries6,0);
	    aSeries7 = new int[aDateGrouping.size()]; Arrays.fill(aSeries7,0);
	    aSeries8 = new int[aDateGrouping.size()]; Arrays.fill(aSeries8,0);
      
	    for (int g=0; g<aDateGrouping.size(); g++) {
		    for (Integer i : aDateGrouping.get(g)) {
		      if (!oOprts.isNull(1,i.intValue())) {
		        String sObj = oOprts.getStringNull(1,i.intValue(),"null");
		        if (sObj.equals(aObjetives[0])) aSeries1[g] += 1;
		        if (aObjetives.length>1)
		          if (sObj.equals(aObjetives[1])) aSeries2[g] += 1;
		        if (aObjetives.length>2)
		          if (sObj.equals(aObjetives[2])) aSeries3[g] += 1;
		        if (aObjetives.length>3)
		          if (sObj.equals(aObjetives[3])) aSeries4[g] += 1;
		        if (aObjetives.length>4)
		          if (sObj.equals(aObjetives[4])) aSeries5[g] += 1;
		        if (aObjetives.length>5)
		          if (sObj.equals(aObjetives[5])) aSeries6[g] += 1;
		        if (aObjetives.length>6)
		          if (sObj.equals(aObjetives[6])) aSeries7[g] += 1;
		        if (aObjetives.length>7)
		          if (sObj.equals(aObjetives[7])) aSeries8[g] += 1;
		      } 
		    } // next
	    } // next
	  } // fi
	  
	  for (int h=0; h<iHistry; h++) {
	    Integer iYear = new Integer(oHistry.getDate(0,h).getYear()+1900);
	    String sObjective = oHistry.getString(1,h);
	    if (!mYears.containsKey(iYear)) mYears.put(iYear,new Integer(iYIndex++));
	    if (!mObjetives.containsKey(sObjective)) mObjetives.put(sObjective,new Integer(iOIndex++));
	  }

	  if (iYIndex>0 && iOIndex>0) {
 	    aOprtsByYearAndObjetive = new int[iYIndex][iOIndex];
 	    aSalesByYearAndObjetive = new int[iYIndex][iOIndex];
	    for (int y=0; y<iYIndex; y++)
	      for (int o=0; o<iOIndex; o++)
	        aOprtsByYearAndObjetive[y][o] = 0;
	    for (int h=0; h<iHistry; h++) {
	      int nYear = mYears.get(new Integer(oHistry.getDate(0,h).getYear()+1900)).intValue();
	      int nObjective = mObjetives.get(oHistry.getString(1,h)).intValue();
	      aOprtsByYearAndObjetive[nYear][nObjective] += 1;
	      if (oHistry.getStringNull(2,h,"").equals("MATRICULA"))
	        aSalesByYearAndObjetive[nYear][nObjective] += 1;
	    }
	  }
  } // fi  
%>
<HTML LANG="<% out.write(sLanguage); %>">
<HEAD>
	<STYLE type="text/css">
	  .minisel { font-family:Verdana,sans-serif,Arial,Helvetica;font-size:7pt; }
	</STYLE>
  <LINK REL="stylesheet" TYPE="text/css" HREF="../javascript/dijit/themes/soria/soria.css" />
  <LINK REL="stylesheet" TYPE="text/css" HREF="../javascript/dijit/themes/soria/soria_rtl.css" />
  <SCRIPT TYPE="text/javascript" SRC="../javascript/cookies.js"></SCRIPT>  
  <SCRIPT TYPE="text/javascript" SRC="../javascript/setskin.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/combobox.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/dojo/dojo.js" djConfig="parseOnLoad: true"></SCRIPT>
  <SCRIPT TYPE="text/javascript">
    <!--

      dojo.require("dojox.charting.Chart2D");
 			dojo.require("dojox.charting.Chart3D");
      dojo.require("dojox.charting.widget.Legend");
      dojo.require("dojox.charting.plot2d.Pie");
      dojo.require("dojox.charting.plot3d.Bars");
      dojo.require("dojox.charting.themes.MiamiNice");
			dojo.require("dojox.charting.action2d.Highlight");
      dojo.require("dojox.charting.action2d.MoveSlice");
      dojo.require("dojox.charting.action2d.Tooltip");

			var start_dates = new Object();
			start_dates["thisweek"]    = "<%=oFmt.format(getDateRange("thisweek",i1stDay)[0])%>";
			start_dates["lastweek"]    = "<%=oFmt.format(getDateRange("lastweek",i1stDay)[0])%>";
			start_dates["thismonth"]   = "<%=oFmt.format(getDateRange("thismonth",i1stDay)[0])%>";
			start_dates["lastmonth"]   = "<%=oFmt.format(getDateRange("lastmonth",i1stDay)[0])%>";
			start_dates["thisquarter"] = "<%=oFmt.format(getDateRange("thisquarter",i1stDay)[0])%>";
			start_dates["lastquarter"] = "<%=oFmt.format(getDateRange("lastquarter",i1stDay)[0])%>";
			start_dates["thisyear"]    = "<%=oFmt.format(getDateRange("thisyear",i1stDay)[0])%>";
			start_dates["lastyear"]    = "<%=oFmt.format(getDateRange("lastyear",i1stDay)[0])%>";
			start_dates["last2years"]  = "<%=oFmt.format(getDateRange("last2years",i1stDay)[0])%>";

			var end_dates = new Object();
			end_dates["thisweek"]    = "<%=oFmt.format(getDateRange("thisweek",i1stDay)[1])%>";
			end_dates["lastweek"]    = "<%=oFmt.format(getDateRange("lastweek",i1stDay)[1])%>";
			end_dates["thismonth"]   = "<%=oFmt.format(getDateRange("thismonth",i1stDay)[1])%>";
			end_dates["lastmonth"]   = "<%=oFmt.format(getDateRange("lastmonth",i1stDay)[1])%>";
			end_dates["thisquarter"] = "<%=oFmt.format(getDateRange("thisquarter",i1stDay)[1])%>";
			end_dates["lastquarter"] = "<%=oFmt.format(getDateRange("lastquarter",i1stDay)[1])%>";
			end_dates["thisyear"]    = "<%=oFmt.format(getDateRange("thisyear",i1stDay)[1])%>";
			end_dates["lastyear"]    = "<%=oFmt.format(getDateRange("lastyear",i1stDay)[1])%>";
			end_dates["last2years"]  = "<%=oFmt.format(getDateRange("last2years",i1stDay)[1])%>";

	    function validate() {
	      var frm = document.forms[0];
	      frm.id_status.value = getCombo (frm.id_statuses);
	      frm.id_objetive.value = getCombo (frm.id_objetives);
	      frm.gu_geozone.value = getCombo (frm.gu_geozones);
	      frm.gu_salesman.value = getCombo (frm.gu_salesmen);
	      return true;
	    }

			function clearStatus() {
	      var frm = document.forms[0];
			  var opt = frm.id_statuses.options;
			  opt[0].selected = true;
			  for (var o=1; o<opt.length; o++) opt[o].selected = false;
			}

			function setInfoType() {
	      var frm = document.forms[0];
			  var opt = frm.id_statuses.options;
			  for (var o=1; o<opt.length; o++) {
			    if (opt[o].selected) {
			      setCheckedValue(frm.tp_info,"modifiedoportunities");
			      break;
			    }
			  }
			}

      function openExcelSheet(range) {
				window.open("rp_saleswinlost_xls.jsp?dt_start=" + start_dates[range] + "&dt_end=" + end_dates[range]);
      } // openExcelSheet()

	    function setCombos() {
	      var frm = document.forms[0];
	    	setCombo(frm.dt_interval, "<%=dt_interval%>");
	    	setCombo(frm.gu_campaign, "<%=gu_campaign%>");
	    	setComboMult(frm.id_objetives, "<%=id_objetive%>", ",");
	    	setComboMult(frm.id_statuses, "<%=id_status%>", ",");
	    	setComboMult(frm.gu_geozones, "<%=gu_geozone%>", ",");
	    	setComboMult(frm.gu_salesmen, "<%=gu_salesman%>", ",");
	    	setCheckedValue(frm.tp_info,"<%=tp_info%>")
	    } // setCombos()
    //-->    
  </SCRIPT>
  <TITLE>hipergate :: Opportunities Dashboard</TITLE>
</HEAD>
<BODY TOPMARGIN="8" MARGINHEIGHT="8">
  <%@ include file="../common/tabmenu.jspf" %>
  <FORM METHOD="post" ACTION="oportunity_dashboard.jsp" onsubmit="return validate()">
    <TABLE><TR><TD CLASS="striptitle"><FONT CLASS="title1">Opportunities Dashboard</FONT></TD></TR></TABLE>
		<DIV class="cxMnu1" style="width:280px"><DIV class="cxMnu2" style="width:280px">
      <SPAN class="hmMnuOff" onMouseOver="this.className='hmMnuOn'" onMouseOut="this.className='hmMnuOff'" onClick="document.location='oportunity_listing.jsp?selected=<%=selected%>&subselected=<%=subselected%>'"><IMG src="../images/images/toolmenu/historyback.gif" width="16" style="vertical-align:middle" height="16" border="0" alt="Back">Go back to opportunities listing</SPAN>
    </DIV></DIV>
    <BR/>
    <INPUT TYPE="hidden" NAME="id_domain" VALUE="<%=id_domain%>">
    <INPUT TYPE="hidden" NAME="gu_workarea" VALUE="<%=gu_workarea%>">
    <INPUT TYPE="hidden" NAME="id_status" VALUE="<%=id_status%>">
    <INPUT TYPE="hidden" NAME="id_objetive" VALUE="<%=id_objetive%>">
    <INPUT TYPE="hidden" NAME="gu_geozone" VALUE="<%=gu_geozone%>">
    <INPUT TYPE="hidden" NAME="gu_salesman" VALUE="<%=gu_salesman%>">
    <TABLE>
    	<TR>
    		<TD CLASS="textplain">Filter by date</TD>
    		<TD CLASS="textplain">Filter by status</TD>
    		<TD CLASS="textplain">Filter by campaign</TD>
			</TR>
      <TR>
      	<TD VALIGN="top"><SELECT CLASS="minisel" ID="sel_interval" NAME="dt_interval"><OPTION VALUE="thisweek">This Week</OPTION><OPTION VALUE="lastweek">Previous week</OPTION><OPTION VALUE="last7days">Last seven days</OPTION><OPTION VALUE="thismonth">This month</OPTION><OPTION VALUE="lastmonth">Previous month</OPTION><OPTION VALUE="thisquarter">This quarter</OPTION><OPTION VALUE="lastquarter">Previous quarter</OPTION><OPTION VALUE="thisyear">This year</OPTION><OPTION VALUE="lastyear">Previous year</OPTION><OPTION VALUE="last2years">This year and previous year</OPTION></SELECT></TD>
        <TD VALIGN="top"><SELECT CLASS="minisel" ID="sel_status" NAME="id_statuses" SIZE="10" MULTIPLE="multiple" onclick="setInfoType()"><OPTION VALUE="" SELECTED>ANY</OPTION><%=sStatusLookUp%></SELECT></TD>
        <TD VALIGN="top" CLASS="textplain">
        	<SELECT CLASS="minisel" ID="sel_campaign" NAME="gu_campaign"><OPTION VALUE=""></OPTION><%=sCampaignsLookUp%></SELECT>
        	<BR/><BR/>
        	<INPUT TYPE="radio" NAME="tp_info" VALUE="newoportunities" onclick="clearStatus()" CHECKED>&nbsp;New Opportunities
        	<BR/>
        	<FONT CLASS="textplain"><INPUT TYPE="radio" NAME="tp_info" VALUE="modifiedoportunities" CHECKED>&nbsp;Modified Opportunities</TD>
      </TR>
      <TR>
    		<TD CLASS="textplain">Filter by zone</TD>
    		<TD CLASS="textplain">Filter by salesman</TD>
        <TD CLASS="textplain">Filter by objetive</TD>
      </TR>
      <TR>
        <TD VALIGN="top"><SELECT CLASS="minisel" ID="sel_zone" NAME="gu_geozones" SIZE="10" MULTIPLE="multiple"><OPTION VALUE="" SELECTED>ANY</OPTION><%=sTerms%></SELECT></TD>
        <TD VALIGN="top"><SELECT CLASS="minisel" ID="sel_salesman" NAME="gu_salesmen" SIZE="10" MULTIPLE="multiple"><OPTION VALUE="" SELECTED>ANY</OPTION><%=sSalesMenLookUp%></SELECT></TD>
        <TD VALIGN="top"><SELECT CLASS="minisel" ID="sel_objetive" NAME="id_objetives" SIZE="10" MULTIPLE="multiple"><OPTION VALUE="" SELECTED>ANY</OPTION><%=sObjectiveLookUp%></SELECT></TD>
      </TR>
    	<TR>
    		<TD></TD>
    		<TD></TD>
    		<TD>
    			<INPUT TYPE="submit" VALUE="Show" onSubmit="return validate()" />
    		  &nbsp;&nbsp;&nbsp;
    		  <IMG SRC="../images/images/excel16.gif" WIDTH="16" HEIGHT="16" BORDER="0">&nbsp;<A HREF="#" CLASS="linkplain" onclick="openExcelSheet(getCombo(document.forms[0].dt_interval))">Download data as Excel</A>
    		</TD>
			</TR>
    </TABLE>
  </FORM>
  <% if (dtMin==null || dtMax==null) out.write("<FONT CLASS=\"textplain\">No data found matching the givenn criteria</FONT>"); %>
  <% if (tp_info.equals("newoportunities")) out.write("<FONT CLASS=\"textstrong\">New opportunities by date</FONT>"); %>
  <DIV ID="OpsByDateLegend"></DIV>
  <DIV ID="OpsByDateChart" STYLE="width: 960px; height: 400px;"></DIV>
  <BR/><BR/>
  <% if (dt_interval.equals("last2years")) {
       out.write("<FONT CLASS=\"textstrong\">Year-to-Year comparison</FONT>"); %>
       <DIV ID="OpsYearToYearLegend"></DIV>
       <DIV ID="OpsYearToYearChart" STYLE="width: 960px; height: 400px;"></DIV>
       <BR/><BR/>
  <% } %>  
  <% if (tp_info.equals("newoportunities")) out.write("<FONT CLASS=\"textstrong\">New opportunities evolution</FONT>"); %>
  <DIV ID="OpsAcumulatedLegend"></DIV>
  <DIV ID="OpsAcumulatedChart" STYLE="width: 960px; height: 400px;"></DIV>
  <BR/><BR/>
  <% if (tp_info.equals("newoportunities") && id_objetive.length()>0) out.write("<FONT CLASS=\"textstrong\">New Opportunities by Objetive</FONT>"); %>
<%      if (aObjetives!=null) { if (aObjetives.length>1) { %>
  <DIV ID="OpsByObjetiveLegend"></DIV>
  <DIV ID="OpsByObjetiveChart" STYLE="width: 960px; height: 400px;"></DIV>
<% } } if (aOprtsByYearAndObjetive!=null) { %>  
  <DIV ID="SalesForecastByObjetiveTable">
  <TABLE SUMMARY="Sales forecast by objetive" BORDER="1">
  	<TR>
  		<TD CLASS="textstrong">Sales Forecast</TD><%
  		Iterator<Integer> oYeas = mYears.keySet().iterator();
			while (oYeas.hasNext()) {
			  out.write("<TD COLSPAN=\"2\" ALIGN=\"center\" CLASS=\"textstrong\">"+oYeas.next()+"</TD>"); } %>
		  <TD CLASS="textstrong" ROWSPAN="2" ALIGN="center">Forecast<BR/><%=mYears.lastKey()%></TD>
  	</TR>
  	<TR>
  		<TD CLASS="textstrong">Objetive</TD><% for (int y=0; y<iYIndex; y++) { out.write("<TD CLASS=\"textsmall\">Opportunities</TD><TD CLASS=\"textsmall\">Sales</TD>"); } %>
		</TR>
<%  Iterator<String> oObjs = mObjetives.keySet().iterator();
    while (oObjs.hasNext()) {
		  String sObj = oObjs.next();
		  boolean bShowObjetive = (aObjetives==null);			
      if (!bShowObjetive)
        bShowObjetive = (Gadgets.search(aObjetives, sObj)>=0);
      if (bShowObjetive) {
        int p = mObjetives.get(sObj).intValue();
        out.write("<TR><TD CLASS=\"textstrong\">"+sObj+"</TD>");
        oYeas = mYears.keySet().iterator();
        
			  int nOprtsAcum = 0, nSalesAcum = 0;
			  while (oYeas.hasNext()) {
			    int y = mYears.get(oYeas.next()).intValue();			
			  	if (y<iYIndex-1) {
			  	  nOprtsAcum += aOprtsByYearAndObjetive[y][p];
			  	  nSalesAcum += aSalesByYearAndObjetive[y][p];
			  	}
			  	out.write("<TD CLASS=\"textplain\" ALIGN=\"center\">"+String.valueOf(aOprtsByYearAndObjetive[y][p])+"</TD><TD CLASS=\"textplain\" ALIGN=\"center\">"+String.valueOf(aSalesByYearAndObjetive[y][p])+"</TD>");
        } // wend
        
        if (0==nOprtsAcum)
          out.write("<TD ALIGN=\"center\" CLASS=\"textplain\"></TD></TR>");      	
        else
          out.write("<TD ALIGN=\"center\" CLASS=\"textplain\">"+String.valueOf((aOprtsByYearAndObjetive[iYIndex-1][p]*nSalesAcum)/nOprtsAcum)+"</TD></TR>");
      } // fi
    } // wend %>
  </TABLE>
  </DIV><% } // fi %>
</BODY>
<SCRIPT TYPE="text/javascript">
  <!--
      
      dojo.addOnLoad(function() {
			  
				setCombos();

<%      if (dtMin!=null && dtMax!=null) { %>
        var c = new dojox.charting.Chart2D("OpsByDateChart");
        c.addPlot("default", {
            type: "ClusteredColumns",
            gap: 2
        }).addAxis("x", {
            fixLower: "none",
            fixUpper: "none",
            labels: [<% for (int g=0; g<aDateGrouping.size(); g++) out.write((g==0 ? "" : ",")+"{value: "+String.valueOf(g+1)+", text: \""+oLbf.format(aDateGrouping.get(g).getDateFrom())+"\"}"); %>]
        }).addAxis("y", {
            vertical: true,
            fixLower: "none",
            fixUpper: "none",
            includeZero: true
        });
        c.setTheme(dojox.charting.themes.MiamiNice);
<%      if (id_objetive.length()==0) { %>
          c.addSeries("Opportunities", [<% for (int g=0; g<aDateGrouping.size(); g++) out.write((g==0 ? "" : ",")+String.valueOf(aDateGrouping.get(g).size())); %>]);
<%      } else {
          int nSeries = aObjetives.length>4 ? 4 : aObjetives.length; %>
          c.addSeries("<%=aObjetives[0]%>", [<% for (int g=0; g<aDateGrouping.size(); g++) out.write((g==0 ? "" : ",")+String.valueOf(aSeries1[g])); %>]);
<%        if (nSeries>1) { %>   
          c.addSeries("<%=aObjetives[1]%>", [<% for (int g=0; g<aDateGrouping.size(); g++) out.write((g==0 ? "" : ",")+String.valueOf(aSeries2[g])); %>]);
<%        }
					if (nSeries>2) { %>
          c.addSeries("<%=aObjetives[2]%>", [<% for (int g=0; g<aDateGrouping.size(); g++) out.write((g==0 ? "" : ",")+String.valueOf(aSeries3[g])); %>]);
<%        }
					if (nSeries>3) { %>
          c.addSeries("<%=aObjetives[3]%>", [<% for (int g=0; g<aDateGrouping.size(); g++) out.write((g==0 ? "" : ",")+String.valueOf(aSeries4[g])); %>]);
<%        }
        } %>
        c.render();
        
<%      if (id_objetive.length()>0) { %>
					var l = new dojox.charting.widget.Legend({chart: c, class: "textplain", horizontal: true}, "OpsByDateLegend");
<%      } %>

        c = new dojox.charting.Chart2D("OpsAcumulatedChart");
        c.addPlot("default", {
            type: "StackedAreas",
            tension: 3
        }).addAxis("x", {
            fixLower: "none",
            fixUpper: "none",
            labels: [<% for (int g=0; g<aDateGrouping.size(); g++) out.write((g==0 ? "" : ",")+"{value: "+String.valueOf(g+1)+", text: \""+oLbf.format(aDateGrouping.get(g).getDateFrom())+"\"}"); %>]
        }).addAxis("y", {
            vertical: true,
            fixLower: "none",
            fixUpper: "none",
            min: 0
        });
        c.setTheme(dojox.charting.themes.MiamiNice);
<%      if (id_objetive.length()==0) { %>
          c.addSeries("Opportunities", [<% a=0; for (int g=0; g<aDateGrouping.size(); g++) { a+=aDateGrouping.get(g).size(); out.write((g==0 ? "" : ",")+String.valueOf(a)); } %>]);
<%      } else {
          int nSeries = aObjetives.length>4 ? 4 : aObjetives.length; %>
<%			  if (nSeries>3) { %>
          c.addSeries("<%=aObjetives[3]%>", [<% a=0; for (int g=0; g<aDateGrouping.size(); g++) { a+=aSeries4[g]; out.write((g==0 ? "" : ",")+String.valueOf(a)); } %>]);
<%        } %>
<%			  if (nSeries>2) { %>
          c.addSeries("<%=aObjetives[2]%>", [<% a=0; for (int g=0; g<aDateGrouping.size(); g++) { a+=aSeries3[g]; out.write((g==0 ? "" : ",")+String.valueOf(a)); } %>]);
<%        } %>
<%        if (nSeries>1) { %>   
          c.addSeries("<%=aObjetives[1]%>", [<% a=0; for (int g=0; g<aDateGrouping.size(); g++) { a+=aSeries2[g]; out.write((g==0 ? "" : ",")+String.valueOf(a)); } %>]);
<%        } %>
          c.addSeries("<%=aObjetives[0]%>", [<% a=0; for (int g=0; g<aDateGrouping.size(); g++) { a+=aSeries1[g]; out.write((g==0 ? "" : ",")+String.valueOf(a)); } %>]);
<%      } %>
        c.render();

<%      if (id_objetive.length()>0) { %>
					var l = new dojox.charting.widget.Legend({chart: c, class: "textplain", horizontal: true}, "OpsAcumulatedLegend");
<%      } %>

<%      if (aObjetives!=null) {
          if (aObjetives.length>1) { %>
            var c = new dojox.charting.Chart2D("OpsByObjetiveChart");
            c.addPlot("default", {
                type: "Columns",
                gap: 2
            }).addAxis("x", {
                fixLower: "none",
                fixUpper: "none",
                labels: [<% for (int o=0; o<(aObjetives.length>8 ? 8 : aObjetives.length); o++) out.write((o==0 ? "" : ",")+"{value: "+String.valueOf(o+1)+", text: \""+Gadgets.left(aObjetives[o],20)+"\"}"); %>]
            }).addAxis("y", {
                vertical: true,
                fixLower: "none",
                fixUpper: "none",
                includeZero: true
            });
              c.addSeries("Objetives", [<%
                  int nTotalByObj = 0;
                  for (int i=0; i<aSeries1.length; i++) nTotalByObj+=aSeries1[i];
									out.write(String.valueOf(nTotalByObj));
									nTotalByObj = 0;
                  for (int i=0; i<aSeries2.length; i++) nTotalByObj+=aSeries2[i];
									out.write(","+String.valueOf(nTotalByObj));
									if (aObjetives.length>2) {
									  nTotalByObj = 0;
                    for (int i=0; i<aSeries3.length; i++) nTotalByObj+=aSeries3[i];
									  out.write(","+String.valueOf(nTotalByObj));
									} // fi
									if (aObjetives.length>3) {
									  nTotalByObj = 0;
                    for (int i=0; i<aSeries4.length; i++) nTotalByObj+=aSeries4[i];
									  out.write(","+String.valueOf(nTotalByObj));
									} // fi
									if (aObjetives.length>4) {
									  nTotalByObj = 0;
                    for (int i=0; i<aSeries5.length; i++) nTotalByObj+=aSeries5[i];
									  out.write(","+String.valueOf(nTotalByObj));
									} // fi
									if (aObjetives.length>5) {
									  nTotalByObj = 0;
                    for (int i=0; i<aSeries6.length; i++) nTotalByObj+=aSeries6[i];
									  out.write(","+String.valueOf(nTotalByObj));
									} // fi
									if (aObjetives.length>6) {
									  nTotalByObj = 0;
                    for (int i=0; i<aSeries7.length; i++) nTotalByObj+=aSeries7[i];
									  out.write(","+String.valueOf(nTotalByObj));
									} // fi
									if (aObjetives.length>7) {
									  nTotalByObj = 0;
                    for (int i=0; i<aSeries8.length; i++) nTotalByObj+=aSeries8[i];
									  out.write(","+String.valueOf(nTotalByObj));
									} // fi									
									%>]);
        			c.render();
<%				  } // fi (aObjetives.length>1) %>
<%        } // fi (aObjetives!=null) %>
<%      } // fi (data found) %>

      });
  //-->
</SCRIPT>
</HTML>