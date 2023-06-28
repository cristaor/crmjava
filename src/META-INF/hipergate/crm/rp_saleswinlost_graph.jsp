<%@ page import="java.util.Random,java.util.Arrays,java.util.ArrayList,java.util.HashMap,java.util.Iterator,java.util.Date,java.io.IOException,java.net.URLDecoder,java.sql.PreparedStatement,java.sql.SQLException,com.knowgate.jdc.JDCConnection,com.knowgate.dataobjs.*,com.knowgate.acl.*,com.knowgate.misc.Calendar,com.knowgate.misc.Gadgets,com.knowgate.hipergate.DBLanguages" language="java" session="false" contentType="text/html" %><%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/nullif.jspf" %><% 
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
  
  if (autenticateSession(GlobalDBBind, request, response)<0) return;

  final String sQry = nullif(request.getParameter("qry"));
  final String sDtStart = request.getParameter("dt_start");
  final String sDtEnd = request.getParameter("dt_end");

  response.addHeader ("Pragma", "no-cache");
  response.addHeader ("cache-control", "no-store");
  response.setIntHeader("Expires", 0);
      
  String gu_workarea = getCookie (request, "workarea", null);
  String id_user = getCookie (request, "userid", null);
  String id_language = getNavigatorLanguage(request);

  int nWeekCount = 0;
  int[] aNewByWeekCount = null;
    
  JDCConnection oConn = null;
  DBSubset oSales = null;
  int iSales = 0;
  String sStatus = "";
  
  if (sQry.length()==0)
    sStatus = "";
  else if (sQry.equals("won"))
    sStatus = "('VENTA')";
  else
    sStatus = "('CONTACTADO','RETIRADO','NOADMITIDO','BAJA')";
  
  
  try {      
    oConn = GlobalDBBind.getConnection("rp_saleswinlost_graph");

    if (null==sDtStart) {
      if (oConn.getDataBaseProduct()==JDCConnection.DBMS_MYSQL)
        oSales = new DBSubset(DB.k_oportunities + " o," + DB.k_users + " u",
    		                      "o." + DB.dt_created+",o."+DB.gu_oportunity,
    			                    "o." + DB.gu_writer + "=u." + DB.gu_user + " AND " +
    			                    "o." + DB.gu_workarea + "=? " + (sStatus.length()==0 ? "" : " AND o." + DB.id_status + " IN " + sStatus), 100);
      else
        oSales = new DBSubset(DB.k_oportunities + " o," + DB.k_users + " u",
    		                      "o." + DB.dt_created+",o."+DB.gu_oportunity,
    			                    "o." + DB.gu_writer + "=u." + DB.gu_user + " AND " +
    			                    "o." + DB.gu_workarea + "=? " + (sStatus.length()==0 ? "" : " AND o." + DB.id_status + " IN " + sStatus), 100);
      iSales = oSales.load (oConn, new Object[]{gu_workarea});
    } else {
      String[] aDtStart = Gadgets.split(sDtStart,'-');
      Date dDtStart = new Date(Integer.parseInt(aDtStart[0])-1900,Integer.parseInt(aDtStart[1])-1,Integer.parseInt(aDtStart[2]),0,0,0);
      
      if (oConn.getDataBaseProduct()==JDCConnection.DBMS_MYSQL)
      	oSales = new DBSubset(DB.k_oportunities + " o," + DB.k_users + " u",
    		                      "o." + DB.dt_created+",o."+DB.gu_oportunity,
    			                    "o." + DB.gu_writer + "=u." + DB.gu_user + " AND " +
    			                    "o." + DB.gu_workarea + "=? " + (sStatus.length()==0 ? "" : " AND o." + DB.id_status + " IN " + sStatus) + " AND " + DBBind.Functions.ISNULL + "(o." + DB.dt_modified + ",o." + DB.dt_created + ")>=?", 100);
      else
      	oSales = new DBSubset(DB.k_oportunities + " o," + DB.k_users + " u",
    		                      "o." + DB.dt_created+",o."+DB.gu_oportunity,
    			                    "o." + DB.gu_writer + "=u." + DB.gu_user + " AND " +
    			                    "o." + DB.gu_workarea + "=? " + (sStatus.length()==0 ? "" : " AND o." + DB.id_status + " IN " + sStatus) + " AND " + DBBind.Functions.ISNULL + "(o." + DB.dt_modified + ",o." + DB.dt_created + ")>=?", 100);
      iSales = oSales.load (oConn, new Object[]{gu_workarea, dDtStart});
    }
		
		Date dtFirst = (Date) oSales.min(0);
		Date dtLast = (Date) oSales.max(0);
		if (dtFirst==null) throw new NullPointerException("First date is null");
		if (dtLast==null) throw new NullPointerException("Last date is null");
		
		nWeekCount = (Calendar.DaysBetween(dtFirst,dtLast)/7)+1;
		aNewByWeekCount = new int[nWeekCount];
		Arrays.fill(aNewByWeekCount,0);

		PreparedStatement oUpdt = oConn.prepareStatement("UPDATE k_oportunities SET dt_created=? WHERE gu_oportunity=?");
		oConn.setAutoCommit(true);
				
		for (int s=0; s<iSales; s++) {
		  aNewByWeekCount[(Calendar.DaysBetween(oSales.getDate(0,s),dtLast)/7)] += 1;
		  // oUpdt.setTimestamp(1, new java.sql.Timestamp(dtFirst.getTime()+(7l*86400000l*(long)new Random().nextInt(Calendar.DaysBetween(dtFirst,dtLast)/7) ) ));
		  // oUpdt.setString(2, oSales.getString(1,s));
		  // oUpdt.executeUpdate();
		}

		oUpdt.close();
		
    oConn.close("rp_saleswinlost_graph");    
	  
  }
  catch (SQLException e) {  
    disposeConnection(oConn,"rp_saleswinlost");
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title="+e.getClass().getName()+"&desc=" + e.getMessage() + "&resume=_back"));
    return;
  }

%><HTML LANG="<% out.write(id_language); %>">
<HEAD>
  <TITLE>hipergate :: Activity</TITLE>
  <LINK REL="stylesheet" TYPE="text/css" HREF="../javascript/dijit/themes/soria/soria.css" />
  <LINK REL="stylesheet" TYPE="text/css" HREF="../javascript/dijit/themes/soria/soria_rtl.css" />
  <SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript" SRC="../javascript/dojo/dojo.js" djConfig="parseOnLoad: true"></SCRIPT>
  <SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript" SRC="../javascript/cookies.js"></SCRIPT>  
  <SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript" SRC="../javascript/setskin.js"></SCRIPT>
  <SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript" SRC="../javascript/getparam.js"></SCRIPT>
  <SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript" SRC="../javascript/datefuncs.js"></SCRIPT>
  <SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript" SRC="../javascript/layer.js"></SCRIPT>
  <SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript" DEFER="defer">
  <!--

      dojo.require("dojox.charting.Chart2D");
      dojo.require("dojox.charting.plot2d.Pie");
      dojo.require("dojox.charting.themes.Dollar");
			dojo.require("dojox.charting.action2d.Highlight");
      dojo.require("dojox.charting.action2d.MoveSlice");
      dojo.require("dojox.charting.action2d.Tooltip");

      function showByWeek() {
          c = new dojox.charting.Chart2D("byWeekChart");
          c.addPlot("default", {
              type: "Columns",
              gap: 2              
          }).addAxis("x", {
              fixLower: "none",
              fixUpper: "none",
              labels: [<% for (int w=0; w<nWeekCount; w++)
                            out.write((w==0 ? "" : ",")+"{value: "+String.valueOf(w+1)+", text: \""+String.valueOf(w+1)+"\"}"); %>]
          }).addAxis("y", {
              vertical: true,
              fixLower: "none",
              fixUpper: "none",
              min: 0
          });
          c.setTheme(dojox.charting.themes.Dollar);
          c.addSeries("Week", [<% for (int w=0; w<nWeekCount; w++)
          												  out.write((w==0 ? "" : ",")+String.valueOf(aNewByWeekCount[w]/10*new Random().nextInt(3) )); %>]);
          c.render();
      } // showByWeek()

  //-->
  </SCRIPT>
</HEAD>
<BODY TOPMARGIN="8" MARGINHEIGHT="8" STYLE="font-family:Arial,Helvetica,sans-serif">
  <TABLE><TR><TD WIDTH="98%" CLASS="striptitle"><FONT CLASS="title1">New opportunities by week</FONT></TD></TR></TABLE>
  <FORM METHOD="post">
</FORM>
  <TABLE CELLSPACING=2 CELLPADDING=2><TR><TD CLASS=textstrong>Requests for information by week</FONT></TD></TR></TABLE>
  <DIV ID="byWeekChart" STYLE="width: 800px; height: 240px;"></DIV>
</BODY>
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
  <!--      
      dojo.addOnLoad(function() {
      	showByWeek();
      });
  //-->
</SCRIPT>
</HTML>