<%@ page import="java.net.URL,java.io.ByteArrayOutputStream,java.io.File,java.util.Date,java.util.Properties,java.util.HashSet,java.sql.PreparedStatement,java.sql.ResultSet,java.sql.SQLException,javax.activation.DataHandler,javax.mail.*,javax.mail.internet.InternetAddress,javax.mail.internet.AddressException,javax.mail.internet.MimeMessage,javax.mail.internet.MimeBodyPart,com.knowgate.acl.ACL,com.knowgate.acl.ACLUser,com.knowgate.jdc.JDCConnection,com.knowgate.dataobjs.*,com.knowgate.misc.Gadgets,com.knowgate.hipermail.MailAccount,com.knowgate.hipermail.DBStore,com.knowgate.hipermail.DBFolder,com.knowgate.hipermail.SessionHandler,com.knowgate.hipermail.DBMimeMessage,com.knowgate.hipermail.DBMimePart,com.knowgate.hipermail.DBMimeMultipart,com.knowgate.hipermail.HeadersHelper,com.knowgate.hipermail.SendMail,com.knowgate.crm.Contact,com.knowgate.crm.Attachment,com.knowgate.crm.SalesMan,com.knowgate.dfs.FileSystem,com.knowgate.debug.DebugFile,com.knowgate.debug.StackTraceUtil" language="java" session="false" contentType="text/html;charset=UTF-8" %><%@ include file="../methods/dbbind.jsp" %><%@ include file="../methods/cookies.jspf" %><%@ include file="../methods/authusrs.jspf" %><%@ include file="../methods/nullif.jspf" %>
<HTML>
  <HEAD>
  	<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
  	<TITLE>Carga de ficheros adjuntos</TITLE>
    <STYLE type="text/css">
      body { font-family:Arial,helvetica,sans-serif;font-size:9pt; }
    </STYLE>
  </HEAD>
  <BODY><%

  out.write("Iniciando proceso de carga.<BR>\n"); out.flush();
  
  final String PAGE_NAME = "attachments_import";

  final String GU_FSE = "ac1263a412bc4fcb51e100016bcb56bf";
  final String GU_ALUMNI = "ac1263a412786d4bd9a10401aa995d3a";
  final String GU_ADMISIONES = "ac1263a41237f7076a3100003c8939ba";
  final String GU_INCOMPANY = "ac1263a412f92d8eedf101d98f58a6df";

  final String nm_domain = "TEST";
  final String gu_workarea = "c0a8010b135051cc02a100000d6a0bce";
  final String id_user = "c0a8010b135051cc091100001d27a1f6";
  final String tx_pwd = "TEST";
  final String authstr = ACL.encript(tx_pwd, ENCRYPT_ALGORITHM);
  final String gu_account = "c0a8010b135967f6717100033c3976a6";
  final int id_domain = 2049;
  String sReceivedGuid = null;
  String sMovedIds = "";
  String sMovedNum = "";
  String sMsgId;

  final String sTempDir = GlobalDBBind.getPropertyPath ("temp");
  final String sWebSrvr = Gadgets.chomp(GlobalDBBind.getProperty("webserver"),"/");

	Contact oCont;

  FileSystem oFs = new FileSystem();
  File oUpload = new File (sTempDir+"upload");
  if (!oUpload.exists()) oUpload.mkdir();

  JDCConnection oConn = null;
  PreparedStatement oStmt = null;
  ResultSet oRSet = null;
  Date dtNow = new Date();

  final String sMBoxDir = DBStore.MBoxDirectory(GlobalDBBind.getProfileName(),id_domain,gu_workarea);

  ACLUser oMe = null;
  MailAccount oMacc = null;
  Properties oHeaders;

  JDCConnection oMailEnvConn = null;
  try {
    oMailEnvConn = GlobalDBBind.getConnection("msg_env");
    oMe = new ACLUser(oMailEnvConn, id_user);
	  out.write("Cargando datos de la cuenta de correo "+gu_account+".<BR>\n"); out.flush();
    oMacc = new MailAccount(oMailEnvConn, gu_account);
    sReceivedGuid = oMe.getMailFolder (oMailEnvConn, "received");
    oMailEnvConn.close("msg_env");
    oMailEnvConn=null;
  }
  catch (Exception e) {  
    if (oMailEnvConn!=null) { try { if (!oMailEnvConn.isClosed()) oMailEnvConn.close("msg_env"); } catch (Exception ignore) {} }
  }

  if (null==oMacc) {
	  out.write("No se pudo cargar la cuenta de correo "+gu_account+".<BR>\n"); out.flush();
    return;
  }
  
	out.write("Iniciando exploración del buzon.<BR>\n"); out.flush();
  
  SessionHandler oHndl = new SessionHandler(oMacc, sMBoxDir);
  DBStore oRDBMS = null;
  DBFolder oInbox = null;
  DBMimeMessage oMsg = null;
  
  oRDBMS = new DBStore(oHndl.getSession(), new URLName("jdbc://", GlobalDBBind.getProfileName(), -1, sMBoxDir, id_user, tx_pwd));

  oRDBMS.connect();
  
  oInbox = (DBFolder) oRDBMS.getFolder("inbox");

  out.write("Abriendo carpeta inbox.<BR>\n"); out.flush();

  oInbox.open(Folder.READ_ONLY|DBFolder.MODE_MBOX);

  out.write("Carpeta inbox abierta sobre el fichero "+oInbox.getFile()+".<BR>\n"); out.flush();
  
  out.write("Obteniendo cabeceras de los mensajes.<BR>\n"); out.flush();
  
  HeadersHelper[] aHdrs = oHndl.listFolderMessagesHeaders("inbox");
  
  final int nMsgs = aHdrs.length;

  out.write(String.valueOf(nMsgs)+" mensajes encontrados.<BR>\n"); out.flush();
    
  for (int m=0; m<nMsgs; m++) {

	  sMsgId = aHdrs[m].getMessageID();

    out.write("Obteniendo cabeceras de "+sMsgId+".<BR>\n"); out.flush();

    oHeaders = oInbox.getMessageHeaders (sMsgId);

    if (null==oHeaders) {
      out.write("Cabeceras no encontradas en el cache local.<BR>\n"); out.flush();
      oMsg = oRDBMS.preFetchMessage(oHndl.getFolder("INBOX"), m+1);
      oHeaders = oInbox.getMessageHeaders (sMsgId);
      oMsg = new DBMimeMessage(oInbox, oHeaders.getProperty(DB.gu_mimemsg));      
    } else {
      out.write("Cabeceras encontradas en el cache local.<BR>\n"); out.flush();
      oMsg = new DBMimeMessage(oInbox, oHeaders.getProperty(DB.gu_mimemsg));      
    } // fi (oHeaders)
    
    oMsg.setHeader("Message-ID", sMsgId);

	  String sTxSubject = oMsg.getSubject();
	  InternetAddress oFrom = (InternetAddress) aHdrs[m].getFrom();
		out.write("Procesando "+sTxSubject+" "+sMsgId+" de ");
		if (null==oFrom)
		  out.write("null");
	  else
		  out.write(oFrom.getAddress());		
		out.write("<BR>"); out.flush();

    oConn = GlobalDBBind.getConnection(PAGE_NAME,true);
    oStmt = oConn.prepareStatement("SELECT gu_contact FROM k_member_address WHERE tx_email=? AND gu_workarea=? AND gu_contact IS NOT NULL");
		oStmt.setString(1, oFrom.getAddress());
		oStmt.setString(2, gu_workarea);
		oRSet = oStmt.executeQuery();
	  if (oRSet.next()) {
	    oCont = new Contact(oConn, oRSet.getString(1));
	  } else {
	    oCont = null;
	  }
		oRSet.close();
    oStmt.close();
    oConn.close(PAGE_NAME);

		out.write("Obtenido GUID del contacto "+oCont.getStringNull("gu_contact","null")+"<BR>"); out.flush();
				
		if (null!=oCont) {

      DBMimeMultipart oParts = (DBMimeMultipart) oMsg.getParts();

		  out.write("Obtenidas partes del mensaje "+oMsg.getMessageID()+"<BR>"); out.flush();

	    if (oParts!=null) {

		    out.write("Cacheando adjuntos previamente cargados<BR>"); out.flush();

	      HashSet<String> oAttchs = new HashSet<String>();
    		oConn = GlobalDBBind.getConnection(PAGE_NAME,true);
			  oStmt = oConn.prepareStatement("SELECT p.nm_product,p.tag_product FROM k_products p INNER JOIN k_contact_attachs a ON p.gu_product=a.gu_product WHERE a.gu_contact=?");
			  oStmt.setString(1, oCont.getString("gu_contact"));
				oRSet = oStmt.executeQuery();
			  while (oRSet.next())
			    oAttchs.add(oRSet.getString(1)+"."+oRSet.getString(2));
			  oRSet.close();
			  oStmt.close();
    		oConn.close(PAGE_NAME);

	      int nAttachments = 0;

		    out.write("Obteniendo cuerpo del mensaje<BR>"); out.flush();

	      StringBuffer oBuffer = new StringBuffer();
	      try {
	        oMsg.getTextPlain (oBuffer);
        } catch (Exception e) {
		      out.write(e.getClass().getName()+" obteniendo cuerpo del mensaje "+e.getMessage()+"<BR>"); out.flush();
					out.write(Gadgets.replace(StackTraceUtil.getStackTrace(e),"\n","<BR>"));
        }

	      int nParts =	oParts.getCount();
		    out.write(String.valueOf(nParts)+" adjuntos encontrados<BR>"); out.flush();

	      for (int p=0; p<nParts; p++) {			  
          DBMimePart oPart = (DBMimePart) oParts.getBodyPart(p);
          String sContentId = nullif(oPart.getContentType()).toUpperCase();
          String sDisposition = nullif(oPart.getDisposition(),"inline");
          if (!sDisposition.equalsIgnoreCase("inline") ||
             (!sContentId.startsWith("TEXT/PLAIN") && !sContentId.startsWith("TEXT/HTML") && !sContentId.startsWith("MULTIPART/ALTERNATIVE"))) {
            
            if (sContentId.startsWith("MESSAGE/DELIVERY-STATUS")) {
              out.write("<A HREF=\"msg_part.jsp?folder=inbox&msgid="+Gadgets.URLEncode(sMsgId)+"&part="+String.valueOf(p+1)+"\">"+nullif(oPart.getDescription(),"Delivery error report")+"</A>&nbsp;"); out.flush();
            } else if (sContentId.startsWith("TEXT/RFC822-HEADERS")) {
              out.write("<A HREF=\"msg_part.jsp?folder=inbox&msgid="+Gadgets.URLEncode(sMsgId)+"&part="+String.valueOf(p+1)+"\">"+nullif(oPart.getDescription(),"Undelivered-message headers")+"</A>&nbsp;"); out.flush();
            } else {
              String sFile = oPart.getFileName();
              if (null==sFile)
                sFile = "attachment"+String.valueOf(p+1);    
              if (oAttchs.contains(sFile+"."+sMsgId)) {
                out.write("El adjunto "+sFile+" ya habia sido cargado anteriormente para el mensaje "+sMsgId);
              } else {
              	oAttchs.add(sFile+"."+sMsgId);
                out.write("("+sDisposition+") "+sContentId+" <A CLASS=\"linkplain\" HREF=\"msg_part.jsp?part="+String.valueOf(p+1)+"&folder=inbox&msgid="+Gadgets.URLEncode(sMsgId)+"\">" + sFile + "</A>&nbsp;"); out.flush();
  						  oFs.writefilebin (sTempDir+"upload"+File.separator+sFile, oFs.readfilebin(sWebSrvr+"hipermail/msg_part.jsp?domainnm="+nm_domain+"&workarea="+gu_workarea+"&userid="+id_user+"&authstr="+authstr+"&part="+String.valueOf(p+1)+"&folder=inbox&msgid="+Gadgets.URLEncode(sMsgId)));

    					  oConn = GlobalDBBind.getConnection(PAGE_NAME);
  						  oConn.setAutoCommit(false);  						
                out.write("Adjuntando "+sTempDir+"upload"+File.separator+sFile+"<BR>");
  						  Attachment oAttch = oCont.addAttachment(oConn, id_user, sTempDir+"upload", sFile, oBuffer.substring(0,Math.min(oBuffer.length(), 254)), true);
							  oStmt = oConn.prepareStatement("UPDATE k_products SET tag_product=? WHERE gu_product=?");
							  oStmt.setString(1, sMsgId);
							  oStmt.setString(2, oAttch.getString("gu_product"));
						    oStmt.executeUpdate();
						    oStmt.close();
							  oConn.commit();
    					  oConn.close(PAGE_NAME);
							
                nAttachments++;
              }
            }
            if (p<nParts-1) out.write("&nbsp;&nbsp;&nbsp;&nbsp;"); out.flush();
		       } // fi
		     } // next (part)
		     if (nAttachments>0) {
		       sMovedIds += (sMovedIds.length()>0 ? "," : "") + sMsgId;
 					 sMovedNum += (sMovedNum.length()>0 ? "," : "") + String.valueOf(m+1);
					 SendMail.send(oHndl.getProperties(), "Gracias por...", "Confirmacion de recepcion de adjuntos", oMe.getString(DB.tx_main_email), "Attachments", "noreply@hipergate.org", new String[]{oFrom.getAddress()});
					 SalesMan oSlsm = oCont.getSalesMan(oConn);
					 if (null!=oSlsm) {
					   String sTxSalesManEmail = oSlsm.getUser().getString(DB.tx_main_email);
					   sTxSalesManEmail = "sergiom@knowgate.com";
					   SendMail.send(oHndl.getProperties(),
					                 "Se han recibido "+String.valueOf(nAttachments)+" nuevos adjuntos de "+oCont.getStringNull(DB.tx_name,"")+" "+oCont.getStringNull(DB.tx_surname,"")+" <"+oFrom.getAddress()+"> que han sido adjuntados a su ficha de contacto en el CRM",
					                 "Nuevos adjuntos recibidos de "+oCont.getStringNull(DB.tx_name,"")+" "+oCont.getStringNull(DB.tx_surname,""), oMe.getString(DB.tx_main_email), "Attachments", "noreply@hipergate.org", new String[]{sTxSalesManEmail});
					 }
				 }
		    out.write("<HR>"); out.flush();
		  } else {
		    SendMail.send(oHndl.getProperties(), "Hemos recibido un correo electronico tuyo, desafortunadamente no hemos podido extraer automáticamente sus archivos adjuntos, por favor re-envíalos a...",
		  						    "Recepcion de adjuntos fallida", oMe.getString(DB.tx_main_email), "Attachments", "noreply@hipergate.org", new String[]{oFrom.getAddress()});
	      out.write("El mensaje no contiene adjuntos<BR><HR>"); out.flush();	
		  }
		} else {
		  SendMail.send(oHndl.getProperties(), "Hemos recibido un correo electronico tuyo con archivos adjuntos, desafortunadamente tu dirección de e-mail no figura en nuestra base de datos y por consiguiente no podemos procesar automáticamente dichos archivos, por favor re-envíalos a...",
		  						  "Recepcion de adjuntos fallida", oMe.getString(DB.tx_main_email), "Attachments", "noreply@hipergate.org", new String[]{oFrom.getAddress()});
	    out.write("La direccion de email del remitente no existe en la BB.DD.<BR><HR>"); out.flush();	
		}
  } //next
  
  oInbox.close(false);
  
  if (sMovedIds.length()>0) {

    String[] aMsgNums = Gadgets.split(sMovedNum,',');
    String[] aMsgIds = Gadgets.split(sMovedIds,',');
    final int nMsgIds = aMsgIds.length;

    DBFolder oLocalFldr = oRDBMS.openDBFolder("inbox", Folder.READ_WRITE|DBFolder.MODE_MBOX);
    DBFolder oTargetFldr = oRDBMS.openDBFolder(sReceivedGuid, Folder.READ_WRITE|DBFolder.MODE_MBOX);

    oInbox.open(Folder.READ_WRITE);
    
    final int nInboxMsgsCount = oInbox.getMessageCount();
          
	  for (int m=0; m<nMsgIds; m++) {
  		out.write("Moviendo mensaje "+aMsgIds[m]+" a la carpeta de recibidos.<BR>"); out.flush();

      oTargetFldr.moveMessage(oMsg);

  		out.write("Buscando mensaje "+aMsgIds[m]+" en el servidor de correo.<BR>"); out.flush();
      
      sMsgId = aMsgIds[m];
      int iMsgNum = Integer.parseInt(aMsgNums[m]);
      MimeMessage oServerMsg = null;
      
	    try {
	      oServerMsg = (MimeMessage) oInbox.getMessage(iMsgNum);
	      if (sMsgId.equals(oServerMsg.getMessageID())) {
	        for (int c=1; c<=nInboxMsgsCount; c++) {
	          oServerMsg = (MimeMessage) oInbox.getMessage(c);
	          if (oServerMsg!=null)
	            if (sMsgId.equals(oServerMsg.getMessageID())) break; else oServerMsg = null;
	        } // next
	      }
	    } catch (ArrayIndexOutOfBoundsException aiob) {
	      for (int c=1; c<=nInboxMsgsCount; c++) {
	        oServerMsg = (MimeMessage) oInbox.getMessage(c);
	        if (oServerMsg!=null)
	          if (sMsgId.equals(oServerMsg.getMessageID())) break; else oServerMsg = null;
	      } // next	    
	    }

			if (null!=oServerMsg) {
  		  out.write("Borrando mensaje "+aMsgIds[m]+" del servidor de correo.<BR>"); out.flush();
	      oServerMsg.setFlag(Flags.Flag.DELETED, true);
			} else {
  		  out.write("Mensaje "+aMsgIds[m]+" no encontrado en el servidor de correo.<BR>"); out.flush();
			}

	  } // next (m)

    final String sInboxCachePath = oLocalFldr.getDirectoryPath()+oMacc.getString(DB.gu_account)+".inbox.cache";
    
	  oInbox.close(true);
    oTargetFldr.close(false);
    oTargetFldr=null;
    oLocalFldr.close(true);
    oLocalFldr=null;
    oRDBMS.close();
    oHndl.close();

    // ****************************************
    // Remove deleted messages from inbox cache

    File oCache = new File(sInboxCachePath);

	  if (oCache.exists()) {
      final String sCache = oFs.readfilestr(sInboxCachePath, "UTF-8");
      oCache.delete();
      if (sCache.length()>0) {
        StringBuffer oMsgsXML = new StringBuffer(sCache.length());
        String[] aPopServerMsgsXML = Gadgets.split(sCache,'\n');
        int nPopServerMsgsXML = aPopServerMsgsXML.length;
        boolean bFirstLine = true;
        int nRemoved = 0;
        for (int l=0; l<nPopServerMsgsXML; l++) {
          boolean bMatch = false;
          for (int m=0; m<nMsgIds && !bMatch; m++) {
            bMatch = (aPopServerMsgsXML[l].indexOf("<id><![CDATA["+aMsgIds[m].replace('\n',' ')+"]]></id>")>=0);
          } // next
          if (!bMatch) {
            if (!bFirstLine) oMsgsXML.append("\n");
            oMsgsXML.append(aPopServerMsgsXML[l]);
            bFirstLine=false;
            nRemoved++;
          } // fi
        } //next
        oFs.writefilestr(sInboxCachePath, oMsgsXML.toString(), "UTF-8");
        if (DebugFile.trace) DebugFile.writeln(String.valueOf(nRemoved)+" messages removed. Cache file after update is\n"+oMsgsXML.toString());
      }
    } // fi

  }

  out.write("Proceso finalizado.<BR></BODY></HTML>"); out.flush();
%>