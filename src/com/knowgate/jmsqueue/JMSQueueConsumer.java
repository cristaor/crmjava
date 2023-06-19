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

package com.knowgate.jmsqueue;

import java.io.IOException;
import java.util.ArrayList;

import javax.jms.Queue;
import javax.jms.Session;
import javax.jms.Message;
import javax.jms.Connection;
import javax.jms.JMSException;
import javax.jms.QueueReceiver;
import javax.jms.QueueBrowser;
import com.sun.messaging.ConnectionFactory;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;

import java.util.Hashtable;
import java.util.Enumeration;
import java.util.NoSuchElementException;

import com.knowgate.storage.Engine;
import com.knowgate.storage.RecordQueueConsumer;
import com.knowgate.storage.StorageException;

import com.knowgate.debug.DebugFile;
import com.knowgate.debug.StackTraceUtil;

public class JMSQueueConsumer implements RecordQueueConsumer {

  private boolean bSnc;
  private String sLoginId;
  private String sAuthStr;
  private Hashtable oEnv;
  private Context oCtx;
  private String oQnm;
  private ConnectionFactory oCnf;
  private Connection oQcn;
  private Queue oQue;
  private Session oSes;
  private QueueReceiver oQrc;
	  
  public JMSQueueConsumer(String sConnectionFactoryName, String sQueueName, String sDirectory,
  						     String sUserId, String sPassword, boolean bSynchronous)
  	throws StorageException,NamingException,JMSException {  		
  	sLoginId = sUserId;
  	sAuthStr = sPassword;
    oEnv = new Hashtable();
    oEnv.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.fscontext.RefFSContextFactory");
    oEnv.put(Context.PROVIDER_URL, "file://"+sDirectory);
    oCtx = new InitialContext(oEnv);
    oCnf = (ConnectionFactory) oCtx.lookup(sConnectionFactoryName);
    oQnm = sQueueName;
    bSnc = bSynchronous;
    oQcn = null;
    oSes = null;
    oQue = null;
    oQrc = null;
  }

  protected  void finalize() {
  	try { stop(); } catch (Exception ignore) {}
  }

  public ArrayList<Message> browse() throws JMSException {

    if (DebugFile.trace) {
      DebugFile.writeln("Begin RecordQueueConsumer.browse()");
      DebugFile.incIdent();
    }
	
	Connection oCnn = oCnf.createConnection(sLoginId,sAuthStr);
	Session oSss = oCnn.createSession(false, Session.AUTO_ACKNOWLEDGE);
    Queue oQuu = oSss.createQueue(oQnm);
    QueueReceiver oQrr = (QueueReceiver) oSss.createConsumer(oQuu);
    ArrayList<Message> oMsgs = new ArrayList<Message>();
    QueueBrowser oQbr = oSss.createBrowser(oQuu);
	Enumeration oEnu = oQbr.getEnumeration();
	while (oEnu.hasMoreElements()) {
	  oMsgs.add((Message) oEnu.nextElement());
    } // wend
    oQrr.close();
    oSss.close();
    oCnn.close();

    if (DebugFile.trace) {
      DebugFile.decIdent();
      DebugFile.writeln("End RecordQueueConsumer.browse() : "+String.valueOf(oMsgs.size())+" queued messages");
    }

	return oMsgs;
  } // browse
  
  public void start(Engine eEngine, String sProfile)
  	throws IllegalStateException,InstantiationException,StorageException {

  	Message oMsg;
	JMSQueueListener oRql;
	
	if (oQcn!=null) throw new IllegalStateException("RecordQueueConsumer is already connected");

    if (DebugFile.trace) {
      DebugFile.writeln("Begin RecordQueueConsumer.start()");
      DebugFile.incIdent();
      DebugFile.writeln("ConnectionFactory.createConnection("+sLoginId+", ...)");
    }
	
    try {
    	oQcn = oCnf.createConnection(sLoginId,sAuthStr);

        if (DebugFile.trace) DebugFile.writeln("Connection.createSession(false, Session.AUTO_ACKNOWLEDGE)");

    	oSes = oQcn.createSession(false, Session.AUTO_ACKNOWLEDGE);
        oQue = oSes.createQueue(oQnm);

        if (DebugFile.trace) {
    	  int nMsgs=0;	  
    	  QueueBrowser oQbr = oSes.createBrowser(oQue);
    	  try {
    	    Enumeration oEnu = oQbr.getEnumeration();	  
    	    while (oEnu.hasMoreElements()) {
    	      nMsgs++;
    	      oEnu.nextElement();
            } // wend
    	  } catch (NoSuchElementException nosuch) {
            DebugFile.writeln("NoSuchElementException "+nosuch.getMessage());
    	  } finally {
            if (null!=oQbr) oQbr.close();
    	  }
          DebugFile.writeln("queue had "+String.valueOf(nMsgs)+" previous messages");
        } // fi

        oQrc = (QueueReceiver) oSes.createConsumer(oQue);
        oRql = new JMSQueueListener(eEngine,"extranet",oSes);
        if (bSnc) {
          if (DebugFile.trace) DebugFile.writeln("Connection.start()");
          oQcn.start();
          while ((oMsg=oQrc.receive())!=null) {
            if (DebugFile.trace) DebugFile.writeln("new message "+oMsg.getJMSMessageID()+" received at "+oQrc.getQueue().getQueueName());
            int iCmd = -1;
            try {
              iCmd = oMsg.getIntProperty("command");
            } catch (NullPointerException npe) {
              if (DebugFile.trace) DebugFile.writeln("no command set at message");        
            }
            if (DebugFile.trace) DebugFile.writeln("before RecordQueueListener.onMessage("+oMsg.getJMSMessageID()+")");
          	oRql.onMessage(oMsg);
            if (iCmd==0) {
              stop();
              break;
            }
          } // wend
        } else {
          if (DebugFile.trace) DebugFile.writeln("QueueReceiver.setMessageListener("+oRql.toString()+")");
          oQrc.setMessageListener(oRql);
          if (DebugFile.trace) DebugFile.writeln("Connection.start()");
          oQcn.start();
        }    	
    } catch (JMSException jmse) {
        if (DebugFile.trace) {
            DebugFile.writeln("JMSQueueConsumer.start() JMSException " + jmse.getMessage());
            try {
				DebugFile.writeln(StackTraceUtil.getStackTrace(jmse));
			} catch (IOException ignore) { }
            DebugFile.decIdent();
          }
    	throw new StorageException(jmse.getMessage(), jmse);
    }

    if (DebugFile.trace) {
      DebugFile.decIdent();
      DebugFile.writeln("End RecordQueueConsumer.start()");
    }
  } // start
  
  public void stop() throws StorageException {

    if (DebugFile.trace) {
      DebugFile.writeln("Begin RecordQueueConsumer.stop()");
      DebugFile.incIdent();
    }

    try {
	    if (oQcn!=null) {
		  oQcn.stop();
		}
	    if (null!=oQrc) {
	      oQrc.close();
	      oQrc = null;
	    }
	    oQue = null;
	    if (null!=oSes) {
	      oSes.close();
	      oSes = null;
	    }
		if (oQcn!=null) {
		  oQcn.close();
		  oQcn=null;
		}    	
    } catch (JMSException jmse) {
        if (DebugFile.trace) {
            DebugFile.writeln("JMSQueueConsumer.stop() JMSException " + jmse.getMessage());
            try {
				DebugFile.writeln(StackTraceUtil.getStackTrace(jmse));
			} catch (IOException ignore) { }
            DebugFile.decIdent();
          }
    	throw new StorageException(jmse.getMessage(), jmse);
    }

    if (DebugFile.trace) {
      DebugFile.decIdent();
      DebugFile.writeln("End RecordQueueConsumer.stop()");
    }
  } // stop

  public static void main (String[] args) throws Exception {
  	JMSQueueConsumer oRqc = new JMSQueueConsumer("ClocialQueueConnectionFactory",
   												       "ClocialDestinationQueue", "C:/Temp",
   												       "admin","admin",true);
    oRqc.start(Engine.BERKELYDB, null);
  }
}
