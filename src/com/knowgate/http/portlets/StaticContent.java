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
 * Portlet that displays a static content without any database access
 * This is a portlet designed for the home page of hipergate.
 * @author Sergio Montoro Ten
 */

public class StaticContent extends GenericPortlet {

  // ---------------------------------------------------------------------------

  public StaticContent() { }

  // ---------------------------------------------------------------------------

  public StaticContent(HipergatePortletConfig oConfig)
    throws javax.portlet.PortletException {

    init(oConfig);
  } // HelloWorld

  // ---------------------------------------------------------------------------

  public String render(RenderRequest req, final String sEncoding)
    throws PortletException, IOException, IllegalStateException {

    String sOutput;
    ByteArrayInputStream oInStream;
    ByteArrayOutputStream oOutStream;

	// ****************************************************************************
	// These are the properties passed to this portlet from desktop.jsp page

    String sDomainId   = req.getProperty("domain");
    String sWorkAreaId = req.getProperty("workarea");
    String sUserId     = req.getProperty("user");
    String sZone       = req.getProperty("zone");
    String sLang       = req.getProperty("language");
    String sStorage    = req.getProperty("storage");
    String sTemplatePath  = req.getProperty("template");

    // No more properties
	// ****************************************************************************

    String sXML = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><?xml-stylesheet type=\"text/xsl\"?>";
	
    if (req.getWindowState().equals(WindowState.MINIMIZED)) {      
    	sXML += "<void>...</void>";
    } else {
    	sXML += "<void>...</void>";
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

} // StaticContent
