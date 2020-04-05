/* Formatted on 2013/10/10 17:00 (Formatter Plus v4.8.8) */
SELECT E.EDUCATION_LVL
, B.EMPLID
, F.NAME
, F.PAYGROUP
, EXTRACT(YEAR from F.CMPNY_SENIORITY_DT) as "Antiguedad"
, F.JOBCODE
, F.JOBTITLE
, F.DEPTID
, F.DEPTNAME
, F.LOCATION
, TO_CHAR (D.EFFDT, 'YYYY-MM-DD')
, D.JPM_YN_1
, D.NVQ_STATUS
, D.JPM_TEXT1325_1
, E.JPM_DESCR90
, F.EMPL_STATUS
, F.PAYGROUP
, D.JPM_TEXT254_1
, E.JPM_CAT_TYPE
, E.JPM_CAT_ITEM_ID
  FROM   PS_JPM_PROFILE B
       , PS_JPM_JP_ITEMS D
       , PS_JPM_CAT_ITEMS E
       , PS_EMPLOYEES F/*PS_AA_EMPLOYEESCNV F*/    
 WHERE f.emplid = b.emplid
        AND b.jpm_profile_id = d.jpm_profile_id
        AND d.effdt =
               (SELECT MAX (a.effdt)
                  FROM sysadm.ps_jpm_jp_items a
                 WHERE a.jpm_profile_id = d.jpm_profile_id
                   AND a.jpm_cat_type = d.jpm_cat_type
                   AND a.jpm_cat_item_id = d.jpm_cat_item_id)
        AND d.jpm_cat_type = e.jpm_cat_type
        AND d.jpm_cat_item_id = e.jpm_cat_item_id
        AND e.effdt =
               (SELECT MAX (e_ed.effdt)
                  FROM sysadm.ps_jpm_cat_items e_ed
                 WHERE e.jpm_cat_type = e_ed.jpm_cat_type
                   AND e.jpm_cat_item_id = e_ed.jpm_cat_item_id
                   AND e_ed.effdt <= SYSDATE)
       AND (
                case  WHEN e.education_lvl >=  '50' then E.EDUCATION_LVL  end IN ('50', '60', '70', '80', '90')
                
            OR
                  CASE WHEN e.education_lvl < '50' THEN (SELECT MAX (g.education_lvl)
                  FROM sysadm.ps_jpm_jp_items f, sysadm.ps_jpm_cat_items g
                 WHERE f.jpm_cat_type = g.jpm_cat_type
                   AND f.jpm_cat_item_id = g.jpm_cat_item_id
                   AND g.effdt <= SYSDATE
                   AND f.jpm_profile_id = b.jpm_profile_id
                   AND g.jpm_cat_type NOT IN ('EDLVLACHV', 'LIC')
                   ) END IN ('40', '47')
                   
                   
                   
             )      
        AND f.paygroup IN ('FDC', 'CNV', 'RES')
        AND f.empl_status = 'A'
        AND e.education_lvl >= '30'
        AND e.education_lvl <= '99'
        AND (d.nvq_status = 'C' OR ' ' = 'C')
        AND (e.education_lvl = ' ' OR ' ' = ' ')
        AND e.jpm_cat_type NOT IN ('EDLVLACHV', 'LIC', 'LNG')
       -- AND B.EMPLID = '605519'
       AND f.paygroup IN ('FDC', 'CNV')
order by education_lvl desc 
/