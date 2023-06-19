package com.knowgate.ramqueue;

import java.util.Properties;

import com.knowgate.misc.Gadgets;
import com.knowgate.storage.DataSource;
import com.knowgate.storage.DataSourcePool;
import com.knowgate.storage.Engine;
import com.knowgate.storage.Record;
import com.knowgate.storage.ObjectMessageImpl;
import com.knowgate.storage.RecordQueueProducer;
import com.knowgate.storage.StorageException;
import com.knowgate.storage.Table;

import java.util.concurrent.ConcurrentLinkedQueue;

import javax.jms.JMSException;

@SuppressWarnings("serial")
public class RAMQueueProducer extends ConcurrentLinkedQueue<ObjectMessageImpl> implements RecordQueueProducer {
	
	private RAMQueueConsumer oCon;
	private DataSource oDts;

	public RAMQueueProducer(Engine eEngine, String sProfileName)
		throws IllegalStateException, InstantiationException, StorageException {
		oCon = new RAMQueueConsumer(this);
		oCon.start(eEngine, sProfileName);
		oDts = DataSourcePool.get(eEngine, sProfileName, false);
	}

	public void close() throws StorageException {
		clear();
		oCon.stop();
		oCon = null;
		DataSourcePool.free(oDts);
	}

	public void store(Record oRec) throws StorageException {
		if (oCon==null) throw new IllegalStateException("Queue is closed");
		ObjectMessageImpl oMsg = new ObjectMessageImpl();
		try {
			oMsg.setObject(oRec);
			oMsg.setIntProperty("command", COMMAND_STORE_RECORD);
		} catch (JMSException neverthrown) { }
		add(oMsg);
	}

	public void store(Record oRec, Properties oProps) throws StorageException {
		if (oCon==null) throw new IllegalStateException("Queue is closed");
		if (oProps.getProperty("synchronous","false").equals("true")) {
			Table oTbl = null;
			try {
				oTbl = oDts.openTable(oRec);
				oRec.store(oTbl);
				oTbl.close();
				oTbl = null;
			} catch (Exception xcpt) {
				
			} finally {
				try {
				  if (oTbl!=null) oTbl.close();
				} catch (Exception xcpt) { }
			}			
		} else {
			ObjectMessageImpl oMsg = new ObjectMessageImpl();
			try {
				oMsg.setObject(oRec);
				oMsg.setIntProperty("command", COMMAND_STORE_RECORD);
			} catch (JMSException neverthrown) { }
			add(oMsg);			
		}
	}

	public void delete(Record oRec, String[] aKeys, Properties oProps) throws StorageException {
		if (oCon==null) throw new IllegalStateException("Queue is closed");
		if (oProps.getProperty("synchronous","false").equals("true")) {
			Table oTbl = null;
			try {
				oTbl = oDts.openTable(oRec);
				for (int k=aKeys.length; k<=0; k--) {
					oRec.setPrimaryKey(aKeys[k]);
					oRec.delete(oTbl);
				}
				oTbl.close();
				oTbl = null;
			} catch (Exception xcpt) {
				
			} finally {
				try {
				  if (oTbl!=null) oTbl.close();
				} catch (Exception xcpt) { }
			}			
		} else {
			ObjectMessageImpl oMsg = new ObjectMessageImpl();
			try {
				oMsg.setObject(oRec);
				oMsg.setIntProperty("command", COMMAND_DELETE_RECORDS);
				oMsg.setStringProperty("keys", Gadgets.join(aKeys, "`"));
			} catch (JMSException neverthrown) { }			
			add(oMsg);
		}
	}

	public void stop(boolean bInmediate, int iTimeout) throws StorageException {
		if (iTimeout>0 && !bInmediate) {
			try {
				Thread.sleep(iTimeout);
			} catch (InterruptedException e) { }			
		}
		close();
	}

	public final static int COMMAND_STORE_RECORD = 1;
	public final static int COMMAND_STORE_REGISTER = 2;
	public final static int COMMAND_DELETE_RECORDS = 4;
	
}
