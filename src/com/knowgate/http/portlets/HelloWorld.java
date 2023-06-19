package com.knowgate.http.portlets;

import java.io.File;
import java.io.IOException;
import java.io.ByteArrayOutputStream;
import java.io.ByteArrayInputStream;

import java.util.Date;
import java.util.Properties;
import java.util.Enumeration;

import java.sql.SQLException;

import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerConfigurationException;

import javax.portlet.GenericPortlet;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.portlet.PortletException;
import javax.portlet.WindowState;

import com.knowgate.jdc.JDCConnection;
import com.knowgate.dataobjs.DB;
import com.knowgate.dataobjs.DBBind;
import com.knowgate.dataobjs.DBCommand;
import com.knowgate.dataxslt.StylesheetCache;
import com.knowgate.dfs.FileSystem;

/**
 * Hello World Portlet Example
 * This is a portlet designed for the home page of hipergate.
 * It displays the current user name and surname.
 * @author Sergio Montoro Ten
 */

public class HelloWorld extends GenericPortlet {

  // ---------------------------------------------------------------------------

  public HelloWorld() { }

  // ---------------------------------------------------------------------------

  public HelloWorld(HipergatePortletConfig oConfig)
    throws javax.portlet.PortletException {

    init(oConfig);
  } // HelloWorld

  // ---------------------------------------------------------------------------

  public String render(RenderRequest req, final String sEncoding)
    throws PortletException, IOException, IllegalStateException {

    String sOutput;
    ByteArrayInputStream oInStream;
    ByteArrayOutputStream oOutStream;

    FileSystem oFS = new FileSystem(FileSystem.OS_PUREJAVA);

	// ****************************************************************************
	// These are the properties passed to this portlet from desktop.jsp page

    String sDomainId   = req.getProperty("domain");
    String sWorkAreaId = req.getProperty("workarea");
    String sUserId     = req.getProperty("user");
    String sZone       = req.getProperty("zone");
    String sLang       = req.getProperty("language");
    String sStorage    = req.getProperty("storage");
    String sTemplatePath  = req.getProperty("template");
    String sCacheFilesDir = sStorage+"domains"+File.separator+
    	                    sDomainId+File.separator+"workareas"+File.separator+
        	                sWorkAreaId+File.separator+"cache"+File.separator+sUserId;
    String sCachedFile = getClass().getName() + "." + req.getWindowState().toString() + ".xhtm";

    // No more properties
	// ****************************************************************************

	// ****************************************************************************
	// Portlets are cached for reducing database accesses and improving performance

    Date oDtModified = (Date) req.getAttribute("modified");
	
    if (null!=oDtModified) {
      try {

        File oCached = new File(sCacheFilesDir+File.separator+sCachedFile);

        if (!oCached.exists())
          oFS.mkdirs(sCacheFilesDir);
        else if (oCached.lastModified()>oDtModified.getTime())
          return oFS.readfilestr("file://"+sCacheFilesDir+File.separator+sCachedFile,
                                 sEncoding==null ? "ISO8859_1" : sEncoding);
      } catch (Exception xcpt) {
        System.err.println(xcpt.getClass().getName() + " " + xcpt.getMessage());
      }
    } // fi (oDtModified)

	// ****************************************************************************

    String sXML = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><?xml-stylesheet type=\"text/xsl\"?>";
	
    if (req.getWindowState().equals(WindowState.MINIMIZED)) {
      
      // If portlet state is minimized then there is no need to do any database access
      
      sXML += "<FullName/>";
    }
    else {

      // Get database connection from desktop.jsp page

      DBBind oDBB = (DBBind) getPortletContext().getAttribute("GlobalDBBind");

      JDCConnection oCon = null;

      try  {
        oCon = oDBB.getConnection("HelloWorld");

	    String sFullName = DBCommand.queryStr(oCon, "SELECT "+DB.nm_user+",' ',"+DB.tx_surname1+" FROM "+DB.k_users+" WHERE '"+DB.gu_user+"='"+sUserId+"'");

        oCon.close("HelloWorld");
        oCon = null;

        sXML += "<FullName>"+sFullName+"</FullName>";
      }
      catch (SQLException e) {
        sXML += "<FullName/>";

        try {
          if (null != oCon)
            if (!oCon.isClosed())
              oCon.close("HelloWorld");
        } catch (SQLException ignore) { }
      }
    } // fi (WindowState)

    try {

	   // ******************************************
	   // Set input parameters for XSL StyleSheet
	   
       Properties oProps = new Properties();
       Enumeration oKeys = req.getPropertyNames();
       while (oKeys.hasMoreElements()) {
         String sKey = (String) oKeys.nextElement();
         oProps.setProperty(sKey, req.getProperty(sKey));
       } // wend

       oProps.setProperty("windowstate",
                          req.getWindowState().equals(WindowState.MINIMIZED) ?
                          "MINIMIZED" : "NORMAL");

	   // ******************************************

	   // ******************************************
	   // Perform XSLT Transformation for generating
	   // portlet XHTML code fragment.

       if (sEncoding==null)
         oInStream = new ByteArrayInputStream(sXML.getBytes());
       else
         oInStream = new ByteArrayInputStream(sXML.getBytes(sEncoding));

       oOutStream = new ByteArrayOutputStream(4000);

       StylesheetCache.transform (sTemplatePath, oInStream, oOutStream, oProps);

       if (sEncoding==null)
         sOutput = oOutStream.toString();
       else
         sOutput = oOutStream.toString("UTF-8");

       oOutStream.close();

       oInStream.close();
       oInStream = null;

	   // **************************************
	   // Cache generated XHTML code into a file

       oFS.writefilestr ("file://"+sCacheFilesDir+File.separator+sCachedFile, sOutput,
                         sEncoding==null ? "ISO8859_1" : sEncoding);
     }
     catch (Exception xcpt) {
       throw new PortletException(xcpt.getClass().getName() + " " + xcpt.getMessage(), xcpt);
     }

     return sOutput;
   } // render

   // --------------------------------------------------------------------------

   public void render(RenderRequest req, RenderResponse res)
     throws PortletException, IOException, IllegalStateException {
     res.getWriter().write(render(req,res.getCharacterEncoding()));
   } // render

} // HelloWorld
