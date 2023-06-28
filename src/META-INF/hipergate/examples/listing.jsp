<%@ page import="java.net.URLDecoder,java.io.File,java.sql.SQLException,com.knowgate.acl.*,com.knowgate.jdc.JDCConnection,com.knowgate.dataobjs.DB,com.knowgate.dataobjs.DBBind,com.knowgate.dataobjs.DBSubset,com.knowgate.misc.Environment,com.knowgate.misc.Gadgets,com.knowgate.hipergate.QueryByForm" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/nullif.jspf" %>
<jsp:useBean id="GlobalCacheClient" scope="application" class="com.knowgate.cache.DistributedCachePeer"/><%

/*
  Generic listing page
  
  Copyright (C) 2003-2008  Know Gate S.L. All rights reserved.
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

  response.addHeader ("Pragma", "no-cache");
  response.addHeader ("cache-control", "no-store");
  response.setIntHeader("Expires", 0);

  final String BASE_TABLE = "k_examples b";
  final String COLUMNS_LIST = "b.gu_example,b.dt_created,b.dt_modified,b.nm_example,b.nu_example,b.bo_active,b.dt_example,b.tp_example,b.de_example";

  final String sLanguage = getNavigatorLanguage(request);  
  final String sSkin = getCookie(request, "skin", "xp");

  // hipergate is stateless at server side , sessions are kept in client cookies

  final String id_domain = getCookie(request,"domainid","");
  final String n_domain = getCookie(request,"domainnm","");
  final String gu_workarea = getCookie(request,"workarea","");

  String screen_width = nullif(request.getParameter("screen_width"),"1024");

  int iScreenWidth;

  if (screen_width.length()==0)
    iScreenWidth = 1024;
  else
    iScreenWidth = Integer.parseInt(screen_width);
  
  float fScreenRatio = ((float) iScreenWidth) / 1024f;
  if (fScreenRatio<1) fScreenRatio=1;

  final String sField = nullif(request.getParameter("field")); // Column sought
  final String sFind = nullif(request.getParameter("find"));   // Text to be found
  final String sWhere = nullif(request.getParameter("where")); // An SQL injected WHERE clause
  final String sQuery = nullif(request.getParameter("query")); // The name of an XML query definition stored at /storage/qbf

  // Get storage property from /etc/hipergate.cnf file
  final String sStorage = GlobalDBBind.getPropertyPath("storage");

  // **********************************************

  int iInstanceCount = 0;
  DBSubset oInstances;        
  String sOrderBy;
  int iOrderBy;  
  int iMaxRows;
  int iSkip;

  // 06. Maximum number of rows to display and row to start with

  try {  
    if (request.getParameter("maxrows")!=null)
      iMaxRows = Integer.parseInt(request.getParameter("maxrows"));
    else 
      iMaxRows = Integer.parseInt(getCookie(request, "maxrows", "10"));
  }
  catch (NumberFormatException nfe) { iMaxRows = 100; }
  
  if (request.getParameter("skip")!=null)
    iSkip = Integer.parseInt(request.getParameter("skip"));      
  else
    iSkip = 0;
    
  if (iSkip<0) iSkip = 0;

  // **********************************************

  // 07. Order by column

  sOrderBy = nullif(request.getParameter("orderby"));
    
  if (sOrderBy.length()>0)
    iOrderBy = Integer.parseInt(sOrderBy);
  else
    iOrderBy = 0;

  // **********************************************

  JDCConnection oConn = null;  
  QueryByForm oQBF;
  boolean bIsGuest = true;
  
  try {

    bIsGuest = isDomainGuest (GlobalCacheClient, GlobalDBBind, request, response);
    
    // 08. Get a connection from pool

    oConn = GlobalDBBind.getConnection("instancelisting");  
    
    // Results are stored in a DBSubset object and connection is closed.
    // Later the DBSubset is iterated and each row is send to HTML output.
    
    if (sWhere.length()>0) {

      // 09. Query By Form Filtered Listing
      
      oQBF = new QueryByForm("file://" + sStorage + "qbf" + File.separator + request.getParameter("queryspec") + ".xml");
    
      oInstances = new DBSubset (oQBF.getBaseObject(), COLUMNS_LIST,
      				 "(" + oQBF.getBaseFilter(request) + ") " + sWhere + (iOrderBy>0 ? " ORDER BY " + sOrderBy : ""), iMaxRows);      				 
      
      oInstances.setMaxRows(iMaxRows);
      iInstanceCount = oInstances.load (oConn, iSkip);
    }
    
    else if (sFind.length()==0 || sField.length()==0) {
      
      // 10. If filter does not exist then return all rows up to maxrows limit

      oInstances = new DBSubset (BASE_TABLE, COLUMNS_LIST,
      				                   "b." + DB.gu_workarea+ "='" + gu_workarea + "'" + (iOrderBy>0 ? " ORDER BY " + sOrderBy : ""), iMaxRows);      				 

      oInstances.setMaxRows(iMaxRows);
      iInstanceCount = oInstances.load (oConn, iSkip);
    }
    else {

      // 11. Single field Filtered Listing

      oQBF = new QueryByForm("file://" + sStorage + "/qbf/" + request.getParameter("queryspec") + ".xml");
      oInstances = new DBSubset (BASE_TABLE, COLUMNS_LIST,
      				                   "(" + oQBF.getBaseFilter(request) + ") AND (" + sField + " " + DBBind.Functions.ILIKE + " ?)" + (iOrderBy>0 ? " ORDER BY " + sOrderBy : ""), iMaxRows);      				 

      oInstances.setMaxRows(iMaxRows);

      Object[] aFind = { "%" + sFind + "%" };      
      iInstanceCount = oInstances.load (oConn, aFind, iSkip);
    }
    
    oConn.close("instancelisting"); 
  }
  catch (SQLException e) {  
    oInstances = null;
    if (oConn!=null)
      if (!oConn.isClosed())
        oConn.close("instancelisting");
    oConn = null;
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=Error&desc=" + e.getLocalizedMessage() + "&resume=_back"));
  }
  
  if (null==oConn) return;
  
  oConn = null;  
%>
<HTML LANG="<% out.write(sLanguage); %>">
<HEAD>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/cookies.js"></SCRIPT>  
  <SCRIPT TYPE="text/javascript" SRC="../javascript/setskin.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/combobox.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/getparam.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/simplevalidations.js"></SCRIPT>  
  <SCRIPT TYPE="text/javascript" SRC="../javascript/dynapi3/dynapi.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript">
    <!--
    
    // DynAPI library show right mouse button click context menu
    dynapi.library.setPath('../javascript/dynapi3/');
    dynapi.library.include('dynapi.api.DynLayer');

    var menuLayer,addrLayer;
    dynapi.onLoad(init);
    function init() {
 
      setCombos();
      menuLayer = new DynLayer();
      menuLayer.setWidth(160);
      menuLayer.setHTML(rightMenuHTML);      
    }
    //-->
  </SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/dynapi3/rightmenu.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/dynapi3/floatdiv.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" DEFER="defer">
    <!--
        // Global variables for moving the clicked row to the context menu
        
        var jsInstanceId;
        var jsInstanceNm;
            
        <%
          // Write instance primary keys in a JavaScript Array
          // This Array is used when posting multiple elements
          // for deletion.
          
          out.write("var jsInstances = new Array(");
            
            for (int i=0; i<iInstanceCount; i++) {
              if (i>0) out.write(","); 
              out.write("\"" + oInstances.getString(0,i) + "\"");
            }
            
          out.write(");\n        ");
        %>

        // ----------------------------------------------------

<% if (!bIsGuest) { %>
        
        // 12. Create new instance

	      function createInstance() {	  
	        open ("form_edit.jsp?id_domain=<%=id_domain%>&n_domain=" + escape("<%=n_domain%>") + "&gu_workarea=<%=gu_workarea%>", "editinstance", "directories=no,toolbar=no,menubar=no,width=500,height=460");	  
	      } // createInstance()

        // ----------------------------------------------------

        // 13. Delete checked instances
	
	      function deleteInstances() {
	  
	        var offset = 0;
	        var frm = document.forms[0];
	        var chi = frm.checkeditems;
	  	  
	        if (window.confirm("Are you sure you wish to delete the selected instances?")) {
	  	  
	          chi.value = "";	  	  
	          frm.action = "form_delete.jsp?selected=" + getURLParam("selected") + "&subselected=" + getURLParam("subselected");
	  	  
	          for (var i=0;i<jsInstances.length; i++) {
              while (frm.elements[offset].type!="checkbox") offset++;
    	        if (frm.elements[offset].checked)
                chi.value += jsInstances[i] + ",";
                offset++;
	          } // next()
	    
	          if (chi.value.length>0) {
	            chi.value = chi.value.substr(0,chi.value.length-1);
              frm.submit();
            } // fi(chi!="")
          } // fi (confirm)
	} // deleteInstances()
<% } %>	
        // ----------------------------------------------------

        // 14. Modify Instance

	      function modifyInstance(id,nm) {
	        open ("form_edit.jsp?id_domain=<%=id_domain%>&n_domain=" + escape("<%=n_domain%>") + "&gu_workarea=<%=gu_workarea%>" + "&gu_instance=" + id + "&n_instance=" + escape(nm), "editinstance", "directories=no,toolbar=no,menubar=no,width=500,height=460");
	      } // modifyInstance

        // ----------------------------------------------------

        // 15. Reload Page sorting by a field

	      function sortBy(fld) {
	  
	        var frm = document.forms[0];
	  
	          window.location = "listing.jsp?id_domain=<%=id_domain%>&n_domain=" + escape("<%=n_domain%>") + "&skip=0&orderby=" + fld + "&where=" + escape("<%=sWhere%>") + "&field=" + getCombo(frm.sel_searched) + "&find=" + escape(frm.find.value) + "&selected=" + getURLParam("selected") + "&subselected=" + getURLParam("subselected") + "&screen_width=" + String(screen.width);
	      } // sortBy		

        // ----------------------------------------------------

        // 16. Select All Instances

        function selectAll() {
          
          var frm = document.forms[0];
          
          for (var c=0; c<jsInstances.length; c++)                        
            eval ("frm.elements['" + jsInstances[c] + "'].click()");
        } // selectAll()
       
        // ----------------------------------------------------

        // 17. Reload Page finding instances by a single field
	
	      function findInstance() {
	  	  
	        var frm = document.forms[0];

			    if (hasForbiddenChars(frm.find.value)) {
			      alert ("The string sought contains invalid characters");
				    frm.find.focus();
				    return false;
			    }
	  
	        if (frm.find.value.length>0)
	          window.location = "instance_listing.jsp?id_domain=<%=id_domain%>&n_domain=" + escape("<%=n_domain%>") + "&skip=0&orderby=<%=sOrderBy%>&field=" + getCombo(frm.sel_searched) + "&find=" + escape(frm.find.value) + "&selected=" + getURLParam("selected") + "&subselected=" + getURLParam("subselected") + "&screen_width=" + String(screen.width);
	        else
	          window.location = "instance_listing.jsp?id_domain=<%=id_domain%>&n_domain=" + escape("<%=n_domain%>") + "&skip=0&orderby=<%=sOrderBy%>&selected=" + getURLParam("selected") + "&subselected=" + getURLParam("subselected") + "&screen_width=" + String(screen.width);
	  
	      } // findInstance()

        // ----------------------------------------------------

        var intervalId;
        var winclone;

        // This function is called every 100 miliseconds for testing
        // whether or not clone call has finished.
      
        function findCloned() {
        
          if (winclone.closed) {
            clearInterval(intervalId);
            setCombo(document.forms[0].sel_searched, "<%=DB.nm_legal%>");
            document.forms[0].find.value = jsInstanceNm;
            findInstance();
          }
        } // findCloned()

        // 18. Clone an instance using an XML data structure definition
      
        function clone() {        
          // Open a clone window and wait for it to be closed
        
          winclone = window.open ("../common/clone.jsp?id_domain=<%=id_domain%>&n_domain=" + escape("<%=n_domain%>") + "&datastruct=instance_clon&gu_instance=" + jsInstanceId +"&opcode=CCOM&classid=91", null, "directories=no,toolbar=no,menubar=no,width=320,height=200");                
          intervalId = setInterval ("findCloned()", 100);
        }	// clone()
      
        // ------------------------------------------------------	
    //-->    
  </SCRIPT>
  <SCRIPT TYPE="text/javascript">
    <!--
	    function setCombos() {
	      setCookie ("maxrows", "<%=iMaxRows%>");
	      setCombo(document.forms[0].maxresults, "<%=iMaxRows%>");
	      setCombo(document.forms[0].sel_searched, "<%=sField%>");
	    } // setCombos()
    //-->    
  </SCRIPT>
  <TITLE>hipergate :: Example Listing</TITLE>
</HEAD>
<BODY TOPMARGIN="8" MARGINHEIGHT="8" onClick="hideRightMenu()">
    <%@ include file="../common/tabmenu.jspf" %>
    <FORM METHOD="post">
      <TABLE><TR><TD WIDTH="<%=iTabWidth*iActive%>" CLASS="striptitle"><FONT CLASS="title1">Example Listing</FONT></TD></TR></TABLE>  
      <INPUT TYPE="hidden" NAME="id_domain" VALUE="<%=id_domain%>">
      <INPUT TYPE="hidden" NAME="n_domain" VALUE="<%=n_domain%>">
      <INPUT TYPE="hidden" NAME="gu_workarea" VALUE="<%=gu_workarea%>">
      <INPUT TYPE="hidden" NAME="maxrows" VALUE="<%=String.valueOf(iMaxRows)%>">
      <INPUT TYPE="hidden" NAME="skip" VALUE="<%=String.valueOf(iSkip)%>">      
      <INPUT TYPE="hidden" NAME="where" VALUE="<%=sWhere%>">
      <INPUT TYPE="hidden" NAME="checkeditems">
      <!-- 19. Top controls and filters -->
      <TABLE SUMMARY="Top controls and filters" CELLSPACING="2" CELLPADDING="2">
      <TR><TD COLSPAN="8" BACKGROUND="../images/images/loginfoot_med.gif" HEIGHT="3"></TD></TR>
      <TR>
<% if (bIsGuest) { %>      
        <TD COLSPAN="4"></TD>
<% } else { %>
        <TD>&nbsp;&nbsp;<IMG SRC="../images/images/new16x16.gif" WIDTH="16" HEIGHT="16" BORDER="0" ALT="New"></TD>
        <TD VALIGN="middle"><A HREF="#" onclick="createInstance()" CLASS="linkplain">New</A></TD>
        <TD>&nbsp;&nbsp;<IMG SRC="../images/images/papelera.gif" WIDTH="16" HEIGHT="16" BORDER="0" ALT="Delete"></TD>
        <TD><A HREF="#" onclick="deleteInstances()" CLASS="linkplain">Delete</A></TD>
<% } %>
        <TD VALIGN="bottom">&nbsp;&nbsp;<IMG SRC="../images/images/find16.gif" HEIGHT="16" BORDER="0" ALT="Find"></TD>
        <TD VALIGN="middle">
          <SELECT NAME="sel_searched" CLASS="combomini"><OPTION VALUE=""></OPTION><OPTION VALUE="nm_example">Name</OPTION><OPTION VALUE="tp_example">Type</OPTION></SELECT>
          <INPUT CLASS="textmini" TYPE="text" NAME="find" MAXLENGTH="50" VALUE="<%=sFind%>">
	        &nbsp;<A HREF="javascript:findInstance();" CLASS="linkplain" TITLE="Find">Find</A>	  
        </TD>
        <TD VALIGN="bottom">&nbsp;&nbsp;&nbsp;<IMG SRC="../images/images/findundo16.gif" HEIGHT="16" BORDER="0" ALT="Discard Search"></TD>
        <TD VALIGN="bottom">
          <A HREF="javascript:document.forms[0].find.value='';findInstance();" CLASS="linkplain" TITLE="Discard Search">Discard</A>
          <FONT CLASS="textplain">&nbsp;&nbsp;&nbsp;Show&nbsp;</FONT><SELECT CLASS="combomini" NAME="maxresults" onchange="setCookie('maxrows',getCombo(document.forms[0].maxresults));"><OPTION VALUE="10">10<OPTION VALUE="20">20<OPTION VALUE="50">50<OPTION VALUE="100">100<OPTION VALUE="200">200<OPTION VALUE="500">500</SELECT><FONT CLASS="textplain">&nbsp;&nbsp;&nbsp;results&nbsp;</FONT>
        </TD>
      </TR>
      <TR><TD COLSPAN="8" BACKGROUND="../images/images/loginfoot_med.gif" HEIGHT="3"></TD></TR>
      </TABLE>
      <!-- End Top controls and filters -->
      <TABLE SUMMARY="Data" CELLSPACING="1" CELLPADDING="0">
        <TR>
          <TD COLSPAN="3" ALIGN="left">
<%
    	  // 20. Paint Next and Previous Links
    
    	  if (iInstanceCount>0) {
            if (iSkip>0) // If iSkip>0 then we have prev items
              out.write("            <A HREF=\"listing.jsp?id_domain=" + id_domain + "&n_domain=" + n_domain + "&skip=" + String.valueOf(iSkip-iMaxRows) + "&orderby=" + sOrderBy + "&field=" + sField + "&find=" + sFind + "&selected=" + request.getParameter("selected") + "&subselected=" + request.getParameter("subselected") + "\" CLASS=\"linkplain\">&lt;&lt;&nbsp;Previous" + "</A>&nbsp;&nbsp;&nbsp;");
    
            if (!oInstances.eof())
              out.write("            <A HREF=\"listing.jsp?id_domain=" + id_domain + "&n_domain=" + n_domain + "&skip=" + String.valueOf(iSkip+iMaxRows) + "&orderby=" + sOrderBy + "&field=" + sField + "&find=" + sFind + "&selected=" + request.getParameter("selected") + "&subselected=" + request.getParameter("subselected") + "\" CLASS=\"linkplain\">Next&nbsp;&gt;&gt;</A>");
	  } // fi (iInstanceCount)
%>
          </TD>
        </TR>
        <TR>
          <TD CLASS="tableheader" WIDTH="<%=String.valueOf(floor(150f*fScreenRatio))%>" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif">&nbsp;<A HREF="javascript:sortBy(2);" oncontextmenu="return false;"><IMG SRC="../skins/<%=sSkin + (iOrderBy==2 ? "/sortedfld.gif" : "/sortablefld.gif")%>" WIDTH="14" HEIGHT="10" BORDER="0" ALT="Ordenar por este campo"></A>&nbsp;<B>Name</B></TD>
          <TD CLASS="tableheader" WIDTH="<%=String.valueOf(floor(320f*fScreenRatio))%>" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif">&nbsp;<A HREF="javascript:sortBy(3);" oncontextmenu="return false;"><IMG SRC="../skins/<%=sSkin + (iOrderBy==3 ? "/sortedfld.gif" : "/sortablefld.gif")%>" WIDTH="14" HEIGHT="10" BORDER="0" ALT="Ordenar por este campo"></A>&nbsp;<B>Description</B></TD>
          <TD CLASS="tableheader" WIDTH="100" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif">&nbsp;<A HREF="javascript:sortBy(5);" oncontextmenu="return false;"><IMG SRC="../skins/<%=sSkin + (iOrderBy==5 ? "/sortedfld.gif" : "/sortablefld.gif")%>" WIDTH="14" HEIGHT="10" BORDER="0" ALT="Ordenar por este campo"></A>&nbsp;<B>Date</B></TD>
          <TD CLASS="tableheader" BACKGROUND="../skins/<%=sSkin%>/tablehead.gif"><A HREF="#" onclick="selectAll()" TITLE="Select All"><IMG SRC="../images/images/selall16.gif" BORDER="0" ALT="Select All"></A></TD></TR>
<%
    	    // 21. List rows

	        String sInstId, sInstNm, sInstNu, sInstDt, sStrip;
	    
	        for (int i=0; i<iInstanceCount; i++) {
            sInstId = oInstances.getString(0,i);
            sInstNm = oInstances.getStringHtml(3,i,"");
            if (oInstances.isNull(4,i))
              sInstNu = "";
            else
              sInstNu = String.valueOf(oInstances.getInt(4,i));
            
            sStrip = String.valueOf((i%2)+1);
            if (oInstances.isNull(6,i))
              sInstDt = "";
            else
            	sInstDt = oInstances.getDateShort(6,i);
%>            
            <TR HEIGHT="14">
              <TD CLASS="strip<% out.write (sStrip); %>">&nbsp;<A HREF="#" oncontextmenu="jsInstanceId='<%=sInstId%>'; jsInstanceNm='<%=oInstances.getStringNull(3,i,"").replace((char)39,'´')%>'; return showRightMenu(event);" onclick="modifyInstance('<%=sInstId%>','<%=oInstances.getStringNull(3,i,"").replace((char)39,'´')%>')" TITLE="Right click to see context menu"><%=sInstNm%></A></TD>
              <TD CLASS="strip<% out.write (sStrip); %>">&nbsp;<%=oInstances.getStringNull(1,i,"")%></TD>
              <TD CLASS="strip<% out.write (sStrip); %>">&nbsp;<%=oInstances.getStringNull(1,i,"")%></TD>
              <TD CLASS="strip<% out.write (sStrip); %>" ALIGN="center"><INPUT VALUE="1" TYPE="checkbox" NAME="<% out.write (sInstId); %>"></TD>
            </TR>
<%        } // next(i) %>          	  
      </TABLE>
    </FORM>
    <!-- 22. DynFloat Right-click context menu -->
    <SCRIPT TYPE="text/javascript">
      <!--
      addMenuOption("Open","modifyInstance(jsInstanceId)",1);
      addMenuOption("Clone","clone()",0);
      addMenuSeparator();
      //-->
    </SCRIPT>
    <!-- /RightMenuBody -->    
</BODY>
</HTML>