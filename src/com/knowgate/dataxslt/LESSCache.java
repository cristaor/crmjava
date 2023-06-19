/*
  Copyright (C) 2003-2012  Know Gate S.L. All rights reserved.

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

import java.io.File;
import java.io.IOException;

import java.util.WeakHashMap;

import org.lesscss.LessCompiler;
import org.lesscss.LessException;

public class LESSCache extends WeakHashMap<String,String> {

  public String render(File oLCSS)
	throws LessException, IOException {
    final String sFilePath = oLCSS.getAbsolutePath();
	String sRetCSS = null;    
	if (containsKey(sFilePath)) {
	  sRetCSS = get(sFilePath);
	} else {
      LessCompiler oLssC = null;
      try {
        oLssC = new LessCompiler();
	    sRetCSS = oLssC.compile(oLCSS);
		put(sFilePath, sRetCSS);
      } finally {
    	if (oLssC!=null) oLssC.close();
      }
	}
	return sRetCSS;
  } // 	render

}
