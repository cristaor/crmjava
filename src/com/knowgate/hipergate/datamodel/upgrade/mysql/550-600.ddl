UPDATE k_version SET vs_stamp='6.0.0'
GO;

DROP PROCEDURE k_sp_cat_expand 
GO;

CREATE PROCEDURE k_sp_cat_expand (Cat CHAR(32))
BEGIN
  DECLARE Walk  INT;
  DECLARE Level INT;
  DECLARE Depth INT;
  DECLARE Unwalked INT;
  DECLARE GuPrnt CHAR(32);
  DECLARE GuChld CHAR(32);
  DECLARE NmChld VARCHAR(50);
  DECLARE CurName VARCHAR(254) DEFAULT NULL;
  DECLARE StackBot INTEGER;
  DECLARE StackTop INTEGER;
  DECLARE Done INT DEFAULT 0;
  DECLARE childs CURSOR FOR SELECT gu_cat,od_lvl,od_wlk,gu_par FROM tmp_exp_cat_stack ORDER BY od_wlk;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET Done=1;

  DELETE FROM k_cat_expand WHERE gu_rootcat = Cat;

  SELECT nm_category INTO CurName FROM k_categories WHERE gu_category=Cat;

  IF CurName IS NOT NULL THEN

    CREATE TEMPORARY TABLE tmp_exp_cat_stack (nu_pos INTEGER UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, gu_rot CHAR(32) NOT NULL, gu_cat CHAR(32) NOT NULL, od_lvl INTEGER NOT NULL, gu_par CHAR(32) NULL, od_wlk INTEGER NULL) TYPE MYISAM;
    CREATE TEMPORARY TABLE tmp_exp_cat_slice (gu_cat CHAR(32) NOT NULL, gu_par CHAR(32) NOT NULL) ENGINE = MEMORY;

    INSERT INTO tmp_exp_cat_stack (gu_rot,gu_cat,od_lvl,gu_par,od_wlk) VALUES (Cat, Cat, 1, NULL, 1);
    SET Level = 2;
    SET StackBot = 1;
    SET StackTop = 1;

    REPEAT
      INSERT INTO tmp_exp_cat_slice (gu_cat,gu_par) SELECT gu_child_cat,gu_parent_cat FROM k_cat_tree WHERE gu_parent_cat IN (SELECT gu_cat FROM tmp_exp_cat_stack WHERE nu_pos BETWEEN StackBot AND StackTop);
      INSERT INTO tmp_exp_cat_stack (gu_rot,gu_cat,od_lvl,gu_par,od_wlk) SELECT Cat,gu_cat,Level,gu_par,NULL FROM tmp_exp_cat_slice;
      DELETE FROM tmp_exp_cat_slice;
      SET StackBot = StackTop+1;
      SET Level = Level+1;
      SELECT MAX(nu_pos) INTO StackTop FROM tmp_exp_cat_stack;
    UNTIL StackTop<StackBot END REPEAT;

    SET Walk = 2;
    SET Level = 2;
    SET GuPrnt = Cat;
    SELECT COUNT(*) INTO Unwalked FROM tmp_exp_cat_stack WHERE od_wlk IS NULL;
    SELECT MAX(od_lvl) INTO Depth FROM tmp_exp_cat_stack;
    WHILE Unwalked>0 AND Level>1 DO
      SET GuChld=NULL;
      SELECT gu_cat INTO GuChld FROM tmp_exp_cat_stack WHERE od_wlk IS NULL AND gu_par=GuPrnt ORDER BY nu_pos LIMIT 0,1;
      IF GuChld IS NULL THEN
        SET Level = Level-1;
        SELECT gu_parent_cat INTO GuPrnt FROM k_cat_tree WHERE gu_child_cat=GuPrnt;
      ELSE
        UPDATE tmp_exp_cat_stack SET od_wlk=Walk WHERE gu_cat=GuChld;
        SET Walk = Walk+1;
        SET Level = Level+1;
        SET GuPrnt = GuChld;
      END IF;
      SELECT COUNT(*) INTO Unwalked FROM tmp_exp_cat_stack WHERE od_wlk IS NULL;
    END WHILE;

    SET Done=0;
    OPEN childs;
    REPEAT
      FETCH childs INTO GuChld,Level,Walk,GuPrnt;
      IF Done=0 THEN
        INSERT INTO k_cat_expand (gu_rootcat,gu_category,od_level,od_walk,gu_parent_cat) VALUES (Cat, GuChld, Level, Walk, GuPrnt);
      END IF;
    UNTIL Done=1 END REPEAT;
    CLOSE childs;
  END IF;

  DROP TEMPORARY TABLE tmp_exp_cat_slice;
  DROP TEMPORARY TABLE tmp_exp_cat_stack;
END
GO;

DROP PROCEDURE k_sp_read_pageset 
GO;

CREATE PROCEDURE k_sp_read_pageset (IdPageSet CHAR(32), OUT IdMicrosite CHAR(32), OUT NmMicrosite VARCHAR(128), OUT IdWorkArea CHAR(32), OUT NmPageSet VARCHAR(100), OUT VsStamp VARCHAR(16), OUT IdLanguage CHAR(2), OUT DtModified TIMESTAMP, OUT PathData VARCHAR(254), OUT IdStatus VARCHAR(30), OUT PathMetaData VARCHAR(254), OUT TxComments VARCHAR(254), OUT GuCompany CHAR(32), OUT GuProject CHAR(32), OUT TxEmailFrom VARCHAR(254), OUT TxEmailReply VARCHAR(254), OUT NmFrom VARCHAR(254), OUT TxSubject VARCHAR(254))
BEGIN
  SELECT m.nm_microsite,m.gu_microsite,p.gu_workarea,p.nm_pageset,p.vs_stamp,p.id_language,p.dt_modified,p.path_data,p.id_status,m.path_metadata,p.tx_comments,p.gu_company,p.gu_project,p.tx_email_from,p.tx_email_reply,p.nm_from,p.tx_subject INTO NmMicrosite,IdMicrosite,IdWorkArea,NmPageSet,VsStamp,IdLanguage,DtModified,PathData,IdStatus,PathMetaData,TxComments,GuCompany,GuProject,TxEmailFrom,TxEmailReply,NmFrom,TxSubject FROM k_pagesets p LEFT OUTER JOIN k_microsites m ON p.gu_microsite=m.gu_microsite WHERE p.gu_pageset=IdPageSet;
END
GO;

ALTER TABLE k_x_list_members ADD tx_info VARCHAR(254) NULL
GO;

ALTER TABLE k_pagesets ADD tx_email_from VARCHAR(254) NULL
GO;
ALTER TABLE k_pagesets ADD tx_email_reply VARCHAR(254) NULL
GO;
ALTER TABLE k_pagesets ADD nm_from VARCHAR(254) NULL
GO;
ALTER TABLE k_pagesets ADD tx_subject VARCHAR(254) NULL
GO;
ALTER TABLE k_meetings ADD id_icalendar VARCHAR(255) NULL
GO;
CREATE INDEX i4_meetings ON k_meetings(id_icalendar);
GO;
ALTER TABLE k_jobs ADD nu_sent INTEGER DEFAULT 0
GO;
ALTER TABLE k_jobs ADD nu_opened INTEGER DEFAULT 0
GO;
ALTER TABLE k_jobs ADD nu_unique INTEGER DEFAULT 0
GO;
ALTER TABLE k_jobs ADD nu_clicks INTEGER DEFAULT 0
GO;

ALTER TABLE k_urls ADD nu_clicks INTEGER DEFAULT 0
GO;
ALTER TABLE k_urls ADD dt_last_visit TIMESTAMP NULL
GO;

ALTER TABLE k_contacts ADD url_twitter VARCHAR(254) NULL
GO;

CREATE TABLE k_jobs_atoms_by_day
(
dt_execution  CHAR(10)    NOT NULL,
gu_job        CHAR(32)    NOT NULL,
gu_workarea   CHAR(32)    NOT NULL,
gu_job_group  CHAR(32)        NULL,
nu_msgs       INTEGER    DEFAULT 0,
CONSTRAINT pk_jobs_atoms_by_day PRIMARY KEY(dt_execution,gu_job)
)  
GO;

CREATE TABLE k_jobs_atoms_by_hour
(
dt_hour       SMALLINT    NOT NULL,
gu_job        CHAR(32)    NOT NULL,
gu_workarea   CHAR(32)    NOT NULL,
gu_job_group  CHAR(32)        NULL,
nu_msgs       INTEGER    DEFAULT 0,
CONSTRAINT pk_jobs_atoms_by_hour PRIMARY KEY(dt_hour,gu_job)
)  
GO;

CREATE TABLE k_jobs_atoms_by_agent
(
id_agent      VARCHAR(50) NOT NULL,
gu_job        CHAR(32)    NOT NULL,
gu_workarea   CHAR(32)    NOT NULL,
gu_job_group  CHAR(32)        NULL,
nu_msgs       INTEGER    DEFAULT 0,
CONSTRAINT pk_jobs_atoms_by_agent PRIMARY KEY(id_agent,gu_job)
)  
GO;

DROP PROCEDURE k_sp_del_job
GO;

CREATE PROCEDURE k_sp_del_job (IdJob CHAR(32))
BEGIN
  DELETE FROM k_jobs_atoms_by_agent WHERE gu_job=IdJob;
  DELETE FROM k_jobs_atoms_by_hour WHERE gu_job=IdJob;
  DELETE FROM k_jobs_atoms_by_day WHERE gu_job=IdJob;
  DELETE FROM k_job_atoms_clicks WHERE gu_job=IdJob;
  DELETE FROM k_job_atoms_tracking WHERE gu_job=IdJob;
  DELETE FROM k_job_atoms_archived WHERE gu_job=IdJob;
  DELETE FROM k_job_atoms WHERE gu_job=IdJob;
  DELETE FROM k_jobs WHERE gu_job=IdJob;
END
GO;

CREATE PROCEDURE k_sp_del_duplicates (ListId CHAR(32), OUT Deleted INTEGER)
BEGIN
  DECLARE NuTimes INTEGER;
  DECLARE TxEmail VARCHAR(100);
  DECLARE Members CURSOR FOR SELECT tx_email FROM k_x_list_members WHERE gu_list = ListId;
  CREATE TEMPORARY TABLE k_temp_list_emails (tx_email VARCHAR(100) CONSTRAINT pk_temp_list_emails PRIMARY KEY, nu_times INTEGER) ENGINE = MEMORY;
  INSERT INTO k_temp_list_emails SELECT DISTINCT(tx_email),0 FROM k_x_list_members WHERE gu_list=ListId;
  SET Deleted=0;
  OPEN Members;
  FETCH Members INTO TxEmail;
  WHILE FOUND DO
    UPDATE k_temp_list_emails SET nu_times=nu_times+1 WHERE tx_email = TxEmail;    
    FETCH Members INTO TxEmail;
  END WHILE;
  CLOSE Members;
  DECLARE Dups CURSOR FOR SELECT tx_email,nu_times FROM k_temp_list_emails WHERE nu_times>1;
  OPEN Dups;
  FETCH Dups INTO TxEmail,NuTimes;
  WHILE FOUND DO
    DELETE FROM k_x_list_members WHERE gu_list=ListId AND tx_email=TxEmail LIMIT NuTimes-1;
    FETCH Dups INTO TxEmail,NuTimes;
  END WHILE;
  CLOSE Dups;
  DROP TABLE k_temp_list_emails;
END
GO;

DROP procedure k_sp_del_list
GO;

CREATE PROCEDURE k_sp_del_list (ListId CHAR(32))
BEGIN
  DECLARE tp SMALLINT;
  DECLARE wa CHAR(32) DEFAULT NULL;
  DECLARE bk CHAR(32) DEFAULT NULL;

  SELECT tp_list,gu_workarea INTO tp,wa FROM k_lists WHERE gu_list=ListId;

  DELETE FROM k_x_cat_objs WHERE gu_object=ListId;
  UPDATE k_activities SET gu_list=NULL WHERE gu_list=ListId;
  UPDATE k_x_activity_audience SET gu_list=NULL WHERE gu_list=ListId;

  SELECT gu_list INTO bk FROM k_lists WHERE gu_workarea=wa AND gu_query=ListId AND tp_list=4;
  IF bk IS NULL THEN
    DELETE FROM k_list_members WHERE gu_member IN (SELECT gu_contact FROM k_x_list_members WHERE gu_list=ListId) AND gu_member NOT IN (SELECT x.gu_contact FROM k_x_list_members x, k_lists l WHERE x.gu_list=l.gu_list AND l.gu_workarea=wa AND x.gu_list<>ListId);
    DELETE FROM k_list_members WHERE gu_member IN (SELECT gu_company FROM k_x_list_members WHERE gu_list=ListId) AND gu_member NOT IN (SELECT x.gu_company FROM k_x_list_members x, k_lists l WHERE x.gu_list=l.gu_list AND l.gu_workarea=wa AND x.gu_list<>ListId);
    DELETE FROM k_x_list_members WHERE gu_list=ListId;
    DELETE FROM k_x_adhoc_mailing_list WHERE gu_list=ListId;
    DELETE FROM k_lists WHERE gu_list=ListId;
  ELSE  
    DELETE FROM k_list_members WHERE gu_member IN (SELECT gu_contact FROM k_x_list_members WHERE gu_list=bk) AND gu_member NOT IN (SELECT x.gu_contact FROM k_x_list_members x, k_lists l WHERE x.gu_list=l.gu_list AND l.gu_workarea=wa AND x.gu_list<>bk);
    DELETE FROM k_list_members WHERE gu_member IN (SELECT gu_company FROM k_x_list_members WHERE gu_list=bk) AND gu_member NOT IN (SELECT x.gu_company FROM k_x_list_members x, k_lists l WHERE x.gu_list=l.gu_list AND l.gu_workarea=wa AND x.gu_list<>bk);
    DELETE FROM k_x_list_members WHERE gu_list=bk;
    DELETE FROM k_x_campaign_lists WHERE gu_list=bk;
    DELETE FROM k_x_adhoc_mailing_list WHERE gu_list=bk;
    DELETE FROM k_lists WHERE gu_list=bk;
  END IF;
END
GO;

ALTER TABLE k_bulkloads ADD de_file VARCHAR(254) NULL
GO;
ALTER TABLE k_bulkloads ADD tp_batch VARCHAR(32) NULL
GO;

CREATE TABLE k_x_user_acourse
(
gu_acourse   CHAR(32) NOT NULL,
gu_user      CHAR(32) NOT NULL,
dt_created   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
bo_admin     SMALLINT DEFAULT 0,
bo_user      SMALLINT DEFAULT 1,

CONSTRAINT pk_x_user_acourse PRIMARY KEY (gu_acourse,gu_user),
CONSTRAINT f1_x_user_acourse FOREIGN KEY (gu_acourse) REFERENCES k_academic_courses(gu_acourse),
CONSTRAINT f2_x_user_acourse FOREIGN KEY (gu_user) REFERENCES k_users(gu_user)
)
GO;

DROP PROCEDURE k_sp_del_acourse
GO;

CREATE PROCEDURE k_sp_del_acourse (CourseId CHAR(32))
BEGIN
  DECLARE GuAddress CHAR(32);
  SELECT gu_address INTO GuAddress FROM k_academic_courses WHERE gu_acourse=CourseId;
  DELETE FROM k_x_user_acourse WHERE gu_acourse=CourseId;
  DELETE FROM k_x_course_alumni WHERE gu_acourse=CourseId;
  DELETE FROM k_x_course_bookings WHERE gu_acourse=CourseId;
  DELETE FROM k_evaluations WHERE gu_acourse=CourseId;
  DELETE FROM k_absentisms WHERE gu_acourse=CourseId;
  DELETE FROM k_academic_courses WHERE gu_acourse=CourseId;
  IF GuAddress IS NOT NULL THEN
    DELETE FROM k_addresses WHERE gu_address=GuAddress;
  END IF;  
END
GO;

CREATE TABLE k_syndentries
(
id_domain    INTEGER      NOT NULL,
gu_workarea  CHAR(32)      NULL,
uri_entry    VARCHAR(200) NOT NULL,
gu_feed      CHAR(32)      NULL,
id_type      VARCHAR(50)   NULL,
dt_published TIMESTAMP     NULL,
dt_modified  TIMESTAMP     NULL,
tx_query     VARCHAR(100)  NULL,
gu_contact   CHAR(32)      NULL,
nu_influence INTEGER       NULL,
nm_author    VARCHAR(100)  NULL,
tl_entry     VARCHAR(254)  NULL,
de_entry     VARCHAR(1000) NULL,
url_addr     VARCHAR(254)  NULL,
bin_entry    MEDIUMBLOB    NULL,
CONSTRAINT pk_syndentries PRIMARY KEY (id_domain,gu_workarea,uri_entry)
)
GO;


