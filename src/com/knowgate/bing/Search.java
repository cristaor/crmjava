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

package com.knowgate.bing;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;
import java.util.ListIterator;

import com.knowgate.misc.Gadgets;
import com.sun.syndication.feed.synd.SyndEntry;
import com.sun.syndication.feed.synd.SyndFeed;
import com.sun.syndication.fetcher.FetcherException;
import com.sun.syndication.fetcher.impl.HttpURLFeedFetcher;
import com.sun.syndication.io.FeedException;

/**
 * Search using bing.com
 * @author Sergio Montoro Ten
 *
 */
public class Search {

  private String appid;
  
  public Search(String sAppId) {
	  appid = Gadgets.URLEncode(sAppId);
  }

  /**
   * Perform an Internet wide search using bing.com
   * @param sText String searched
   * @return Array of Item or <b>null</b> if no results were found
   * @throws IllegalArgumentException
   * @throws IOException
   */
  public Item[] query (String sText)
    throws IllegalArgumentException, IOException {
	SyndFeed oFeed = null;
	Item[] aItems = null;
	HttpURLFeedFetcher oFtchr = new HttpURLFeedFetcher();	
	try {
	  oFeed = oFtchr.retrieveFeed(new URL("http://www.bing.com/search?appid="+appid+"&format=rss&q="+sText.replace(' ','+')));
	} catch (MalformedURLException neverthrown) {		
	} catch (FeedException e) {
		throw new IOException(e.getMessage(),e);
	} catch (FetcherException e) {
		throw new IOException(e.getMessage(),e);
	}
	List<SyndEntry> oEntries = oFeed.getEntries();
	if (oEntries!=null) {
	  if (oEntries.size()>0) {
		aItems = new Item[oEntries.size()];
		ListIterator<SyndEntry> oIter = oEntries.listIterator();
		int iItem = 0;
		while (oIter.hasNext()) {
			SyndEntry oEntry = oIter.next();
		  aItems[iItem++] = new Item(oEntry.getTitle(), oEntry.getLink(), oEntry.getDescription().getValue(), oEntry.getPublishedDate());		  
		}
	  }
	}
	return aItems;
  } // query

  /**
   * Search text at an specific site
   * @param sText String searched
   * @param sSite String domain name
   * @return Array of Item or <b>null</b> if no results were found
   * @throws IllegalArgumentException
   * @throws IOException
   */
  public Item[] query (String sText, String sSite) throws IllegalArgumentException, IOException {
	  return query(sText+"+site%3A"+sSite);
  }
  
}
