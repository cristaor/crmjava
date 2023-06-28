<%@ page import="java.sql.SQLException,com.knowgate.dataobjs.DB,com.knowgate.jdc.JDCConnection,com.knowgate.acl.ACL,com.knowgate.acl.ACLUser,com.knowgate.workareas.WorkArea" language="java" session="false" contentType="text/html;charset=UTF-8" %>
<%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/nullif.jspf" %><%

  final int WebBuilder = 14;
  final int Hipermail = 21;
  final int CollaborativeTools = 17;
  final int MarketingTools = 18;
  
  int iAppMask = Integer.parseInt(String.valueOf((1<<WebBuilder)+(1<<Hipermail)));

  final String EMAIL = nullif(request.getParameter("tx_main_email"), "administrator@hipergate-test.com" );
                                                                  // "anonimopromocion@eoi.es"

  JDCConnection oConn = null;
  ACLUser oUser = new ACLUser();
  WorkArea oWrkA = new WorkArea();

  try {

    oConn = GlobalDBBind.getConnection("autologin"); 

    String sGuUser = ACLUser.getIdFromEmail(oConn, EMAIL);
    
    if (null==sGuUser) throw new SQLException("User "+EMAIL+" not found at k_users table");

		oUser.load(oConn, new Object[]{sGuUser});

	  if (!oUser.isNull(DB.gu_workarea)) {
	    oWrkA.load(oConn, new Object[]{oUser.getString(DB.gu_workarea)});
	    // iAppMask = WorkArea.getUserAppMask(oConn, oUser.getString(DB.gu_workarea), oUser.getString(DB.gu_user));
    }
    
    oConn.close("autologin");

  } catch (Exception xcpt) {
    if (null!=oConn) oConn.close("autologin");
    response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title="+xcpt.getClass().getName()+"&desc=" + xcpt.getMessage() + "&resume=_back"));
    return;
  }
%>
<HTML>
<HEAD><TITLE>hipergate :: Autologin and Redirect</TITLE>
<SCRIPT TYPE="text/javascript" SRC="../javascript/cookies.js"></SCRIPT>
<SCRIPT TYPE="text/javascript">
  <!--
  function redir() {
    var dtInf = new Date(2020, 11, 30, 0, 0, 0, 0);
                      
    setCookie ("profilenm","<%=GlobalDBBind.getProfileName()%>",dtInf);

		// Values from k_domains table
    setCookie ("domainid","<%=String.valueOf(oUser.getInt(DB.id_domain))%>",dtInf);
    setCookie ("domainnm","UNKNOWN",dtInf);

		// Values from k_users table
    setCookie ("userid","<%=oUser.getString(DB.gu_user)%>");
    setCookie ("authstr","<%=ACL.encript(oUser.getString(DB.tx_pwd),ENCRYPT_ALGORITHM)%>");
    setCookie ("workarea","<%=oUser.getStringNull(DB.gu_workarea,"ac1263a41235762fe5b1000c49e09610")%>");
    setCookie ("workareanm","<%=oWrkA.getStringNull(DB.nm_workarea,"unknown")%>");
    
    // This value leave it always to C
    setCookie ("idaccount","C"); 
    
    // Set one bit of app mask for each application according to the
    // value of id_app column at k_apps table, for enabling all the
    // applications set appmask to 2147483647
    setCookie ("appmask","<%=String.valueOf(iAppMask)%>");
		
    setCookie ("skin","xp",dtInf);
    setCookie ("face","<%=GlobalDBBind.getProperty("face","crm")%>",dtInf);

  	document.location = "newsletters.jsp";
  }
  //-->
</SCRIPT>
</HEAD>
<BODY onload="redir()"></BODY>
</HTML>


















