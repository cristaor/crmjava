/*
  Copyright (C) 2010  Know Gate S.L. All rights reserved.

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

package com.knowgate.dataxslt;

import java.io.IOException;
import java.io.StringReader;
import java.io.ByteArrayOutputStream;
import java.io.StringBufferInputStream;

import java.nio.charset.Charset;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.sax.SAXResult;

import org.w3c.tidy.Tidy;
import org.w3c.dom.Document;

/*
import org.apache.fop.apps.Fop;
import org.apache.fop.apps.FopFactory;
import org.apache.fop.apps.FOPException;
import org.apache.fop.apps.MimeConstants;
*/

/**
 * Convert HTML document to PDF using Apache FOP
 */
 
public class Html2Pdf {

  /**
   * <p>Transform XHTML to PDF</p>
   * Input XHTML is converted to XSL:FO using a stylesheet from Antenna House
   * @param sXHTML String containing XHTML source to be converted to PDF
   * @return ByteArrayOutputStream with generated PDF document
   * @throws IOException
   * @throws FOPException
   * @throws TransformerException
   * @throws TransformerConfigurationException
   */
  
	/*
  public ByteArrayOutputStream transformXHTML(String sXHTML)
  	throws IOException,FOPException,TransformerException,TransformerConfigurationException {
  	ByteArrayOutputStream oPdf = new ByteArrayOutputStream();

  	String sFO = StylesheetCache.transform (getClass().getResourceAsStream("xhtml2fo.xsl"), sXHTML, null);

	System.out.print(sFO);

  	StreamSource oSrc = new StreamSource(new StringReader(sFO));

    SAXResult oRes = new SAXResult(FopFactory.newInstance().newFop(MimeConstants.MIME_PDF, oPdf).getDefaultHandler());

    TransformerFactory.newInstance().newTransformer().transform(oSrc, oRes);

	return oPdf;  	
  }
  */

  /**
   * Transform HTML to PDF
   * @param sHTML String containing HTML source to be converted to PDF
   * @return ByteArrayOutputStream with generated PDF document
   * @throws IOException
   * @throws FOPException
   * @throws TransformerException
   * @throws TransformerConfigurationException
   */

  /*
  public ByteArrayOutputStream transformHTML(String sHTML)
  	throws IOException,FOPException,TransformerException,TransformerConfigurationException {
    ByteArrayOutputStream oXml = new ByteArrayOutputStream();
    StringBufferInputStream oHtm = new StringBufferInputStream(sHTML);
    Tidy oTdy = new Tidy();
    oTdy.setXmlOut(true);
    oTdy.setTidyMark(false); 
    oTdy.setNumEntities(true); 
	oTdy.parseDOM(oHtm, oXml);
	return transformXHTML(oXml.toString(Charset.defaultCharset().name()));
  }
  */
  
}
