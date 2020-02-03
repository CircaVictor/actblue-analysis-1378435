

-- Contributors by overall total

WITH grouped_contributions AS (

  SELECT individual_id,
         count(*) AS transactions,
         sum(amount)::money AS total,
         avg(amount)::money AS avg_contribution
    FROM ab_1378435_contributions_sorted a
   WHERE individual_id IS NOT NULL
  GROUP
      BY individual_id
  ORDER
      BY sum(amount) DESC
   LIMIT 50

)
SELECT a.name,
       state,
       zip_code
       transactions,
       total,
       avg_contribution
  FROM grouped_contributions g
       LEFT JOIN LATERAL (SELECT (first_name || ' ' || last_name) AS name,
                                 state,
                                 zip_code
                            FROM ab_1378435_contributions_sorted a
                           WHERE a.individual_id = g.individual_id
                           LIMIT 1) AS a
                                    ON true;






-- Contributors by average >= 5 contributions

WITH grouped_contributions AS (

  SELECT individual_id,
         count(*) AS transactions,
         sum(amount)::money AS total,
         avg(amount)::money AS avg_contribution
    FROM ab_1378435_contributions_sorted a
  GROUP
      BY individual_id
  HAVING count(*) >= 5
  ORDER
      BY avg(amount) DESC
   LIMIT 50

)
SELECT a.name,
       state,
       zip_code
       transactions,
       total,
       avg_contribution
  FROM grouped_contributions g
       LEFT JOIN LATERAL (SELECT (first_name || ' ' || last_name) AS name,
                                 state,
                                 zip_code
                            FROM ab_1378435_contributions_sorted a
                           WHERE a.individual_id = g.individual_id
                           LIMIT 1) AS a
                                    ON true;





-- Recipient Committees by overall total

WITH grouped_contributions AS (

  SELECT recipient_committee_fec_id,
         count(*) AS transactions,
         sum(amount)::money AS total,
         avg(amount)::money AS avg_contribution
    FROM ab_1378435_contributions_sorted a
  GROUP
      BY recipient_committee_fec_id
  ORDER
      BY sum(amount) DESC
   LIMIT 50

)
SELECT g.recipient_committee_fec_id AS fec_id,
       a.name,
       transactions,
       total,
       avg_contribution,
       a.candidate_fec_id,
       a.candidate_name,
       a.office,
       a.state,
       a.district,
       a.incumbent_challenger,
       a.is_authorized_committee,
       a.is_principal_committee
  FROM grouped_contributions g
       LEFT JOIN LATERAL (SELECT name,
                                 candidate_fec_id,
                                 candidate_name,
                                 office,
                                 state,
                                 district,
                                 incumbent_challenger,
                                 is_authorized_committee,
                                 is_principal_committee
                            FROM ab_1378435_committees c
                           WHERE c.fec_id = g.recipient_committee_fec_id
                           LIMIT 1) AS a
                                    ON true;





-- Recipient Committees by average

WITH grouped_contributions AS (

  SELECT recipient_committee_fec_id,
         count(*) AS transactions,
         sum(amount)::money AS total,
         avg(amount)::money AS avg_contribution
    FROM ab_1378435_contributions_sorted a
  GROUP
      BY recipient_committee_fec_id
  ORDER
      BY avg(amount) DESC
   LIMIT 50

)
SELECT g.recipient_committee_fec_id AS fec_id,
       a.name,
       transactions,
       total,
       avg_contribution,
       a.candidate_fec_id,
       a.candidate_name,
       a.office,
       a.state,
       a.district,
       a.incumbent_challenger,
       a.is_authorized_committee,
       a.is_principal_committee
  FROM grouped_contributions g
       LEFT JOIN LATERAL (SELECT name,
                                 candidate_fec_id,
                                 candidate_name,
                                 office,
                                 state,
                                 district,
                                 incumbent_challenger,
                                 is_authorized_committee,
                                 is_principal_committee
                            FROM ab_1378435_committees c
                           WHERE c.fec_id = g.recipient_committee_fec_id
                           LIMIT 1) AS a
                                    ON true;





-- States by overall total

SELECT state,
       count(*) AS transactions,
       sum(amount)::money,
       avg(amount)::money
  FROM ab_1378435_contributions_sorted
GROUP
    BY state
ORDER
    BY sum(amount) DESC;





-- States by average

SELECT state,
       count(*) AS transactions,
       sum(amount)::money,
       avg(amount)::money
  FROM ab_1378435_contributions_sorted
GROUP
    BY state
ORDER
    BY sum(amount) DESC;





-- Zipcodes by overall total

SELECT zip_code,
       count(*) AS transactions,
       sum(amount)::money AS total,
       avg(amount)::money AS avg_contribution
  FROM ab_1378435_contributions_sorted
GROUP
    BY zip_code
ORDER
    BY sum(amount) DESC
 LIMIT 50;





-- Zipcodes by average >= 250 contributions

SELECT zip_code,
       count(*) AS transactions,
       sum(amount)::money AS total,
       avg(amount)::money AS avg_contribution
  FROM ab_1378435_contributions_sorted
GROUP
    BY zip_code
HAVING count(*) >= 250
ORDER
    BY avg(amount) DESC
 LIMIT 50;





-- Direct contributions to ActBlue

SELECT count(*) AS transactions,
       sum(amount)::money AS total,
       avg(amount)::money AS avg_contribution
  FROM ab_1378435_contributions_sorted c
 WHERE memo = 'CONTRIBUTION TO ACTBLUE';





-- Future nominee contributions

SELECT count(*) AS transactions,
       sum(amount)::money AS total,
       coalesce(future.candidate,
                'NONE') AS future_candidate,
       avg(amount)::money AS avg_contribution
  FROM ab_1378435_contributions_sorted c
       LEFT JOIN LATERAL (SELECT (regexp_matches(memo, 'EARMARKED FOR DEMOCRATIC NOMINEE FOR (.+) HELD'))[1] AS candidate) AS future
                                                                                                                           ON true
 WHERE memo ~ 'NOMINEE'
GROUP
    BY future.candidate
ORDER
    BY sum(amount) DESC;
         








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

