package com.knowgate.storage;

public enum RDBMS {

	MYSQL(1),
	POSTGRESQL(2),
	MSSQL(3),
	ORACLE(5),
	DB2(6);

	private final int iCode;

	RDBMS (int iRDBMSCode) {
	  iCode = iRDBMSCode;
	}

	public String toString() {
	  switch (iCode) {
	    case 1: return "MySQL";
	    case 2: return "PostgreSQL";
	    case 3: return "Microsoft SQL Server";
	    case 5: return "Oracle";
	    case 6: return "DB2";
	    default: return "Unknown DBMS";
	  }
	}

	public final int intValue() {
	  return iCode;
	}
	
}
