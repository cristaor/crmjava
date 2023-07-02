<%@ page import="java.util.Enumeration,java.io.IOException,java.io.File,java.io.FileInputStream,java.net.URLDecoder,com.oreilly.servlet.MailMessage,com.oreilly.servlet.MultipartRequest,com.knowgate.acl.*,com.knowgate.misc.Environment,com.knowgate.workareas.FileSystemWorkArea" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../../../methods/dbbind.jsp" %><%@ include file="../../../methods/cookies.jspf" %><%@ include file="../../../methods/authusrs.jspf" %><%@ include file="../../../methods/nullif.jspf" %><%
/*
  Copyright (C) 2009  Know Gate S.L. All rights reserved.
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

  if (autenticateSession(GlobalDBBind, request, response)<0) return;

  final String sSep = java.io.File.separator;

  String sDefWrkArPut = request.getRealPath(request.getServletPath());
  sDefWrkArPut = sDefWrkArPut.substring(0,sDefWrkArPut.lastIndexOf(sSep));
  sDefWrkArPut = sDefWrkArPut.substring(0,sDefWrkArPut.lastIndexOf(sSep));
  sDefWrkArPut = sDefWrkArPut + sSep + "workareas";
  String sWrkAPut = Environment.getProfileVar(GlobalDBBind.getProfileName(), "workareasput", sDefWrkArPut);

  String sDefaultWorkAreasGet = request.getRequestURI();
  sDefaultWorkAreasGet = sDefaultWorkAreasGet.substring(0,sDefaultWorkAreasGet.lastIndexOf("/"));
  sDefaultWorkAreasGet = sDefaultWorkAreasGet.substring(0,sDefaultWorkAreasGet.lastIndexOf("/"));
  sDefaultWorkAreasGet = sDefaultWorkAreasGet + "/workareas";
  String sWrkAGet = Environment.getProfileVar(GlobalDBBind.getProfileName(), "workareasget", sDefaultWorkAreasGet);
  
  int iMaxUpload = Integer.parseInt(Environment.getProfileVar(GlobalDBBind.getProfileName(), "maxfileupload", "10485760"));
  
  String gu_workarea = getCookie(request,"workarea","");
 
  final String sApp = nullif(request.getParameter("app"),"Forum");

  String sImagesPut = sWrkAPut + sSep + gu_workarea + sSep + "apps" + sSep + sApp;
  String sImagesGet = sWrkAGet + "/" + gu_workarea + "/" + "apps" + "/" + sApp;

  MultipartRequest oReq;
  FileSystemWorkArea oFileSys;
  String sFileName = null;

  try {
    oFileSys = new FileSystemWorkArea(Environment.getProfile(GlobalDBBind.getProfileName()));
    oFileSys.mkdirs("file://" + sImagesPut);
    oFileSys = null;

    oReq = new MultipartRequest(request, sImagesPut, iMaxUpload, "UTF-8");

		Enumeration oFileNames = oReq.getFileNames();

    sFileName = oReq.getOriginalFileName(oFileNames.nextElement().toString());
  }
  catch (IOException e) {
    oReq = null;
    if (request.getContentLength()>=iMaxUpload) {
      response.sendRedirect (response.encodeRedirectUrl ("../../../common/errmsg.jsp?title=[~Archivo demasiado grande~]&desc=[~La longuitud del archivo excede el maximo permitido~] " + String.valueOf(iMaxUpload/1024) + "Kb&resume=_back"));
      return;
    }
    else {
      response.sendRedirect (response.encodeRedirectUrl ("../../../common/errmsg.jsp?title=IOException&desc=" + e.getMessage() + "&resume=_back"));
      return;
    }
  }
%>
<html>
<head>
<script type="text/javascript" src="popup.js"></script>
<script type="text/javascript">

function ok() {

  // pass data back to the calling window
  var fields = ["f_url", "f_alt", "f_align", "f_border",
                "f_horiz", "f_vert"];
  var param = new Object();
  for (var i in fields) {
    var id = fields[i];
    var el = document.getElementById(id);
    param[id] = el.value;
  }
  __dlg_close(param);
  return false;
};

</script>
</head>
<body onload="ok()">
<form>
<input type="hidden" name="url" id="f_url" value="<%=sImagesGet+"/"+sFileName%>" />
<input type="hidden" name="alt" id="f_alt" value="<%=oReq.getParameter("alt")%>" />
<input type="hidden" name="align" id="f_align" value="<%=oReq.getParameter("align")%>" />
<input type="hidden" name="border" id="f_border" value="<%=oReq.getParameter("border")%>" />
<input type="hidden" name="horiz" id="f_horiz" value="<%=oReq.getParameter("horiz")%>" />
<input type="hidden" name="vert" id="f_vert" value="<%=oReq.getParameter("vert")%>" />
</form>
</body>
</html>