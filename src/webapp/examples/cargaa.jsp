<%@ page import="java.sql.Timestamp,java.sql.PreparedStatement,java.sql.SQLException,java.util.Date,java.util.regex.*,java.util.ArrayList,java.util.HashMap,com.knowgate.misc.CSVParser,com.knowgate.misc.Gadgets,com.knowgate.jdc.JDCConnection,com.knowgate.dataobjs.*,com.knowgate.crm.*,com.knowgate.hipergate.Address,com.knowgate.training.AcademicCourseBooking" language="java" session="false" contentType="text/plain;charset=UTF-8" %><%@ include file="../methods/dbbind.jsp" %><% 

  final String PAGE_NAME = "carga_auriga";
  final String GU_WORKAREA = "0a000003136df53a9401000319acf5ce";

	final int id_ref = 0; // Puede ser nº o nº+abcd...
	final int tp_origin = 1;
	final int tx_name = 2;
	final int tx_surname = 3;
	final int tx_surname2 = 4;
	final int sn_passport = 5;
	final int phone = 6; // Movil si empieza por 6 fijo en otro caso pudiendo haber varios separados por /
	final int tx_email = 7;
	final int nm_street = 8;
  final int zipcode = 9; // XXXXX + Municipio + (Provincia)	
	// Conductor
	final int tx_driver_name = 10;
	final int tx_driver_surname = 11;
	final int tx_driver_surname2 = 12;
	final int sn_driver_passport = 13;
	final int driver_phone = 14;
	final int tx_driver_email = 15;
	final int nm_driver_street = 16;
  final int driver_zipcode = 17;
  final int nm_state = 18;
  final int driver_nationality = 19;
  final int id_salutation = 20;
  final int id_circuit = 21;
  final int id_course = 22;
  final int id_turn = 23;
  final int dt_quotation = 24;
  final int nu_quotation = 25;
  final int bo_quotation = 26;
  final int bo_paid = 27;
  final int im_revenue = 28;
  final int bo_confirmed = 29;
  final int nu_invoice = 30;
  final int tx_note = 31;
  final int tx_note2 = 32;
  final int bo_buys = 33;
  final int tx_note3 = 34;
 
  Pattern oIdRef = Pattern.compile("\\x2A?\\d+");
  Pattern oCalled1 = Pattern.compile("LLAMADO EL D?I?A?\\s?(\\d\\d/\\d{1,2})",Pattern.CASE_INSENSITIVE);
  Pattern oCalled2 = Pattern.compile("Llamo el dia\\s?(\\d\\d/\\d{1,2})",Pattern.CASE_INSENSITIVE);
  Pattern oFullZip = Pattern.compile("(\\d{5})\\s+([,-ÿ]|\\s)+\\x28([,-ÿ]|\\s)+\\x29");
  Pattern oPartZip = Pattern.compile("(\\d{5})\\s+([,-ÿ]|\\s)+");
  
  JDCConnection oConn = null;  
  Contact oCont;
  Address oAddr;
  Oportunity oOprt;
  PhoneCall oPhnc;

  CSVParser oCsv = new CSVParser("ISO8859_1");
  oCsv.parseFile("C:\\Temp\\CargaAuriga.txt", "id_ref\ttp_origin\ttx_name\ttx_surname\ttx_surname2\tsn_passport\tphone\ttx_email\ttx_addr1\tzipcode\ttx_driver_name\ttx_driver_surname\ttx_driver_surname2\tsn_driver_passport\tdriver_phone\ttx_driver_email\ttx_driver_addr1\tdriver_zipcode\tnm_state\tdriver_nationality\tid_salutation\tid_circuit\tid_course\tid_turn\tdt_quotation\tnu_quotation\tbo_quotation\tbo_paid\tim_revenue\tbo_confirmed\tnu_invoice\ttx_note\ttx_note2\tbo_buys\ttx_note3;");
  final int nLines = oCsv.getLineCount();
  int l = -1;
 
  try {
    oConn = GlobalDBBind.getConnection(PAGE_NAME);
    
    DBSubset oProvs = new DBSubset("k_lu_states", "nm_state,id_state", "id_country='es'", 55);
    oProvs.load(oConn);
    oProvs.sortBy(0);

    oConn.setAutoCommit(false);
    
    DBSubset oClear = new DBSubset(DB.k_contacts, DB.gu_contact, DB.gu_workarea+"=? AND id_batch='PrecargaAuriga'", 1000);
    int nContacts = oClear.load(oConn, new Object[]{GU_WORKAREA});
    for (int c=0; c<nContacts; c++) {
      Contact.delete(oConn, oClear.getString(0,c));
    }
    
    String sFormerOportunity = null;
    for (l=0; l<nLines; l++) {
			
      boolean bNewLead = oIdRef.matcher(oCsv.getField(id_ref,l)).matches();
      
			oCont = new Contact();
			if (oCsv.getField(id_salutation,l).indexOf("Estimado")>=0)
			  oCont.put (DB.id_gender,"M");
			else if (oCsv.getField(id_salutation,l).indexOf("Estimada")>=0)
			  oCont.put (DB.id_gender,"F");
			oCont.put (DB.gu_workarea,GU_WORKAREA);
			oCont.put (DB.bo_restricted,(short) 0);
			oCont.put (DB.bo_private,(short) 0);
			oCont.put (DB.nu_notes,0);
			oCont.put (DB.nu_attachs,0);
			oCont.put ("id_batch","PrecargaAuriga");
			oCont.put (DB.de_title, bNewLead ? "CUSTOMER" : "DRIVER");
			oCont.put (DB.id_ref,oCsv.getField(id_ref,l).trim());
			oCont.put (DB.tx_name,oCsv.getField(bNewLead ? tx_name : tx_driver_name,l).trim().toUpperCase());
			if (!oCont.isNull(DB.tx_name) && oCont.getStringNull(DB.tx_name,"").length()==0) oCont.remove (DB.tx_name);
			oCont.put (DB.tx_surname,(oCsv.getField(bNewLead ? tx_surname : tx_driver_surname,l)+" "+oCsv.getField(bNewLead ? tx_surname2 : tx_driver_surname2,l)).trim().toUpperCase());
			if (!oCont.isNull(DB.tx_surname) && oCont.getStringNull(DB.tx_surname,"").length()==0) oCont.remove (DB.tx_surname);
			oCont.put (DB.sn_passport,Gadgets.left(oCsv.getField(bNewLead ? sn_passport : sn_driver_passport,l).trim().toUpperCase(),16));
			oCont.store(oConn);

			oAddr = new Address();
			oAddr.put(DB.ix_address,1);
			oAddr.put (DB.gu_workarea,GU_WORKAREA);
			oAddr.put (DB.bo_active,(short) 1);
			if (oCsv.getField(bNewLead ? nm_street : nm_driver_street,l).trim().length()>0)
			  oAddr.put (DB.nm_street,Gadgets.left(oCsv.getField(bNewLead ? nm_street : nm_driver_street,l).trim().toUpperCase(),100));
			oAddr.put (DB.tx_email,Gadgets.left(oCsv.getField(bNewLead ? tx_email : tx_driver_email,l).trim().toLowerCase(),100));
			if (oCsv.getField(bNewLead ? phone : driver_phone,l).trim().length()>0) {
			  String aPhones[] = oCsv.getField(bNewLead ? phone : driver_phone,l).split("/");
			  if (aPhones!=null) {
			    for (int p=0; p<aPhones.length; p++) {
			      String sPhone = Gadgets.left(aPhones[p].trim(),16);
						oAddr.put (sPhone.charAt(0)=='6' ? DB.mov_phone : DB.direct_phone, sPhone);
          }
        }
			}
			Matcher oMatch = oFullZip.matcher(oCsv.getField(bNewLead ? zipcode : driver_zipcode,l));
			if (oMatch.matches()) {
			  oAddr.put (DB.zipcode,oMatch.group(1).trim());
			  oAddr.put (DB.mn_city,oMatch.group(2).trim().toUpperCase());
			  oAddr.put (DB.nm_state,oMatch.group(3).trim().toUpperCase());
			} else {
			  oMatch = oPartZip.matcher(oCsv.getField(bNewLead ? zipcode : driver_zipcode,l));
			  if (oMatch.matches()) {
			    oAddr.put (DB.zipcode,oMatch.group(1).trim());
			    oAddr.put (DB.mn_city,oMatch.group(2).trim().toUpperCase());
			    oAddr.put (DB.nm_state,oMatch.group(2).trim().toUpperCase());
			  }
			}
			oAddr.put (DB.nm_country,"España");
			oAddr.put (DB.id_country,"es");
			if (oAddr.getStringNull(DB.nm_state,"").length()>0) {
			  int iIdState = oProvs.binaryFind(0,oAddr.getString(DB.nm_state));
			  if (iIdState>=0) oAddr.put (DB.id_state,oProvs.getString(1,iIdState));
			}

			oAddr.store(oConn);
			oCont.addAddress(oConn, oAddr.getString(DB.gu_address));

      if (bNewLead) {
				oOprt = new Oportunity();
			  oOprt.put (DB.gu_workarea,GU_WORKAREA);
			  oOprt.put (DB.gu_campaign, "0a000003136df7a9d1810001cb53725d");
			  oOprt.put (DB.gu_writer,"0a000003136df56d53410003298cf758");
			  oOprt.put (DB.bo_private,(short) 0);
			  oOprt.put (DB.nu_oportunities,1);
			  oOprt.put (DB.gu_contact, oCont.getString(DB.gu_contact));
			  oOprt.put (DB.tx_contact, oCont.getStringNull(DB.tx_name,"")+" "+oCont.getStringNull(DB.tx_surname,""));
			  String sLevel = oCsv.getField(id_course,l).toUpperCase();
			  if (sLevel.length()>0) {
			    if (sLevel.indexOf("NIVEL 1")>0)
			      sLevel = "NIVEL 1";
			    else if (sLevel.indexOf("NIVEL 2")>0)
			      sLevel = "NIVEL 2";
			    else if (sLevel.indexOf("NIVEL 3")>0)
			      sLevel = "NIVEL 3";
			  }
			  oOprt.put (DB.tl_oportunity, oCsv.getField(id_circuit,l)+" "+sLevel+" "+oCsv.getField(id_turn,l));
				if (oOprt.getStringNull(DB.tl_oportunity,"").trim().length()==0) {
				  oOprt.replace (DB.tl_oportunity, "SIN CURSO DEFINIDO");
			  } else {
			    String sObjetive = DBCommand.queryStr(oConn, "SELECT gu_acourse FROM k_academic_courses WHERE nm_course='"+oCsv.getField(id_circuit,l)+" "+sLevel+" "+oCsv.getField(id_turn,l)+"'");
			    if (null!=sObjetive) {
			      oOprt.put (DB.id_objetive, sObjetive);
			    }
			  }		    
				String sTpOrigin = oCsv.getField(tp_origin,l).toUpperCase();    
				if (sTpOrigin.indexOf("FORMULARIO WEB")>=0)
			    oOprt.put (DB.tp_origin, "INTERNET");
				else if (sTpOrigin.indexOf("BMW")>=0)
			    oOprt.put (DB.tp_origin, "BMWCUSTOMER");
				else if (sTpOrigin.indexOf("TELEFONO")>=0)
			    oOprt.put (DB.tp_origin, "902");
				else if (sTpOrigin.indexOf("AMIGO")>=0)
			    oOprt.put (DB.tp_origin, "REFER");
				else if (sTpOrigin.indexOf("AMIGO")>=0)
			    oOprt.put (DB.tp_origin, "REFER");
				else if (sTpOrigin.indexOf("NEWSLETTER")>=0)
			    oOprt.put (DB.tp_origin, "E-MAILING");
				else if (sTpOrigin.indexOf("AURIGA")>=0)
			    oOprt.put (DB.tp_origin, "AURIGA");
			  oOprt.put(DB.tx_note, oCsv.getField(tx_note,l)+"\n"+oCsv.getField(tx_note2,l)+"\n"+oCsv.getField(tx_note3,l));

			  oOprt.put(DB.id_status, "NUEVA");
			  
			  if (oCsv.getField(bo_quotation,l).trim().toUpperCase().equals("SI")) {
			    oOprt.put(DB.id_status, "QUOTATIONSEND");
			  }

			  if (oCsv.getField(nu_quotation,l).trim().length()>0) {
			    oOprt.put(DB.im_cost, (float) Integer.parseInt(oCsv.getField(nu_quotation,l)));
			    oOprt.put(DB.id_status, "QUOTATIONSEND");			    
			  }

			  if (oCsv.getField(bo_buys,l).trim().toUpperCase().equals("SI")) {
			    oOprt.put(DB.id_status, "GANADA");
			    oOprt.put(DB.tx_cause, "VENTA");
			  }

			  if (oCsv.getField(bo_paid,l).trim().toUpperCase().equals("SI")) {
			    oOprt.put(DB.id_status, "PAGADO");
			    oOprt.put(DB.tx_cause, "VENTA");
			  }

			  if (oCsv.getField(im_revenue,l).trim().length()>0) {
			    oOprt.put(DB.im_revenue, (float) Integer.parseInt(oCsv.getField(im_revenue,l)));
			  }
			  
				oOprt.store(oConn);
				sFormerOportunity = oOprt.getString(DB.gu_oportunity);
				
				String sTxNote = oCsv.getField(tx_note,l);
				oMatch = oCalled1.matcher(sTxNote);
				if (oMatch.find()) {
				  String sDate = oMatch.group(1);
				  String[] aDayMonth = sDate.split("/");
				  oPhnc = new PhoneCall();
				  oPhnc.put(DB.tp_phonecall,"S");
				  oPhnc.put(DB.gu_workarea,GU_WORKAREA);
				  oPhnc.put(DB.gu_writer,"0a000003137e684e155103253fb50b26");
				  oPhnc.put(DB.id_status,(short) 1);
				  oPhnc.put(DB.gu_contact,oCont.getString(DB.gu_contact));
				  oPhnc.put(DB.gu_oportunity,oOprt.getString(DB.gu_oportunity));
				  if (!oAddr.isNull(DB.mov_phone))
				    oPhnc.put(DB.tx_phone,oAddr.getString(DB.mov_phone));
				  oPhnc.put(DB.tx_comments, sTxNote);
				  oPhnc.put(DB.dt_start, new Date(112, Integer.parseInt(aDayMonth[1])-1,Integer.parseInt(aDayMonth[0])));
				  oPhnc.store(oConn);
				  PreparedStatement oStmt = oConn.prepareStatement("UPDATE k_oportunities SET dt_last_call=? WHERE gu_oportunity=?");
				  oStmt.setTimestamp(1, new Timestamp(oPhnc.getDate(DB.dt_start).getTime()));
				  oStmt.setString(2, oOprt.getString(DB.gu_oportunity));
				  oStmt.executeUpdate();
				  oStmt.close();
				}			

      } else {
        DBPersist oOpCn = new DBPersist("k_x_oportunity_contacts", "OpCn");
        oOpCn.put(DB.gu_contact, oCont.getString(DB.gu_contact));
        oOpCn.put(DB.gu_oportunity, sFormerOportunity);
        oOpCn.put("tp_relation","DRIVER");
        oOpCn.store(oConn);
      }
      
      oOprt = new Oportunity();
      oOprt.load(oConn, new Object[]{sFormerOportunity});
      if (!oOprt.isNull(DB.id_objetive)) {
        String sIdStat = oOprt.getStringNull(DB.id_status,"");
        if (sIdStat.equals("GANADA") || sIdStat.equals("PAGADO")) {
          AcademicCourseBooking oBook = new AcademicCourseBooking();
          oBook.put(DB.gu_acourse, oOprt.getString(DB.id_objetive));
          oBook.put(DB.gu_contact, oCont.getString(DB.gu_contact));
          oBook.put(DB.bo_confirmed, (short) 1);
          oBook.put(DB.bo_canceled, (short)0);
          oBook.put(DB.bo_waiting, (short) 0);
          oBook.put(DB.bo_paid, (short) (sIdStat.equals("PAGADO") ? 1 : 0));
          oBook.store(oConn);
          oBook.createAlumni(oConn);
        }
      }

    }
    
    oConn.commit();
      
    oConn.close(PAGE_NAME);
    
    out.write("Carga completada con exito");
  }
  catch (Exception e) {  
    disposeConnection(oConn,PAGE_NAME);
    oConn = null;
    out.write("Linea "+String.valueOf(l+1)+" "+e.getClass().getName()+" "+e.getMessage());
  }
  
  if (null==oConn) return;    
  oConn = null;

  /* TO DO: Write HTML or redirect to another page */
%>