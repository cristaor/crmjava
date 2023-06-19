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

package com.knowgate.http.oauth;

import java.util.Date;
import java.util.Random;
import java.net.InetAddress;
import java.net.UnknownHostException;

public class OAuthAccess {
  
  private String sCid;
  private String sUri;  
  private String sValue;
  private String sRefresh;
  private String sScope;
  private Date dtIssued;
  private Date dtExpire;
  private short iType;

  private static final long DEFAULT_LOGIN_TIMEOUT = 120000l;
  private static final long DEFAULT_KEEP_ALIVE = 3600000l;
  
  public OAuthAccess(short iAccessType, String sClientId, String sRedirectURI) {
  	iType = iAccessType;
  	sCid = sClientId;
  	sUri = sRedirectURI;
  	sValue = generateUUID();
  	sScope = null;
  	sRefresh = (iAccessType==TYPE_TOKEN ? generateUUID() : null);
  	dtIssued = new Date();
  	dtExpire = new Date(dtIssued.getTime() + (getType()==TYPE_CODE ? DEFAULT_LOGIN_TIMEOUT : DEFAULT_KEEP_ALIVE));
  }

  public String getValue() {
  	return sValue;
  }

  public String getRefresh() {
  	return sRefresh;
  }

  public void refresh() {
  	dtExpire = new Date(dtExpire.getTime()+DEFAULT_KEEP_ALIVE);
  }

  public String getClient() {
  	return sCid;
  }

  public String getScope() {
  	return sScope;
  }

  public void setScope(String sWrkA) {
  	sScope = sWrkA;
  }

  public String getURI() {
  	return sUri;
  }

  public boolean isExpired() {
  	return dtExpire.compareTo(new Date())<=0;
  }

  public long expiresInSecs() {
  	return (dtExpire.getTime()-dtIssued.getTime())/1000l;
  }

  public short getType() {
  	return iType;
  }

  public static short TYPE_CODE = 1;
  public static short TYPE_TOKEN = 2;

  private static int iSequence = 1048576;

  private static String[] byteToStr = {
                                 "00","01","02","03","04","05","06","07","08","09","0a","0b","0c","0d","0e","0f",
                                 "10","11","12","13","14","15","16","17","18","19","1a","1b","1c","1d","1e","1f",
                                 "20","21","22","23","24","25","26","27","28","29","2a","2b","2c","2d","2e","2f",
                                 "30","31","32","33","34","35","36","37","38","39","3a","3b","3c","3d","3e","3f",
                                 "40","41","42","43","44","45","46","47","48","49","4a","4b","4c","4d","4e","4f",
                                 "50","51","52","53","54","55","56","57","58","59","5a","5b","5c","5d","5e","5f",
                                 "60","61","62","63","64","65","66","67","68","69","6a","6b","6c","6d","6e","6f",
                                 "70","71","72","73","74","75","76","77","78","79","7a","7b","7c","7d","7e","7f",
                                 "80","81","82","83","84","85","86","87","88","89","8a","8b","8c","8d","8e","8f",
                                 "90","91","92","93","94","95","96","97","98","99","9a","9b","9c","9d","9e","9f",
                                 "a0","a1","a2","a3","a4","a5","a6","a7","a8","a9","aa","ab","ac","ad","ae","af",
                                 "b0","b1","b2","b3","b4","b5","b6","b7","b8","b9","ba","bb","bc","bd","be","bf",
                                 "c0","c1","c2","c3","c4","c5","c6","c7","c8","c9","ca","cb","cc","cd","ce","cf",
                                 "d0","d1","d2","d3","d4","d5","d6","d7","d8","d9","da","db","dc","dd","de","df",
                                 "e0","e1","e2","e3","e4","e5","e6","e7","e8","e9","ea","eb","ec","ed","ee","ef",
                                 "f0","f1","f2","f3","f4","f5","f6","f7","f8","f9","fa","fb","fc","fd","fe","ff" };

  //-----------------------------------------------------------

  /**
   * Generate an universal unique identifier
   * @return An hexadecimal string of 32 characters,
   * created using the machine IP address, current system date, a randon number
   * and a sequence.
   */
  private String generateUUID() {

    int iRnd;
    long lSeed = new Date().getTime();
    Random oRnd = new Random(lSeed);
    String sHex;
    StringBuffer sUUID = new StringBuffer(32);
    byte[] localIPAddr = new byte[4];

    try {

      // 8 characters Code IP address of this machine
      localIPAddr = InetAddress.getLocalHost().getAddress();

      sUUID.append(byteToStr[((int) localIPAddr[0]) & 255]);
      sUUID.append(byteToStr[((int) localIPAddr[1]) & 255]);
      sUUID.append(byteToStr[((int) localIPAddr[2]) & 255]);
      sUUID.append(byteToStr[((int) localIPAddr[3]) & 255]);
    }
    catch (UnknownHostException e) {
      // Use localhost by default
      sUUID.append("7F000000");
    }

    // Append a seed value based on current system date
    sUUID.append(Long.toHexString(lSeed));

    // 6 characters - an incremental sequence
    sUUID.append(Integer.toHexString(iSequence++));

    if (iSequence>16777000) iSequence=1048576;

    do {
      iRnd = oRnd.nextInt();
      if (iRnd>0) iRnd = -iRnd;
      sHex = Integer.toHexString(iRnd);
    } while (0==iRnd);

    // Finally append a random number
    sUUID.append(sHex);

    return sUUID.substring(0, 32);
  } // generateUUID()

}
