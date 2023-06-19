package com.knowgate.syndication.fetcher;

import java.util.Properties;

import com.knowgate.debug.DebugFile;
import com.knowgate.storage.DataSource;

import com.knowgate.bing.Item;
import com.knowgate.bing.Search;

import com.sun.syndication.feed.synd.SyndContentImpl;
import com.sun.syndication.feed.synd.SyndEntryImpl;

public class BingFetcher extends AbstractEntriesFetcher {
	
	private Properties oPrps;
	
  	public BingFetcher(DataSource oDts, String sQueryString, Properties oProps) {
  	  super(oDts, "", "bingsearch", sQueryString, null, oProps);
  	  oPrps = oProps;
	}

  	public void run() {
	  if (DebugFile.trace) {
		  DebugFile.writeln("Begin BingFetcher.run()");
		  DebugFile.incIdent();
	  }
	  int nItm = 0;
  	  try {
        Search oSrch = new Search(oPrps.getProperty("bingkey"));
        Item[] aItm = oSrch.query(getQueryString());
        if (aItm!=null) {
  		  nItm = aItm.length;
          for (int i=0; i<nItm; i++) {
  	      	  String sUrl = aItm[i].url;
  	      	  SyndEntryImpl oEntr = new SyndEntryImpl();
  	      	  oEntr.setUri(sUrl);
  	      	  oEntr.setLink(sUrl);
  	      	  oEntr.setTitle(aItm[i].title);
  	      	  SyndContentImpl oScnt = new SyndContentImpl();
  	      	  oScnt.setType("text/plain");
  	      	  oScnt.setValue(aItm[i].abstrct);
  	      	  try {
  	      	  	  oEntr.setPublishedDate(aItm[i].pubdate);
  	      	  	  oEntr.setUpdatedDate(aItm[i].pubdate);
  	      	  } catch (Exception xcpt) { }

  		      if (preFetch(oEntr)) {
  	      	    addEntry(createEntry(0, "", "bingsearch", null, getQueryString(), null, getCountry(sUrl), getLanguage(sUrl), getAuthor(oEntr), oEntr));
  			  }
          } // next
  	    } // fi  
	  } catch (Exception xcpt) {
	  	if (DebugFile.trace) {
	  	  DebugFile.writeln("BingFetcher.run() "+xcpt.getClass().getName()+" "+xcpt.getMessage());
	  	  DebugFile.decIdent();
	  	}
	  }
	  if (DebugFile.trace) {
		  DebugFile.writeln("End BingFetcher.run() : "+String.valueOf(nItm));
		  DebugFile.decIdent();
	  }
  	} // run
}
