<%@ page import="java.math.BigDecimal,java.util.Date,java.io.IOException,java.net.URLDecoder,java.sql.SQLException,com.knowgate.jdc.JDCConnection,com.knowgate.dataobjs.*,com.knowgate.hipergate.*,com.knowgate.crm.Contact" language="java" session="false" contentType="text/plain;charset=UTF-8" %>
<%@ include file="../../methods/dbbind.jsp" %><%@ include file="../../methods/cookies.jspf" %><%@ include file="../../methods/authusrs.jspf" %><%@ include file="../../methods/nullif.jspf" %>
<% 
  
  if (autenticateSession(GlobalDBBind, request, response)<0) return;

  String sLanguage = getNavigatorLanguage(request);
      
  String gu_contact = request.getParameter("gu_contact");
  String gu_workarea = request.getParameter("gu_workarea");
  String gu_shop = request.getParameter("gu_shop");
  String gu_category = request.getParameter("gu_category");
  String gu_address = request.getParameter("gu_address");
  String gu_owner = getCookie (request, "userid", null);

  final long OneYearMilis = 31536000000l;
  
  Date dtStart = new Date();
  Date dtEnd = new Date(dtStart.getTime()+OneYearMilis);
  BigDecimal oZero = new BigDecimal("0");
  JDCConnection oConn = null;
  Contact oCont = new Contact();
  Product oProd = new Product();
  Category oCatg = new Category();
  Order oOrdr = new Order();
    
  try {
    oConn = GlobalDBBind.getConnection("product_request_store");
    
    oCont.load(oConn, gu_contact);

    oCatg.load(oConn, gu_category);

    oProd.put(DB.gu_owner, gu_owner);
    oProd.put(DB.nm_product, oCatg.getLabel(oConn, sLanguage));
    oProd.put(DB.de_product, (oCont.getStringNull(DB.tx_name,"")+" "+oCont.getStringNull(DB.tx_surname,"")).trim());
    oProd.put(DB.dt_start, dtStart);
    oProd.put(DB.dt_end, dtEnd);
    oProd.put(DB.gu_address, gu_address);
    oProd.put(DB.tag_product, gu_contact);
    oProd.put(DB.pr_list, oZero); 
    oProd.put(DB.pr_sale, oZero); 
    oProd.put (DB.id_currency, "978");
    
    oOrdr.put (DB.gu_workarea, gu_workarea);
    oOrdr.put (DB.gu_shop, gu_shop);
    oOrdr.put (DB.id_currency, "978");
    oOrdr.put (DB.gu_sales_man, gu_owner);
    oOrdr.put (DB.gu_contact, gu_contact);
    oOrdr.put (DB.nm_client, (oCont.getStringNull(DB.tx_name,"")+" "+oCont.getStringNull(DB.tx_surname,"")).trim());
    oOrdr.put(DB.de_order, oProd.getString(DB.nm_product)+" "+oCont.getStringNull(DB.id_ref,""));
    if (!oCont.isNull(DB.sn_passport))
      oOrdr.put (DB.id_legal, oCont.getString(DB.sn_passport));
    oOrdr.put(DB.gu_ship_addr, gu_address);
    oOrdr.put(DB.gu_bill_addr, gu_address);
    	
    oConn.setAutoCommit(false);
    
    oProd.store (oConn);
    oProd.addToCategory(oConn, gu_category, 1);
    
    oOrdr.store(oConn);
    oOrdr.addProduct(oConn, oProd.getString(DB.gu_product), 1f);

    oConn.commit();
      
    oConn.close("product_request_store");
  }
  catch (SQLException e) {  
    if (oConn!=null)
      if (!oConn.isClosed()) {
        oConn.rollback();
        oConn.close("product_request_store");
      }
    oConn = null;
    response.sendRedirect (response.encodeRedirectUrl ("../../common/errmsg.jsp?title=SQLException&desc=" + e.getLocalizedMessage() + "&resume=_back"));
  }
  catch (NumberFormatException e) {
    if (oConn!=null)
      if (!oConn.isClosed()) {
        oConn.rollback();
        oConn.close("product_request_store");
      }
    oConn = null;
    response.sendRedirect (response.encodeRedirectUrl ("../../common/errmsg.jsp?title=NumberFormatException&desc=" + e.getMessage() + "&resume=_back"));
  }
  
  if (null==oConn) return;    
  oConn = null;

  response.sendRedirect (response.encodeRedirectUrl ("../contact_edit.jsp?id_domain="+request.getParameter("id_domain")+"&n_domain="+request.getParameter("n_domain")+"&gu_contact="+request.getParameter("gu_contact")));

%>