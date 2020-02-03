

DROP TABLE _ab_1378435_contributions1;


-- create first table

CREATE TABLE _ab_1378435_contributions1 AS

  WITH target_fec_files AS (

    SELECT 1378435 AS fec_file

  )
  SELECT actor_individual_id,
         location_id,
         amount,
         contributed,
         transaction_id,
         contribution_aggregate,
         memo_id
    FROM contributions_2020_cycle c
   WHERE c.actor_individual_id NOT IN (-1, 0)
     AND c.actor_organization_id = 0
     AND EXISTS (SELECT 1
                   FROM target_fec_files tff
                  WHERE tff.fec_file = c.fec_file)
     -- check that we are not looking at bundled contributions
     AND NOT EXISTS (SELECT 1
                       FROM contributions_2020_cycle_maintenance chk
                      WHERE chk.form_id = c.form_id
                        AND grouped = true)
     -- check that we are not looking duplicate contributions
     AND NOT EXISTS (SELECT 1
                       FROM contributions_2020_cycle_maintenance chk
                      WHERE chk.form_id = c.form_id
                        AND duplicate = true)
     -- ignore refunds
     AND NOT EXISTS (SELECT 1
                       FROM contributions_2020_cycle_maintenance chk
                      WHERE chk.form_id = c.form_id
                        AND refund = true);





DROP TABLE IF EXISTS _ab_1378435_contributions2;


-- create second cleansing table


CREATE TABLE _ab_1378435_contributions2 AS

  SELECT actor_individual_id AS individual_id,
         location_id,
         substring(n.first FROM 1 FOR 1) AS first_name,
         n.last AS last_name,
         amount,
         contributed,
         com.fec_id AS recipient_committee_fec_id,
         com_name.name AS recipient_committee_name,
         transaction_id,
         contribution_aggregate,
         m.memo,
         a.zip_code,
         a.state
    FROM _ab_1378435_contributions1 c
         LEFT JOIN LATERAL (SELECT name_id,
                                   zip_code,
                                   state
                              FROM actors a
                             WHERE a.id = c.actor_individual_id) AS a
                                                                 ON true
         LEFT JOIN LATERAL (SELECT first,
                                   last
                              FROM names n
                             WHERE n.id = a.name_id) AS n
                                                     ON true
         LEFT JOIN LATERAL (SELECT memo
                              FROM contribution_memos m
                             WHERE m.id = c.memo_id) AS m
                                                     ON true
         LEFT JOIN LATERAL (SELECT (regexp_matches(memo, '(C\d{8})'))[1] AS fec_id) AS com
                                                                                    ON true
         LEFT JOIN LATERAL (SELECT (regexp_matches(memo, 'EARMARKED FOR (.+)$'))[1] AS name) AS com_name
                                                                                       -- memo does not contain fec id
                                                                                    ON (memo !~ '(C\d{8})'
                                                                                              -- ignore actblue contributions
                                                                                              -- and future nominees
                                                                                          AND memo !~ 'ACTBLUE|NOMINEE');





-- DEBUG: look for opportunities to improve memo logic
SELECT recipient_committee_name,
       count(*)
  FROM _ab_1378435_contributions2
 WHERE recipient_committee_fec_id IS NULL
   AND recipient_committee_name IS NOT NULL
GROUP
    BY recipient_committee_name
ORDER
    BY count(*) DESC;





-- fix empty fec ids
UPDATE _ab_1378435_contributions2
   SET recipient_committee_fec_id = 'C00365536'
 WHERE recipient_committee_name = 'CHC BOLD PAC COMMITTEE FOR HISPANIC CAUSES BUILDING OUR LEADERSHIP DIVERSITY C0036553';





-- update missing recipient committee fec ids
WITH missing_com_names AS (

  SELECT DISTINCT recipient_committee_name
    FROM _ab_1378435_contributions2
   WHERE recipient_committee_fec_id IS NULL
     AND recipient_committee_name IS NOT NULL

), com_matches AS (
  
  SELECT recipient_committee_name,
         coalesce(com.fec_id,
                  a.fec_id) AS fec_id
    FROM missing_com_names m
         LEFT JOIN LATERAL (SELECT fec_id
                              FROM fec_committees_detailed f
                             WHERE f.name = m.recipient_committee_name
                            ORDER
                                BY csv_file
                             LIMIT 1) AS com
                                      ON true
         LEFT JOIN LATERAL (SELECT fec_id
                              FROM actors a
                             WHERE a.name = m.recipient_committee_name
                               AND fec_id IS NOT NULL
                            ORDER
                                BY id
                             LIMIT 1) AS a
                                      ON (com.fec_id IS NULL)

)
UPDATE _ab_1378435_contributions2 a
   SET recipient_committee_fec_id = cm.fec_id
  FROM com_matches cm
 WHERE a.recipient_committee_name = cm.recipient_committee_name;






CREATE INDEX _ab_1378435_contributions2_sort_idx
          ON _ab_1378435_contributions2(state, zip_code, contributed, amount);



DROP TABLE IF EXISTS ab_1378435_contributions_sorted;


-- create final table


CREATE TABLE ab_1378435_contributions_sorted AS
  
  SELECT row_number() OVER (ORDER
                                BY state,
                                   zip_code,
                                   contributed,
                                   amount) AS id,
         individual_id,
         location_id,
         first_name,
         last_name,
         amount,
         contributed,
         recipient_committee_fec_id,
         transaction_id,
         contribution_aggregate,
         memo,
         zip_code,
         state
    FROM _ab_1378435_contributions2 c
  ORDER
      BY state,
         zip_code,
         contributed,
         amount;





-- for exporting
CREATE INDEX ab_1378435_contributions_sorted_export_idx
          ON ab_1378435_contributions_sorted(state);


CREATE INDEX ab_1378435_contributions_sorted_individual_idx
          ON ab_1378435_contributions_sorted(individual_id);







--------- COMMITTEES ---------------


CREATE TABLE ab_1378435_committees AS


  WITH ab_fec_ids AS (

    SELECT DISTINCT recipient_committee_fec_id
      FROM ab_1378435_contributions_sorted
     WHERE recipient_committee_fec_id IS NOT NULL

  ), principal_committee_fec_ids AS (

    SELECT fec_id
      FROM fec_committees_detailed
     WHERE csv_file = 2020
       AND designation in ('P')
       -- make sure we have a candidate and affiliation
       AND candidate_fec_id IS NOT NULL
       AND affiliation IS NOT NULL
    GROUP
        BY fec_id

  -- find actors ids based off of the fec_id
  ), authorized_committee_fec_ids AS (

    SELECT fec_id
      FROM fec_committees_detailed
     WHERE csv_file = 2020
       AND designation in ('A')
       -- make sure we have a candidate and affiliation
       AND candidate_fec_id IS NOT NULL
       AND affiliation IS NOT NULL
    GROUP
        BY fec_id

  )
  SELECT recipient_committee_fec_id AS fec_id,
         com.name,
         com.candidate_fec_id,
         com.candidate_name,
         com.affiliation,
         com.office,
         com.state,
         com.district,
         com.incumbent_challenger,
         (CASE WHEN (is_authorized.committee = true)
               THEN true
               ELSE false
                END) AS is_authorized_committee,
         (CASE WHEN (is_principal.committee = true)
               THEN true
               ELSE false
                END) AS is_principal_committee
    FROM ab_fec_ids ab
         LEFT JOIN LATERAL (SELECT f.name,
                                   f.candidate_fec_id,
                                   can.name AS candidate_name,
                                   coalesce(can.affiliation,
                                            f.affiliation) AS affiliation,
                                   can.office,
                                   can.state,
                                   can.district,
                                   can.incumbent_challenger
                              FROM fec_committees_detailed f
                                   LEFT JOIN LATERAL (SELECT name,
                                                             affiliation,
                                                             office,
                                                             state,
                                                             district,
                                                             incumbent_challenger
                                                        FROM fec_candidates_detailed fc
                                                       WHERE fc.fec_id = f.candidate_fec_id
                                                      ORDER
                                                          BY csv_file DESC
                                                       LIMIT 1) AS can
                                                                ON (f.candidate_fec_id IS NOT NULL)
                             WHERE f.fec_id = ab.recipient_committee_fec_id
                            ORDER
                                BY f.csv_file DESC
                             LIMIT 1) AS com
                                      ON true
         LEFT JOIN LATERAL (SELECT true AS committee
                              FROM authorized_committee_fec_ids p
                             WHERE p.fec_id = ab.recipient_committee_fec_id
                             LIMIT 1) AS is_authorized
                                      ON true
         LEFT JOIN LATERAL (SELECT true AS committee
                              FROM principal_committee_fec_ids p
                             WHERE p.fec_id = ab.recipient_committee_fec_id
                             LIMIT 1) AS is_principal
                                      ON true;




