/*
  Copyright (C) 2008  Know Gate S.L. All rights reserved.
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
package com.knowgate.scheduler.events;

import java.io.InputStream;
import java.io.IOException;
import java.io.InputStreamReader;

import java.util.Map;
import java.util.Properties;

import bsh.Interpreter;

import com.knowgate.debug.DebugFile;
import com.knowgate.jdc.JDCConnection;
import com.knowgate.dataobjs.DBBind;
import com.knowgate.scheduler.Event;

public final class ExecuteBeanShell extends Event {

  private static final long serialVersionUID = 700l;

  // ----------------------------------------------------------
  
  public ExecuteBeanShell() { }
  
  // ----------------------------------------------------------

  public ExecuteBeanShell(DBBind oDbb) {
    super(oDbb);
  }
  
  // ----------------------------------------------------------

  /**
   * <p>Get an embedded resource file as a String</p>
   * @param sResourcePath Relative path at JAR file from com/knowgate/scheduler/events
   * @param sEncoding Character encoding for resource if it is a text file.<br>
   * If sEncoding is <b>null</b> then UTF-8 is assumed.
   * @return Readed file or <b>null</b> if no file with such name was found
   * @throws IOException
   */
  public String getResourceAsString (String sResourcePath, String sEncoding)
      throws IOException {

    if (DebugFile.trace) {
      DebugFile.writeln("Begin ExecuteBeanShell.getResourceAsString(" + sResourcePath + "," + sEncoding + ")");
      DebugFile.incIdent();
    }

    StringBuffer oXMLSource = new StringBuffer(12000);
    char[] Buffer = new char[4000];
    InputStreamReader oReader = null;
    int iReaded, iSkip;

    if (null==sEncoding) sEncoding = "UTF-8";

    InputStream oIoStrm = getClass().getResourceAsStream(sResourcePath);

	if (null==oIoStrm) return null;

    oReader = new InputStreamReader(oIoStrm, sEncoding);

	if (null==oReader) {
      if (DebugFile.trace) {
        DebugFile.writeln("Could not find file " + sResourcePath);
        DebugFile.decIdent();
      }		
	  return null;
	}
	
    while (true) {
      iReaded = oReader.read(Buffer, 0, 4000);

      if (-1==iReaded) break;

      // Skip FF FE character mark for Unidode files
      iSkip = ((int)Buffer[0]==65279 || (int)Buffer[0]==65534 ? 1 : 0);

      oXMLSource.append(Buffer, iSkip, iReaded-iSkip);
    } // wend

    oReader.close();
	oIoStrm.close();

    if (DebugFile.trace) {
      DebugFile.decIdent();
      DebugFile.writeln("End ExecuteBeanShell.getResourceAsString()");
    }

    return oXMLSource.toString();

  } // getResourceAsString

  // ----------------------------------------------------------

  public void trigger (JDCConnection oConn, Map oParameters, Properties oEnvironment) throws Exception {
	
	if (DebugFile.trace) {
	  DebugFile.writeln("Begin ExecuteBeanShell.trigger([JDCConnection], [Map], [Properties])");
	  DebugFile.incIdent();
	}

	Integer iCodError = null;
	String sScriptCode = getResourceAsString("scripts/"+getEventId()+".js", "UTF-8");

	if (null!=sScriptCode) {
      Interpreter oInterpreter = new Interpreter();

      oInterpreter.set ("ThisEvent", this);
      oInterpreter.set ("Parameters", oParameters);
      oInterpreter.set ("JDBCConnection", oConn);
      oInterpreter.set ("EnvironmentProperties", oEnvironment);

      oInterpreter.eval(sScriptCode);

      Object oErrCod = oInterpreter.get("ErrorCode");

      if (null==oErrCod) {
        log ("No return error status code found for "+getEventId());
  	  	DebugFile.decIdent();
        DebugFile.writeln("No return error status code found for "+getEventId());
    	throw new Exception("No return error status code found for "+getEventId());
      }
      
      iCodError = (Integer) oErrCod;

      if (iCodError.compareTo(new Integer (0))!=0) {
        log (getEventId()+" returned error code "+iCodError.toString());
    	DebugFile.decIdent();
        DebugFile.writeln(getEventId()+" returned error code "+iCodError.toString());
        throw new Exception(iCodError.toString()+" "+(String) oInterpreter.get("ErrorMessage"));
      }

	} else {
	  if (DebugFile.trace) DebugFile.writeln("File not found scripts/"+getEventId()+".js");
	  log ("File not found scripts/"+getEventId()+".js");
	}

	if (DebugFile.trace) {
	  DebugFile.decIdent();
      DebugFile.writeln("End ExecuteBeanShell.trigger() : "+iCodError);
    }	
  } // trigger

}
