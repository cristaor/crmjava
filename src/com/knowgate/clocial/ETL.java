package com.knowgate.clocial;

import java.sql.SQLException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.knowgate.storage.RecordSet;
import com.knowgate.storage.Table;
import com.knowgate.storage.DataSource;
import com.knowgate.storage.StorageException;
import com.knowgate.jdc.JDCConnection;
import com.knowgate.dataobjs.DB;
import com.knowgate.dataobjs.DBSubset;
import com.knowgate.clocial.UserAccount;
import com.knowgate.clocial.UserAccountAlias;
import com.knowgate.syndication.fetcher.AuthorGuessing;

public class ETL {
	
  private static void copyMemberToAccount(DBSubset oDbs, UserAccount oUsr, String sGuAccount, int r) {
      oUsr.replace("gu_account", sGuAccount);
      if (!oDbs.isNull(2, r))
	      oUsr.replace("gu_company",oDbs.getString(2, r));
	    else
		  oUsr.remove("gu_company");
      if (!oDbs.isNull(7, r))
	      oUsr.replace("nm_user",oDbs.getString(7, r));
	    else
		  oUsr.remove("nm_user");
      if (!oDbs.isNull(8, r))
	      oUsr.replace("tx_surname1",oDbs.getString(8, r));
	    else
		  oUsr.remove("tx_surname1");
	    oUsr.replace("full_name",oDbs.getStringNull(7,r,"")+" "+oDbs.getStringNull(8,r,""));
      if (!oDbs.isNull(9, r))
        oUsr.replace("tx_main_email",oDbs.getString(9, r));
      else
	      oUsr.remove("tx_main_email");	        
      if (!oDbs.isNull(10, r))
	      oUsr.replace("nm_company",oDbs.getString(10, r));
	    else
		  oUsr.remove("nm_company");
      if (!oDbs.isNull(11, r))
	      oUsr.replace("id_country",oDbs.getString(11, r).trim());
	    else
		  oUsr.remove("id_country");
      if (!oDbs.isNull(12, r))
	      oUsr.replace("tp_passport",oDbs.getString(12, r));
	    else
		  oUsr.remove("tp_passport");
      if (!oDbs.isNull(13, r))
	      oUsr.replace("sn_passport",oDbs.getString(13, r));
	    else
		  oUsr.remove("sn_passport");
  }

  private static void copyMemberToAlias(DBSubset oDbs, UserAccountAlias oUal, String sGuAccount, String sNmService, int r) {
    oUal.replace("gu_account", sGuAccount);
    oUal.replace("nm_service", sNmService);
    oUal.replace("nm_alias", AuthorGuessing.extractAuthorFromURL(oDbs.getString("url_"+sNmService, r)));
    oUal.replace("nm_display", oDbs.getStringNull(DB.tx_name, r, "")+" "+oDbs.getStringNull(DB.tx_surname, r, ""));
    oUal.replace("url_addr", oDbs.getString("url_"+sNmService, r));    
  }
  
  public static void copyMemberAddressToUserAccounts(JDCConnection oSourceCon, DataSource oTargetDts, String sGuWorkArea)
    throws StorageException, InstantiationException {
	Integer iDomain;
	UserAccount oUsr = new UserAccount(oTargetDts);
	UserAccountAlias oUal = new UserAccountAlias(oTargetDts);
	Table oUac=null,oUaa=null;
	DBSubset oDbs = new DBSubset(DB.k_member_address, DB.gu_address+","+DB.gu_contact+","+DB.gu_company+","+DB.url_addr+","+DB.url_linkedin+","+DB.url_facebook+","+DB.url_twitter+","+
													  DB.tx_name+","+DB.tx_surname+","+DB.tx_email+","+DB.nm_legal+","+DB.id_country+","+DB.tp_passport+","+DB.sn_passport, DB.gu_workarea+"=?",10000);
	try {
	  PreparedStatement oStmt = oSourceCon.prepareStatement("SELECT id_domain FROM k_workareas WHERE gu_workarea=?");
	  oStmt.setString(1, sGuWorkArea);
	  ResultSet oRst = oStmt.executeQuery();
	  if (oRst.next())
		iDomain = new Integer(oRst.getInt(1));
	  else
		iDomain = null;
	  oRst.close();
	  oStmt.close();	  
	  if (null==iDomain) throw new StorageException("WorkArea "+sGuWorkArea+" not found");		  
	  oUsr.put("id_domain",iDomain);
	  final int nDbs = oDbs.load(oSourceCon,new Object[]{sGuWorkArea});
  	  oUac = oTargetDts.openTable(oUsr);
  	  oUaa = oTargetDts.openTable(oUal);

	  for (int r=0; r<nDbs; r++) {
		String sGuAccount = oDbs.getStringNull(1, r, oDbs.getString(2, r));
		RecordSet oRSet;
		int nRSet = 0;
		if (!oDbs.isNull(3, r)) {
		  oRSet = oUaa.fetch("url_addr", oDbs.getString(3, r));
		  nRSet = oRSet.size();
		}
		boolean bUrlAlreadyExists = (nRSet>0);
		boolean bLinkedInAlreadyExists = (oDbs.isNull(4, r) ? false : oUaa.exists(UserAccountAlias.makeId("linkedin", oDbs.getString(4, r))));
		boolean bFacebookAlreadyExists = (oDbs.isNull(5, r) ? false : oUaa.exists(UserAccountAlias.makeId("facebook", oDbs.getString(5, r))));
		boolean bTwitterAlreadyExists  = (oDbs.isNull(6, r) ? false : oUaa.exists(UserAccountAlias.makeId("twitter" , oDbs.getString(6, r))));
		boolean bAccountAlreadyExists = bUrlAlreadyExists || bLinkedInAlreadyExists || bFacebookAlreadyExists || bTwitterAlreadyExists;
		if (!bAccountAlreadyExists) {
		  copyMemberToAccount(oDbs, oUsr, sGuAccount, r); 
		  oUsr.store(oUac);			
		}
		if (!oDbs.isNull(3, r) && !bUrlAlreadyExists) {
		  oUal.replace("gu_account", sGuAccount);
		  oUal.replace("nm_service", "url");
		  oUal.replace("nm_alias", oDbs.getString("url_addr", r));
		  oUal.replace("nm_display", oDbs.getStringNull(DB.tx_name, r, "")+" "+oDbs.getStringNull(DB.tx_surname, r, ""));
		  oUal.replace("url_addr", oDbs.getString("url_addr", r));    
		}
		if (!oDbs.isNull(4, r) && !bLinkedInAlreadyExists) {
		  copyMemberToAlias(oDbs, oUal, sGuAccount, "linkedin", r);
		  oUal.store(oUaa);
		}
		if (!oDbs.isNull(5, r) && !bFacebookAlreadyExists) {
	      copyMemberToAlias(oDbs, oUal, sGuAccount, "facebook", r);
		  oUal.store(oUaa);
	    }
		if (!oDbs.isNull(6, r) && !bTwitterAlreadyExists) {
		  copyMemberToAlias(oDbs, oUal, sGuAccount, "twitter", r);
		  oUal.store(oUaa);
	    }
	  } // next
	  oUaa.close();
	  oUaa=null;
	  oUac.close();
	  oUac=null;
	} catch (SQLException sqle) {
	  if (oUaa!=null) { try { oUaa.close(); } catch (SQLException ignore) {} }
	  if (oUac!=null) { try { oUac.close(); } catch (SQLException ignore) {} }
	  throw new StorageException(sqle.getMessage(), sqle);
	}
  }
}
