
import java.io.File;
import java.io.FileOutputStream;

import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMultipart;

import com.sun.mail.smtp.SMTPMessage;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFCell;

import com.knowgate.debug.DebugFile;

Integer ReturnValue;
Integer ErrorCode;
String  ErrorMessage;

if (DebugFile.trace) DebugFile.writeln("Begin beforesmtpmime script");

/*
String FILE_NAME = "Attachment.xls";

SMTPMessage oSentMessage = (SMTPMessage) Parameters.get("bin_smtpmessage");

MimeMultipart oParts = (MimeMultipart) oSentMessage.getContent();
for (int p=0; p<oParts.getCount(); p++) {
  String sFileName = oParts.getBodyPart(p).getFileName();
  if (null!=sFileName) {
    if (sFileName.equals(FILE_NAME)) {
      HSSFWorkbook oXlsWrk = new HSSFWorkbook(oParts.getBodyPart(p).getInputStream());
      HSSFSheet oXlsSht = oXlsWrk.getSheetAt(0);
      HSSFRow oXlsRow = oXlsSht.getRow(9);
      HSSFCell oXlsCel = oXlsRow.getCell(5);
      oXlsCel.setCellValue("Antonio López Rigue");
      File oFout = new File("C:\\"+FILE_NAME);
      if (oFout.exists()) oFout.delete();
      FileOutputStream oSout = new FileOutputStream(oFout);
      oXlsWrk.write(oSout);
      oSout.close();
      oParts.getBodyPart(p).attachFile("C:\\NotaInformativaEOI1.xls");
    }
  }
}

*/
if (DebugFile.trace) DebugFile.writeln("End beforesmtpmime script");

ErrorMessage = "";
ErrorCode = new Integer(0);
ReturnValue = new Integer(0);
