UPDATE k_version SET vs_stamp='6.0.0'
GO;

CREATE OR REPLACE PROCEDURE k_sp_read_pageset (IdPageSet CHAR, IdMicrosite OUT CHAR, NmMicrosite OUT VARCHAR22, IdWorkArea OUT CHAR, NmPageSet OUT VARCHAR22, VsStamp OUT VARCHAR22, IdLanguage OUT CHAR, DtModified OUT DATE, PathData OUT VARCHAR22, IdStatus OUT VARCHAR22, PathMetaData OUT VARCHAR22, TxComments OUT VARCHAR22, GuCompany OUT CHAR, GuProject OUT CHAR, TxEmailFrom OUT VARCHAR22,TxEmailReply OUT VARCHAR22, NmFrom OUT VARCHAR22, TxSubject OUT VARCHAR22) IS
BEGIN
  SELECT m.nm_microsite,m.gu_microsite,p.gu_workarea,p.nm_pageset,p.vs_stamp,p.id_language,p.dt_modified,p.path_data,p.id_status,m.path_metadata,p.tx_comments,p.gu_company,p.gu_project,p.tx_email_from,p.tx_email_reply,p.nm_from,p.tx_subject INTO NmMicrosite,IdMicrosite,IdWorkArea,NmPageSet,VsStamp,IdLanguage,DtModified,PathData,IdStatus,PathMetaData,TxComments,GuCompany,GuProject,TxEmailFrom,TxEmailReply,NmFrom,TxSubject FROM k_pagesets p, k_microsites m WHERE p.gu_pageset=IdPageSet AND p.gu_microsite(+)=m.gu_microsite;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NmMicrosite:=NULL;
    IdMicrosite:=NULL;
    IdWorkArea :=NULL;
    NmPageSet  :=NULL;
    DtModified :=NULL;
    GuCompany  :=NULL;
    GuProject  :=NULL;
    NmFrom     :=NULL;
    TxSubject  :=NULL;    
    TxEmailFrom:=NULL;
    TxEmailReply:=NULL;
END k_sp_read_pageset;
GO;

ALTER TABLE k_x_list_members ADD tx_info VARCHAR2(254) NULL
GO;

ALTER TABLE k_pagesets ADD tx_email_from VARCHAR2(254) NULL
GO;
ALTER TABLE k_pagesets ADD tx_email_reply VARCHAR2(254) NULL
GO;
ALTER TABLE k_pagesets ADD nm_from VARCHAR2(254) NULL
GO;
ALTER TABLE k_pagesets ADD tx_subject VARCHAR2(254) NULL
GO;
ALTER TABLE k_meetings ADD id_icalendar VARCHAR2(255) NULL
GO;
CREATE INDEX i4_meetings ON k_meetings(id_icalendar);
GO;
ALTER TABLE k_jobs ADD nu_sent NUMBER(11) DEFAULT 0
GO;
ALTER TABLE k_jobs ADD nu_opened NUMBER(11) DEFAULT 0
GO;
ALTER TABLE k_jobs ADD nu_unique NUMBER(11) DEFAULT 0
GO;
ALTER TABLE k_jobs ADD nu_clicks NUMBER(11) DEFAULT 0
GO;

ALTER TABLE k_urls ADD nu_clicks NUMBER(11) DEFAULT 0
GO;
ALTER TABLE k_urls ADD dt_last_visit TIMESTAMP NULL
GO;

ALTER TABLE k_contacts ADD url_twitter VARCHAR2(254) NULL
GO;

CREATE TABLE k_jobs_atoms_by_day
(
dt_execution  CHAR(10)    NOT NULL,
gu_job        CHAR(32)    NOT NULL,
gu_workarea   CHAR(32)    NOT NULL,
gu_job_group  CHAR(32)        NULL,
nu_msgs       NUMBER(11)    DEFAULT 0,
CONSTRAINT pk_jobs_atoms_by_day PRIMARY KEY(dt_execution,gu_job)
)  
GO;

CREATE TABLE k_jobs_atoms_by_hour
(
dt_hour       NUMBER(5)    NOT NULL,
gu_job        CHAR(32)    NOT NULL,
gu_workarea   CHAR(32)    NOT NULL,
gu_job_group  CHAR(32)        NULL,
nu_msgs       NUMBER(11)    DEFAULT 0,
CONSTRAINT pk_jobs_atoms_by_hour PRIMARY KEY(dt_hour,gu_job)
)  
GO;

CREATE TABLE k_jobs_atoms_by_agent
(
id_agent      VARCHAR2(50) NOT NULL,
gu_job        CHAR(32)    NOT NULL,
gu_workarea   CHAR(32)    NOT NULL,
gu_job_group  CHAR(32)        NULL,
nu_msgs       NUMBER(11)    DEFAULT 0,
CONSTRAINT pk_jobs_atoms_by_agent PRIMARY KEY(id_agent,gu_job)
)  
GO;

CREATE OR REPLACE PROCEDURE k_sp_del_job (IdJob CHAR) IS
BEGIN
  DELETE k_jobs_atoms_by_agent WHERE gu_job=IdJob;
  DELETE k_jobs_atoms_by_hour WHERE gu_job=IdJob;
  DELETE k_jobs_atoms_by_day WHERE gu_job=IdJob;
  DELETE k_job_atoms_clicks WHERE gu_job=IdJob;
  DELETE k_job_atoms_tracking WHERE gu_job=IdJob;
  DELETE k_job_atoms_archived WHERE gu_job=IdJob;
  DELETE k_job_atoms WHERE gu_job=IdJob;
  DELETE k_jobs WHERE gu_job=IdJob;
END k_sp_del_job;
GO;

CREATE OR REPLACE PROCEDURE k_sp_del_list (ListId CHAR) IS
  tp NUMBER(6);
  wa CHAR(32);
  bk CHAR(32);

BEGIN

  SELECT tp_list,gu_workarea INTO tp,wa FROM k_lists WHERE gu_list=ListId;

  SELECT gu_list INTO bk FROM k_lists WHERE gu_workarea=wa AND gu_query=ListId AND tp_list=4;

  DELETE k_x_cat_objs WHERE gu_object=ListId;
  UPDATE k_activities SET gu_list=NULL WHERE gu_list=ListId;
  UPDATE k_x_activity_audience SET gu_list=NULL WHERE gu_list=ListId;

  DELETE k_list_members WHERE gu_member IN (SELECT gu_contact FROM k_x_list_members WHERE gu_list=bk) AND gu_member NOT IN (SELECT x.gu_contact FROM k_x_list_members x, k_lists l WHERE x.gu_list=l.gu_list AND l.gu_workarea=wa AND x.gu_list<>bk);
  DELETE k_list_members WHERE gu_member IN (SELECT gu_company FROM k_x_list_members WHERE gu_list=bk) AND gu_member NOT IN (SELECT x.gu_company FROM k_x_list_members x, k_lists l WHERE x.gu_list=l.gu_list AND l.gu_workarea=wa AND x.gu_list<>bk);

  DELETE k_x_list_members WHERE gu_list=bk;
  
  DELETE k_x_campaign_lists WHERE gu_list=bk;

  DELETE k_x_adhoc_mailing_list WHERE gu_list=bk;
  
  DELETE k_lists WHERE gu_list=bk;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    bk:=NULL;

    DELETE k_list_members WHERE gu_member IN (SELECT gu_contact FROM k_x_list_members WHERE gu_list=ListId) AND gu_member NOT IN (SELECT x.gu_contact FROM k_x_list_members x, k_lists l WHERE x.gu_list=l.gu_list AND l.gu_workarea=wa AND x.gu_list<>ListId);

    DELETE k_list_members WHERE gu_member IN (SELECT gu_company FROM k_x_list_members WHERE gu_list=ListId) AND gu_member NOT IN (SELECT x.gu_company FROM k_x_list_members x, k_lists l WHERE x.gu_list=l.gu_list AND l.gu_workarea=wa AND x.gu_list<>ListId);

    DELETE k_x_list_members WHERE gu_list=ListId;

    DELETE k_x_campaign_lists WHERE gu_list=ListId;

    DELETE k_x_adhoc_mailing_list WHERE gu_list=ListId;

    DELETE k_lists WHERE gu_list=ListId;
END k_sp_del_list;
GO;

ALTER TABLE k_bulkloads ADD de_file VARCHAR2(254) NULL
GO;
ALTER TABLE k_bulkloads ADD tp_batch VARCHAR2(32) NULL
GO;

CREATE TABLE k_x_user_acourse
(
gu_acourse   CHAR(32) NOT NULL,
gu_user      CHAR(32) NOT NULL,
dt_created   DATE DEFAULT GETDATE,
bo_admin     NUMBER(5) DEFAULT 0,
bo_user      NUMBER(5) DEFAULT 1,

CONSTRAINT pk_x_user_acourse PRIMARY KEY (gu_acourse,gu_user),
CONSTRAINT f1_x_user_acourse FOREIGN KEY (gu_acourse) REFERENCES k_academic_courses(gu_acourse),
CONSTRAINT f2_x_user_acourse FOREIGN KEY (gu_user) REFERENCES k_users(gu_user)
)
GO;

CREATE OR REPLACE PROCEDURE k_sp_del_acourse (CourseId CHAR) IS
  GuAddress CHAR(32);
BEGIN
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
  DELETE FROM k_academic_courses WHERE gu_acourse=CourseId;
END k_sp_del_acourse;
GO;

CREATE TABLE k_syndentries
(
id_domain    NUMBER(11)      NOT NULL,
gu_workarea  CHAR(32)      NULL,
uri_entry    VARCHAR2(200) NOT NULL,
gu_feed      CHAR(32)      NULL,
id_type      VARCHAR2(50)   NULL,
dt_published DATE     NULL,
dt_modified  DATE     NULL,
tx_query     VARCHAR2(100)  NULL,
gu_contact   CHAR(32)      NULL,
nu_influence NUMBER(11)       NULL,
nm_author    VARCHAR2(100)  NULL,
tl_entry     VARCHAR2(254)  NULL,
de_entry     VARCHAR2(1000) NULL,
url_addr     VARCHAR2(254)  NULL,
bin_entry    LONG RAW    NULL,
CONSTRAINT pk_syndentries PRIMARY KEY (id_domain,gu_workarea,uri_entry)
)
GO;
