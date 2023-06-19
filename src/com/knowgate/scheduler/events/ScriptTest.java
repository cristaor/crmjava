package com.knowgate.scheduler.events;

import java.util.Date;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Properties;

import java.text.SimpleDateFormat;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;

import java.net.URL;
import java.net.URLDecoder;

import java.sql.ResultSet;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import com.knowgate.jdc.JDCConnection;
import com.knowgate.dataobjs.DB;
import com.knowgate.dataobjs.DBBind;
import com.knowgate.dataobjs.DBCommand;
import com.knowgate.dfs.FileSystem;
import com.knowgate.dfs.chardet.CharacterSetDetector;
import com.knowgate.misc.Gadgets;
import com.knowgate.scheduler.Event;
import com.knowgate.dataxslt.db.PageSetDB;
import com.knowgate.hipermail.MailAccount;
import com.knowgate.hipermail.SendMail;
import com.knowgate.crm.GlobalBlackList;
import com.knowgate.crm.DistributionList;


public class ScriptTest {

	public void main() {

		Event ThisEvent = null;
		HashMap Parameters = null;
		JDCConnection JDBCConnection = null;
		Properties EnvironmentProperties = null;

		final String GU_TEST = "5262a821135070db7b3100126c066ced"; // GUID del Area de Trabajo de TEST en la tabla k_workareas
		final String GU_REAL = "5262a821135070dbb291001888284316"; // GUID del Area de Trabajo de PRODUCCION en la tabla k_workareas
		final String GU_USER = "5262a821135070dbb2b100189828fef4"; // GUID del usuario administrador de PRODUCCION en la tabla k_users

		ThisEvent.log("Start script sendmailtest "+(new Date().toString()));

		Integer returnValue = new Integer(0);
		Integer ErrorCode = new Integer(0);
		String  ErrorMessage = "";

	}
}
