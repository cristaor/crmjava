/*
  Copyright (C) 2011  Know Gate S.L. All rights reserved.

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

package com.knowgate.twitter;

import java.io.IOException;
import java.io.StringBufferInputStream;
import java.io.UnsupportedEncodingException;

import java.net.HttpURLConnection;
import java.net.URISyntaxException;
import java.net.MalformedURLException;

import java.util.Locale;
import java.text.ParseException;
import java.text.SimpleDateFormat;

import org.xml.sax.Attributes;
import org.xml.sax.Parser;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.InputSource;
import org.xml.sax.helpers.XMLReaderFactory;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.helpers.ParserAdapter;
import org.xml.sax.helpers.ParserFactory;

import com.knowgate.misc.Gadgets;
import com.knowgate.debug.DebugFile;
import com.knowgate.debug.StackTraceUtil;

import com.knowgate.dfs.HttpRequest;

public class Show extends DefaultHandler {

  private static SimpleDateFormat dtAt = new SimpleDateFormat("EEE MMM dd HH:mm:ss Z yyyy", Locale.US);

  private Tweet oTwt;
  private User oUsr;
  private StringBuffer oChars;
  private boolean bWrittingUser;
  
  public Show(String sId)
  	throws IOException {
 
	oTwt = new Tweet();
  	oUsr = oTwt.getUser();
  	oChars = new StringBuffer();
  	
  	bWrittingUser = false;
  	
    if (DebugFile.trace) DebugFile.writeln("Begin Show("+sId+")");
    
    HttpRequest oReq = new HttpRequest("http://api.twitter.com/1/statuses/show/"+sId+".xml");

    try {
    
	  oReq.get();
	  
      XMLReader oParser;
      Parser oSax1Parser;
    
      try {
        oParser = XMLReaderFactory.createXMLReader("org.apache.xerces.parsers.SAXParser");
      } catch (Exception e) {
        oSax1Parser = ParserFactory.makeParser("org.apache.xerces.parsers.SAXParser");
        oParser = new ParserAdapter(oSax1Parser);
      }
    
      oParser.setContentHandler(this);
    
      StringBufferInputStream oInStm = new StringBufferInputStream(oReq.src());
      InputSource oInSrc = new InputSource(oInStm);
      oParser.parse(oInSrc);
      oInStm.close();
	  
    } catch (Exception e) {
      try {
        if (DebugFile.trace) {
          if (oReq.responseCode()==HttpURLConnection.HTTP_BAD_REQUEST)
            DebugFile.writeln(Gadgets.substrBetween(oReq.src(),"<error>","</error>"));
          DebugFile.writeln(e.getClass().getName()+" "+e.getMessage()+"\n"+StackTraceUtil.getStackTrace(e));
        } // fi (trace)
      } catch (Exception ignore) {}
      throw new IOException(e.getMessage(),e);
    }
    if (DebugFile.trace) DebugFile.writeln("End Show()");  	
  }

  public Show(long lId)
  	throws IOException,URISyntaxException,MalformedURLException,UnsupportedEncodingException {  	
  	this(String.valueOf(lId));
  }
  
  public void startElement(String uri, String local, String raw, Attributes attrs) throws SAXException {		
    if (local.equals("user")) {
      bWrittingUser = true;
    } else {
      oChars.setLength(0);
    }
  } // startElement

  public void characters(char[] ch, int start, int length) throws SAXException {
    oChars.append(ch, start, length);
  }
                	
  public void endElement(String uri, String local, String name) throws SAXException {
    if (bWrittingUser) {
   	  oUsr.put(local, oChars.toString());
    } else {
      if (local.equals("created_at")) {
		try {
		  oTwt.put(local, dtAt.parse(oChars.toString()));
		} catch (ParseException pex) {
		  throw new SAXException(pex.getMessage(), pex);
		}
      } else {
      	oTwt.put(local, oChars.toString());
      }
    }
    if (local.equals("user")) {
      bWrittingUser = false;
    }
  }

  public Tweet getTweet() {
  	return oTwt;
  }

  public User getUser() {
  	return oUsr;
  }
}
