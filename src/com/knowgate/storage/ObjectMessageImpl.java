package com.knowgate.storage;

import javax.jms.ObjectMessage;
import java.io.Serializable;
import javax.jms.JMSException;
import javax.jms.Destination;

import java.util.Hashtable;
import java.util.Enumeration;

public class ObjectMessageImpl implements ObjectMessage {
	
	private Serializable oObj;
	private String sId;
	private String sCid;
	private String sJtp;
	private int iDlm;
	private int iPrt;
	private boolean bRdl;
	private long lTs;
	private long lExp;
	private Hashtable<String,Object> oPrp;
	
	public ObjectMessageImpl() {
		oPrp = new Hashtable<String,Object>();
	}
	
	/**
	 * Method setObject
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 */
	public void setObject(Serializable parm1) throws JMSException {
		oObj = parm1;
	}

	/**
	 * Method getObject
	 *
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public Serializable getObject() throws JMSException {
		return oObj;
	}

	/**
	 * Method getJMSMessageID
	 *
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public String getJMSMessageID() throws JMSException {
		return sId;
	}

	/**
	 * Method setJMSMessageID
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 */
	public void setJMSMessageID(String parm1) throws JMSException {
		sId = parm1;
	}

	/**
	 * Method getJMSTimestamp
	 *
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public long getJMSTimestamp() throws JMSException {
		return lTs;
	}

	/**
	 * Method setJMSTimestamp
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 */
	public void setJMSTimestamp(long parm1) throws JMSException {
		lTs = parm1;
	}

	/**
	 * Method getJMSCorrelationIDAsBytes
	 *
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public byte[] getJMSCorrelationIDAsBytes() throws JMSException {
		return sCid.getBytes();
	}

	/**
	 * Method setJMSCorrelationIDAsBytes
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 */
	public void setJMSCorrelationIDAsBytes(byte[] parm1) throws JMSException {
		sCid = new String(parm1);
	}

	/**
	 * Method setJMSCorrelationID
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 */
	public void setJMSCorrelationID(String parm1) throws JMSException {
		sCid = parm1;
	}

	/**
	 * Method getJMSCorrelationID
	 *
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public String getJMSCorrelationID() throws JMSException {
		return sCid;
	}

	/**
	 * Method getJMSReplyTo
	 *
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public Destination getJMSReplyTo() throws JMSException {
		return null;
	}

	/**
	 * Method setJMSReplyTo
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 */
	public void setJMSReplyTo(Destination parm1) throws JMSException {
		// TODO: Add your code here
	}

	/**
	 * Method getJMSDestination
	 *
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public Destination getJMSDestination() throws JMSException {
		return null;
	}

	/**
	 * Method setJMSDestination
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 */
	public void setJMSDestination(Destination parm1) throws JMSException {
		// TODO: Add your code here
	}

	/**
	 * Method getJMSDeliveryMode
	 *
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public int getJMSDeliveryMode() throws JMSException {
		return iDlm;
	}

	/**
	 * Method setJMSDeliveryMode
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 */
	public void setJMSDeliveryMode(int parm1) throws JMSException {
		iDlm = parm1;
	}

	/**
	 * Method getJMSRedelivered
	 *
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public boolean getJMSRedelivered() throws JMSException {
		return bRdl;
	}

	/**
	 * Method setJMSRedelivered
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 */
	public void setJMSRedelivered(boolean parm1) throws JMSException {
		bRdl = parm1;
	}

	/**
	 * Method getJMSType
	 *
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public String getJMSType() throws JMSException {
		return sJtp;
	}

	/**
	 * Method setJMSType
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 */
	public void setJMSType(String parm1) throws JMSException {
		sJtp = parm1;
	}

	/**
	 * Method getJMSExpiration
	 *
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public long getJMSExpiration() throws JMSException {
		return lExp;
	}

	/**
	 * Method setJMSExpiration
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 */
	public void setJMSExpiration(long parm1) throws JMSException {
		lExp = parm1;
	}

	/**
	 * Method getJMSPriority
	 *
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public int getJMSPriority() throws JMSException {
		return iPrt;
	}

	/**
	 * Method setJMSPriority
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 */
	public void setJMSPriority(int parm1) throws JMSException {
		iPrt = parm1;
	}

	/**
	 * Method clearProperties
	 *
	 *
	 @throws JMSException
	 *
	 */
	public void clearProperties() throws JMSException {
		oPrp.clear();
	}

	/**
	 * Method propertyExists
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public boolean propertyExists(String parm1) throws JMSException {
		return oPrp.containsKey(parm1);
	}

	/**
	 * Method getBooleanProperty
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public boolean getBooleanProperty(String parm1) throws JMSException {
		return ((Boolean) oPrp.get(parm1)).booleanValue();
	}

	/**
	 * Method getByteProperty
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public byte getByteProperty(String parm1) throws JMSException {
		return ((Byte) oPrp.get(parm1)).byteValue();
	}

	/**
	 * Method getShortProperty
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public short getShortProperty(String parm1) throws JMSException {
		return ((Short) oPrp.get(parm1)).shortValue();
	}

	/**
	 * Method getIntProperty
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public int getIntProperty(String parm1) throws JMSException {
		return ((Integer) oPrp.get(parm1)).intValue();
	}

	/**
	 * Method getLongProperty
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public long getLongProperty(String parm1) throws JMSException {
		return ((Long) oPrp.get(parm1)).longValue();
	}

	/**
	 * Method getFloatProperty
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public float getFloatProperty(String parm1) throws JMSException {
		return ((Float) oPrp.get(parm1)).floatValue();
	}

	/**
	 * Method getDoubleProperty
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public double getDoubleProperty(String parm1) throws JMSException {
		return ((Double) oPrp.get(parm1)).doubleValue();
	}

	/**
	 * Method getStringProperty
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public String getStringProperty(String parm1) throws JMSException {
		return (String) oPrp.get(parm1);
	}

	/**
	 * Method getObjectProperty
	 *
	 *
	 * @param parm1
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public Object getObjectProperty(String parm1) throws JMSException {
		return oPrp.get(parm1);
	}

	/**
	 * Method getPropertyNames
	 *
	 *
	 @throws JMSException
	 *
	 * @return
	 *
	 */
	public Enumeration getPropertyNames() throws JMSException {
		return oPrp.keys();
	}

	/**
	 * Method setBooleanProperty
	 *
	 *
	 * @param parm1
	 * @param parm2
	 *
	 @throws JMSException
	 *
	 */
	public void setBooleanProperty(String parm1, boolean parm2) throws JMSException {
		oPrp.put(parm1, new Boolean(parm2));
	}

	/**
	 * Method setByteProperty
	 *
	 *
	 * @param parm1
	 * @param parm2
	 *
	 @throws JMSException
	 *
	 */
	public void setByteProperty(String parm1, byte parm2) throws JMSException {
		oPrp.put(parm1, new Byte(parm2));
	}

	/**
	 * Method setShortProperty
	 *
	 *
	 * @param parm1
	 * @param parm2
	 *
	 @throws JMSException
	 *
	 */
	public void setShortProperty(String parm1, short parm2) throws JMSException {
		oPrp.put(parm1, new Short(parm2));
	}

	/**
	 * Method setIntProperty
	 *
	 *
	 * @param parm1
	 * @param parm2
	 *
	 @throws JMSException
	 *
	 */
	public void setIntProperty(String parm1, int parm2) throws JMSException {
		oPrp.put(parm1, new Integer(parm2));
	}

	/**
	 * Method setLongProperty
	 *
	 *
	 * @param parm1
	 * @param parm2
	 *
	 @throws JMSException
	 *
	 */
	public void setLongProperty(String parm1, long parm2) throws JMSException {
		oPrp.put(parm1, new Long(parm2));
	}

	/**
	 * Method setFloatProperty
	 *
	 *
	 * @param parm1
	 * @param parm2
	 *
	 @throws JMSException
	 *
	 */
	public void setFloatProperty(String parm1, float parm2) throws JMSException {
		oPrp.put(parm1, new Float(parm2));
	}

	/**
	 * Method setDoubleProperty
	 *
	 *
	 * @param parm1
	 * @param parm2
	 *
	 @throws JMSException
	 *
	 */
	public void setDoubleProperty(String parm1, double parm2) throws JMSException {
		oPrp.put(parm1, new Double(parm2));
	}

	/**
	 * Method setStringProperty
	 *
	 *
	 * @param parm1
	 * @param parm2
	 *
	 @throws JMSException
	 *
	 */
	public void setStringProperty(String parm1, String parm2) throws JMSException {
		oPrp.put(parm1, parm2);
	}

	/**
	 * Method setObjectProperty
	 *
	 *
	 * @param parm1
	 * @param parm2
	 *
	 @throws JMSException
	 *
	 */
	public void setObjectProperty(String parm1, Object parm2) throws JMSException {
		oPrp.put(parm1, parm2);
	}

	/**
	 * Method acknowledge
	 *
	 *
	 @throws JMSException
	 *
	 */
	public void acknowledge() throws JMSException {
		// TODO: Add your code here
	}

	/**
	 * Method clearBody
	 *
	 *
	 @throws JMSException
	 *
	 */
	public void clearBody() throws JMSException {
		oObj = null;
	}	
}
