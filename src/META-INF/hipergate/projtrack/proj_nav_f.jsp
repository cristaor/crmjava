<%@ page import="java.io.IOException,java.net.URLDecoder,java.sql.SQLException,java.sql.PreparedStatement,java.sql.ResultSet,com.knowgate.debug.DebugFile,com.knowgate.jdc.JDCConnection,com.knowgate.acl.*,com.knowgate.dataobjs.*,com.knowgate.projtrack.*" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../methods/page_prolog.jspf" %><%@ include file="../methods/dbbind.jsp" %>
<%  response.setHeader("Cache-Control","no-cache");response.setHeader("Pragma","no-cache"); response.setIntHeader("Expires", 0); %>
<%@ include file="../methods/cookies.jspf" %>
<%@ include file="../methods/authusrs.jspf" %>
<%@ include file="../methods/clientip.jspf" %>
<%!
  static boolean hasChilds (DBSubset oDBSS, String sGUID, int iLevel, int iOffset, int iUBound) {
    
    if (DebugFile.trace) {
      DebugFile.writeln("<JSP:proj_nav_f hasChilds([DBSubset], " + sGUID + ", " + String.valueOf(iLevel) + ", " + String.valueOf(iOffset) + ", " + String.valueOf(iUBound) + ")>");
      DebugFile.incIdent();
    }
    
    boolean bHasChilds = false;
    int c = iOffset;
    
    while (c<iUBound && oDBSS.getInt(2,c)==iLevel) c++;
        
    for (; c<iUBound && !bHasChilds; c++) {
      bHasChilds = oDBSS.getStringNull(4,c,"").equals(sGUID);
      
      if (oDBSS.getInt(2,c)<=iLevel) break;
    }

    if (DebugFile.trace) {
      DebugFile.decIdent();
      DebugFile.writeln("<JSP:proj_nav_f hasChilds() : " + String.valueOf(bHasChilds)+ ">");
    }
    
    return bHasChilds;
  } // hasChilds()  
%>
<%
/*
  Copyright (C) 2003  Know Gate S.L. All rights reserved.
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

  // if (autenticateSession(GlobalDBBind, request, response)<0) return;

  String sWorkArea = getCookie(request,"workarea", "");

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 FRAMESET//EN" "http://www.w3.org/TR/REC-html40/FRAMESET.dtd">
<HTML>
  <HEAD>
    <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
    <TITLE>hipergate :: Project Tree</TITLE>
    <SCRIPT SRC="../javascript/cookies.js"></SCRIPT>
    <SCRIPT TYPE="text/javascript">
    <!--
    var skin = getCookie("skin");
    if (""==skin) skin="xp";
      
    document.write ('<LINK REL="stylesheet" TYPE="text/css" HREF="../skins/' + skin + '/styles.css">');
                  
  
    // User-defined tree menu data.

    var treeMenuName       = "SubProjects"; // Make this unique for each tree menu.
    var treeMenuDays       = 1;                // Number of days to keep the cookie.
    var treeMenuFrame      = "tree";           // Name of the menu frame.
    var treeMenuImgDir     = "../images/images/tree/"        // Path to graphics directory.
    var treeMenuBackground = "../images/images/tree/menu_background.gif";               // Background image for menu frame.   
    var treeMenuBgColor    = "#FFFFFF";        // Color for menu frame background.   
    var treeMenuFgColor    = "#000000";        // Color for menu item text.
    var treeMenuHiBg       = "#034E7A";        // Color for selected item background.
    var treeMenuHiFg       = "#FFFF00";        // Color for selected item text.
    var treeMenuFont       = "Arial,Helvetica"; // Text font face.
    var treeMenuFontSize   = 2;                    // Text font size.
    var treeMenuRoot       = "PROJECTS"; // Text for the menu root.
    var treeMenuFolders    = 1;                    // Sets display of '+' and '-' icons.
    var treeMenuAltText    = false;                 // Use menu item text for icon image ALT text.

    var SelectedNode;
    var SelectedName;
    
    function selectNode(guid,name) {      
      window.frames[2].document.forms[0].code.value = guid;
      window.frames[2].document.forms[0].ctrl.value = name;
    }

  //-->
  </SCRIPT>

  <SCRIPT SRC="../javascript/treemenu.js"></SCRIPT>
  <SCRIPT SRC="../javascript/scroller.js" DEFER=true></SCRIPT>  

  <SCRIPT TYPE="text/javascript">
  <!--
    
    var treeMenu = new TreeMenu();   // This is the main menu.  
        
    <%
       JDCConnection oConn = null;
       PreparedStatement oStmt;
       ResultSet oRSet;
       Project oProj;
       DBSubset oChlds;
       int iChlds;
       String sProjId;
       String sProjNm;
       String sSubProjId;
       String sSubProjNm;
       String sParentPrj;
       int iSubProjLv;
       int iNode;
       int ChildsPerLevel[] = new int[255];

       for (int l=0;l<255;l++) ChildsPerLevel[l]=0;
       
       try {
         oConn = GlobalDBBind.getConnection("proj_nav_f");

         if (DebugFile.trace)
           DebugFile.writeln("<JSP:proj_nav_f Connection.prepareStatement(SELECT " + DB.gu_project + "," + DB.nm_project + " FROM " + DB.k_projects + " WHERE " + DB.gu_owner + "='" + sWorkArea + "' AND " + DB.id_parent + " IS NULL)>");
                  
         oStmt = oConn.prepareStatement("SELECT " + DB.gu_project + "," + DB.nm_project + " FROM " + DB.k_projects + " WHERE " + DB.gu_owner + "=? AND " + DB.id_parent + " IS NULL", ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_READ_ONLY);

	 oStmt.setString(1, sWorkArea);
	 
	 oRSet = oStmt.executeQuery();

	 iNode = 0;
	 while (oRSet.next()) {
	 
	   if (DebugFile.trace)
             DebugFile.writeln("<JSP:proj_nav_f expanding " + oRSet.getString(2) + ">");

	   sProjId = oRSet.getString(1);
	   sProjNm = oRSet.getString(2);
	   oProj = new Project(sProjId);
	   oChlds = oProj.getAllChilds(oConn);
	   iChlds = oChlds.getRowCount();

	   if (DebugFile.trace)
             DebugFile.writeln("<JSP:proj_nav_f " + String.valueOf(iChlds) + " childs found>");

	   out.write ("    var p_" +  sProjId + " = new TreeMenu();\n");	     	   
	   
           out.write ("    treeMenu.addItem(new TreeMenuItem(\"" + sProjNm + "\", \"prj_edit.jsp?gu_project=" + sProjId + "\", \"editprj\"));\n");

	   if (iChlds>0) 
	     out.write ("    treeMenu.items[" + iNode + "].makeSubmenu(p_" + sProjId + ");\n");
	   
	   for (int s=0; s<iChlds; s++) {
	     sSubProjId = oChlds.getString(0,s);
	     sSubProjNm = oChlds.getString(1,s);
	     iSubProjLv = oChlds.getInt(2,s);
	     sParentPrj = oChlds.getString(4,s);
	     
	     if (iSubProjLv>1) {	       
	       out.write ("    var p_" +  sSubProjId + " = new TreeMenu();\n");	     	   
	       
	       out.write ("    p_" + sParentPrj  + ".addItem(new TreeMenuItem(\"" + sSubProjNm + "\", \"prj_edit.jsp?gu_project=" + sSubProjId + "&id_parent=" + sParentPrj + "\", \"editprj\"));\n");
	     	       
	       if (hasChilds(oChlds, sSubProjId, iSubProjLv, s, iChlds))	      
	         out.write ("    p_" + sParentPrj + ".items[" + ChildsPerLevel[iSubProjLv] + "].makeSubmenu(p_" + sSubProjId + ");\n");

	       ChildsPerLevel[iSubProjLv] += 1;
	       
	       if (DebugFile.trace)
                 DebugFile.writeln("<JSP:proj_nav_f ChildsPerLevel[" + String.valueOf(iSubProjLv) + "]=" + String.valueOf(ChildsPerLevel[iSubProjLv]) + ">");
           
	     } // fi(iSubProjLv)
	     
	   } // next (s)
	   
	   iNode++;
	 } // wend (oRSet.next())
	 oRSet.close();
	 oStmt.close();
	 
	 oConn.close("proj_nav_f");
       }
       catch (SQLException e) {
         if (null!=oConn)
           if (!oConn.isClosed()) {
             oConn.close("proj_nav_f");
             oConn = null;
           }

         if (com.knowgate.debug.DebugFile.trace) {
           com.knowgate.dataobjs.DBAudit.log ((short)0, "CJSP", sUserIdCookiePrologValue, request.getServletPath(), "", 0, request.getRemoteAddr(), "SQLException", e.getMessage());
         }
                            
         response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=Error de Acceso a la Base de Datos&desc=" + e.getLocalizedMessage() + "&resume=_back"));    
       }
       
       if (null==oConn) return;
       
       oConn = null;
    %>	 
  //-->
  </SCRIPT>
  
</HEAD>
  <FRAMESET NAME="projtop" COLS="270,*" >
  <FRAMESET ROWS="32,*" BORDER="0" FRAMEBORDER="0">
    <FRAME NAME="scroll" FRAMEBORDER=0 MARGINWIDTH=0 MARGINHEIGHT=0 SRC="tree_scroll.htm" SCROLLING="no">
    <FRAME NAME="tree" FRAMEBORDER=0 MARGINWIDTH=8 SRC="tree_nodes.htm" SCROLLING="yes">
  </FRAMESET>
  <FRAME NAME="editprj" SRC="../common/blank.htm">
  </FRAMESET>  
<NOFRAMES>
  <BODY>
    <P>This page use frames, but your web browser does not handle them</P>
  </BODY>
</NOFRAMES>
<HTML>
<%@ include file="../methods/page_epilog.jspf" %>