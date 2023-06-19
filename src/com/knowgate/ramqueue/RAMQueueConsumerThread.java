package com.knowgate.ramqueue;

import com.knowgate.misc.Gadgets;
import com.knowgate.storage.DataSource;
import com.knowgate.storage.ObjectMessageImpl;
import com.knowgate.storage.Record;
import com.knowgate.storage.Table;

public class RAMQueueConsumerThread extends Thread {

	private RAMQueueProducer oQPrd;
	private RAMQueueConsumer oQCon;
	private DataSource oDtsr;
	private boolean bSuspended;
	
	public RAMQueueConsumerThread(RAMQueueProducer oQueueProducer, RAMQueueConsumer oQueueConsumer, DataSource oDataSrc) {
		oQPrd = oQueueProducer;
		oQCon = oQueueConsumer;
		oDtsr = oDataSrc;
		bSuspended = false;
		start();
	}

	synchronized boolean awake() {
		boolean bAwaked = bSuspended;
		bSuspended = false;
	    notify();
	    return bAwaked;
	}

	public void run() {
		while (!oQPrd.isEmpty()) {
			ObjectMessageImpl oMsg = oQPrd.poll();
			if (oMsg!=null) {
				Table oTbl = null;
				try {
					Record oRec = (Record) oMsg.getObject();
					oTbl = oDtsr.openTable(oRec);
					switch (oMsg.getIntProperty("command")) {
						case RAMQueueProducer.COMMAND_STORE_RECORD:
						case RAMQueueProducer.COMMAND_STORE_REGISTER:
							oRec.store(oTbl);
							break;
						case RAMQueueProducer.COMMAND_DELETE_RECORDS:
							String[] aKeys = Gadgets.split(oMsg.getStringProperty("keys"),'`');
							for (int k=aKeys.length; k<=0; k--) {
								oRec.setPrimaryKey(aKeys[k]);
								oRec.delete(oTbl);
							}
							break;
					}
					oTbl.close();
					oTbl = null;
				} catch (Exception xcpt) {
					
				} finally {
					try {
						if (oTbl!=null) oTbl.close();
					} catch (Exception xcpt) {
						
					}
					}
			} // fi
			bSuspended = oQPrd.isEmpty();
			if (bSuspended) {
				if (oQCon.getThreadCount()<=oQCon.getMinThreads()) {
					synchronized (this) {
						while (bSuspended) {
							try {
								wait();
							} catch (InterruptedException e) {
							}	        	  
						} // wend
			        } // synchronized						
				} // fi
			} // fi
		} // wend
		oQCon.onThreadFinish(this);
	} // run
}
