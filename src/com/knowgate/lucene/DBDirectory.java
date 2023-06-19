/*
  Copyright (C) 2003-2011  Know Gate S.L. All rights reserved.

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

package com.knowgate.lucene;

import java.io.IOException;
import java.util.Properties;

import org.apache.lucene.store.db.DbDirectory;

import com.knowgate.berkeleydb.DBEnvironment;
import com.sleepycat.db.Database;
import com.sleepycat.db.Transaction;

/**
 * Shared Berkeley DB Environment subclass of DbDirectory
 * @author Sergio Montoro Ten
 * @since 7.0
 *
 */
public class DBDirectory extends DbDirectory {
  private static DBEnvironment oDbEnv = null;
  private static int nClients = 0;
  private Transaction oDbTxn;
  
  private DBDirectory(Transaction oTrns, Database oFiles, Database oBlks) {
    super(oTrns, oFiles, oBlks);
  }

  @Override
  public void close()
    throws IOException {
	super.close();
    try {
	  if (null!=oDbTxn)
	    oDbTxn.commit();
	  if (0==--nClients) {
	    if (null!=oDbEnv)
	      oDbEnv.close();
	    oDbEnv=null;
	  }
    } catch (Exception xcpt) {
      throw new IOException(xcpt.getMessage(),xcpt);
    }
  } 

  /**
   * <p>Open Lucene Directory on the specified disk path</p>
   * Two Berkely DB Database files will be opened with names
   * lucene_records and lucene_datablocks
   * @param sDirectory String Directory full path
   * @return DBDirectory
   * @throws IOException
   */
  public static DBDirectory open(String sDirectory)
    throws IOException {	
	DBDirectory oDbDir = null;
	Properties oPrps = new Properties();
	try {
	  if (null==oDbEnv) oDbEnv = new DBEnvironment(sDirectory, null, false);
	  nClients++;
	  Transaction oTrns = oDbEnv.getEnvironment().beginTransaction(null,null);
	  oPrps.put("name","lucene_records");
	  Database oRecs = oDbEnv.openTable(oPrps).getDatabase();
	  oPrps.put("name","lucene_datablocks");
	  Database oBlks = oDbEnv.openTable(oPrps).getDatabase();	
	  oDbDir = new  DBDirectory(oTrns, oRecs, oBlks);
	} catch (Exception xcpt) {
	  throw new IOException(xcpt.getMessage(),xcpt);	
	}
	return oDbDir;
  }
  
}
