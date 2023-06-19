package com.knowgate.marketing;

import java.sql.SQLException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;

import com.knowgate.debug.DebugFile;
import com.knowgate.jdc.JDCConnection;
import com.knowgate.dataobjs.DB;
import com.knowgate.dataobjs.DBBind;
import com.knowgate.dataobjs.DBPersist;

public class ActivityTag extends DBPersist {

  public ActivityTag() {
    super(DB.k_activity_tags, "ActivityTag");
  }

  public boolean exists(JDCConnection oConn) throws SQLException {
    PreparedStatement oStmt = oConn.prepareStatement("SELECT NULL FROM "+
	                                                 DB.k_activity_tags+" WHERE "+DB.gu_activity+"=? AND "+
	    		                                     DBBind.Functions.LOWER+"("+DB.nm_tag+")="+DBBind.Functions.LOWER+"(?)",
	    		                                     ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_READ_ONLY);
	oStmt.setString(1, getStringNull(DB.gu_activity,""));
	oStmt.setString(2, getStringNull(DB.nm_tag,""));
	ResultSet oRSet = oStmt.executeQuery();
	boolean bRetVal = oRSet.next();
	oRSet.close();
	oStmt.close();

	return bRetVal;
  } // exists

  public boolean load(JDCConnection oConn, Object[] aPK) throws SQLException {
    PreparedStatement oStmt = oConn.prepareStatement("SELECT "+DB.gu_activity+","+DB.tp_tag+","+DB.nm_tag+" FROM "+
                                                     DB.k_activity_tags+" WHERE "+DB.gu_activity+"=? AND "+
    		                                         DBBind.Functions.LOWER+"("+DB.nm_tag+")="+DBBind.Functions.LOWER+"(?)",
    		                                         ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_READ_ONLY);
    oStmt.setObject(1, aPK, Types.CHAR);
    oStmt.setObject(2, aPK, Types.VARCHAR);
    ResultSet oRSet = oStmt.executeQuery();
    boolean bRetVal = oRSet.next();
    if (bRetVal) {
      put(DB.gu_activity, oRSet.getString(1));
      put(DB.tp_tag, oRSet.getString(2));
      put(DB.nm_tag, oRSet.getString(3));
    } else {
      clear();
    }
    oRSet.close();
    oStmt.close();

    return bRetVal;
  } // load

  public boolean store(JDCConnection oConn) throws SQLException {

	PreparedStatement oStmt = oConn.prepareStatement("DELETE FROM "+
                              DB.k_activity_tags+" WHERE "+DB.gu_activity+"=? AND "+
                              DBBind.Functions.LOWER+"("+DB.nm_tag+")="+DBBind.Functions.LOWER+"(?)");
	oStmt.setString(1, getStringNull(DB.gu_activity,""));
	oStmt.setString(2, getStringNull(DB.nm_tag,""));
	oStmt.executeUpdate();
	oStmt.close();

	oStmt = oConn.prepareStatement("INSERT INTO "+DB.k_activity_tags+
    		                       " ("+DB.gu_activity+","+DB.tp_tag+","+DB.nm_tag+") VALUES (?,?,?)");
    if (isNull(DB.gu_activity))
      oStmt.setNull(1, Types.CHAR);
    else
	  oStmt.setString(1, getString(DB.gu_activity));
    if (isNull(DB.tp_tag))
      oStmt.setNull(2, Types.VARCHAR);
    else
  	  oStmt.setString(2, getString(DB.tp_tag));
    if (isNull(DB.nm_tag))
      oStmt.setNull(2, Types.VARCHAR);
    else
      oStmt.setString(2, getString(DB.nm_tag));
    oStmt.executeUpdate();
    oStmt.close();

    return true;
  } // store

  public static void storeMultiple(JDCConnection oConn, String sGuActivity, String sTpTag, String[] aTags) throws SQLException {
    PreparedStatement oStmt = oConn.prepareStatement("DELETE FROM "+
                                                      DB.k_activity_tags+" WHERE "+DB.gu_activity+"=?");
    oStmt.setString(1, sGuActivity);
    oStmt.executeUpdate();
    oStmt.close();

    oStmt = oConn.prepareStatement("INSERT INTO "+DB.k_activity_tags+
            " ("+DB.gu_activity+","+DB.tp_tag+","+DB.nm_tag+") VALUES (?,?,?)");

    oStmt.setString(1, sGuActivity);

    if (null==sTpTag)
      oStmt.setNull(2, Types.VARCHAR);
    else
      oStmt.setString(2, sTpTag);

    if (aTags!=null) {
      final int nTags = aTags.length;
      for (int t=0; t<nTags; t++) {
    	if (null!=aTags[t]) {
    	  oStmt.setString(3, aTags[t]);
    	  oStmt.executeUpdate();
    	} // fi
      } // next
    } // fi
    
    oStmt.close();
  } // store

  // **********************************************************
  // Public Constants
  
  public static final short ClassId = 313;
	
}
