<%@ page import="java.io.File,java.sql.Statement,java.sql.ResultSet,java.sql.ResultSetMetaData,java.sql.Types,com.oreilly.servlet.MultipartRequest,com.knowgate.hipergate.datamodel.ImportExport,com.knowgate.jdc.JDCConnection,com.knowgate.misc.Environment,com.knowgate.misc.Gadgets,com.knowgate.dfs.FileSystem" language="java" session="false" contentType="text/plain;charset=UTF-8" %>
<%@ include file="../methods/dbbind.jsp" %><% 
/*
  Copyright (C) 2003-2010  Know Gate S.L. All rights reserved.
                           C/Oña, 107 1º2 28050 Madrid (Spain)

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

  final String PAGE_NAME = "ldr_exec";

  FileSystem oFS = new FileSystem();

  String sTmpDir = Gadgets.chomp(Environment.getProfileVar(GlobalDBBind.getProfileName(), "temp", Environment.getTempDir()),File.separator);
  String sTmpDirE = Gadgets.escapeChars(sTmpDir,"\\", '\\');

  MultipartRequest oReq = new MultipartRequest(request, sTmpDir, Integer.parseInt(Environment.getProfileVar(GlobalDBBind.getProfileName(), "maxfileupload", "10485760")), "UTF-8");

  final String con_target = oReq.getParameter("con_target");
  final String tbl_target = oReq.getParameter("tbl_target");
  final String char_set = oReq.getParameter("char_set");
  final String date_format = oReq.getParameter("date_format");
  final String col_delim = oReq.getParameter("col_delim").equals("t") ? "\t" : request.getParameter("col_delim");
  final String txt_file = oReq.getOriginalFileName(oReq.getFileNames().nextElement().toString());

  JDCConnection oConn = null;  
  String sCDesc = "";
  try {
    oConn = GlobalDBBind.getConnection(PAGE_NAME,true);
    
    Statement oStmt = oConn.createStatement();
    ResultSet oRSet = oStmt.executeQuery("SELECT * FROM "+tbl_target+" WHERE 1=0");
    ResultSetMetaData oMDat = oRSet.getMetaData();
    for (int c=1; c<=oMDat.getColumnCount(); c++) {
      sCDesc += (sCDesc.length()==0 ? "" : ",") + oMDat.getColumnName(c) + " ";
      switch (oMDat.getColumnType(c)) {
        case Types.CHAR:
          sCDesc += "CHAR";
          break;
        case Types.SMALLINT:
          sCDesc += "SMALLINT";
          break;
        case Types.INTEGER:
          sCDesc += "INTEGER";
          break;
        case Types.FLOAT:
          sCDesc += "FLOAT";
          break;
        case Types.DOUBLE:
          sCDesc += "DOUBLE";
          break;
        case Types.DECIMAL:
        case Types.NUMERIC:
          sCDesc += "NUMERIC";
          break;
        case Types.DATE:
          sCDesc += "DATE \"+date_format+\"";
          break;
        case Types.TIMESTAMP:
          sCDesc += "DATE \""+date_format+" HH:mm:ss\"";
          break;
        default:
          sCDesc += "VARCHAR";
          
      }
    } // next
    oRSet.close();
    oStmt.close();
    oConn.close(PAGE_NAME);
    
    ImportExport oImp = new ImportExport();    
    int nErrors = oImp.perform("APPEND "+tbl_target+" CONNECT "+Environment.getProfileVar(con_target,"dbuser")+" TO \""+Environment.getProfileVar(con_target,"dburl")+"\" IDENTIFIED BY "+Environment.getProfileVar(con_target,"dbpassword")+" RECOVERABLE INPUTFILE \""+sTmpDirE+txt_file+"\" BADFILE \""+sTmpDirE+txt_file+".bad \" DISCARDFILE \""+sTmpDirE+txt_file+".dis\" CHARSET "+char_set+" ROWDELIM LF COLDELIM \""+col_delim+"\" ("+sCDesc+")");
    if (nErrors==0) {
      out.write("Importacion finalizada con exito");
    } else {
      out.write("Importacion fallida, "+String.valueOf(nErrors)+" errores encontrados\n");
      out.write(sCDesc+"\n");
      out.write(oFS.readfilestr("file://"+sTmpDir+txt_file+".bad",char_set));
      new File(sTmpDir+txt_file+".bad").delete();
      new File(sTmpDir+txt_file+".dis").delete();
    }
    new File(sTmpDir+txt_file).delete();
  }
  
  catch (java.sql.SQLException e) {  
    disposeConnection(oConn,PAGE_NAME);
    oConn = null;
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=Error&"+e.getClass().getName()+"=" + e.getMessage() + "&resume=_close"));  
  }
  
  if (null==oConn) return;    
  oConn = null;

  /* TO DO: Write HTML or redirect to another page */
%>