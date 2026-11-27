-- ==================================================================================================
-- PROJET URBANWATT - sql/03_requetes.sql (Questions 01 à 08 - Mathieu) (Questions 09 à 15 - Thomas)
-- ==================================================================================================

-- Q01 : Afficher les clients ayant réalisé au moins une session de recharge dans la station ST-LIL, sans doublon, avec leur nom et leur prénom.
-- Justification : Chaînage des jointures clients -> vehicules -> sessions_recharge -> bornes -> stations filtré sur ST-LIL, avec DISTINCT sur id_client/nom/prénom pour éliminer les doublons sans confondre d'éventuels homonymes.
SELECT DISTINCT c.id_client, c.nom, c.prenom
FROM clients c
JOIN vehicules v ON c.id_client = v.id_client
JOIN sessions_recharge s ON v.id_vehicule = s.id_vehicule
JOIN bornes b ON s.id_borne = b.id_borne
JOIN stations st ON b.id_station = st.id_station
WHERE st.code_station = 'ST-LIL'
ORDER BY c.nom ASC, c.prenom ASC;

-- Q02 : Lister toutes les bornes de la station ST-TOU, avec leur code, leur puissance, leur type de connecteur et leur état, triées par puissance décroissante.
-- Justification : Jointure interne entre bornes et stations filtrée sur code_station = 'ST-TOU', avec un tri principal par puissance_kw décroissante et un tri secondaire sur code_borne pour la lisibilité.
SELECT b.code_borne, b.puissance_kw, b.connecteur, b.etat
FROM bornes b
JOIN stations st ON b.id_station = st.id_station
WHERE st.code_station = 'ST-TOU'
ORDER BY b.puissance_kw DESC, b.code_borne ASC;

-- Q03 : Afficher l'historique des sessions du véhicule ESSAI-0001 : dates, borne utilisée, énergie, coût et statut, de la plus récente à la plus ancienne.
-- Justification : Jointure de sessions_recharge avec vehicules (filtre sur l'immatriculation) et bornes (pour obtenir le code_borne), triée par debut_session DESC ; les sessions annulées apparaissent naturellement avec NULL pour fin/énergie/coût.
SELECT s.debut_session, s.fin_session, b.code_borne, s.energie_kwh, s.cout_eur, s.statut
FROM sessions_recharge s
JOIN vehicules v ON s.id_vehicule = v.id_vehicule
JOIN bornes b ON s.id_borne = b.id_borne
WHERE v.immatriculation = 'ESSAI-0001'
ORDER BY s.debut_session DESC;

-- Q04 : Lister les clients n'ayant jamais eu de session annulée ou interrompue, y compris ceux qui n'ont effectué aucune recharge.
-- Justification : Utilisation de NOT EXISTS plutôt qu'un JOIN avec filtre != afin de conserver les clients sans véhicule ou sans aucune session, tout en excluant tout client possédant au moins une session annulée ou interrompue.
SELECT c.id_client, c.nom, c.prenom, c.email
FROM clients c
WHERE NOT EXISTS (
    SELECT 1
    FROM vehicules v
    JOIN sessions_recharge s ON v.id_vehicule = s.id_vehicule
    WHERE v.id_client = c.id_client
      AND s.statut IN ('annulee', 'interrompue')
)
ORDER BY c.id_client ASC;

-- Q05 : Afficher les sessions terminées dans la station ST-LYO, triées par énergie délivrée de la plus élevée à la plus faible.
-- Justification : Double filtrage sur la station ST-LYO et sur statut = 'terminee' (excluant les sessions annulées et interrompues), suivi d'un tri décroissant sur energie_kwh.
SELECT s.id_session, b.code_borne, v.immatriculation, s.debut_session, s.fin_session, s.energie_kwh, s.cout_eur
FROM sessions_recharge s
JOIN bornes b ON s.id_borne = b.id_borne
JOIN stations st ON b.id_station = st.id_station
JOIN vehicules v ON s.id_vehicule = v.id_vehicule
WHERE st.code_station = 'ST-LYO'
  AND s.statut = 'terminee'
ORDER BY s.energie_kwh DESC;

-- Q06 : Présenter, pour le client n° 10, toutes ses sessions avec le véhicule concerné, la station, la date et le statut.
-- Justification : Filtrage sur v.id_client = 10 permettant de regrouper l'ensemble des sessions effectuées par tous les véhicules rattachés au client n° 10, avec remontée jusqu'à la table stations.
SELECT s.id_session, v.immatriculation, st.code_station, st.nom_station, s.debut_session, s.statut
FROM sessions_recharge s
JOIN vehicules v ON s.id_vehicule = v.id_vehicule
JOIN bornes b ON s.id_borne = b.id_borne
JOIN stations st ON b.id_station = st.id_station
WHERE v.id_client = 10
ORDER BY s.debut_session DESC;

-- Q07 : Lister les incidents de gravité haute avec le code de la borne, la station, la catégorie, la date de signalement et l'état de résolution.
-- Justification : Jointure incidents -> bornes -> stations filtrée sur gravite = 'haute', affichant le statut (ouvert/resolu) et la date_resolution (NULL si non résolu) triés du plus récent au plus ancien.
SELECT i.id_incident, b.code_borne, st.code_station, i.categorie, i.date_signalement, i.statut, i.date_resolution
FROM incidents i
JOIN bornes b ON i.id_borne = b.id_borne
JOIN stations st ON b.id_station = st.id_station
WHERE i.gravite = 'haute'
ORDER BY i.date_signalement DESC;

-- Q08 : Afficher tous les incidents associés à ST-BOR, classés par date décroissante, en indiquant les interventions éventuelles.
-- Justification : Utilisation d'un LEFT JOIN vers interventions afin de conserver tous les incidents de ST-BOR, y compris ceux qui n'ont encore donné lieu à aucune intervention technique.
SELECT i.id_incident, b.code_borne, i.date_signalement, i.categorie, i.gravite, i.statut AS statut_incident,
       itv.id_intervention, itv.date_debut, itv.date_fin, itv.statut AS statut_intervention
FROM incidents i
JOIN bornes b ON i.id_borne = b.id_borne
JOIN stations st ON b.id_station = st.id_station
LEFT JOIN interventions itv ON i.id_incident = itv.id_incident
WHERE st.code_station = 'ST-BOR'
ORDER BY i.date_signalement DESC;

-- Q09 : Sessions annulées ou interrompues dans ST-NAN
-- Justification : les jointures permettent de relier la session à son véhicule et à la station par l'intermédiaire de la borne. IN sélectionne les deux statuts demandés.
SELECT
    v.immatriculation,
    sr.debut_session,
    sr.statut
FROM sessions_recharge sr
JOIN vehicules v
    ON sr.id_vehicule = v.id_vehicule
JOIN bornes b
    ON sr.id_borne = b.id_borne
JOIN stations st
    ON b.id_station = st.id_station
WHERE st.code_station = 'ST-NAN'
  AND sr.statut IN ('annulee', 'interrompue')
ORDER BY sr.debut_session;

-- Q10 : Clients ayant réalisé une session terminée de plus de 30 kWh
-- Justification : DISTINCT élimine les doublons. Le filtre conserve uniquement les sessions terminées dont l'énergie dépasse strictement 30 kWh.
SELECT DISTINCT
    c.id_client,
    c.prenom,
    c.nom
FROM clients c
JOIN vehicules v
    ON c.id_client = v.id_client
JOIN sessions_recharge sr
    ON v.id_vehicule = sr.id_vehicule
WHERE sr.statut = 'terminee'
  AND sr.energie_kwh > 30
ORDER BY c.nom, c.prenom;

-- Q11 : Nombre de bornes par état et par station
-- Justification: LEFT JOIN conserve toutes les stations. FILTER permet de compter séparément les bornes selon leur état.
SELECT
    st.code_station,
    st.nom_station,
    COUNT(b.id_borne) FILTER (
        WHERE b.etat = 'disponible'
    ) AS bornes_disponibles,
    COUNT(b.id_borne) FILTER (
        WHERE b.etat = 'maintenance'
    ) AS bornes_maintenance,
    COUNT(b.id_borne) FILTER (
        WHERE b.etat = 'hors_service'
    ) AS bornes_hors_service
FROM stations st
LEFT JOIN bornes b
    ON st.id_station = b.id_station
GROUP BY st.id_station, st.code_station, st.nom_station
ORDER BY st.code_station;

-- Q12 : Session terminée avec l'énergie maximale à ST-LIL
-- Justification : la sous-requête calcule l'énergie maximale pour ST-LIL. La requête principale récupère les sessions qui ont exactement cette valeur.
SELECT
    sr.id_session,
    sr.debut_session,
    v.immatriculation,
    b.code_borne,
    sr.energie_kwh
FROM sessions_recharge sr
JOIN bornes b
    ON sr.id_borne = b.id_borne
JOIN stations st
    ON b.id_station = st.id_station
JOIN vehicules v
    ON sr.id_vehicule = v.id_vehicule
WHERE st.code_station = 'ST-LIL'
  AND sr.statut = 'terminee'
  AND sr.energie_kwh = (
      SELECT MAX(sr2.energie_kwh)
      FROM sessions_recharge sr2
      JOIN bornes b2
          ON sr2.id_borne = b2.id_borne
      JOIN stations st2
          ON b2.id_station = st2.id_station
      WHERE st2.code_station = 'ST-LIL'
        AND sr2.statut = 'terminee'
  );

-- Q13 : Nombre de véhicules distincts par station
-- Justification : COUNT(DISTINCT ...) évite de compter plusieurs fois un véhicule ayant rechargé plusieurs fois dans une même station. Le filtre placé dans la jointure conserve les stations sans session terminée.
SELECT
    st.code_station,
    st.nom_station,
    COUNT(DISTINCT sr.id_vehicule) AS nombre_vehicules
FROM stations st
LEFT JOIN bornes b
    ON st.id_station = b.id_station
LEFT JOIN sessions_recharge sr
    ON b.id_borne = sr.id_borne
   AND sr.statut = 'terminee'
GROUP BY st.id_station, st.code_station, st.nom_station
ORDER BY st.code_station;

-- Q14 : Énergie moyenne par véhicule
-- Justification : LEFT JOIN conserve tous les véhicules. AVG ignore les valeurs NULL : un véhicule sans session terminée aura donc une moyenne NULL, et non zéro.
SELECT
    v.immatriculation,
    v.marque,
    v.modele,
    ROUND(AVG(sr.energie_kwh), 2) AS energie_moyenne_kwh
FROM vehicules v
LEFT JOIN sessions_recharge sr
    ON v.id_vehicule = sr.id_vehicule
   AND sr.statut = 'terminee'
GROUP BY v.id_vehicule, v.immatriculation, v.marque, v.modele
ORDER BY v.immatriculation;

-- Q15 : Énergie maximale par station et borne associée
-- Justification : la CTE sessions_max calcule le maximum par station. La requête principale retrouve la borne associée à cette valeur.
WITH sessions_max AS (
    SELECT
        b.id_station,
        MAX(sr.energie_kwh) AS energie_max
    FROM bornes b
    JOIN sessions_recharge sr
        ON b.id_borne = sr.id_borne
    WHERE sr.statut = 'terminee'
    GROUP BY b.id_station
)
SELECT
    st.code_station,
    st.nom_station,
    b.code_borne,
    sm.energie_max
FROM sessions_max sm
JOIN stations st
    ON sm.id_station = st.id_station
JOIN bornes b
    ON st.id_station = b.id_station
JOIN sessions_recharge sr
    ON b.id_borne = sr.id_borne
   AND sr.statut = 'terminee'
   AND sr.energie_kwh = sm.energie_max
ORDER BY st.code_station, b.code_borne;
