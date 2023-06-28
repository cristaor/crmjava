UPDATE k_version SET vs_stamp='7.0.0'
GO;

ALTER TABLE k_workareas ADD bo_acrs_oprt SMALLINT DEFAULT 0
GO;
ALTER TABLE k_member_address ADD id_nationality CHAR(3) NULL
GO;
ALTER TABLE k_academic_courses ADD gu_supplier CHAR(32) NULL
GO;
ALTER TABLE k_academic_courses ADD nu_booked INTEGER NULL
GO;
ALTER TABLE k_academic_courses ADD nu_confirmed INTEGER NULL
GO;
ALTER TABLE k_academic_courses ADD nu_alumni INTEGER NULL
GO;
ALTER TABLE  k_suppliers ADD id_sector VARCHAR(16) NULL
GO;
ALTER TABLE k_suppliers ADD nu_employees INTEGER NULL
GO;
ALTER TABLE k_addresses ADD tx_dept VARCHAR(70) NULL
GO;
ALTER TABLE k_oportunities ADD id_message VARCHAR(254) NULL
GO;
CREATE TABLE k_x_pageset_list (
  gu_list CHAR(32)    NOT NULL,
  gu_pageset CHAR(32) NOT NULL,
  CONSTRAINT pk_x_pageset_list PRIMARY KEY (gu_list,gu_pageset)
)
GO;
DROP FUNCTION k_sp_del_meeting (CHAR)
GO;
CREATE FUNCTION k_sp_del_meeting (CHAR) RETURNS INTEGER AS '
BEGIN
  UPDATE k_activities SET gu_meeting=NULL WHERE gu_meeting=$1;
  DELETE FROM k_x_meeting_contact WHERE gu_meeting=$1;
  DELETE FROM k_x_meeting_fellow WHERE gu_meeting=$1;
  DELETE FROM k_x_meeting_room WHERE gu_meeting=$1;
  DELETE FROM k_meetings WHERE gu_meeting=$1;
  RETURN 0;
END;
' LANGUAGE 'plpgsql';
GO;
DROP FUNCTION k_sp_del_adhoc_mailing (CHAR)
GO;
CREATE FUNCTION k_sp_del_adhoc_mailing (CHAR) RETURNS INTEGER AS '
BEGIN
  UPDATE k_activities SET gu_mailing=NULL WHERE gu_mailing=$1;
  DELETE FROM k_x_adhoc_mailing_list WHERE gu_mailing=$1;
  DELETE FROM k_adhoc_mailings WHERE gu_mailing=$1;
  RETURN 0;
END;
' LANGUAGE 'plpgsql';
GO;
DROP FUNCTION k_sp_del_list (CHAR)
GO;
CREATE FUNCTION k_sp_del_list (CHAR) RETURNS INTEGER AS '
DECLARE
  tp SMALLINT;
  wa CHAR(32);
  bk CHAR(32);
BEGIN

  SELECT tp_list,gu_workarea INTO tp,wa FROM k_lists WHERE gu_list=$1;

  SELECT gu_list INTO bk FROM k_lists WHERE gu_workarea=wa AND gu_query=$1 AND tp_list=4;

  IF FOUND THEN
    DELETE FROM k_list_members WHERE gu_member IN (SELECT gu_contact FROM k_x_list_members WHERE gu_list=bk) AND gu_member NOT IN (SELECT x.gu_contact FROM k_x_list_members x, k_lists l WHERE x.gu_list=l.gu_list AND l.gu_workarea=wa AND x.gu_list<>bk);
    DELETE FROM k_list_members WHERE gu_member IN (SELECT gu_company FROM k_x_list_members WHERE gu_list=bk) AND gu_member NOT IN (SELECT x.gu_company FROM k_x_list_members x, k_lists l WHERE x.gu_list=l.gu_list AND l.gu_workarea=wa AND x.gu_list<>bk);

    DELETE FROM k_x_list_members WHERE gu_list=bk;

    DELETE FROM k_x_campaign_lists WHERE gu_list=bk;

    DELETE FROM k_x_adhoc_mailing_list WHERE gu_list=bk;

    DELETE FROM k_x_pageset_list WHERE gu_list=bk;

    DELETE FROM k_lists WHERE gu_list=bk;
  END IF;

  DELETE FROM k_list_members WHERE gu_member IN (SELECT gu_contact FROM k_x_list_members WHERE gu_list=$1) AND gu_member NOT IN (SELECT x.gu_contact FROM k_x_list_members x, k_lists l WHERE x.gu_list=l.gu_list AND l.gu_workarea=wa AND x.gu_list<>$1);

  DELETE FROM k_list_members WHERE gu_member IN (SELECT gu_company FROM k_x_list_members WHERE gu_list=$1) AND gu_member NOT IN (SELECT x.gu_company FROM k_x_list_members x, k_lists l WHERE x.gu_list=l.gu_list AND l.gu_workarea=wa AND x.gu_list<>$1);

  DELETE FROM k_x_list_members WHERE gu_list=$1;

  DELETE FROM k_x_campaign_lists WHERE gu_list=$1;

  DELETE FROM k_x_adhoc_mailing_list WHERE gu_list=$1;

  DELETE FROM k_x_pageset_list WHERE gu_list=$1;

  DELETE FROM k_x_cat_objs WHERE gu_object=$1;
  UPDATE k_activities SET gu_list=NULL WHERE gu_list=$1;
  UPDATE k_x_activity_audience SET gu_list=NULL WHERE gu_list=$1;

  DELETE FROM k_lists WHERE gu_list=$1;

  RETURN 0;
END;
' LANGUAGE 'plpgsql';
GO;

ALTER TABLE k_oportunities ADD nu_oportunities INTEGER DEFAULT 1
GO;

CREATE TABLE k_x_oportunity_contacts
(
gu_contact    CHAR(32) NOT NULL,
gu_oportunity CHAR(32) NOT NULL,
tp_relation   VARCHAR(30)  NULL,
dt_created    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

CONSTRAINT pk_x_oportunity_contacts PRIMARY KEY(gu_contact,gu_oportunity)
)
GO;

DROP FUNCTION k_sp_del_contact (CHAR);

CREATE FUNCTION k_sp_del_contact (CHAR) RETURNS INTEGER AS '
DECLARE
  addr RECORD;
  addrs text;
  aCount INTEGER := 0;

  bank RECORD;
  banks text;
  bCount INTEGER := 0;

  GuWorkArea CHAR(32);

BEGIN
  UPDATE k_sms_audit SET gu_contact=NULL WHERE gu_contact=$1;
  DELETE FROM k_phone_calls WHERE gu_contact=$1;
  DELETE FROM k_x_meeting_contact WHERE gu_contact=$1;
  DELETE FROM k_x_activity_audience WHERE gu_contact=$1;
  DELETE FROM k_x_course_bookings WHERE gu_contact=$1;
  DELETE FROM k_x_course_alumni WHERE gu_alumni=$1;  
  DELETE FROM k_contact_education WHERE gu_contact=$1;
  DELETE FROM k_contact_languages WHERE gu_contact=$1;
  DELETE FROM k_contact_computer_science WHERE gu_contact=$1;
  DELETE FROM k_contact_experience WHERE gu_contact=$1;
  DELETE FROM k_admission WHERE gu_contact=$1;
  DELETE FROM k_x_duty_resource WHERE nm_resource=$1;
  DELETE FROM k_welcome_packs_changelog WHERE gu_pack IN (SELECT gu_pack FROM k_welcome_packs WHERE gu_contact=$1);
  DELETE FROM k_welcome_packs WHERE gu_contact=$1;
  DELETE FROM k_x_list_members WHERE gu_contact=$1;
  DELETE FROM k_member_address WHERE gu_contact=$1;
  DELETE FROM k_contacts_recent WHERE gu_contact=$1;
  DELETE FROM k_x_group_contact WHERE gu_contact=$1;

  SELECT gu_workarea INTO GuWorkArea FROM k_contacts WHERE gu_contact=$1;

  FOR addr IN SELECT * FROM k_x_contact_addr WHERE gu_contact=$1 LOOP
    aCount := aCount + 1;
    IF 1=aCount THEN
      addrs := quote_literal(addr.gu_address);
    ELSE
      addrs := addrs || chr(44) || quote_literal(addr.gu_address);
    END IF;
  END LOOP;

  DELETE FROM k_x_contact_addr WHERE gu_contact=$1;
  
  IF char_length(addrs)>0 THEN
    EXECUTE ''UPDATE '' || quote_ident(''k_x_activity_audience'') || '' SET gu_address=NULL WHERE gu_address IN ('' || addrs || '')'';
    EXECUTE ''DELETE FROM '' || quote_ident(''k_addresses'') || '' WHERE gu_address IN ('' || addrs || '')'';
  END IF;

  FOR bank IN SELECT * FROM k_x_contact_bank WHERE gu_contact=$1 LOOP
    bCount := bCount + 1;
    IF 1=bCount THEN
      banks := quote_literal(bank.nu_bank_acc);
    ELSE
      banks := banks || chr(44) || quote_literal(bank.nu_bank_acc);
    END IF;
  END LOOP;

  DELETE FROM k_x_contact_bank WHERE gu_contact=$1;

  IF char_length(banks)>0 THEN
    EXECUTE ''DELETE FROM '' || quote_ident(''k_bank_accounts'') || '' WHERE nu_bank_acc IN ('' || banks || '') AND gu_workarea='' || quote_literal(GuWorkArea);
  END IF;

  DELETE FROM k_x_oportunity_contacts WHERE gu_oportunity IN (SELECT gu_oportunity FROM k_oportunities WHERE gu_contact=$1);
  DELETE FROM k_oportunities_attachs WHERE gu_oportunity IN (SELECT gu_oportunity FROM k_oportunities WHERE gu_contact=$1);
  DELETE FROM k_oportunities_changelog WHERE gu_oportunity IN (SELECT gu_oportunity FROM k_oportunities WHERE gu_contact=$1);
  DELETE FROM k_oportunities_attrs WHERE gu_object IN (SELECT gu_oportunity FROM k_oportunities WHERE gu_contact=$1);
  DELETE FROM k_oportunities WHERE gu_contact=$1;

  DELETE FROM k_x_cat_objs WHERE gu_object=$1 AND id_class=90;

  DELETE FROM k_x_contact_prods WHERE gu_contact=$1;
  DELETE FROM k_contacts_attrs WHERE gu_object=$1;
  DELETE FROM k_contact_notes WHERE gu_contact=$1;
  DELETE FROM k_contacts WHERE gu_contact=$1;
  RETURN 0;
END;
' LANGUAGE 'plpgsql';
GO;

DROP FUNCTION k_sp_del_company (CHAR);

CREATE FUNCTION k_sp_del_company (CHAR) RETURNS INTEGER AS '
DECLARE
  addr RECORD;
  addrs text;
  aCount INTEGER := 0;

  bank RECORD;
  banks text;
  bCount INTEGER := 0;

BEGIN

  DELETE FROM k_x_duty_resource WHERE nm_resource=$1;
  DELETE FROM k_welcome_packs_changelog WHERE gu_pack IN (SELECT gu_pack FROM k_welcome_packs WHERE gu_company=$1);
  DELETE FROM k_welcome_packs WHERE gu_company=$1;
  DELETE FROM k_x_list_members WHERE gu_company=$1;
  DELETE FROM k_member_address WHERE gu_company=$1;
  DELETE FROM k_companies_recent WHERE gu_company=$1;
  DELETE FROM k_x_group_company WHERE gu_company=$1;

  FOR addr IN SELECT * FROM k_x_company_addr WHERE gu_company=$1 LOOP
    aCount := aCount + 1;
    IF 1=aCount THEN
      addrs := quote_literal(addr.gu_address);
    ELSE
      addrs := addrs || chr(44) || quote_literal(addr.gu_address);
    END IF;
  END LOOP;

  DELETE FROM k_x_company_addr WHERE gu_company=$1;

  IF char_length(addrs)>0 THEN
    EXECUTE ''DELETE FROM '' || quote_ident(''k_addresses'') || '' WHERE gu_address IN ('' || addrs || '')'';
  END IF;

  FOR bank IN SELECT * FROM k_x_company_bank WHERE gu_company=$1 LOOP
    bCount := bCount + 1;
    IF 1=bCount THEN
      banks := quote_literal(bank.nu_bank_acc);
    ELSE
      banks := banks || chr(44) || quote_literal(bank.nu_bank_acc);
    END IF;
  END LOOP;

  DELETE FROM k_x_company_bank WHERE gu_company=$1;

  IF char_length(banks)>0 THEN
    EXECUTE ''DELETE FROM '' || quote_ident(''k_bank_accounts'') || '' WHERE nu_bank_acc IN ('' || banks || '') AND gu_workarea='' || quote_literal(GuWorkArea);
  END IF;

  /* Borrar las oportunidades */
  DELETE FROM k_x_oportunity_contacts WHERE gu_oportunity IN (SELECT gu_oportunity FROM k_oportunities WHERE gu_company=$1);
  DELETE FROM k_oportunities_attachs WHERE gu_oportunity IN (SELECT gu_oportunity FROM k_oportunities WHERE gu_company=$1);
  DELETE FROM k_oportunities_changelog WHERE gu_oportunity IN (SELECT gu_oportunity FROM k_oportunities WHERE gu_company=$1);
  DELETE FROM k_oportunities_attrs WHERE gu_object IN (SELECT gu_oportunity FROM k_oportunities WHERE gu_company=$1);
  DELETE FROM k_oportunities WHERE gu_company=$1;

  /* Borrar las referencias de PageSets */
  UPDATE k_pagesets SET gu_company=NULL WHERE gu_company=$1;

  /* Borrar el enlace con categor�as */
  DELETE FROM k_x_cat_objs WHERE gu_object=$1 AND id_class=91;

  DELETE FROM k_x_company_prods WHERE gu_company=$1;
  DELETE FROM k_companies_attrs WHERE gu_object=$1;
  DELETE FROM k_companies WHERE gu_company=$1;
  RETURN 0;
END;
' LANGUAGE 'plpgsql';
GO;

DROP FUNCTION k_sp_del_oportunity (CHAR);

CREATE FUNCTION k_sp_del_oportunity (CHAR) RETURNS INTEGER AS '
DECLARE
  GuContact CHAR(32);
BEGIN
  SELECT gu_contact INTO GuContact FROM k_oportunities WHERE gu_oportunity=$1;
  UPDATE k_phone_calls SET gu_oportunity=NULL WHERE gu_oportunity=$1;
  DELETE FROM k_x_oportunity_contacts WHERE gu_oportunity=$1;
  DELETE FROM k_oportunities_attachs WHERE gu_oportunity=$1;
  DELETE FROM k_oportunities_changelog WHERE gu_oportunity=$1;
  DELETE FROM k_oportunities_attrs WHERE gu_object=$1;
  DELETE FROM k_oportunities WHERE gu_oportunity=$1;
  IF GuContact IS NOT NULL THEN
    UPDATE k_oportunities SET nu_oportunities=(SELECT COUNT(*) FROM k_oportunities WHERE gu_contact=GuContact) WHERE gu_contact=GuContact;
  END IF;
  RETURN 0;
END;
' LANGUAGE 'plpgsql';
GO;

CREATE TABLE k_syndsearches
(
tx_sought VARCHAR(254) NOT NULL,
dt_created   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
dt_last_run  TIMESTAMP     NULL,
dt_next_run  TIMESTAMP     NULL,
dt_last_request TIMESTAMP  NULL,
nu_rerun_after_secs INTEGER DEFAULT 1200,
nu_runs      INTEGER       NULL,
nu_requests  INTEGER       NULL,
nu_results   INTEGER       NULL,
xml_recent   TEXT          NULL,
CONSTRAINT pk_syndsearches PRIMARY KEY (tx_sought)
)
GO;

CREATE TABLE k_syndsearch_request
(
id_request INTEGER      NOT NULL,
tx_sought  VARCHAR(254) NOT NULL,
dt_request TIMESTAMP        NULL,
nu_milis   INTEGER          NULL,
gu_user    CHAR(32)         NULL,
gu_account CHAR(32)         NULL,
CONSTRAINT pk_syndsearch_request PRIMARY KEY (id_request)
)
GO;

CREATE TABLE k_syndsearch_run
(
id_run       INTEGER      NOT NULL,
tx_sought    VARCHAR(254) NOT NULL,
dt_run       TIMESTAMP        NULL,
nu_milis     INTEGER          NULL,
nu_entries   INTEGER          NULL,
CONSTRAINT pk_syndsearch_run PRIMARY KEY (id_run)
)
GO;

CREATE TABLE k_syndreferers
(
id_syndref VARCHAR(480) NOT NULL,
dt_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
tx_sought  VARCHAR(254) NOT NULL,
url_domain VARCHAR(100) NOT NULL,
nu_entries   INTEGER        NULL,
CONSTRAINT pk_syndreferers PRIMARY KEY (id_syndref)
)
GO;

DROP TABLE k_syndentries
GO;

CREATE TABLE k_syndentries
(
id_domain    INTEGER       NOT NULL,
id_syndentry INTEGER       NOT NULL,
gu_workarea  CHAR(32)      NULL,
uri_entry    VARCHAR(200)  NOT NULL,
gu_feed      CHAR(32)      NULL,
id_type      VARCHAR(50)   NULL,
id_acalias   VARCHAR(150)  NULL,
id_country   CHAR(2)       NULL,
id_language  CHAR(2)       NULL,
dt_created   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
dt_published TIMESTAMP     NULL,
dt_modified  TIMESTAMP     NULL,
dt_run       TIMESTAMP     NULL,
tx_sought    VARCHAR(254)  NULL,
tx_sought_by_date VARCHAR(276) NULL,
gu_account   CHAR(32)      NULL,
nu_influence INTEGER       NULL,
nu_relevance INTEGER       NULL,
url_author   VARCHAR(254)  NULL,
tl_entry     VARCHAR(254)  NULL,
de_entry     VARCHAR(1000) NULL,
url_addr     VARCHAR(254)  NULL,
url_domain   VARCHAR(254)  NULL,
bin_entry    LONGVARBINARY NULL,
CONSTRAINT pk_syndentries PRIMARY KEY (id_syndentry)
)
GO;

CREATE SEQUENCE seq_k_syndsearch_request INCREMENT 1 START 1
GO;

CREATE SEQUENCE seq_k_syndsearch_run INCREMENT 1 START 1
GO;

CREATE SEQUENCE seq_k_syndentries INCREMENT 1 START 1
GO;

CREATE TABLE k_user_accounts
(
  gu_account        CHAR(32) NOT NULL,
  id_domain         INTEGER NOT NULL,
  dt_created        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  tx_nickname       VARCHAR(50) NOT NULL,
  tx_pwd            VARCHAR(50) NULL,
  tx_pwd_sign       VARCHAR(50) NULL,
  bo_change_pwd     SMALLINT NOT NULL DEFAULT 1,
  bo_searchable     SMALLINT NOT NULL DEFAULT 1,
  bo_active         SMALLINT NOT NULL DEFAULT 1,
  nu_login_attempts INTEGER NULL,
  len_quota         DECIMAL(28) NULL,
  max_quota         DECIMAL(28) NULL,
  tp_account        CHAR(1) NULL,
  id_account        CHAR(10) NULL,
  dt_last_update    TIMESTAMP NULL,
  dt_last_visit     TIMESTAMP NULL,
  dt_cancel         TIMESTAMP NULL,
  tx_main_email     VARCHAR(100) NULL,
  tx_alt_email      VARCHAR(100) NULL,
  nm_user           VARCHAR(100) NULL,
  tx_surname1       VARCHAR(100) NULL,
  tx_surname2       VARCHAR(100) NULL,
  full_name         VARCHAR(300) NULL,
  nm_ascii          VARCHAR(300) NULL,
  tx_challenge      VARCHAR(100) NULL,
  tx_reply          VARCHAR(100) NULL,
  dt_pwd_expires    TIMESTAMP NULL,
  gu_company        CHAR(32) NULL,
  nm_company        VARCHAR(70) NULL,
  de_title          VARCHAR(70) NULL,
  id_country        CHAR(2) NULL,
  id_gender         CHAR(1) NULL,
  dt_birth          TIMESTAMP NULL,
  ny_age            SMALLINT NULL,
  marital_status    CHAR(1) NULL,
  tx_education      VARCHAR(100) NULL,
  icq_id            VARCHAR(50) NULL,
  sn_passport       VARCHAR(16) NULL,
  tp_passport       CHAR(1) NULL,
  mov_phone         VARCHAR(16) NULL,
  tx_comments       VARCHAR(254) NULL,
  gu_image          CHAR(32),
  jv_recent_searches BYTEA NULL,
  CONSTRAINT pk_user_accounts PRIMARY KEY (gu_account)
)
GO;

CREATE TABLE k_user_account_alias
(
    id_acalias VARCHAR(150) NOT NULL,
	  gu_account CHAR(32) NULL,
    dt_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    nm_service VARCHAR(50) NOT NULL,
    nm_alias   VARCHAR(100) NOT NULL,
    nm_display VARCHAR(100) NULL,
    nm_ascii   VARCHAR(100) NULL,
    url_addr   VARCHAR(254) NULL,
    CONSTRAINT pk_user_account_alias PRIMARY KEY (id_acalias)
)
GO;