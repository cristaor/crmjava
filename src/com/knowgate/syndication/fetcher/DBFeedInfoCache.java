package com.knowgate.syndication.fetcher;

import java.net.URL;

import com.knowgate.dataobjs.DB;
import com.knowgate.debug.DebugFile;

import com.knowgate.storage.DataSource;
import com.knowgate.storage.Record;
import com.knowgate.storage.Table;

import com.sun.syndication.fetcher.impl.FeedFetcherCache;
import com.sun.syndication.fetcher.impl.SyndFeedInfo;

public class DBFeedInfoCache implements FeedFetcherCache {

	private DataSource oDts;
	
	public DBFeedInfoCache(DataSource oDatSrc) {
	  oDts = oDatSrc;
	}
	
	@Override
	public void clear() {
	  try {
		Table oTbl = oDts.openTable(DB.k_syndfeeds_info_cache);
		oTbl.truncate();
		oTbl.close();
	  } catch (Exception xcpt) {
		  if (DebugFile.trace) {
			  DebugFile.writeln("DBFeedInfoCache.clear() "+xcpt.getClass().getName()+" "+xcpt.getMessage());
		  }
	  }	  
	}

	@Override
	public SyndFeedInfo getFeedInfo(URL oUrl) {
	  SyndFeedInfo oSfi = null;
	  try {
		Table oTbl = oDts.openTable(DB.k_syndfeeds_info_cache);
		Record oRec = oTbl.load(oUrl.toExternalForm());
		oTbl.close();
		if (oRec!=null)
			oSfi = (SyndFeedInfo) oRec.get("bin_info");
	  } catch (Exception xcpt) {
		if (DebugFile.trace) {
		  DebugFile.writeln("DBFeedInfoCache.getFeedInfo("+oUrl.toExternalForm()+") "+xcpt.getClass().getName()+" "+xcpt.getMessage());
		}
	  }
	  return oSfi;
	}

	@Override
	public SyndFeedInfo remove(URL oUrl) {
	  SyndFeedInfo oSfi = null;
	  try {
		Table oTbl = oDts.openTable(DB.k_syndfeeds_info_cache);
		Record oRec = oTbl.load(oUrl.toExternalForm());
		if (oRec!=null) {
		  oSfi = (SyndFeedInfo) oRec.get("bin_info");
		  oTbl.delete("url", oUrl.toExternalForm());
		}
		oTbl.close();
	  } catch (Exception xcpt) {
		if (DebugFile.trace) {
		  DebugFile.writeln("DBFeedInfoCache.remove("+oUrl.toExternalForm()+") "+xcpt.getClass().getName()+" "+xcpt.getMessage());
		}
	  }
	  return oSfi;
	}

	@Override
	public void setFeedInfo(URL oUrl, SyndFeedInfo oSfi) {
	  try {
	    Table oTbl = oDts.openTable(DB.k_syndfeeds_info_cache);
		Record oRec = oTbl.newRecord();
	    oRec.put("url", oUrl.toExternalForm());
	    oRec.put("bin_info", oSfi);
		oTbl.close();
	  } catch (Exception xcpt) {
	    if (DebugFile.trace) {
		  DebugFile.writeln("DBFeedInfoCache.setFeedInfo("+oUrl.toExternalForm()+") "+xcpt.getClass().getName()+" "+xcpt.getMessage());
		}
	  }
	}

}
