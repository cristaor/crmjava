/*
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

package com.knowgate.http.portlets;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.File;

import java.sql.SQLException;

import java.util.Date;
import java.util.Enumeration;
import java.util.Properties;

import javax.mail.AuthenticationFailedException;
import javax.mail.NoSuchProviderException;
import javax.mail.MessagingException;

import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerConfigurationException;

import javax.portlet.*;

import com.knowgate.debug.DebugFile;
import com.knowgate.jdc.JDCConnection;
import com.knowgate.hipermail.MailAccount;
import com.knowgate.hipermail.SessionHandler;
import com.knowgate.dataobjs.*;
import com.knowgate.dataxslt.StylesheetCache;
import com.knowgate.dfs.FileSystem;

public class NewMail extends GenericPortlet {

  public NewMail() { }

  public NewMail(HipergatePortletConfig oConfig)
    throws PortletException {

    init(oConfig);
  }

  // ---------------------------------------------------------------------------

  @SuppressWarnings("unused")
public String render(RenderRequest req, String sEncoding)
    throws PortletException, IOException, IllegalStateException {

     if (DebugFile.trace) {
       DebugFile.writeln("Begin NewMail.render([RenderRequest], "+sEncoding+")");
       DebugFile.incIdent();
     }

    final int iMaxNew = 8;              // Show a limited number of most recent messages
    final long lRefreshEvery = 60000l;  // 1 minute

    ByteArrayInputStream oInStream;
    ByteArrayOutputStream oOutStream;

    FileSystem oFS = new FileSystem(FileSystem.OS_PUREJAVA);
 
    String sOutput;
    String sDomainId = req.getProperty("domain");
    String sWorkAreaId = req.getProperty("workarea");
    String sUserId = req.getProperty("user");
    String sMailAccount = req.getProperty("account");
    String sZone = req.getProperty("zone");
    String sLang = req.getProperty("language");
    String sTemplatePath = req.getProperty("template");
    String sStorage = req.getProperty("storage");
    String sFileDir = "file://" + sStorage + "domains" + File.separator + sDomainId + File.separator + "workareas" + File.separator + sWorkAreaId + File.separator + "cache" + File.separator + sUserId;
    String sCachedFile = "newmails_" + req.getWindowState().toString() + ".xhtm";

    boolean bFetch;

    File oCached = new File(sFileDir.substring(7)+File.separator+sCachedFile);

    if (!oCached.exists()) {
      bFetch = true;
      try {
      	oFS.mkdirs(sFileDir);
      } catch (Exception xcpt) {
        throw new PortletException(xcpt.getMessage(), xcpt);
      } 
    } else {
      bFetch = (new Date().getTime()-oCached.lastModified()>lRefreshEvery);
    }
      
	if (bFetch) {

      String sXML = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><?xml-stylesheet type=\"text/xsl\"?>\n<folder account=\""+(null==sMailAccount ? "" : sMailAccount)+"\" name=\"inbox\">";
    
      if (req.getWindowState().equals(WindowState.MINIMIZED) || null==sMailAccount) {
        sXML += "<messages total=\"0\" skip=\"0\"/></folder>";
      } else {
        JDCConnection oCon = null;
        try {
	      
	      SessionHandler oHnr;

          DBBind oDBB = (DBBind) getPortletContext().getAttribute("GlobalDBBind");
	      
	      oCon = oDBB.getConnection("NewMail");
	      
	      MailAccount oMacc = new MailAccount(oCon, sMailAccount);
	      
	      if (oMacc.load(oCon, sMailAccount))
	        oHnr = new SessionHandler(oMacc);
		  else
		  	oHnr = null;

		  oCon.close("NewMail");
		  oCon=null;
		  
		  if (null!=oHnr) {
		    String[] aRecentXML = oHnr.listRecentMessages("INBOX", iMaxNew);
	        if (null!=aRecentXML) {
		      int nRecentXML = aRecentXML.length;
		      sXML += "<messages total=\""+String.valueOf(nRecentXML)+"\" skip=\"0\">";
		      for (int r=0; r<nRecentXML; r++)
	      	    sXML += aRecentXML[r];
	          sXML += "</messages>";
	        } else {
	          sXML += "<messages total=\"0\" skip=\"0\"/>";
	        }// fi
		  } else {
     		if (DebugFile.trace) {
       		  DebugFile.writeln("Mail Account "+sMailAccount+" not found");
     		}
		      sXML += "<messages total=\"0\" skip=\"0\" />";
		  }
        } catch (SQLException sqle) {
          if (oCon!=null) { try { oCon.close("NewMail"); oCon=null; } catch (SQLException ignore) {} }
          throw new PortletException(sqle.getMessage(), sqle);
        } catch (AuthenticationFailedException afe) {
          if (oCon!=null) { try { oCon.close("NewMail"); oCon=null; } catch (SQLException ignore) {} }
          throw new PortletException(afe.getMessage(), afe);
        } catch (NoSuchProviderException nspe) {
          if (oCon!=null) { try { oCon.close("NewMail"); oCon=null; } catch (SQLException ignore) {} }
          throw new PortletException(nspe.getMessage(), nspe);
        } catch (MessagingException jmme) {
          if (oCon!=null) { try { oCon.close("NewMail"); oCon=null; } catch (SQLException ignore) {} }
          throw new PortletException(jmme.getMessage(), jmme);
        }
        sXML += "</folder>";
      } // fi

	  DebugFile.writeln(sXML);

      try {
       if (DebugFile.trace) DebugFile.writeln("new ByteArrayInputStream(" + String.valueOf(sXML.length()) + ")");

       if (sEncoding==null)
         oInStream = new ByteArrayInputStream(sXML.getBytes());
       else
         oInStream = new ByteArrayInputStream(sXML.getBytes(sEncoding));

       oOutStream = new ByteArrayOutputStream(4000);

       Properties oProps = new Properties();

       Enumeration oKeys = req.getPropertyNames();
       while (oKeys.hasMoreElements()) {
         String sKey = (String) oKeys.nextElement();
         oProps.setProperty(sKey, req.getProperty(sKey));
       } // wend

       if (req.getWindowState().equals(WindowState.MINIMIZED))
         oProps.setProperty("windowstate", "MINIMIZED");
       else
         oProps.setProperty("windowstate", "NORMAL");

       StylesheetCache.transform (sTemplatePath, oInStream, oOutStream, oProps);

       if (sEncoding==null)
         sOutput = oOutStream.toString();
       else
         sOutput = oOutStream.toString("UTF-8");

       oOutStream.close();

       oInStream.close();
       oInStream = null;

       oFS.writefilestr (sFileDir+File.separator+sCachedFile, sOutput, sEncoding==null ? "ISO8859_1" : sEncoding);
      }
      catch (TransformerConfigurationException tce) {
       if (DebugFile.trace) {
         DebugFile.writeln("TransformerConfigurationException " + tce.getMessageAndLocation());
         try {
           DebugFile.write("--------------------------------------------------------------------------------\n");
           DebugFile.write(FileSystem.readfile(sTemplatePath));
           DebugFile.write("\n--------------------------------------------------------------------------------\n");
           DebugFile.write(sXML);
           DebugFile.write("\n--------------------------------------------------------------------------------\n");
         }
         catch (java.io.IOException ignore) { }
         catch (com.enterprisedt.net.ftp.FTPException ignore) { }

         DebugFile.decIdent();
       }
       throw new PortletException("TransformerConfigurationException " + tce.getMessage(), tce);
      }
      catch (TransformerException tex) {
       if (DebugFile.trace) {
         DebugFile.writeln("TransformerException " + tex.getMessageAndLocation());

         try {
           DebugFile.write("--------------------------------------------------------------------------------\n");
           DebugFile.write(FileSystem.readfile(sTemplatePath));
           DebugFile.write("\n--------------------------------------------------------------------------------\n");
           DebugFile.write(sXML);
           DebugFile.write("\n--------------------------------------------------------------------------------\n");
         }
         catch (java.io.IOException ignore) { }
         catch (com.enterprisedt.net.ftp.FTPException ignore) { }

         DebugFile.decIdent();
       }
       throw new PortletException("TransformerException " + tex.getMessage(), tex);
      }
	} else {
      try {
      	sOutput = new String(oFS.readfile(sFileDir+File.separator+sCachedFile, sEncoding==null ? "ISO8859_1" : sEncoding));
      } catch (Exception xcpt) {
      	throw new PortletException(xcpt.getClass().getName()+" "+xcpt.getMessage(), xcpt);
      }
	} // fi (bFetch)
	
     if (DebugFile.trace) {
       DebugFile.decIdent();
       DebugFile.writeln("End NewMail.render()");
     }

     return sOutput;     
  } // render	

   // --------------------------------------------------------------------------

   public void render(RenderRequest req, RenderResponse res)
     throws PortletException, IOException, IllegalStateException {

     if (DebugFile.trace) {
       DebugFile.writeln("Begin NewMail.render([RenderRequest], [RenderResponse])");
       DebugFile.incIdent();
     }

     res.getWriter().write(render(req,res.getCharacterEncoding()));

     if (DebugFile.trace) {
       DebugFile.decIdent();
       DebugFile.writeln("End NewMail.render()");
     }
   } //render

}
