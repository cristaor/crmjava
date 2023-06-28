<%@ page import="com.knowgate.storage.DataSource,com.knowgate.storage.RecordSet,com.knowgate.syndication.crawler.SearchRunner" language="java" session="false" contentType="text/xml;charset=UTF-8" %><jsp:useBean id="GlobalNoSQLStore" scope="application" class="com.knowgate.storage.Manager"/><% 
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

  out.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");

  final String PAGE_NAME = "conversation_crawl";

  DataSource oDts = null;  
    
  try {
    SearchRunner oRun = new SearchRunner(request.getParameter("s"), GlobalNoSQLStore.getProperties());
    oDts = GlobalNoSQLStore.getDataSource();	  
	  oRun.run(oDts);
	  GlobalNoSQLStore.free(oDts);
	  oDts=null;
	  RecordSet oRst = GlobalNoSQLStore.fetch("k_syndentries", "tx_sought", request.getParameter("s"));
    out.write(SearchRunner.recordSetToXML(oRst, null, 100, 0));
	}
  catch (Exception e) {
    out.write("<error>"+e.getClass().getName()+" " + e.getMessage() + "</error>");  
    out.flush();
    if (oDts!=null) GlobalNoSQLStore.free(oDts);
  }
%>