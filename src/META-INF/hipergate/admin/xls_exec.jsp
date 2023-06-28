<%@ page import="java.text.SimpleDateFormat,java.util.Date,java.util.Enumeration,java.io.File,java.io.FileInputStream,java.io.IOException,java.sql.Types,java.sql.SQLException,com.oreilly.servlet.MultipartRequest,com.knowgate.jdc.JDCConnection,com.knowgate.dataobjs.*,com.knowgate.misc.Gadgets,org.apache.poi.hssf.usermodel.HSSFWorkbook,org.apache.poi.hssf.usermodel.HSSFSheet,org.apache.poi.hssf.usermodel.HSSFRow,org.apache.poi.hssf.usermodel.HSSFCell" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../methods/dbbind.jsp" %><%
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

  final String PAGE_NAME = "void_name";

  response.setHeader("Cache-Control","no-cache");
  response.setHeader("Pragma","no-cache");
  response.setIntHeader("Expires", 0);

  final String sTmpDir = Gadgets.chomp(GlobalDBBind.getProperty("temp",Environment.getTempDir()),File.separator);
  
  MultipartRequest oReq = new MultipartRequest(request, sTmpDir, Integer.parseInt(GlobalDBBind.getProperty("maxfileupload", "10485760")), "UTF-8");


  JDCConnection oConn = null;
  PreparedStatement oStmt = null;
  String sDDL, sSQL, sErr = "";
	String[] aTableNames = null;
	String[] aColumnNames;
	String[] aColumnTypes;
	short[] aSQLTypes;
  SimpleDateFormat oDtTag = new SimpleDateFormat("MMddHHmmss");
  String sNow = oDtTag.parse(new Date());
  int s=0, r=0, c=0;
  
  try {
    Enumeration oFileNames = oReq.getFileNames();

    while (oFileNames.hasMoreElements()) {
      String sFileName = oReq.getOriginalFileName(oFileNames.nextElement().toString());

      if (sFileName!=null) {
        File oPoifs = new File(sTmpDir + sFileName);
				FileInputStream oStrm = new FileInputStream (oFile);				
				HSSFWorkbook oWrkb = new HSSFWorkbook(oPoifs, false);
				oPoifs.close();
				aTableNames = new String[oWrkb.getNumberOfSheets()]; 
				for (s=0; s<oWrkb.getNumberOfSheets(); s++) {
				  HSSFSheet oSht = oWrkb.getSheetAt(s);
				  aTableNames[s] = Gadgets.ASCIIEncode(oSht.getSheetName()).toLowerCase().replace(' ','_').replace('.','_');
				  sDDL = "CREATE TABLE k_xls_"+aTableNames[s]+"_"+sNow+" (nu_row INTEGER";
				  HSSFRow oRow = oSht.getRow(0);
				  int nRows = oSht.getLastRowNum();
				  int nCols = oRow.getLastCellNum();
				  aColumnNames = new String[nCols];
				  aColumnTypes = new String[nCols];
					aSQLTypes = new short[nCols];
				  for (c=0; c<nCols; n++) {
				    if (oRow.getCell(c).getCellType()==HSSFCell.CELL_TYPE_STRING) {
				      aColumnNames[c] = Gadgets.ASCIIEncode(oRow.getCell(c).getStringCellValue()).toLowerCase().replace(' ','_').replace('.','_');
				      aSQLTypes[c] = Types.NULL;
				      for (r=0; r<nRows && aSQLTypes[c]!=Types.VARCHAR; r++) {
				        int iCelType = oSht.getRow(r).getCell(c).getCellType();
				        switch (iCelType) {
				          case HSSFCell.CELL_TYPE_BLANK:
				            break;
				          case HSSFCell.CELL_TYPE_STRING:
				      	    aColumnTypes[c] = "VARCHAR(255)";
				      		  aSQLTypes[c] = Types.VARCHAR;
				            break;
				          case HSSFCell.CELL_TYPE_NUMERIC:
				            switch (oSht.getRow(r).getCell(c).getCellStyle().getDataFormat()) {
				           		case (short) 2:
				      	    	  aColumnTypes[c] = "INTEGER";
				      		      aSQLTypes[c] = Types.INTEGER;
				           		  break;
				           		case (short) 15: // m/d/yy
				           		case (short) 16: // d-mmm-yy
				      	    	  aColumnTypes[c] = "DATETIME";
				      		  		aSQLTypes[c] = Types.DATETIME;
				            		break;				           		
				              default:
				      	    	  aColumnTypes[c] = "DOUBLE";
				      		      aSQLTypes[c] = Types.DOUBLE;
				            }
				            break;				            
				        } // end switch
				      } // next
				      sDDL += ","+aColumnNames[c]+" "+aColumnTypes[c]+" NULL";
				    } else {
				      aColumnNames[c] = null;
				      aColumnTypes[c] = null;
				      aSQLTypes[c] = Types.NULL;
				    }
				  } // next
				  sDDL += ")";
				  ModelManager oMMan = ModelManager();
				  oMMan.connect(GlobalDBBind.getProperty("driver"), GlobalDBBind.getProperty("dburl"), GlobalDBBind.getProperty("schema"), GlobalDBBind.getProperty("dbusr"), GlobalDBBind.getProperty("dbpwd"));
          oMMan.executeSQLScript (oMMan.translate(sDDL), ";");
          oMMan.disconnect();
          oConn = GlobalDBBind.getConnection(PAGE_NAME);
          PreparedStatement oStmt = oConn.prepareStatement("INSERT INTO k_xls_"+aTableNames[s]+"_"+sNow+" VALUES (?"+Gadgets.repeat(",?",nCols+")");
    			oConn.setAutoCommit(true);
    			for (r=1; r<nRows; r++) {
				    for (c=0; c<nCols; n++) {
				      int iCelType = oSht.getRow(r).getCell(c).getCellType();
							switch (iCelType) {
				        case HSSFCell.CELL_TYPE_BLANK:
    			        oStmt.setNull(c+1, aColumnTypes[c]);
				          break;
				        case HSSFCell.CELL_TYPE_NUMERIC:
				          if (aColumnTypes[c]==Types.DATETIME)
				            oStmt.setTimstamp(c+1, new Timestamp(oSht.getRow(r).getCell(c).getDateCellValue().getTime()));
				          else
				            oStmt.setDouble(c+1, oSht.getRow(r).getCell(c).getNumericCellValue());
				          break;				          	
				        default:
    			        oStmt.setString(c+1, oSht.getRow(r).getCell(c).getStringCellValue());
    			        break;
    			    } // end switch
    			  } // next
    			  oStmt.executeUpdate();
    			} // next    			
    			oStmt.close();
    			oStmt=null;
    			oConn.close(PAGE_NAME);
				} // next (sheet)
			} // fi
	  } // wend

  } catch (Exception e) {  
    if (null!=oStmt) oStmt.close();
    disposeConnection(oConn,PAGE_NAME);
    oConn = null;
    sErr = (aTableNames==null ? "" : aTableNames[s]+"["+String(r+1)+","+String(c+1)+"]")+" "+e.getClass()+" "+e.getMessage();
  }
  
  if (null==oConn) return;    
  oConn = null;

%><HTML>
  <BODY>
    if (aTableNames!=null) {
      out.write("Tablas procesadas<BR/>\n");
      for (int t=0; t<aTableNames.length; t++) {
        out.write("k_xls_"+aTableNames[s]+"_"+sNow);
      }
      if (sErr.length()>0) {
        out.write(sErr);
      }
    }
  </BODY>
</HTML>