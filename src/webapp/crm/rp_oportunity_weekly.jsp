<%@ page import="java.io.ByteArrayOutputStream,java.io.FileNotFoundException,java.util.Date,java.text.SimpleDateFormat,java.text.DecimalFormat,java.util.ArrayList,java.util.Arrays,java.util.Comparator,java.io.IOException,java.net.URLDecoder,java.sql.PreparedStatement,java.sql.ResultSet,java.sql.SQLException,java.sql.Timestamp,com.knowgate.jdc.*,com.knowgate.dataobjs.DB,com.knowgate.dataobjs.DBSubset,com.knowgate.dataobjs.DBSubset.DBSubsetDateGroup,com.knowgate.acl.*,com.knowgate.misc.Calendar,com.knowgate.misc.Gadgets,org.apache.poi.hssf.usermodel.HSSFWorkbook,org.apache.poi.hssf.usermodel.HSSFSheet,org.apache.poi.hssf.usermodel.HSSFRow,org.apache.poi.hssf.usermodel.HSSFCell,org.apache.poi.hssf.usermodel.HSSFCellStyle,org.apache.poi.hssf.usermodel.HSSFFont,org.apache.poi.hssf.usermodel.HSSFDataFormat,org.apache.poi.hssf.usermodel.HSSFPrintSetup,com.knowgate.dfs.FileSystem" language="java" session="false" contentType="text/html;charset=UTF-8" %><%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/nullif.jspf" %><jsp:useBean id="GlobalCacheClient" scope="application" class="com.knowgate.cache.DistributedCachePeer"/><jsp:useBean id="GlobalDBLang" scope="application" class="com.knowgate.hipergate.DBLanguages"/><%

  final String PAGE_NAME = "rp_oportunity_weekly.jsp";
  
  if (autenticateSession(GlobalDBBind, request, response)<0) return;
  
  SimpleDateFormat yyyyMMdd = new SimpleDateFormat("yyyy-MM-dd");
  
  final String id_domain = getCookie(request,"domainid","");
  final String gu_workarea = getCookie(request,"workarea",null); 
    final String dt_start = nullif(request.getParameter("dt_start"),"2012-04-02");
  final String dt_end = nullif(request.getParameter("dt_end"),"2016-01-03");

  final Date dtStart = yyyyMMdd.parse(dt_start);
  final Date dtEnd = yyyyMMdd.parse(dt_end);

  final Timestamp tsStart = new Timestamp(dtStart.getTime());
  final Timestamp tsEnd = new Timestamp(dtEnd.getTime());

  String sDomain = GlobalDBBind.getProperty("webserver");
  String sWrkAreaTemp = GlobalDBBind.getProperty("workareasput")+"/"+gu_workarea+"/temp/";
  String sWrkAreaHttp = sDomain+GlobalDBBind.getProperty("workareasget")+"/"+gu_workarea+"/temp/";

  JDCConnection oConn = null;
  DBSubset oAcBooking = null;
  DBSubset oAcCourses = new DBSubset(DB.k_academic_courses+" a INNER JOIN "+DB.k_courses+" c ON a."+DB.gu_course+"=c."+DB.gu_course,
  																	 "a."+DB.gu_acourse+",a."+DB.nm_course+",a.nu_max_alumni,a.nu_confirmed",
  																	 "c."+DB.gu_workarea+"=? AND a."+DB.bo_active+"=1", 20);
  DBSubset oSentCalls = new DBSubset(DB.k_phone_calls,DB.dt_start,DB.gu_oportunity+" IS NOT NULL AND "+DB.gu_workarea+"=? AND "+DB.tp_phonecall+"='S' AND "+DB.dt_start+" BETWEEN ? AND ?",1000);
  DBSubset oRecvCalls = new DBSubset(DB.k_oportunities,DB.dt_created,DB.gu_workarea+"=? AND "+DB.tp_origin+"='902' AND "+DB.dt_created+" BETWEEN ? AND ?",1000);
  DBSubset oWebLeads = new DBSubset(DB.k_oportunities,DB.dt_created,DB.gu_workarea+"=? AND "+DB.tp_origin+"='BMWCUSTOMER' AND "+DB.dt_created+" BETWEEN ? AND ?",1000);   
  DBSubset oQuotsSent = new DBSubset(DB.k_oportunities,DB.dt_created,DB.gu_workarea+"=? AND "+DB.id_status+" IN ('WAITINGLIST','GANADA','QUOTATIONSEND','PAGADO') AND "+DB.dt_created+" BETWEEN ? AND ?",1000);   
  ArrayList<DBSubset> aAcBookings = new ArrayList<DBSubset>();
  int iAcCourses = 0, iSentCalls = 0, iRecvCalls = 0, iWebLeads = 0, iQuotsSent = 0;
  Date dt1stBook = null, dtLastBook = null;
    
  try {
    oConn = GlobalDBBind.getConnection(PAGE_NAME, true);

    iAcCourses = oAcCourses.load(oConn, new Object[]{gu_workarea});
    for (int c=0; c<iAcCourses; c++) {
  	  oAcBooking = new DBSubset(DB.k_x_course_bookings,DB.dt_created,"("+DB.bo_canceled+"=0 OR "+DB.bo_canceled+" IS NULL) AND "+DB.gu_acourse+"=?", 50);
      oAcBooking.load(oConn, new Object[]{oAcCourses.get(0,c)});
      aAcBookings.add(oAcBooking);
  		if (dt1stBook==null)
  		  dt1stBook = (Date) oAcBooking.min(0);
  		else if (oAcBooking.min(0)!=null)
  			dt1stBook = dt1stBook.compareTo((Date) oAcBooking.min(0))<=0 ? dt1stBook : (Date) oAcBooking.min(0);
      if (dtLastBook==null)
        dtLastBook = (Date) oAcBooking.max(0);
      else if (oAcBooking.max(0)!=null)
      	dtLastBook = dtLastBook.compareTo((Date) oAcBooking.max(0))>=0 ? dtLastBook : (Date) oAcBooking.max(0);
    }
    
    iSentCalls = oSentCalls.load(oConn, new Object[]{gu_workarea,tsStart,tsEnd});
    iRecvCalls = oRecvCalls.load(oConn, new Object[]{gu_workarea,tsStart,tsEnd});
    iWebLeads  = oWebLeads.load(oConn, new Object[]{gu_workarea,tsStart,tsEnd});
    iQuotsSent = oQuotsSent.load(oConn, new Object[]{gu_workarea,tsStart,tsEnd});

    oConn.close(PAGE_NAME);    
  }
  catch (Exception e) {  
    if (oConn!=null)
      if (!oConn.isClosed()) oConn.close(PAGE_NAME);
    oConn = null;
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=Error&desc=" + e.getMessage() + "&resume=_close"));  
  }
  
  if (null==oConn) return;  
  oConn = null;  

  Date dtMin = null;
  if (dtMin==null) dtMin = (Date) oSentCalls.min(0); else if (oSentCalls.min(0)!=null) dtMin = dtMin.compareTo((Date)oSentCalls.min(0))<=0 ? dtMin : (Date) oSentCalls.min(0);
  if (dtMin==null) dtMin = (Date) oRecvCalls.min(0); else if (oRecvCalls.min(0)!=null) dtMin = dtMin.compareTo((Date)oRecvCalls.min(0))<=0 ? dtMin : (Date) oRecvCalls.min(0);
  if (dtMin==null) dtMin = (Date) oWebLeads.min(0);  else if (oWebLeads.min(0)!=null)  dtMin = dtMin.compareTo((Date)oWebLeads.min(0))<=0 ? dtMin : (Date) oWebLeads.min(0);
  if (dtMin==null) dtMin = (Date) oQuotsSent.min(0); else if (oQuotsSent.min(0)!=null) dtMin = dtMin.compareTo((Date)oQuotsSent.min(0))<=0 ? dtMin : (Date) oQuotsSent.min(0);

  Date dtMax = null;
  if (dtMax==null) dtMax = (Date) oSentCalls.max(0); else if (oSentCalls.max(0)!=null) dtMax = dtMax.compareTo((Date)oSentCalls.max(0))>=0 ? dtMax : (Date) oSentCalls.max(0);
  if (dtMax==null) dtMax = (Date) oRecvCalls.max(0); else if (oRecvCalls.max(0)!=null) dtMax = dtMax.compareTo((Date)oRecvCalls.max(0))>=0 ? dtMax : (Date) oRecvCalls.max(0);
  if (dtMax==null) dtMax = (Date) oWebLeads.max(0);  else if (oWebLeads.max(0)!=null)  dtMax = dtMax.compareTo((Date)oWebLeads.max(0))>=0 ? dtMax : (Date) oWebLeads.max(0);
  if (dtMax==null) dtMax = (Date) oQuotsSent.max(0); else if (oQuotsSent.max(0)!=null) dtMax = dtMax.compareTo((Date)oQuotsSent.max(0))>=0 ? dtMax : (Date) oQuotsSent.max(0);
  
  ArrayList<DBSubsetDateGroup> aSentCallsByWeek, aRecvCallsByWeek, aWebLeadsByWeek, aQuotsSentByWeek;
  
  try { aSentCallsByWeek = oSentCalls.groupByWeek(0, 1); } catch (NullPointerException noitemsinrange) { aSentCallsByWeek = new ArrayList<DBSubsetDateGroup>(); }
  try { aRecvCallsByWeek = oRecvCalls.groupByWeek(0, 1); } catch (NullPointerException noitemsinrange) { aRecvCallsByWeek = new ArrayList<DBSubsetDateGroup>(); }
  try { aWebLeadsByWeek  = oWebLeads.groupByWeek (0, 1); } catch (NullPointerException noitemsinrange) { aWebLeadsByWeek  = new ArrayList<DBSubsetDateGroup>(); }
  try { aQuotsSentByWeek = oQuotsSent.groupByWeek(0, 1); } catch (NullPointerException noitemsinrange) { aQuotsSentByWeek = new ArrayList<DBSubsetDateGroup>(); }

  HSSFWorkbook oWrkb = new HSSFWorkbook();
  HSSFSheet oSheet = oWrkb.createSheet();
  oWrkb.setSheetName(0, "Contactos");
  oSheet.getPrintSetup().setLandscape(true);

  HSSFRow oRow, oRow1, oRow2, oRow3, oRow4, oRow5, oRowx;
  HSSFCell oCell;
  HSSFFont oBold = oWrkb.createFont();
  oBold.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
  HSSFCellStyle oHeader = oWrkb.createCellStyle();
  oHeader.setFont(oBold);
  oHeader.setBorderBottom(oHeader.BORDER_THICK);
  HSSFCellStyle oIntFmt = oWrkb.createCellStyle();
  oIntFmt.setAlignment(HSSFCellStyle.ALIGN_CENTER);
  oIntFmt.setDataFormat((short)1);
  HSSFCellStyle oPctFmt = oWrkb.createCellStyle();
  oPctFmt.setAlignment(HSSFCellStyle.ALIGN_CENTER);
  oPctFmt.setDataFormat((short)10);
  HSSFCellStyle oDateFmt = oWrkb.createCellStyle();
  oDateFmt.setDataFormat((short)15);

  oSheet.setColumnWidth(0, 256*40);
  
	oRow = oSheet.createRow(0);
  oCell = oRow.createCell(0);
	oCell.setCellStyle(oHeader);
  oCell.setCellValue("INFORME DE CONTACTOS Y ENVIOS DE INFORMACION");

	oRow2 = oSheet.createRow(2);
  oCell = oRow2.createCell(0);
  oCell.setCellValue("Oportunidades de llamadas recibidas al 902");

	oRow3 = oSheet.createRow(3);
  oCell = oRow3.createCell(0);
  oCell.setCellValue("Oportunidades de formularios bmw.es");

	oRow4 = oSheet.createRow(4);
  oCell = oRow4.createCell(0);
  oCell.setCellValue("Llamadas realizadas");

	oRow5 = oSheet.createRow(5);
  oCell = oRow5.createCell(0);
  oCell.setCellValue("Ofertas enviadas");

	oRow1 = oSheet.createRow(1);
  oCell = oRow1.createCell(1);
  oCell.setCellValue("Total");

  oCell = oRow2.createCell(1);
  oCell.setCellValue(oRecvCalls.getRowCount());

  oCell = oRow3.createCell(1);
  oCell.setCellValue(oWebLeads.getRowCount());

  oCell = oRow4.createCell(1);
  oCell.setCellValue(oSentCalls.getRowCount());

  oCell = oRow5.createCell(1);
  oCell.setCellValue(oQuotsSent.getRowCount());

  int nWeeks = 1 + (Calendar.DaysBetween(dtMin, dtMax) / 7);
	Date dtCur = dtMin;
	Date dtNex = new Date(dtCur.getTime()+6l*86400000l);
	
	for (int w=0; w<=nWeeks; w++) {
    oCell = oRow1.createCell(w+2);
    oCell.setCellValue("del "+String.valueOf(dtCur.getDate())+"/"+String.valueOf(dtCur.getMonth()+1)+" al "+String.valueOf(dtNex.getDate())+"/"+String.valueOf(dtNex.getMonth()+1));
    oSheet.setColumnWidth(w+2, 256*14);
    dtCur = new Date(dtNex.getTime()+86400000l);
    dtNex = new Date(dtCur.getTime()+6l*86400000l);
    oCell = oRow2.createCell(w+2);
    oCell.setCellValue(0);
    oCell = oRow3.createCell(w+2);
    oCell.setCellValue(0);
    oCell = oRow4.createCell(w+2);
    oCell.setCellValue(0);
    oCell = oRow5.createCell(w+2);
    oCell.setCellValue(0);
	}

  for (DBSubsetDateGroup g : aRecvCallsByWeek) {
    oCell = oRow2.createCell(2 + (Calendar.DaysBetween(dtMin, g.getDateFrom()) / 7));
    oCell.setCellValue(g.size());
  }

  for (DBSubsetDateGroup g : aWebLeadsByWeek) {
    oCell = oRow3.createCell(2 + (Calendar.DaysBetween(dtMin, g.getDateFrom()) / 7));
    oCell.setCellValue(g.size());
  }

  for (DBSubsetDateGroup g : aSentCallsByWeek) {
    oCell = oRow4.createCell(2 + (Calendar.DaysBetween(dtMin, g.getDateFrom()) / 7));
    oCell.setCellValue(g.size());
  }

  for (DBSubsetDateGroup g : aQuotsSentByWeek) {
    oCell = oRow5.createCell(2 + (Calendar.DaysBetween(dtMin, g.getDateFrom()) / 7));
    oCell.setCellValue(g.size());
  }
	
  oSheet = oWrkb.createSheet();
  oWrkb.setSheetName(1, "Ventas");
  oSheet.getPrintSetup().setLandscape(true);

	oRow = oSheet.createRow(0);
  oCell = oRow.createCell(0);
	oCell.setCellStyle(oHeader);
  oCell.setCellValue("VENTA DE PLAZAS");

  oSheet.setColumnWidth(0, 256*40);

	oRow = oSheet.createRow(1);
  oCell = oRow.createCell(1);
  oCell.setCellValue("Aforo");
  oCell = oRow.createCell(2);
  oCell.setCellValue("Confirmados");
  oSheet.setColumnWidth(2, 256*14);

  nWeeks = 1 + (Calendar.DaysBetween(dt1stBook, dtLastBook) / 7);
	dtCur = dt1stBook;
	dtNex = new Date(dt1stBook.getTime()+6l*86400000l);
	
	for (int w=0; w<=nWeeks; w++) {
    oCell = oRow.createCell(w+3);
    oCell.setCellValue("del "+String.valueOf(dtCur.getDate())+"/"+String.valueOf(dtCur.getMonth()+1)+" al "+String.valueOf(dtNex.getDate())+"/"+String.valueOf(dtNex.getMonth()+1));
    oSheet.setColumnWidth(w+3, 256*14);
    dtCur = new Date(dtNex.getTime()+86400000l);
    dtNex = new Date(dtCur.getTime()+6l*86400000l);
	}
	
	for (int a=0; a<iAcCourses; a++) {
	  oRow = oSheet.createRow(a+2);
    oCell = oRow.createCell(0);
    oCell.setCellValue(oAcCourses.getString(1,a));
    oCell = oRow.createCell(1);
    if (!oAcCourses.isNull(2,a))
      oCell.setCellValue(oAcCourses.getInt(2,a));
    oCell = oRow.createCell(2);
    if (!oAcCourses.isNull(3,a))
      oCell.setCellValue(oAcCourses.getInt(3,a));
	  for (int w=0; w<=nWeeks; w++) {
       oCell = oRow.createCell(3+w);
       oCell.setCellValue(0);
    }
    oAcBooking = aAcBookings.get(a);
    if (oAcBooking.getRowCount()>0) {
      ArrayList<DBSubsetDateGroup> grps = oAcBooking.groupByWeek(0, 1);
      int ng = 1;
      for (DBSubsetDateGroup g : grps) {
        oCell = oRow.getCell(3 + (Calendar.DaysBetween(dt1stBook, g.getDateTo()) / 7));
        oCell.setCellValue(g.size());
      }
    }
	}
  
  SimpleDateFormat oDtFmt = new SimpleDateFormat("yyyyMMddHHmmss");	
	String sFileName = "InformeDeVentas"+oDtFmt.format(new Date())+".xls";
	ByteArrayOutputStream oBas = new ByteArrayOutputStream();
    oWrkb.write(oBas);
	FileSystem oFs = new FileSystem();
	oFs.writefilebin("file://"+sWrkAreaTemp+sFileName, oBas.toByteArray());
	oBas.close();
	
%><html>
  <script type="text/javascript" src="../javascript/cookies.js"></script>  
  <script type="text/javascript" src="../javascript/setskin.js"></script>
  <head>
    <meta http-equiv="refresh" content="0;URL=<%=sWrkAreaHttp+sFileName%>">
  </head>
  <body class="textplain">
  	<br/>
  	Descarga Excel completada
  	<br/><br/>
  	<a href="#" onclick="window.close()" class="linkplain">Cerrar Ventana</a>
  </body>
</html>