CREATE VIEW v_pagesets_mailings AS
(SELECT
p.gu_pageset,p.gu_workarea,p.nm_pageset,p.tx_comments,p.path_data,p.dt_created,m.nm_microsite,p.id_status,p.id_language,m.id_app,p.bo_urgent,NULL AS dt_execution
FROM k_pagesets p,k_microsites m WHERE p.gu_microsite=m.gu_microsite OR p.gu_microsite IS NULL)
UNION
(SELECT
a.gu_mailing AS gu_pageset,a.gu_workarea,a.nm_mailing AS nm_pageset,a.tx_subject AS tx_comments ,'Hipermail' AS path_data,a.dt_created,'AdHoc' AS nm_microsite,a.id_status,'' AS id_language,21 AS id_app,a.bo_urgent,a.dt_execution
FROM k_adhoc_mailings a);