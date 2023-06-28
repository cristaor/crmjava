<%@ page import="java.io.ByteArrayOutputStream,java.io.FileNotFoundException,java.util.Date,java.text.SimpleDateFormat,java.text.DecimalFormat,java.util.Arrays,java.util.Comparator,java.io.IOException,java.net.URLDecoder,java.sql.PreparedStatement,java.sql.ResultSet,java.sql.SQLException,java.sql.Timestamp,com.knowgate.jdc.*,com.knowgate.dataobjs.*,com.knowgate.acl.*,com.knowgate.misc.Gadgets,com.knowgate.crm.Contact,com.knowgate.training.*,org.apache.poi.hssf.usermodel.HSSFWorkbook,org.apache.poi.hssf.usermodel.HSSFSheet,org.apache.poi.hssf.usermodel.HSSFRow,org.apache.poi.hssf.usermodel.HSSFCell,org.apache.poi.hssf.usermodel.HSSFCellStyle,org.apache.poi.hssf.usermodel.HSSFFont,org.apache.poi.hssf.usermodel.HSSFDataFormat,org.apache.poi.hssf.usermodel.HSSFPrintSetup,com.knowgate.dfs.FileSystem,com.knowgate.hipergate.Address" language="java" session="false" contentType="text/html;charset=UTF-8" %><%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/clientip.jspf" %><%@ include file="../methods/nullif.jspf" %><jsp:useBean id="GlobalCacheClient" scope="application" class="com.knowgate.cache.DistributedCachePeer"/><jsp:useBean id="GlobalDBLang" scope="application" class="com.knowgate.hipergate.DBLanguages"/><% 
/*
  Copyright (C) 2006-2011  Know Gate S.L. All rights reserved.

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

  final class BookingContactComparator<AcademicCourseBooking> implements Comparator {
    public int compare(Object o1, Object o2) {
      com.knowgate.training.AcademicCourseBooking b1 = (com.knowgate.training.AcademicCourseBooking) o1;
      com.knowgate.training.AcademicCourseBooking b2 = (com.knowgate.training.AcademicCourseBooking) o2;
      String sFullName1 = b1.getStringNull(DB.tx_name,"")+" "+b1.getStringNull(DB.tx_surname,"");
      String sFullName2 = b2.getStringNull(DB.tx_name,"")+" "+b2.getStringNull(DB.tx_surname,"");
      return sFullName1.compareTo(sFullName2);
    }
	  public boolean equals(Object o) {
	    return this.equals(o);
	  }
  } 
    
  if (autenticateSession(GlobalDBBind, request, response)<0) return;
  
  final String id_domain = request.getParameter("id_domain");
  final String gu_workarea = request.getParameter("gu_workarea");
  final String gu_acourse = request.getParameter("gu_acourse");

  int iFilter = Integer.parseInt(nullif(request.getParameter("filter"),"0"));
  String sDomain = GlobalDBBind.getProperty("webserver");
  sDomain = sDomain.substring(0,sDomain.lastIndexOf('/'));
  String sWrkAreaTemp = GlobalDBBind.getProperty("workareasput")+"/"+gu_workarea+"/temp/";
  String sWrkAreaHttp = sDomain+GlobalDBBind.getProperty("workareasget")+"/"+gu_workarea+"/temp/";
  SimpleDateFormat oDtFmt = new SimpleDateFormat("yyyyMMddHHmmss");
 
  JDCConnection oConn = null;
  AcademicCourse oAcrs = new AcademicCourse();
  int iBooks = 0;
  AcademicCourseBooking[] aBooks = null;
  AcademicCourseAlumni [] aAlmni = null;
  AcademicCourseAlumni oAlmni = new AcademicCourseAlumni(gu_acourse, null);
  DecimalFormat oFmt2 = new DecimalFormat();
  oFmt2.setMaximumFractionDigits(2);
  Date dtNow = new Date();
  int iMen=0, iWomen=0, iUnknownGender=0;
  int iLessThan25=0, iBetween25aand54=0, iMoreThan54=0, iUnknownAge=0;
  int iISCED12=0, iISCED3=0, iISCED4=0, iISCED5=0, iUnknownISCED=0;
      
  try {
    oConn = GlobalDBBind.getConnection("bookings_edit_xls", true);  

    oAcrs.load(oConn, new Object[]{gu_acourse});
    
    switch (iFilter) { 
      case 0: aBooks = oAcrs.getAllBookings(oConn); break;
      case 1: aBooks = oAcrs.getActiveBookings(oConn); break;
      case 2: aBooks = oAcrs.getConfirmedBookings(oConn); break;
      case 3: aBooks = oAcrs.getUnconfirmedBookings(oConn); break;
      case 4: aBooks = oAcrs.getWaitingBookings(oConn); break;
      case 5: aBooks = oAcrs.getPaidBookings(oConn); break;
      case 6: aBooks = oAcrs.getUnpaidBookings(oConn); break;
      case 7: aBooks = oAcrs.getCancelledBookings(oConn); break;
    }
    
    if (aBooks!=null) {
      iBooks = aBooks.length;
      PreparedStatement oStmt = oConn.prepareStatement("SELECT c."+DB.tx_name+",c."+DB.tx_surname+",a."+DB.tx_email+",a."+DB.direct_phone+",a."+DB.mov_phone+",c."+DB.sn_passport+",c."+DB.id_gender+",c."+DB.id_status+",c."+DB.dt_birth+",c."+DB.tx_division+" FROM "+DB.k_contacts+" c,"+DB.k_x_contact_addr+" x,"+DB.k_addresses+" a WHERE c."+DB.gu_contact+"=x."+DB.gu_contact+" AND x."+DB.gu_address+"=a."+DB.gu_address+" AND c."+DB.gu_contact+"=?");
      for (int c=0; c<iBooks; c++) {
        oStmt.setString(1, aBooks[c].getString(DB.gu_contact));
        ResultSet oRSet = oStmt.executeQuery();
        oRSet.next();
        aBooks[c].put(DB.tx_name, oRSet.getString(1));
        aBooks[c].put(DB.tx_surname, oRSet.getString(2));
        aBooks[c].put(DB.tx_email, oRSet.getString(3));
        aBooks[c].put(DB.direct_phone, oRSet.getString(4));
        aBooks[c].put(DB.mov_phone, oRSet.getString(5));
        aBooks[c].put(DB.sn_passport, oRSet.getString(6));
        aBooks[c].put(DB.id_gender, oRSet.getString(7));
        aBooks[c].put(DB.id_status, oRSet.getString(8));
        Timestamp tsBirth = oRSet.getTimestamp(9);
				if (!oRSet.wasNull()) aBooks[c].put(DB.dt_birth, new Date(tsBirth.getTime()));
        aBooks[c].put(DB.tx_division, oRSet.getString(10));
        oRSet.close();
      } // next
      oStmt.close();
      oStmt = oConn.prepareStatement("SELECT d.gu_degree,d.nm_degree,d.tp_degree FROM k_contact_education c INNER JOIN k_education_degree d ON c.gu_degree=d.gu_degree WHERE c."+DB.gu_contact+"=? ORDER BY c.ix_degree");
      for (int c=0; c<iBooks; c++) {
        oStmt.setString(1, aBooks[c].getString(DB.gu_contact));
        ResultSet oRSet = oStmt.executeQuery();
        if (oRSet.next()) {
          aBooks[c].put("gu_degree", oRSet.getString(1));
          aBooks[c].put("nm_degree", oRSet.getString(2));
          aBooks[c].put("tp_degree", oRSet.getString(3));
        }
        oRSet.close();
      } // next
      oStmt.close();
      oStmt = oConn.prepareStatement("SELECT nu_interview FROM k_admission WHERE nu_interview IS NOT NULL AND "+DB.gu_acourse+"=? AND "+DB.gu_contact+"=?");
      for (int c=0; c<iBooks; c++) {
        oStmt.setString(1, aBooks[c].getString(DB.gu_acourse));
        oStmt.setString(2, aBooks[c].getString(DB.gu_contact));
        ResultSet oRSet = oStmt.executeQuery();
        if (oRSet.next())
          aBooks[c].put("nu_interview", oRSet.getInt(1));
        oRSet.close();
      } // next
      oStmt.close();
      Arrays.sort(aBooks,new BookingContactComparator<AcademicCourseBooking>());
    }

    aAlmni = oAcrs.getAlumni(oConn);
    
    oConn.close("bookings_edit_xls");
  }
  catch (SQLException e) {  
    if (oConn!=null)
      if (!oConn.isClosed()) oConn.close("bookings_edit_xls");
    oConn = null;
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=Error&desc=" + e.getLocalizedMessage() + "&resume=_close"));  
  }
  
  if (null==oConn) return;  
  oConn = null;  

  HSSFWorkbook oWrkb = new HSSFWorkbook();
  HSSFSheet oSheet = oWrkb.createSheet();
  oWrkb.setSheetName(0, "Bookings");
  oSheet.getPrintSetup().setLandscape(true);

  HSSFRow oRow;
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

	oRow = oSheet.createRow(0);
  oCell = oRow.createCell(0);
	oCell.setCellStyle(oHeader);
  oCell.setCellValue(oAcrs.getString(DB.nm_course).trim());

	oRow = oSheet.createRow(1);
  oCell = oRow.createCell(0);
  oCell.setCellValue("Course Code");
  oCell = oRow.createCell(1);
  oCell.setCellValue(oAcrs.getStringNull(DB.id_course,"").trim());

	oRow = oSheet.createRow(2);
  oCell = oRow.createCell(0);
  oCell.setCellValue("Start and end dates");
  oCell = oRow.createCell(1);
  oCell.setCellValue(oAcrs.getStringNull("dt_from",""));
  oCell = oRow.createCell(2);
  oCell.setCellValue(oAcrs.getStringNull("dt_to",""));

	oRow = oSheet.createRow(3);
  oCell = oRow.createCell(0);
  oCell.setCellValue("Director");
  oCell = oRow.createCell(1);
  oCell.setCellValue(oAcrs.getStringNull("nm_tutor",""));
  oCell = oRow.createCell(2);
  oCell.setCellValue(oAcrs.getStringNull("tx_tutor_email",""));

	String[] aHeader = new String[]{"Name","Surname","e-mail","Fixed Phone","Cell Phone","Id. Card.","Gender","Age","Confirmed","Cancelled"};
	final short nCols = (short) aHeader.length;
	
	oRow = oSheet.createRow(4);
	for (short h=0; h<nCols; h++) {
    oCell = oRow.createCell(h);
	  oCell.setCellValue(aHeader[h]);
	  oCell.setCellStyle(oHeader);
	} // next

	oSheet.setColumnWidth(0, 256*40);  // Nombre
	oSheet.setColumnWidth(1, 256*40);  // Apellidos
	oSheet.setColumnWidth(2, 256*40);  // Email
	oSheet.setColumnWidth(3, 256*16);  // Fijo
	oSheet.setColumnWidth(4, 256*16);  // Movil
	oSheet.setColumnWidth(5, 256*16);  // DNI	 
	oSheet.setColumnWidth(6, 256*10);  // Genero
	oSheet.setColumnWidth(7, 256*8);  // Edad
	oSheet.setColumnWidth(8, 256*14);  // Confirmado
	oSheet.setColumnWidth(9, 256*14);  // Cancelado

	for (int i=0; i<iBooks; i++) {

    oAlmni.replace(DB.gu_alumni, aBooks[i].getString(DB.gu_contact));
    boolean bCancelled = aBooks[i].canceled();
    boolean bIsAlumni;
    int nAlumni = -1;
    if (bCancelled)
      bIsAlumni=false;
    else if (null==aAlmni)
   	  bIsAlumni=false;
   	else {
   		nAlumni = Arrays.binarySearch(aAlmni, oAlmni, oAlmni);
   		bIsAlumni = (nAlumni>=0);
    }
    boolean bWaiting = (bCancelled ? false : aBooks[i].waiting());
    boolean bConfrimed = (bCancelled ? false : aBooks[i].confirmed());

    oRow = oSheet.createRow(i+5);
    
    HSSFCell[] aCells = new HSSFCell[nCols];
	  for (short l=0; l<nCols; l++) {
      aCells[l] = oRow.createCell(l);
	  } //next

	  aCells[0].setCellValue(Gadgets.capitalizeFirst(aBooks[i].getStringNull(DB.tx_name,"")));
	  aCells[1].setCellValue(Gadgets.capitalizeFirst(aBooks[i].getStringNull(DB.tx_surname,"")));
	  aCells[2].setCellValue(aBooks[i].getStringNull(DB.tx_email,""));
	  aCells[3].setCellValue(aBooks[i].getStringNull(DB.direct_phone,""));
	  aCells[4].setCellValue(aBooks[i].getStringNull(DB.mov_phone,""));
	  aCells[5].setCellValue(aBooks[i].getStringNull(DB.sn_passport,""));
	  
	  aCells[6].setCellValue(aBooks[i].getStringNull(DB.id_gender,""));
    if (aBooks[i].getStringNull(DB.id_gender,"").equals("M")) {
      if (bConfrimed && !bCancelled) iMen++;
    } else if (aBooks[i].getStringNull(DB.id_gender,"").equals("F")) {
      if (bConfrimed && !bCancelled) iWomen++;
		} else {
			if (bConfrimed && !bCancelled) iUnknownGender++;
    }

	  if (!aBooks[i].isNull(DB.dt_birth)) {
	    int nAge = dtNow.getYear()-aBooks[i].getDate(DB.dt_birth).getYear();
	    if (dtNow.getMonth()<aBooks[i].getDate(DB.dt_birth).getMonth())
	      --nAge;
	    else if (dtNow.getMonth()==aBooks[i].getDate(DB.dt_birth).getMonth() && dtNow.getDate()<aBooks[i].getDate(DB.dt_birth).getDate())
	      --nAge;
	    aCells[7].setCellValue(nAge);
	    if (nAge<25) {
        if (bConfrimed && !bCancelled) iLessThan25++;
      } else if (nAge>=25 && nAge<54) {
        if (bConfrimed && !bCancelled) iBetween25aand54++;
      } else {
        if (bConfrimed && !bCancelled) iMoreThan54++;
	    }
	  } else {
	  	if (bConfrimed && !bCancelled) iUnknownAge++;
	  }
		
	  aCells[8].setCellValue(bConfrimed ? "X" : "");
	  aCells[9].setCellValue(bCancelled ? "X" : "");
	}

  oSheet = oWrkb.createSheet();
  oWrkb.setSheetName(1, "Summary");
  oSheet.getPrintSetup().setLandscape(true);

	oRow = oSheet.createRow(0);
  oCell = oRow.createCell(0);
	oCell.setCellValue("SUMMARY OF CONFIRMED STUDENTS");
	oCell.setCellStyle(oHeader);

	oRow = oSheet.createRow(2);
  oCell = oRow.createCell(0);
	oCell.setCellValue("Gender");
	oCell.setCellStyle(oHeader);
  oCell = oRow.createCell(1);
	oCell.setCellValue("Males");
	oCell.setCellStyle(oHeader);
  oCell = oRow.createCell(2);
	oCell.setCellStyle(oHeader);
  oCell = oRow.createCell(3);
	oCell.setCellValue("Females");
	oCell.setCellStyle(oHeader);
  oCell = oRow.createCell(4);
	oCell.setCellStyle(oHeader);
  oCell = oRow.createCell(5);
	oCell.setCellValue("Unknonw");
	oCell.setCellStyle(oHeader);
  oCell = oRow.createCell(6);
	oCell.setCellStyle(oHeader);
  oCell = oRow.createCell(7);
	oCell.setCellValue("Total");
	oCell.setCellStyle(oHeader);
  oCell = oRow.createCell(8);
	oCell.setCellStyle(oHeader);

  final float fTotalPorGenero = (float) (iMen+iWomen+iUnknownGender);
  
	oRow = oSheet.createRow(3);
  oCell = oRow.createCell(1);
  oCell.setCellValue(iMen);
  oCell.setCellStyle(oIntFmt);
  oCell = oRow.createCell(2);
  if (fTotalPorGenero>0f) 
    oCell.setCellValue(((float)iMen)/fTotalPorGenero);
  oCell.setCellStyle(oPctFmt);
  oCell = oRow.createCell(3);
  oCell.setCellValue(iWomen);
  oCell.setCellStyle(oIntFmt);
  oCell = oRow.createCell(4);
  if (fTotalPorGenero>0f) 
    oCell.setCellValue(((float)iWomen)/fTotalPorGenero);
  oCell.setCellStyle(oPctFmt);
  oCell = oRow.createCell(5);
  oCell.setCellValue(iUnknownGender);
  oCell.setCellStyle(oIntFmt);
  oCell = oRow.createCell(6);
  if (fTotalPorGenero>0f) 
    oCell.setCellValue(((float)iUnknownGender)/fTotalPorGenero);
  oCell.setCellStyle(oPctFmt);
  oCell = oRow.createCell(7);
  oCell.setCellValue(iMen+iWomen+iUnknownGender);
  oCell.setCellStyle(oIntFmt);

	oRow = oSheet.createRow(5);
  oCell = oRow.createCell(0);
	oCell.setCellValue("Age");
	oCell.setCellStyle(oHeader);
  oCell = oRow.createCell(1);
	oCell.setCellValue("<25");
	oCell.setCellStyle(oHeader);
  oCell = oRow.createCell(2);
	oCell.setCellStyle(oHeader);
  oCell = oRow.createCell(3);
	oCell.setCellValue(">=25 <54");
	oCell.setCellStyle(oHeader);
  oCell = oRow.createCell(4);
	oCell.setCellStyle(oHeader);
  oCell = oRow.createCell(5);
	oCell.setCellValue(">54");
	oCell.setCellStyle(oHeader);
  oCell = oRow.createCell(6);
	oCell.setCellStyle(oHeader);
  oCell = oRow.createCell(7);
	oCell.setCellValue("Unknonw");
	oCell.setCellStyle(oHeader);
  oCell = oRow.createCell(8);
	oCell.setCellStyle(oHeader);

	final float fTotalPorEdades = (float) (iLessThan25+iBetween25aand54+iMoreThan54+iUnknownAge);

	oRow = oSheet.createRow(6);
  oCell = oRow.createCell(1);
  oCell.setCellValue(iLessThan25);
  oCell.setCellStyle(oIntFmt);
  oCell = oRow.createCell(2);
  if (fTotalPorEdades>0f) 
    oCell.setCellValue(((float)iLessThan25)/fTotalPorEdades);
  oCell.setCellStyle(oPctFmt);
  oCell = oRow.createCell(3);
  oCell.setCellValue(iBetween25aand54);
  oCell.setCellStyle(oIntFmt);
  oCell = oRow.createCell(4);
  if (fTotalPorEdades>0f) 
    oCell.setCellValue(((float)iBetween25aand54)/fTotalPorEdades);
  oCell.setCellStyle(oPctFmt);
  oCell = oRow.createCell(5);
  oCell.setCellValue(iMoreThan54);
  oCell.setCellStyle(oIntFmt);
  oCell = oRow.createCell(6);
  if (fTotalPorEdades>0f) 
    oCell.setCellValue(((float)iMoreThan54)/fTotalPorEdades);
  oCell.setCellStyle(oPctFmt);
  oCell = oRow.createCell(7);
  oCell.setCellValue(iUnknownAge);
  oCell.setCellStyle(oIntFmt);
  oCell = oRow.createCell(8);
  if (fTotalPorEdades>0f) 
    oCell.setCellValue(((float)iUnknownAge)/fTotalPorEdades);
  oCell.setCellStyle(oPctFmt);

	String sFileName = "CourseBookings"+oDtFmt.format(dtNow)+".xls";
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
  	Excel dump completed
  	<br/><br/>
  	<a href="#" onclick="window.close()" class="linkplain">Close Window</a>
  </body>
</html>