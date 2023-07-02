<%@ page import="java.io.ByteArrayOutputStream,java.text.SimpleDateFormat,java.util.Collections,java.util.ArrayList,java.util.Map,java.util.HashSet,java.util.HashMap,java.util.SortedMap,java.util.TreeMap,java.util.Comparator,java.util.Iterator,java.util.Date,java.io.IOException,java.net.URLDecoder,java.sql.SQLException,java.sql.Timestamp,com.knowgate.jdc.JDCConnection,com.knowgate.dataobjs.*,com.knowgate.dataobjs.DBSubset.DBSubsetDateGroup,com.knowgate.acl.*,com.knowgate.misc.Gadgets,org.apache.poi.hssf.usermodel.HSSFWorkbook,org.apache.poi.hssf.usermodel.HSSFSheet,org.apache.poi.hssf.usermodel.HSSFRow,org.apache.poi.hssf.usermodel.HSSFCell,org.apache.poi.hssf.usermodel.HSSFCellStyle,org.apache.poi.hssf.usermodel.HSSFFont,org.apache.poi.hssf.usermodel.HSSFDataFormat,org.apache.poi.hssf.usermodel.HSSFPrintSetup,com.knowgate.dfs.FileSystem,com.knowgate.hipergate.DBLanguages" language="java" session="false" contentType="text/html;charset=UTF-8" %><%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/nullif.jspf" %><%!
  private static class ValueComparer implements Comparator {
		private Map  _data = null;
		public ValueComparer (Map data){
			super();
			_data = data;
		}

    public int compare(Object o1, Object o2) {
      String e1 = (String) _data.get(o1);
      String e2 = (String) _data.get(o2);
      return e1.compareTo(e2);
    }
	}
%><% 
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
  
  // if (autenticateSession(GlobalDBBind, request, response)<0) return;

  final String sQry = nullif(request.getParameter("qry"));
  final String sDtStart = request.getParameter("dt_start");
  final String sDtEnd = request.getParameter("dt_end");

  response.addHeader ("Pragma", "no-cache");
  response.addHeader ("cache-control", "no-store");
  response.setIntHeader("Expires", 0);
  response.setHeader("Content-Disposition", "inline; filename=\"oportunidades"+(sQry.length()==0 ? "" : sQry.equals("won") ? "_ganadas" : "_perdidas")+".xls\"");
      
  String gu_workarea = getCookie (request, "workarea", "ac1263a41237f7076a3100003c8939ba");
  String id_user = getCookie (request, "userid", "ac1263a41237f7218bf100004f3b150c");
  String id_language = getNavigatorLanguage(request);
  String sGuGeoZone = request.getParameter("gu_geozone");
  // Storage
  String sWrkAreaTemp = GlobalDBBind.getProperty("workareasput")+"/"+gu_workarea+"/temp/";
  
  //GlobalDBBind.getProperty("workareasget")+"/"+gu_workarea+"/temp/";
  SimpleDateFormat oDtFmt = new SimpleDateFormat("yyyyMMddHHmmss");

  String sStatus;
    
  JDCConnection oConn = null;
  HSSFWorkbook oWrkb = new HSSFWorkbook();
  DBSubset oSales = null;
  int iSales = 0;
  HashMap oObjctsNames = null;
  ArrayList oStatuses = null;
  TreeMap<String,HashMap<String,Integer>> oStatusByObjective = new TreeMap<String,HashMap<String,Integer>>();
  Iterator<String> iObjctvs;
  SimpleDateFormat oFmt = new SimpleDateFormat("dd/MM/yy");
  
  if (sQry.length()==0)
    sStatus = "";
  else if (sQry.equals("won"))
    sStatus = "('VENTA')";
  else
    sStatus = "('CONTACTADO','RETIRADO','NOADMITIDO','BAJA')";
  
  try {      
    oConn = GlobalDBBind.getConnection("rp_saleswinlost");

    if (null==sDtStart && null==sDtEnd) {
        oSales = new DBSubset(DB.k_oportunities + " o," + DB.k_users + " u" + (sGuGeoZone==null ? "" : "," + DB.k_contacts + " c"),
    		                      "o." + DB.tl_oportunity + ",o." + DB.id_objetive + ",o." + DB.id_status + ",o." + DB.tx_cause + ",o." + DB.im_revenue + ",o." + DB.dt_modified + ",o." + DB.dt_next_action + "," + DBBind.Functions.ISNULL + "(u." + DB.nm_user + ",'') || ' ' || " + DBBind.Functions.ISNULL + "(u." + DB.tx_surname1 + ",'') || ' ' || " + DBBind.Functions.ISNULL + "(u." + DB.tx_surname2 + ",'') AS full_name,o."+DB.gu_writer+",o."+DB.bo_private+",o."+DB.dt_created,
    			                    "o." + DB.gu_writer + "=u." + DB.gu_user + " AND " +
    			                    (sGuGeoZone==null ? "" : "o." + DB.gu_contact + "=c." + DB.gu_contact + " AND c." + DB.gu_geozone + "='" + sGuGeoZone + "' AND ") +
    			                    "o." + DB.gu_workarea + "=? " + (sStatus.length()==0 ? "" : " AND o." + DB.id_status + " IN " + sStatus), 100);
      iSales = oSales.load (oConn, new Object[]{gu_workarea});
    } else if (null!=sDtStart && null==sDtEnd) {
      String[] aDtStart = Gadgets.split(sDtStart,'-');
      Timestamp dDtStart = new Timestamp(new Date(Integer.parseInt(aDtStart[0])-1900,Integer.parseInt(aDtStart[1])-1,Integer.parseInt(aDtStart[2]),0,0,0).getTime());      
      	oSales = new DBSubset(DB.k_oportunities + " o," + DB.k_users + " u" + (sGuGeoZone==null ? "" : "," + DB.k_contacts + " c"),
    		                    "o." + DB.tl_oportunity + ",o." + DB.id_objetive + ",o." + DB.id_status + ",o." + DB.tx_cause + ",o." + DB.im_revenue + ",o." + DB.dt_modified + ",o." + DB.dt_next_action + "," + DBBind.Functions.ISNULL + "(u." + DB.nm_user + ",'') || ' ' || " + DBBind.Functions.ISNULL + "(u." + DB.tx_surname1 + ",'') || ' ' || " + DBBind.Functions.ISNULL + "(u." + DB.tx_surname2 + ",'') AS full_name,o."+DB.gu_writer+",o."+DB.bo_private+",o."+DB.dt_created,
    			                  "o." + DB.gu_writer + "=u." + DB.gu_user + " AND " +
    			                  (sGuGeoZone==null ? "" : "o." + DB.gu_contact + "=c." + DB.gu_contact + " AND c." + DB.gu_geozone + "='" + sGuGeoZone + "' AND ") +
    			                  "o." + DB.gu_workarea + "=? " + (sStatus.length()==0 ? "" : " AND o." + DB.id_status + " IN " + sStatus) + " AND " +
    			                  (sQry.length()==0 ? "o."+DB.dt_created+">=?" : DBBind.Functions.ISNULL + "(o." + DB.dt_modified + ",o." + DB.dt_created + ")>=?"), 100);
      iSales = oSales.load (oConn, new Object[]{gu_workarea, dDtStart});
    } else if (null==sDtStart && null!=sDtEnd) {
      String[] aDtEnd = Gadgets.split(sDtEnd,'-');
      Timestamp dDtEnd = new Timestamp(new Date(Integer.parseInt(aDtEnd[0])-1900,Integer.parseInt(aDtEnd[1])-1,Integer.parseInt(aDtEnd[2]),23,59,59).getTime());
      	oSales = new DBSubset(DB.k_oportunities + " o," + DB.k_users + " u" + (sGuGeoZone==null ? "" : "," + DB.k_contacts + " c"),
    		                    "o." + DB.tl_oportunity + ",o." + DB.id_objetive + ",o." + DB.id_status + ",o." + DB.tx_cause + ",o." + DB.im_revenue + ",o." + DB.dt_modified + ",o." + DB.dt_next_action + "," + DBBind.Functions.ISNULL + "(u." + DB.nm_user + ",'') || ' ' || " + DBBind.Functions.ISNULL + "(u." + DB.tx_surname1 + ",'') || ' ' || " + DBBind.Functions.ISNULL + "(u." + DB.tx_surname2 + ",'') AS full_name,o."+DB.gu_writer+",o."+DB.bo_private+",o."+DB.dt_created,
    			                  "o." + DB.gu_writer + "=u." + DB.gu_user + " AND " +
    			                  (sGuGeoZone==null ? "" : "o." + DB.gu_contact + "=c." + DB.gu_contact + " AND c." + DB.gu_geozone + "='" + sGuGeoZone + "' AND ") +
    			                  "o." + DB.gu_workarea + "=? " + (sStatus.length()==0 ? "" : " AND o." + DB.id_status + " IN " + sStatus) + " AND " +
    			                  (sQry.length()==0 ? "o."+DB.dt_created+"<=?" : DBBind.Functions.ISNULL + "(o." + DB.dt_modified + ",o." + DB.dt_created + ")<=?"), 100);
      iSales = oSales.load (oConn, new Object[]{gu_workarea, dDtEnd});
    } else {
      String[] aDtStart = Gadgets.split(sDtStart,'-');
      String[] aDtEnd = Gadgets.split(sDtEnd,'-');
      Timestamp dDtStart = new Timestamp(new Date(Integer.parseInt(aDtStart[0])-1900,Integer.parseInt(aDtStart[1])-1,Integer.parseInt(aDtStart[2]),0,0,0).getTime());      
      Timestamp dDtEnd = new Timestamp(new Date(Integer.parseInt(aDtEnd[0])-1900,Integer.parseInt(aDtEnd[1])-1,Integer.parseInt(aDtEnd[2]),23,59,59).getTime());
      	oSales = new DBSubset(DB.k_oportunities + " o," + DB.k_users + " u" + (sGuGeoZone==null ? "" : "," + DB.k_contacts + " c"),
    		                    "o." + DB.tl_oportunity + ",o." + DB.id_objetive + ",o." + DB.id_status + ",o." + DB.tx_cause + ",o." + DB.im_revenue + ",o." + DB.dt_modified + ",o." + DB.dt_next_action + "," + DBBind.Functions.ISNULL + "(u." + DB.nm_user + ",'') || ' ' || " + DBBind.Functions.ISNULL + "(u." + DB.tx_surname1 + ",'') || ' ' || " + DBBind.Functions.ISNULL + "(u." + DB.tx_surname2 + ",'') AS full_name,o."+DB.gu_writer+",o."+DB.bo_private+",o."+DB.dt_created,
    			                  "o." + DB.gu_writer + "=u." + DB.gu_user + " AND " +
    			                  (sGuGeoZone==null ? "" : "o." + DB.gu_contact + "=c." + DB.gu_contact + " AND c." + DB.gu_geozone + "='" + sGuGeoZone + "' AND ") +
    			                  "o." + DB.gu_workarea + "=? " + (sStatus.length()==0 ? "" : " AND o." + DB.id_status + " IN " + sStatus) + " AND " +
    			                  (sQry.length()==0 ? "o."+DB.dt_created+" BETWEEN ? AND ?" : DBBind.Functions.ISNULL + "(o." + DB.dt_modified + ",o." + DB.dt_created + ") BETWEEN ? AND ?"), 100);
      iSales = oSales.load (oConn, new Object[]{gu_workarea, dDtStart, dDtEnd});
    }

		oStatuses = oSales.distinct(2);
		Collections.sort(oStatuses);
		
		oObjctsNames = DBLanguages.getLookUpMap(oConn, DB.k_oportunities_lookup, gu_workarea, DB.id_objetive, id_language);

    oConn.close("rp_saleswinlost");    

		int nTotal = 0;
		Date dtMin = (Date) oSales.min(10);
		if (null==dtMin) dtMin = new Date(80,0,1);
		if (dtMin.compareTo(new Date(2010-1900,11,1))<0) dtMin = new Date(2010-1900,11,1);
		Date dtMinDayLowerBound = new Date(dtMin.getTime()-(6l*86400000l));
		Date dtMax = (Date) oSales.max(10);
		if (null==dtMax) dtMax = new Date(200,0,1);
		if (dtMax.compareTo(new Date())>0) dtMax = new Date();
		Date dtMaxDayUpperBound = new Date(dtMax.getTime()+(6l*86400000l));

		for (int s=0; s<iSales; s++) {
		  boolean bPrivate;
		  if (oSales.isNull(DB.bo_private,s))
		    bPrivate = false;
		  else
		  	bPrivate = (oSales.getShort(DB.bo_private,s)!=(short)0);		  	
			if (!oSales.isNull(1,s) && !oSales.isNull(2,s) && (!bPrivate || id_user.equals(oSales.getStringNull(DB.gu_writer,s,"")))) {
			  nTotal++;
			  String sObjetive = oSales.getString(1,s);
			  String sStatusId = oSales.getString(2,s);
		    HashMap<String,Integer> oStatusesForObjective;
		    if (!oStatusByObjective.containsKey(sObjetive)) {
		      oStatusesForObjective = new HashMap<String,Integer>();
				  oStatusByObjective.put(sObjetive,oStatusesForObjective);
		    } else {
				  oStatusesForObjective = oStatusByObjective.get(sObjetive);		    
		    }
				if (oStatusesForObjective.containsKey(sStatusId)) {
					Integer nSameStatusCount = new Integer(oStatusesForObjective.get(sStatusId).intValue()+1);
					oStatusesForObjective.remove(sStatusId);
				  oStatusesForObjective.put(sStatusId,nSameStatusCount);					
				} else {
				  oStatusesForObjective.put(sStatusId,new Integer(1));
			  }
			} // fi
		} // next
				
    HSSFRow oRow;
    HSSFCell oCel;
    int r = 0;
    int c = 0;
    
    HSSFFont oBold = oWrkb.createFont();
    oBold.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
    
    HSSFCellStyle oHeader = oWrkb.createCellStyle();
    oHeader.setFont(oBold);
    oHeader.setBorderBottom(oHeader.BORDER_THICK);

    HSSFCellStyle oStrong = oWrkb.createCellStyle();
    oStrong.setFont(oBold);

    HSSFCellStyle oIntFmt = oWrkb.createCellStyle();
    oIntFmt.setAlignment(HSSFCellStyle.ALIGN_CENTER);
    oIntFmt.setDataFormat((short)1);

    HSSFCellStyle oIntTotal = oWrkb.createCellStyle();
    oIntTotal.setAlignment(HSSFCellStyle.ALIGN_CENTER);
    oIntTotal.setDataFormat((short)1);
    oIntTotal.setFont(oBold);

    HSSFCellStyle oDateFmt = oWrkb.createCellStyle();
    oDateFmt.setFont(oBold);
    oDateFmt.setDataFormat((short)15);
    
    HSSFSheet oByObjc = oWrkb.createSheet();
    HSSFSheet oByWeek = oWrkb.createSheet();
    oWrkb.setSheetName(0, "EstadosPorPrograma");
    oWrkb.setSheetName(1, "NuevasPeticionesPorSemanas");

		oRow = oByObjc.createRow(r++);
	  oCel = oRow.createCell(0);
    oCel.setCellValue("Estados por Programa");
	  oCel.setCellStyle(oHeader);
	  oCel = oRow.createCell(1);
    oCel.setCellValue(dtMin);
	  oCel.setCellStyle(oDateFmt);
	  oCel = oRow.createCell(2);
    oCel.setCellValue(dtMax);
	  oCel.setCellStyle(oDateFmt);

		oRow = oByObjc.createRow(r++);
	  oCel = oRow.createCell(c++);
    oCel.setCellValue("Programa");
	  oCel.setCellStyle(oHeader);
	  for (Object oStat : oStatuses) {
	    oCel = oRow.createCell(c++);
      oCel.setCellValue((String) oStat);
	    oCel.setCellStyle(oHeader);
	  } // wend
	  
	  iObjctvs = oStatusByObjective.keySet().iterator();
	  while (iObjctvs.hasNext()) {
		  c=0;
			oRow = oByObjc.createRow(r++);
		  String sObjetive = iObjctvs.next();
	    oCel = oRow.createCell(c++);
      oCel.setCellValue(nullif((String) oObjctsNames.get(sObjetive),sObjetive).toUpperCase());
	    for (Object oStat : oStatuses) {
	      oCel = oRow.createCell(c++);
	      if (oStatusByObjective.get(sObjetive).containsKey((String) oStat))
          oCel.setCellValue(oStatusByObjective.get(sObjetive).get((String) oStat).intValue());	        
	      else
	      	oCel.setCellValue(0);
	      oCel.setCellStyle(oIntFmt);
	    } // next
	  } // wend

	  c=0;
		oRow = oByObjc.createRow(r++);
	  oCel = oRow.createCell(c++);
    oCel.setCellValue("Total "+String.valueOf(nTotal));
	  oCel.setCellStyle(oStrong);

	  for (int s=0; s<oStatuses.size(); s++) {
		  String sLetter = (s<=24 ? new String(""+(char)(66+s)) : new String("A"+(char)(41+s)));
		  oCel = oRow.createCell(c++);
		  oCel.setCellFormula("SUM("+sLetter+"3:"+sLetter+String.valueOf(r-1)+")");
	    oCel.setCellStyle(oIntTotal);
	  }
	  
	  r=0;
	  c=0;
		oRow = oByWeek.createRow(r++);
	  oCel = oRow.createCell(0);
    oCel.setCellValue("Peticiones por Programa");
	  oCel.setCellStyle(oHeader);
	  oCel = oRow.createCell(2);
    oCel.setCellValue(dtMin);
	  oCel.setCellStyle(oDateFmt);
	  oCel = oRow.createCell(3);
    oCel.setCellValue(dtMax);
	  oCel.setCellStyle(oDateFmt);
		oRow = oByWeek.createRow(r++);
	  oCel = oRow.createCell(c++);
    oCel.setCellValue("Programa");
	  oCel.setCellStyle(oHeader);
	  oCel = oRow.createCell(c++);
    oCel.setCellValue("Total");
	  oCel.setCellStyle(oHeader);

		ArrayList<DBSubsetDateGroup> aWeeks = oSales.groupByWeek(10, 1);
		for (DBSubsetDateGroup g : aWeeks) {
		  if (g.getDateFrom().compareTo(dtMinDayLowerBound)>=0 && g.getDateTo().compareTo(dtMaxDayUpperBound)<=0) {
	      if (c==255) throw new ArrayIndexOutOfBoundsException("Excel allows no more than 256 columns 'A'..'IV' but found "+oSales.groupByWeek(10, 1).size()+" weeks between "+oFmt.format(dtMin)+" and "+oFmt.format(dtMax));
	      oCel = oRow.createCell(c++);
        oCel.setCellValue(g.getDateFrom());
	      oCel.setCellStyle(oDateFmt);
		  }
		}

	  iObjctvs = oStatusByObjective.keySet().iterator();
	  while (iObjctvs.hasNext()) {
		  c=0;
			oRow = oByWeek.createRow(r++);
		  String sObjetive = iObjctvs.next();
	    oCel = oRow.createCell(c++);
      oCel.setCellValue(nullif((String) oObjctsNames.get(sObjetive),sObjetive).toUpperCase());
	    oCel = oRow.createCell(c++);
	    oCel.setCellValue(0d);
	    for (int s=0; s<iSales; s++) {
			  if (oSales.getStringNull(1,s,"").equals(sObjetive) &&
			      oSales.getDate(10,s).compareTo(dtMinDayLowerBound)>=0 &&
			      oSales.getDate(10,s).compareTo(dtMaxDayUpperBound)<=0)
			    oCel.setCellValue(oCel.getNumericCellValue()+1d);
	    } // next
	    c=2;
	    for (DBSubsetDateGroup oWeek : aWeeks) {
		    if (oWeek.getDateFrom().compareTo(dtMinDayLowerBound)>=0 && oWeek.getDateTo().compareTo(dtMaxDayUpperBound)<=0) {
	        double dWeekCount = 0d;
	        for (Integer i : oWeek) {
	          if (oSales.getStringNull(1,i.intValue(),"").equals(sObjetive)) dWeekCount++;
	        } // next
	        oCel = oRow.createCell(c++);
	        oCel.setCellValue(dWeekCount);
	      } // fi
	    } // next (Week)
	  } // wend

	  double dWithOutObjetive = 0d;
	  for (int s=0; s<iSales; s++) {
			if (oSales.getStringNull(1,s,"").length()==0 &&
			      oSales.getDate(10,s).compareTo(dtMinDayLowerBound)>=0 &&
			      oSales.getDate(10,s).compareTo(dtMaxDayUpperBound)<=0)
			  dWithOutObjetive++;
	  }
	  
	  c=0;
	  oRow = oByWeek.createRow(r++);
	  oCel = oRow.createCell(c++);
    oCel.setCellValue("SIN PROGRAMA ASIGNADO");
	  oCel = oRow.createCell(c++);
	  oCel.setCellValue(dWithOutObjetive); 	    

	  for (DBSubsetDateGroup oWeek : aWeeks) {
		  if (oWeek.getDateFrom().compareTo(dtMinDayLowerBound)>=0 && oWeek.getDateTo().compareTo(dtMaxDayUpperBound)<=0) {
	      double dWeekCount = 0d;
	      for (Integer i : oWeek) {
	        if (oSales.getStringNull(1,i.intValue(),"").length()==0) dWeekCount++;
	      } // next
	      oCel = oRow.createCell(c++);
	      oCel.setCellValue(dWeekCount);
	    } // fi
	  } // next (Week)

  } catch (SQLException e) {  
    disposeConnection(oConn,"rp_saleswinlost");
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title="+e.getClass().getName()+"&desc=" + e.getMessage() + "&resume=_back"));
    oConn = null;
    throw new Exception(e.getMessage());
  }

  //storage
  //oWrkb.write(response.getOutputStream());
  //Begin Storage
   
    String sFileName = "Bookings"+oDtFmt.format(new Date())+".xls";
	ByteArrayOutputStream oBas = new ByteArrayOutputStream();
    oWrkb.write(oBas);
	FileSystem oFs = new FileSystem();
	oFs.writefilebin("file://"+sWrkAreaTemp+sFileName, oBas.toByteArray());
	oBas.close();

	//end storage
  

  //if (true) return; // Do not remove this line or you will get an error "getOutputStream() has already been called for this response"

%>

<html>
  <script type="text/javascript" src="../javascript/cookies.js"></script>  
  <script type="text/javascript" src="../javascript/setskin.js"></script>
    <meta http-equiv="refresh" content="0;URL=http://hipergate1.eoi.es:8080/hipergate/workareas/ac1263a41237f7076a3100003c8939ba/temp/<%=sFileName%>">
  <head>
  </head>
  <body class="textplain">
  	<br/>
	  	Descarga Excel completada<br/>
  	<br/><br/>
  	<a href="#" onclick="window.close()" class="linkplain">Cerrar Ventana</a>
  </body>
</html>