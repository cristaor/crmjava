/*
  Copyright (C) 2012  Know Gate S.L. All rights reserved.

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

package com.knowgate.scheduler;

import static java.util.concurrent.TimeUnit.SECONDS;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

import java.sql.SQLException;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Properties;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.ScheduledExecutorService;

import com.knowgate.jdc.JDCConnection;
import com.knowgate.scheduler.Event;
import com.knowgate.dataobjs.DB;
import com.knowgate.dataobjs.DBBind;
import com.knowgate.dataobjs.DBSubset;
import com.knowgate.dataobjs.DBPersist;
import com.knowgate.debug.DebugFile;

public class EventDaemon {

  private String sProfile;
  private Properties oEnvProps;
  private DBBind oDbb;
	  
  private final ScheduledExecutorService oExecSrvc = Executors.newScheduledThreadPool(1);

  private HashMap<String,ScheduledFuture<?>> aRunHandlers = new HashMap<String,ScheduledFuture<?>>();
  private HashMap<String,Event> aEvents = new HashMap<String,Event>();
  
  // ---------------------------------------------------------------------------

  /**
   * <p>Create new EventDaemon</p>
   * @param sPropertiesFilePath Full path to hipergate.cnf file.<br>
   * Constructor will read the following properties from hipergate.cnf:<br>
   * <b>driver</b> JDBC driver class<br>
   * <b>dburl</b> URL for database connection<br>
   * <b>dbuser</b> Database User<br>
   * <b>dbpassword</b> Database User Password<br>
   * @throws ClassNotFoundException
   * @throws FileNotFoundException
   * @throws IOException
   * @throws SQLException
   */
  public EventDaemon (String sPropertiesFilePath)
    throws FileNotFoundException, IOException {

    oDbb = null;

    if (DebugFile.trace) {
      DebugFile.writeln("new FileInputStream("+sPropertiesFilePath+")");
    }

    FileInputStream oInProps = new FileInputStream (sPropertiesFilePath);
    oEnvProps = new Properties();
    oEnvProps.load (oInProps);
    oInProps.close ();

    sProfile = sPropertiesFilePath.substring(sPropertiesFilePath.lastIndexOf(File.separator)+1,sPropertiesFilePath.lastIndexOf('.'));

  } // EventDaemon

  // ---------------------------------------------------------------------------

  /**
   * <p>Cancel all event handlers and close connection pools</p>
   */
  public void close() {
	if (DebugFile.trace) {
	  DebugFile.writeln("Begin EventDaemon.close()");
	  DebugFile.incIdent();
	}
	
	Iterator<String> oIter = aRunHandlers.keySet().iterator();
	while (oIter.hasNext()) {
	  String sKey = oIter.next();
	  ScheduledFuture<?> oHndl = aRunHandlers.get(sKey);
	  if (DebugFile.trace) DebugFile.writeln("cancelling "+oHndl);
	  oHndl.cancel(false);	  
	}

	aRunHandlers.clear();
	
	aEvents.clear();

    if (null!=oDbb) {
      oDbb.close();
      oDbb=null;
    }

    if (DebugFile.trace) {
	  DebugFile.writeln("End EventDaemon.close()");
	  DebugFile.incIdent();
	}
  } // close

  // ---------------------------------------------------------------------------

  /**
   * <p>Read fixed rate events from k_events table and schedule triggering of all of them</p>
   */
  public void run() {
  
    if (DebugFile.trace) {
      DebugFile.writeln("Begin EventDaemon.run()");
      DebugFile.incIdent();
    }

    if (oDbb==null) oDbb = new DBBind(sProfile);
    JDCConnection oCon = null;
    
    try {
	  oCon = oDbb.getConnection("EventDaemon.run");
	  if (DBBind.exists(oCon, DB.k_events, "U")) {
	    DBPersist oEvn = new DBPersist(DB.k_events, "Event");
	    int nCol = oEvn.getTable(oCon).getColumnIndex(DB.fixed_rate);
	    if (nCol>0) {
	      DBSubset oDbs = new DBSubset(DB.k_events+" e INNER JOIN "+DB.k_lu_job_commands+" c ON e."+DB.id_command+"=c."+DB.id_command,
	      							   "e."+DB.id_event+",e."+DB.id_command+",e."+DB.id_app+",e."+DB.fixed_rate+",e."+DB.de_event+","+
	      							   "e."+DB.tx_parameters+",c."+DB.tx_command+",c."+DB.nm_class+",e."+DB.id_domain,
	      							   "e."+DB.bo_active+"<>0 AND e."+DB.fixed_rate+" IS NOT NULL AND c."+DB.nm_class+" IS NOT NULL", 10);
	      final int nEvents = oDbs.load(oCon);
	      for (int e=0; e<nEvents; e++) {
	        try {
	          Event oEvnt = Event.getEvent(oCon, oDbs.getInt(8, e), oDbs.getString(0, e));
	          triggerAtFixedSeconds(oEvnt, oDbs.getInt(3, e), oDbs.getInt(3, e));
	        } catch (Exception x) {
	          if (DebugFile.trace) DebugFile.writeln(x.getClass().getName()+" "+x.getMessage());
	        }
	      } // next
	    } // fi (exists colun fixed_rate)
	  } // fi (exists table k_events)
	  oCon.close("EventDaemon.run");
	  oCon=null;
	} catch (SQLException e) {
	  if (DebugFile.trace) DebugFile.writeln("SQLException "+e.getMessage());
	  if (oCon!=null) { try { if (!oCon.isClosed()) oCon.close("EventDaemon.run"); } catch (Exception ignore) {} }
	}

    if (DebugFile.trace) {
      DebugFile.decIdent();
      DebugFile.writeln("End EventDaemon.run()");
    }
  } // run

  // ---------------------------------------------------------------------------

  public void suspend(int iDomainId, String sEventId) {
    ScheduledFuture<?> oHndl = aRunHandlers.get(String.valueOf(iDomainId)+sEventId);
    if (oHndl!=null) {
      if (!oHndl.isCancelled())
        oHndl.cancel(false);
    }
  } // suspend

  // ---------------------------------------------------------------------------

  public void resume(int iDomainId, String sEventId) {
    String sKey = String.valueOf(iDomainId)+sEventId;
    ScheduledFuture<?> oHndl = aRunHandlers.get(sKey);
    if (oHndl!=null) {
      if (oHndl.isCancelled()) {
		aRunHandlers.remove(sKey);
		Event oEvnt = aEvents.get(sKey);
		triggerAtFixedSeconds(oEvnt, oEvnt.getInt(DB.fixed_rate), oEvnt.getInt(DB.fixed_rate));
      }
    }
  } // resume

  // ---------------------------------------------------------------------------
  
  /**
   * <p>Trigger an event over and over after a given delay in seconds</p>
   * @param oEvnt com.knowgate.scheduler.Event subclass
   * @param initialDelay Initial delay for first execution in seconds
   * @param intervalDelay Delay between executions in seconds
   */
  public void triggerAtFixedSeconds(Event oEvnt, int initialDelay, int intervalDelay) {
    String sKey = oEvnt.get(DB.id_domain)+oEvnt.getString(DB.id_event);
    aRunHandlers.put(sKey, oExecSrvc.scheduleAtFixedRate(oEvnt, initialDelay, intervalDelay, SECONDS));
    aEvents.put(sKey , oEvnt);
  }

}
