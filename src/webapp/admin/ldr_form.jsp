<%@ page import="java.util.Iterator,java.util.HashMap,com.knowgate.dataobjs.DBBind,com.knowgate.misc.Environment" language="java" session="false" contentType="text/html;charset=UTF-8" %><%

  DBBind oDbb = new DBBind(request.getParameter("con_target")==null ? "hipergate" : request.getParameter("con_target")); 

  HashMap oTbl = oDbb.getDBTablesMap();

%><HTML>
<HEAD>
  <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
  <SCRIPT TYPE="text/javascript" SRC="../javascript/cookies.js"></SCRIPT>  
  <SCRIPT TYPE="text/javascript" SRC="../javascript/setskin.js"></SCRIPT>
  <SCRIPT TYPE="text/javascript" SRC="../javascript/combobox.js"></SCRIPT>

  <SCRIPT TYPE="text/javascript">
    function setCombos() {
      parent.frames[1].document.location="../common/blank.htm";
    	sortCombo (document.forms[0].tbl_target);
    }  
  </SCRIPT>
</HEAD>
<BODY onLoad="setCombos()">
  <table width="100%" cellspacing="0" cellpadding="0" border="0">
    <tr>
      <td align="left" class="striptitle">
        <font class="title1">[~Cargar datos en una tabla~]</font>
      </td>
      <td align="right">
        <table width="200" cellspacing="0" cellpadding="0" border="0">
        <!-- Linea de arriba menu superior derecho -->
        <tr>
          <!-- col 1 -->
          <td width="3"  height="3"><img src="../images/images/tabmenu/esq1.gif" width="3" height="3" border="0"></td>
          <td width="24" height="3" class="opcion" background="../images/images/tabmenu/opcion1.gif"></td>

          <td width="50" height="3" class="opcion" background="../images/images/tabmenu/opcion1.gif"></td>
          <td width="5"  height="3"><img src="../images/images/tabmenu/opcion_med.gif" width="5" height="3" border="0"></td>
          <!-- col 2 -->
          <td width="24" height="3" class="opcion" background="../images/images/tabmenu/opcion1.gif"></td>
          <td width="80" height="3" class="opcion" background="../images/images/tabmenu/opcion1.gif"></td>
          <td width="3"  height="3"><img src="../images/images/tabmenu/esq2.gif" width="3" height="3" border="0"></td>
        </tr>
        <!-- Linea del medio menu superior derecho -->
        <tr>
          <!-- linea izquierda -->
          <td width="3" background="../images/images/tabmenu/opcion_a.gif" class="menu1"><img src="../images/images/tabmenu/transp.gif" width="3" height="1"></td>
          <!-- col 1 -->
          <td width="24" align="top" class="menu1"><img src="../images/images/tabmenu/kgicon.gif" width="24" height="22" border="0"></td>
          <td width="50" align="center" class="menu1"><a href="../common/desktop.jsp" class="opcion" target="_top" title="[~Menu Principal~]">[~Men&uacute;~]</a></td>
          <td width="5" background="../images/images/tabmenu/opcion_ab.gif" class="menu1"></td>
          <!-- col 2 -->
          <td width="24" align="top" class="menu1"><img src="../images/images/tabmenu/disconnect.gif" width="24" height="22" border="0"></td>

          <td width="80" align="center" class="menu1"><a href="../index.html" target="_top" class="opcion" title="[~Desconectar~]">[~Desconectar~]</a></td>
          <!-- linea derecha -->
          <td width="3" background="../images/images/tabmenu/opcion_b.gif" class="menu1"><img src="../images/images/tabmenu/transp.gif" width="3" height="1"></td>
        </tr>
        <!-- Linea de abajo del menu superior derecho -->
        <tr>
          <!-- col 1 -->
          <td width="3"  height="3"><img src="../images/images/tabmenu/esq3.gif" width="3" height="3" border="0"></td>

          <td width="24" height="3" class="opcion" background="../images/images/tabmenu/opcion2.gif"></td>
          <td width="50" height="3" class="opcion" background="../images/images/tabmenu/opcion2.gif"></td>
          <td width="5"  height="3"><img src="../images/images/tabmenu/opcion_medb.gif" width="5" height="3" border="0"></td>
          <!-- col 2 -->
          <td width="24" height="3" class="opcion" background="../images/images/tabmenu/opcion2.gif"></td>
          <td width="80" height="3" class="opcion" background="../images/images/tabmenu/opcion2.gif"></td>
          <td width="3"  height="3"><img src="../images/images/tabmenu/esq4.gif" width="3" height="3" border="0"></td>
        </tr>
        </table>
        <!-- fin tabla menu -->
      </td>  
    </tr>
  </table>
  <BR>
  <FORM TARGET="sqlresultset" METHOD="post" action="ldr_exec.jsp" enctype="multipart/form-data" >
    <TABLE SUMMARY="Origin and Target" BORDER="0">
      <TR>
	      <TD><A CLASS="linkplain" HREF="sql_form.jsp">[~Consulta SQL~]</A></TD>
	      <TD COLSPAN="2"></TD>
      </TR>
      <TR>
        <TD CLASS="textplain">[~Conexi&oacute;n~]</TD>
        <TD><SELECT NAME="con_target"><OPTION VALUE="hipergate" SELECTED="selected">hipergate</OPTION><OPTION VALUE="test">test</OPTION><OPTION VALUE="devel">devel</OPTION><OPTION VALUE="real">real</OPTION><OPTION VALUE="demo">demo</OPTION><OPTION VALUE="crm">crm</OPTION><OPTION VALUE="portal">portal</OPTION><OPTION VALUE="intranet">intranet</OPTION><OPTION VALUE="extranet">extranet</OPTION><OPTION VALUE="shop">shop</OPTION><OPTION VALUE="site">site</OPTION><OPTION VALUE="web">web</OPTION><OPTION VALUE="work">work</OPTION></SELECT></TD>
      </TR>
      <TR>
	      <TD CLASS="textplain">[~Tabla Destino~]</TD>
	      <TD><SELECT NAME="tbl_target"><% for (Iterator t = oTbl.keySet().iterator(); t.hasNext(); ) { String s=(String) t.next(); out.write("<OPTION VALUE=\""+s+"\">"+s+"</OPTION>"); } %></SELECT></TD>
      </TR>
      <TR>
	      <TD CLASS="textplain">[~Archivo~]</TD>
	      <TD><INPUT TYPE="file" NAME="txt_file"></TD>
      </TR>
      <TR>
	      <TD CLASS="textplain">[~Juego de Caracteres~]</TD>
	      <TD><SELECT NAME="char_set"><OPTION VALUE="ISO8859_1" SELECTED="selected">ISO-8859-1</OPTION><OPTION VALUE="UTF-8">UTF-8</OPTION></SELECT></TD>
      </TR>
      <TR>
	      <TD CLASS="textplain">[~Delimitador de columna~]</TD>
	      <TD><SELECT NAME="col_delim"><OPTION VALUE="t" SELECTED="selected">[~Tabulador~]</OPTION><OPTION VALUE=";">[~Punto y coma~]</OPTION><OPTION VALUE="|">[~Barra vertical~]</OPTION></SELECT></TD>
      </TR>
      <TR>
	      <TD CLASS="textplain">[~Formato de fechas~]</TD>
	      <TD><SELECT NAME="date_format"><OPTION VALUE="yyyy-MM-dd" SELECTED="selected">yyyy-MM-dd</OPTION><OPTION VALUE="MM/dd/yyyy">MM/dd/yyyy</OPTION><OPTION VALUE="dd/MM/yyyy">dd/MM/yyyy</OPTION></SELECT></TD>
      </TR>
      <TR>
	      <TD><INPUT TYPE="submit" CLASS="pushbutton" VALUE="[~Cargar~]"></TD>
	      <TD></TD>
	      <TD></TD>
	      <TD></TD>
	      <TD></TD>
      </TR>
    </TABLE>
  </FORM>
</BODY>
</HTML>