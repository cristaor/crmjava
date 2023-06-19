package com.knowgate.syndication.fetcher;

import com.knowgate.dfs.FileSystem;
import com.knowgate.twitter.API;
import com.knowgate.twitter.Tweet;
import com.knowgate.twitter.User;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Locale;

import org.json.JSONArray;
import org.json.JSONObject;

import com.knowgate.debug.DebugFile;
import com.knowgate.storage.DataSource;

import com.sun.syndication.feed.synd.SyndContentImpl;
import com.sun.syndication.feed.synd.SyndEntryImpl;
import com.sun.syndication.feed.synd.SyndFeedImpl;
import com.sun.syndication.feed.synd.SyndPersonImpl;

import com.sun.syndication.feed.synd.SyndFeed;

public class TwitterJsonFetcher extends GenericFeedFetcher  {
  public TwitterJsonFetcher(DataSource oDts, String sFeedUrl, String sQueryString) {
    super(oDts, sFeedUrl, "twittersearch", sQueryString, null, null);
  }

  public SyndFeed retrieveFeed() {
	SyndFeedImpl oFeed = new SyndFeedImpl();
	String sTweets = "";
	try {
	  sTweets = new FileSystem().readfilestr(getURL(),"UTF-8");
	  SimpleDateFormat oEEEdd = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss",Locale.US);
	      
	  JSONArray oResults = new JSONObject(sTweets).getJSONArray("results");
	  final int nLen = oResults.length();
	  ArrayList<SyndEntryImpl> oEntries = new ArrayList<SyndEntryImpl>(nLen);
	  for (int j=0;j<nLen; j++) {
		JSONObject oRes = oResults.getJSONObject(j);
		String sTweetId = oRes.getString("id_str");
		if (sTweetId.length()>0 && !sTweetId.equals("0")) {
			Tweet oTwt = API.getTweet(sTweetId);
			User oUsr = oTwt.getUser();
			
	  	    SyndEntryImpl oEntr = new SyndEntryImpl();
	  	    SyndPersonImpl oPers = new SyndPersonImpl();
	  	    oPers.setName(oUsr.get("name"));
	  	    oPers.setUri(oUsr.get("id"));
	  	    ArrayList<SyndPersonImpl> oAuthor = new ArrayList<SyndPersonImpl>();
	  	    oAuthor.add(oPers);
	  	    oEntr.setAuthors(oAuthor);
		    oEntr.setLink("http://twitter.com/#!/"+oUsr.get("screen_name")+"/status/"+sTweetId);
		    oEntr.setTitle(oTwt.getString("text"));
	        oEntr.setPublishedDate(oTwt.getDate("created_at"));
	        oEntr.setUri("http://twitter.com/#!/"+oUsr.get("screen_name")+"/status/"+sTweetId);	    

	  	    SyndContentImpl oScnt = new SyndContentImpl();
	  	    oScnt.setType("text/plain");
	  	    oScnt.setValue(oTwt.getString("text"));
	  	    oEntr.setDescription(oScnt);

	  	    try {
	  	      oEntr.setPublishedDate(oEEEdd.parse(oRes.getString("created_at").substring(0, 25)));
	  	    } catch (Exception xcpt) {
	  		  if (DebugFile.trace)
	  			DebugFile.writeln("TwitterJsonFetcher.retrieveFeed() Could not parse date "+oRes.getString("created_at").substring(0, 25)+" "+xcpt.getClass().getName()+" "+xcpt.getMessage()+" the expected format was EEE, dd MMM yyyy HH:mm:ss");
	  	    }
	  	    oEntries.add(oEntr);			
		} else {
	      if (DebugFile.trace)
	  		DebugFile.writeln("TwitterJsonFetcher.retrieveFeed() could not find tweet id at "+oResults.toString()+ " object "+String.valueOf(j)+" "+oRes.toString());
		}
	  } // next
	  oFeed.setEntries(oEntries);	  
	} catch (Exception xcpt) {
	  if (DebugFile.trace)
		DebugFile.writeln("TwitterJsonFetcher.retrieveFeed() "+xcpt.getClass().getName()+" "+xcpt.getMessage());
	}
	return oFeed;
  }
}
