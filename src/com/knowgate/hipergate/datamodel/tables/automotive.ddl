CREATE TABLE k_vehicle_brands (
  gu_workarea CHAR(32)    NOT NULL,
	nm_brand    VARCHAR(20) NOT NULL,
  
	CONSTRAINT pk_vehicle_brands PRIMARY KEY (gu_workarea,nm_brand)
)
GO;
  
CREATE TABLE k_brand_models (
  gu_workarea CHAR(32)    NOT NULL,
	nm_brand    VARCHAR(20) NOT NULL,
	nm_model    VARCHAR(30) NOT NULL,
  
	CONSTRAINT pk_brand_models PRIMARY KEY (gu_workarea,nm_brand,nm_model)
)
GO;

CREATE TABLE k_vehicles (
	gu_vehicle	     CHAR(32) NOT NULL,
  gu_workarea      CHAR(32) NOT NULL,
	bo_active        SMALLINT DEFAULT 1,
  dt_created       DATETIME   DEFAULT CURRENT_TIMESTAMP,
	tp_vehicle       VARCHAR(5) DEFAULT 'CAR',
	gu_contact       CHAR(32)     NULL,
	nu_registration  VARCHAR(20)  NULL,
	nu_framework     VARCHAR(30)  NULL,
	dt_purchased     DATETIME     NULL,
	nm_brand         VARCHAR(20)  NULL,
	nm_model         VARCHAR(30)  NULL,
	
	CONSTRAINT pk_vehicles PRIMARY KEY (gu_vehicle)
)
GO;

CREATE TABLE k_drive_tests (
  gu_contact CHAR(32) NOT NULL,
  gu_workarea CHAR(32) NOT NULL,
  p0 SMALLINT NOT NULL,
  p1 SMALLINT NOT NULL,
  p2 SMALLINT NOT NULL,
  p3 SMALLINT NOT NULL,
  p4 SMALLINT NOT NULL,
  p5 SMALLINT NOT NULL,
  p6 SMALLINT NOT NULL,
  p7 SMALLINT NOT NULL,
  p8 SMALLINT NOT NULL,
  p9 SMALLINT NOT NULL,
  p10 SMALLINT NOT NULL,
	CONSTRAINT pk_drive_tests PRIMARY KEY (gu_contact)  
)
GO;

CREATE TABLE k_bcn_09 (
  gu_contact    CHAR(32) NOT NULL,
  gu_workarea   CHAR(32) NOT NULL,
  dt_created    TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
  bo_redbull    SMALLINT NOT NULL,
  bo_clubmember SMALLINT NOT NULL,
  bo_hasseat    SMALLINT NOT NULL,
  bo_hascar     SMALLINT NOT NULL,
  nm_brand      VARCHAR(20) NULL,
  nm_model      VARCHAR(30) NULL,
  nu_year       SMALLINT NULL,
  pe_buynew     SMALLINT NULL,
  nm_host       VARCHAR(50) NULL,
  tx_name       VARCHAR(100) NOT NULL,
  tx_surname    VARCHAR(100) NOT NULL,
  tx_email      VARCHAR(100) NOT NULL,
  sn_passport   VARCHAR(16) NULL,
  id_gender     CHAR(1) NULL,
  tp_street     VARCHAR(16) NULL,
  nm_street     VARCHAR(100) NULL,
  nu_street     VARCHAR(16) NULL,
  zipcode       CHAR(5) NULL,
  mn_city       VARCHAR(100) NULL,
  test_other    SMALLINT NULL,
  test1         SMALLINT NULL,
  test2         SMALLINT NULL,
  test3         SMALLINT NULL,
  test4         SMALLINT NULL,
  test5         SMALLINT NULL,
  test6         SMALLINT NULL,
  test7         SMALLINT NULL,
  test8         SMALLINT NULL,
  test9         SMALLINT NULL,
  test10         SMALLINT NULL,
  
  CONSTRAINT pk_bcn_09 PRIMARY KEY (gu_contact)
)

CREATE TABLE k_huesca_09 (
  gu_contact    CHAR(32) NOT NULL,
  gu_workarea   CHAR(32) NOT NULL,
  dt_created    TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
  nm_brand      VARCHAR(20) NULL,
  nm_model      VARCHAR(30) NULL,
  nu_year       SMALLINT NULL,
  pe_buynew     SMALLINT NULL,
  nm_host       VARCHAR(50) NULL,
  tx_name       VARCHAR(100) NOT NULL,
  tx_surname    VARCHAR(100) NOT NULL,
  tx_email      VARCHAR(100) NOT NULL,
  id_gender     CHAR(1) NULL,
  zipcode       CHAR(5) NULL,
  mn_city       VARCHAR(100) NULL,
  mov_phone     VARCHAR(16) NULL,
  test1         SMALLINT NULL,
  test2         SMALLINT NULL,
  test3         SMALLINT NULL,
  test4         SMALLINT NULL,
  test5         SMALLINT NULL,
  test6         SMALLINT NULL,
  test7         SMALLINT NULL,
  test8         SMALLINT NULL,
  test9         SMALLINT NULL,
  test10        SMALLINT NULL,
  bo_baja       SMALLINT NULL,
  
  CONSTRAINT pk_huesca_09 PRIMARY KEY (gu_contact)
)
