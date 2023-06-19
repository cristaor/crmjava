package com.knowgate.ramqueue;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import com.knowgate.storage.DataSource;
import com.knowgate.storage.Engine;
import com.knowgate.storage.DataSourcePool;
import com.knowgate.storage.ObjectMessageImpl;
import com.knowgate.storage.RecordQueueConsumer;
import com.knowgate.storage.StorageException;

public class RAMQueueConsumer implements RecordQueueConsumer {

	private int iMaxThreads = 5;
	private int iMinThreads = 2;
	private List<RAMQueueConsumerThread> oThreads;
	private RAMQueueProducer oPrd;
	private DataSource oDts;
	
	public RAMQueueConsumer(RAMQueueProducer oQueueProducer) {
		oDts = null;
		oPrd = oQueueProducer;
		oThreads = Collections.synchronizedList(new ArrayList<RAMQueueConsumerThread>());
	}

	public void start(Engine eEngine, String sProfile) throws IllegalStateException, InstantiationException, StorageException {
		oDts = DataSourcePool.get(eEngine, sProfile, false);
	}

	public void stop() throws StorageException {
		if (oDts!=null) {
			DataSourcePool.free(oDts);
		}
	}

	public int getThreadCount() {
		return oThreads.size();
	}

	public int getMinThreads() {
		return iMinThreads;
	}

	public void setMinThreads(int iMin) {
		iMinThreads = iMin;
	}

	public int getMaxThreads() {
		return iMaxThreads;
	}

	public void setMaxThreads(int iMax) {
		iMaxThreads = iMax;
	}

	public void onMessage(ObjectMessageImpl oMsg) {
		synchronized (oThreads) {
			if (oThreads.isEmpty()) {
				oThreads.add(new RAMQueueConsumerThread(oPrd, this, oDts));
			} else {
				boolean bAnyAwaked = false;
				for (RAMQueueConsumerThread oQct : oThreads)
					bAnyAwaked = bAnyAwaked || oQct.awake();
				if (!bAnyAwaked && getThreadCount()<getMaxThreads()) {
					oThreads.add(new RAMQueueConsumerThread(oPrd, this, oDts));
				}
			}
		}			
	}
	
	public void onThreadFinish(RAMQueueConsumerThread oThr) {
		synchronized (oThreads) {
			oThreads.remove(oThr);
		}
	}
}
