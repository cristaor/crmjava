<%@ page import="java.util.Date,java.text.SimpleDateFormat,java.util.HashMap,java.util.LinkedList,java.util.ListIterator,java.io.IOException,java.net.URLDecoder,java.sql.SQLException,java.sql.PreparedStatement,java.sql.ResultSet,com.knowgate.jdc.*,com.knowgate.dataobjs.*,com.knowgate.acl.*,com.knowgate.crm.*,com.knowgate.hipergate.DBLanguages,com.knowgate.hipergate.Term,com.knowgate.misc.Gadgets,com.knowgate.training.Registration" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../methods/nullif.jspf" %><%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %>
<jsp:useBean id="GlobalCacheClient" scope="application" class="com.knowgate.cache.DistributedCachePeer"/><jsp:useBean id="GlobalDBLang" scope="application" class="com.knowgate.hipergate.DBLanguages"/>
<%     // 01. Verify user credentials

if (autenticateSession(GlobalDBBind, request, response)<0) return;

// 02. Avoid page caching

response.addHeader ("Pragma", "no-cache");
response.addHeader ("cache-control", "no-store");
response.setIntHeader("Expires", 0);

// 03. Get parameters

final String PAGE_NAME = "registration_edit";

final String sLanguage = getNavigatorLanguage(request);
final String sSkin = getCookie(request, "skin", "xp");
final int iAppMask = Integer.parseInt(getCookie(request, "appmask", "0"));

final String id_user = getCookie(request, "userid", "");
final String id_domain = request.getParameter("id_domain");
final String gu_workarea = request.getParameter("gu_workarea");
final String gu_contact = request.getParameter("gu_contact");
final String gu_oportunity = request.getParameter("gu_oportunity");


boolean bIsGuest = true;
boolean bLoaded = false;

Registration oObj = new Registration();

String sIdInstitutionLookUp = null;
String dtReserve = null;
String dtRegistration = null;
String dtDrop = null;


HashMap oIdInstitutionLookUp = null;

DBSubset oAcourses = null;

/* DBSubset oAdmission = new DBSubset(DB.k_admission, DB.gu_admission +","+ DB.gu_contact +","+ DB.gu_oportunity +","+ DB.gu_workarea +","+ DB.gu_acourse +","+ 
		DB.id_objetive_1 +","+ DB.id_objetive_2 +","+ DB.id_objetive_3 +","+ DB.dt_created +","+ DB.dt_target +","+ DB.is_call smallint +","+ DB.id_place +","+ 
		DB.id_interviewer +","+ DB.dt_interview +","+ DB.dt_admision_test +","+ DB.is_grant +","+ DB.nu_grant +","+ DB.nu_interview +","+ DB.nu_vips integer +","+ 
		DB.nu_nips +","+ DB.nu_elp integer +","+ DB.nu_total +","+ DB.id_test_result character varying(50) +" where gu_contact = ? and gu_oportunity = ? and gu_wokarea = ?" , 0);*/


int iAcoursesCount = 0;
JDCConnection oConn = null;
PreparedStatement oStmt = null;
ResultSet oRSet = null;
SimpleDateFormat oSimpleDate = new SimpleDateFormat("yyyy-MM-dd");
Date dtDate =null;
try {
	bIsGuest = isDomainGuest (GlobalCacheClient, GlobalDBBind, request, response);
	oConn = GlobalDBBind.getConnection(PAGE_NAME);
	// idAdmissions = oAdmission.load(oConn, new Object[]{gu_contact,gu_oportunity,gu_workarea});
	
	oIdInstitutionLookUp = DBLanguages.getLookUpMap(oConn, DB.k_registrations_lookup, gu_workarea, DB.id_institution, sLanguage);
	oAcourses = new DBSubset (DB.k_academic_courses, DB.gu_acourse + "," + DB.nm_course , " bo_active<>0 ORDER BY 2", 100);
	
	sIdInstitutionLookUp = DBLanguages.getHTMLSelectLookUp (oConn, DB.k_registrations_lookup, gu_workarea, DB.id_institution, sLanguage);
	
	iAcoursesCount = oAcourses.load(oConn, new Object[0]);
	
	if (null!=gu_contact && null!=gu_oportunity) {
		bLoaded = oObj.load(oConn, new Object[]{gu_contact,gu_oportunity});
		if (bLoaded) {
			dtDate = (Date) oObj.get(DB.dt_reserve);
			if (dtDate!=null) {
				dtReserve = oSimpleDate.format(dtDate);
			}
			dtDate = (Date) oObj.get(DB.dt_registration);
			if (dtDate!=null) {
				dtRegistration = oSimpleDate.format(dtDate);
			}
			dtDate = (Date) oObj.get(DB.dt_drop);
			if (dtDate!=null) {
				dtDrop = oSimpleDate.format(dtDate);
			}
		}
		
	}
}catch (SQLException e) {  
    if (oConn!=null){
        if (!oConn.isClosed()){
        	oConn.close(PAGE_NAME);
        }
      oConn = null;
      response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=Error&desc=" + e.getLocalizedMessage() + "&resume=_close"));
	}
}
if (null==oConn){
	return;
}
oConn = null;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML LANG="<%=sLanguage.toUpperCase()%>">
<HEAD>
  <SCRIPT SRC="../javascript/cookies.js"></SCRIPT>  
  <SCRIPT SRC="../javascript/setskin.js"></SCRIPT>
  <SCRIPT SRC="../javascript/getparam.js"></SCRIPT>
  <SCRIPT SRC="../javascript/usrlang.js"></SCRIPT>
  <SCRIPT SRC="../javascript/combobox.js"></SCRIPT>  
  <SCRIPT SRC="../javascript/trim.js"></SCRIPT>
  <SCRIPT SRC="../javascript/datefuncs.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript">
    function setCombos() {
        var frm = document.forms[0];

        setCombo(frm.sel_nm_acourse,"<% out.write(oObj.getStringNull(DB.gu_acourse,"")); %>");
        setCombo(frm.sel_id_institution,"<% out.write(oObj.getStringNull(DB.id_institution,"")); %>");
        setCombo(frm.sel_id_drop_cause,"<%if (!oObj.isNull(DB.id_drop_cause)) out.write(String.valueOf(oObj.getInt(DB.id_drop_cause)));%>");

       
        return true;
    }

    function validate(){
    	var frm = window.document.forms[0];

    	frm.gu_acourse.value = nullif(getCombo(frm.sel_nm_acourse));
        frm.id_institution.value = nullif(getCombo(frm.sel_id_institution));
        frm.id_drop_cause.value = nullif(getCombo(frm.sel_id_drop_cause));
        
        
        return true;
    }
    function lookup(odctrl) {
	      var frm = document.forms[0];
	      switch(parseInt(odctrl)) {
          
          case 1:
            window.open("../common/lookup_f.jsp?nm_table=k_registrations_lookup&id_language=" + getUserLanguage() + "&id_section=id_institution&tp_control=2&nm_control=sel_id_institution&nm_coding=id_institution&id_form=0", "", "toolbar=no,directories=no,menubar=no,resizable=no,width=480,height=520");
            break;
           
	      }
    }

    function showCalendar(ctrl) {
        var dtnw = new Date();

        window.open("../common/calendar.jsp?a=" + (dtnw.getFullYear()) + "&m=" + dtnw.getMonth() + "&c=" + ctrl, "", "toolbar=no,directories=no,menubar=no,resizable=no,width=171,height=195");
      } //showcalendar
  </SCRIPT>       
  <TITLE>hipergate :: Edit Admission</TITLE>
</HEAD>
<BODY TOPMARGIN="8" MARGINHEIGHT="8" onLoad="setCombos();">
<DIV class="cxMnu1" style="width:350px"><DIV class="cxMnu2" style="width:350px">
    <SPAN class="hmMnuOff" onMouseOver="this.className='hmMnuOn'" onMouseOut="this.className='hmMnuOff'" onClick="history.back()"><IMG src="../images/images/toolmenu/historyback.gif" width="16" style="vertical-align:middle" height="16" border="0" alt="Oportunity"> Back</SPAN>
    <SPAN class="hmMnuOff" onMouseOver="this.className='hmMnuOn'" onMouseOut="this.className='hmMnuOff'" onClick="location.reload(true)"><IMG src="../images/images/toolmenu/locationreload.gif" width="16" style="vertical-align:middle" height="16" border="0" alt="Refresh"> Refresh</SPAN>
    <SPAN class="hmMnuOff" onMouseOver="this.className='hmMnuOn'" onMouseOut="this.className='hmMnuOff'" onClick="window.print()"><IMG src="../images/images/toolmenu/windowprint.gif" width="16" height="16" style="vertical-align:middle" border="0" alt="Print"> Print</SPAN>
  </DIV></DIV>
</BODY>
<br>
  <TABLE SUMMARY="Admission" WIDTH="100%">
    <TR><TD><IMG SRC="../images/images/spacer.gif" HEIGHT="4" WIDTH="1" BORDER="0"></TD></TR>
    <TR><TD CLASS="striptitle"><FONT CLASS="title1">Enrollment Data</FONT></TD></TR>
  </TABLE>
  <FORM NAME="" METHOD="post" ACTION="registration_store.jsp" onSubmit="return validate()">
    <INPUT TYPE="hidden" NAME="id_domain" VALUE="<%=id_domain%>">
    <INPUT TYPE="hidden" NAME="gu_workarea" VALUE="<%=gu_workarea%>">
    <INPUT TYPE="hidden" NAME="gu_contact" VALUE="<%=gu_contact%>">
    <INPUT TYPE="hidden" NAME="gu_oportunity" VALUE="<%=gu_oportunity%>">

    <TABLE>
    	<TR>
    		<TD>
    		<fieldset>
				<legend>Enrollment Info</legend>
        		<TABLE WIDTH="100%">
        			<TR>
            			<TD ALIGN="right" WIDTH="55" ><FONT CLASS="formplain">Academic Course</FONT></TD>            
            			<TD ALIGN="left" WIDTH="475" colspan="3">
              				<INPUT TYPE="hidden" NAME="gu_acourse">
              				<SELECT NAME="sel_nm_acourse"><OPTION VALUE=""></OPTION><%for(int i=0; i < iAcoursesCount ; i++){%>
              					<option value = "<%=oAcourses.getStringNull(0,i,"") %>"><%=oAcourses.getStringNull(1,i,"") %></option>
              				<%}%></SELECT>
    			        </TD>
          			</TR>
        			<TR>
            			<TD ALIGN="right" WIDTH="110"><FONT CLASS="formplain">Office</FONT></TD>
            			<TD ALIGN="left" WIDTH="420" colspan="3">
            				<INPUT TYPE="hidden" NAME="id_institution">
              				<SELECT NAME="sel_id_institution"><OPTION VALUE=""></OPTION><%=sIdInstitutionLookUp%></SELECT>&nbsp;
              				<A HREF="javascript:lookup(1)"><IMG SRC="../images/images/find16.gif" HEIGHT="16" BORDER="0" ALT="Institution list"></A>
            			</TD>
          			</TR>
          			<TR>
            			<TD ALIGN="right" WIDTH="55"><FONT CLASS="formplain">Date of seat reservation</FONT></TD>            
            			<TD ALIGN="left" WIDTH="210">
              				<INPUT TYPE="text" MAXLENGTH="10" SIZE="11" NAME="dt_reserve" VALUE="<% if (dtReserve!=null) out.write(dtReserve); %>">&nbsp;&nbsp;
              				<A HREF="javascript:showCalendar('dt_reserve')"><IMG SRC="../images/images/datetime16.gif" WIDTH="16" HEIGHT="16" BORDER="0" ALT="Show Calendar"></A>
    			        </TD>
    			    	<TD ALIGN="right" WIDTH="55"><FONT CLASS="formplain">Enrollment Date</FONT></TD>
            			<TD ALIGN="left" WIDTH="210">
            				<INPUT TYPE="text" MAXLENGTH="10" SIZE="11" NAME="dt_registration" VALUE="<% if (dtRegistration!=null) out.write(dtRegistration); %>">&nbsp;&nbsp;
              				<A HREF="javascript:showCalendar('dt_registration')"><IMG SRC="../images/images/datetime16.gif" WIDTH="16" HEIGHT="16" BORDER="0" ALT="Show Calendar"></A>
            			</TD>
          			</TR>
        		</table>
        	</fieldset>
        	</TD>
        </TR>
        <TR>
    		<TD>
    		<fieldset>
				<legend>Cancellation Data</legend>
        		<TABLE WIDTH="100%">
        			<TR>
          			 	<TD ALIGN="right" WIDTH="55"><FONT CLASS="formplain">Cancellation Date</FONT></TD>
            			<TD ALIGN="left" WIDTH="210" CLASS="formplain">
            				<INPUT TYPE="text" MAXLENGTH="10" SIZE="11" NAME="dt_" VALUE="<% if (dtDrop!=null) out.write(dtDrop); %>">&nbsp;&nbsp;
              				<A HREF="javascript:showCalendar('dt_drop')"><IMG SRC="../images/images/datetime16.gif" WIDTH="16" HEIGHT="16" BORDER="0" ALT="Show Calendar"></A>
            	       </TD>
          				<TD ALIGN="right" WIDTH="55"><FONT CLASS="formplain">Cancellation Reason</FONT></TD>
            			<TD ALIGN="left" WIDTH="210">
            				<SELECT NAME="sel_id_drop_cause"><OPTION VALUE=""></OPTION><OPTION VALUE="1">Volunteer</OPTION><OPTION VALUE="2">Visa</OPTION><OPTION VALUE="3">Academic</OPTION><OPTION VALUE="4">Send-off</OPTION><OPTION VALUE="5">Other</OPTION></SELECT>
              				<INPUT TYPE="hidden" NAME="id_drop_cause" VALUE="<%if (!oObj.isNull(DB.id_drop_cause)) out.write(String.valueOf(oObj.getInt(DB.id_drop_cause))); %>">
						</TD>
            		</TR>
          			
        		</table>
        	</fieldset>
        	</TD>
        </TR>			
        <TR>
    	    <TD COLSPAN="2" ALIGN="center">
              <INPUT TYPE="submit" ACCESSKEY="s" VALUE="Save" CLASS="pushbutton" STYLE="width:80" TITLE="ALT+s">&nbsp;
    	      &nbsp;&nbsp;<INPUT TYPE="reset" ACCESSKEY="c" VALUE="Clear" CLASS="closebutton" STYLE="width:80" TITLE="ALT+c">
    	      <BR><BR>
    	    </TD>
    	 </TR>    
    </TABLE>
  </FORM>
</HTML>