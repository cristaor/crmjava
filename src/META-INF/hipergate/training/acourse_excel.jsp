<%@ page import="org.apache.poi.hssf.usermodel.HSSFCellStyle,org.apache.poi.hssf.usermodel.HSSFWorkbook,org.apache.poi.hssf.usermodel.HSSFSheet,org.apache.poi.hssf.usermodel.HSSFRow,org.apache.poi.hssf.usermodel.HSSFCell,org.apache.poi.hssf.usermodel.HSSFFont,java.text.DecimalFormat,java.util.Vector,java.io.IOException,java.net.URLDecoder,java.sql.PreparedStatement,java.sql.ResultSet,java.sql.SQLException,com.knowgate.jdc.*,com.knowgate.dataobjs.*,com.knowgate.acl.*,com.knowgate.hipergate.Address,com.knowgate.misc.Gadgets,com.knowgate.hipergate.*,com.knowgate.training.AcademicCourse" language="java" session="false" contentType="application/x-excel"  %><%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/clientip.jspf" %><%
/*  
  Copyright (C) 2004-2011  Know Gate S.L. All rights reserved.

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
  
  String sSkin = getCookie(request, "skin", "xp");
  String sLanguage = getNavigatorLanguage(request);

  String id_user = getCookie (request, "userid", null);
  String gu_acourse = request.getParameter("gu_acourse");

  JDCConnection oConn = null;
  AcademicCourse oCur = new AcademicCourse();
  DBSubset oAlm = new DBSubset(DB.k_x_course_alumni+" a,"+DB.k_contacts+" c", DB.tx_name+","+DB.tx_surname+","+DB.sn_passport,
  														 "a."+DB.gu_acourse+"=? AND a."+DB.gu_alumni+"=c."+DB.gu_contact+" ORDER BY 1,2", 100);
  int iAlm = 0;
  Address oAdr = new Address();

  try {
    
    oConn = GlobalDBBind.getConnection("acourse_edit", true);  
        
    oCur.load(oConn, new Object[]{gu_acourse});
    if (!oCur.isNull(DB.gu_address)) {
      oAdr.load(oConn, new Object[]{oCur.getString(DB.gu_address)});
    }

		iAlm = oAlm.load(oConn, new Object[]{gu_acourse});
		
    oConn.close("acourse_edit");
  }
  catch (SQLException e) {  
    if (oConn!=null)
      if (!oConn.isClosed()) oConn.close("acourse_edit");
    oConn = null;
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=SQLException&desc=" + e.getLocalizedMessage() + "&resume=_close"));  
  }
  if (null==oConn) return;  
  oConn = null;  

  response.addHeader ("Pragma", "no-cache");
  response.addHeader ("cache-control", "no-store");
  response.setIntHeader("Expires", 0);
  response.setHeader("Content-Disposition","attachment; filename=\""+Gadgets.left(Gadgets.ASCIIEncode(oCur.getString(DB.nm_course)),50).toLowerCase()+".xls\"");


  HSSFWorkbook oWrkb = new HSSFWorkbook();
  HSSFFont oStrong = oWrkb.createFont();
  oStrong.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
  HSSFCellStyle oBold = oWrkb.createCellStyle();
  oBold.setFont(oStrong);
  HSSFSheet oSht = oWrkb.createSheet();
  HSSFRow oRow;
  HSSFCell oCel;
  int r = 0;
  int c = 0;

	oRow = oSht.createRow(r++);
  oCel = oRow.createCell(0);
  oCel.setCellValue(oCur.getStringNull(DB.id_course,""));
	oRow = oSht.createRow(r++);
  oCel = oRow.createCell(0);
  oCel.setCellStyle(oBold);
  oCel.setCellValue(oCur.getStringNull(DB.nm_course,""));
	oRow = oSht.createRow(r++);
  oCel = oRow.createCell(0);
  oCel.setCellValue(oCur.getStringNull(DB.tx_start,""));
  oCel = oRow.createCell(1);
  oCel.setCellValue(oCur.getStringNull(DB.tx_end,""));
	oRow = oSht.createRow(r++);
  oCel = oRow.createCell(0);
  oCel.setCellValue("Alumnos:");
  oCel = oRow.createCell(1);
  oCel.setCellValue(iAlm);
  for (int a=0; a<iAlm; a++) {
	  oRow = oSht.createRow(r++);
    oCel = oRow.createCell(0);
    oCel.setCellValue(oAlm.getStringNull(DB.tx_name,a,""));
    oCel = oRow.createCell(1);
    oCel.setCellValue(oAlm.getStringNull(DB.tx_surname,a,""));
    oCel = oRow.createCell(2);
    oCel.setCellValue(oAlm.getStringNull(DB.sn_passport,a,""));
  } 

  oWrkb.write(response.getOutputStream());

  if (true) return; // Do not remove this line or you will get an error "getOutputStream() has already been called for this response"
%>