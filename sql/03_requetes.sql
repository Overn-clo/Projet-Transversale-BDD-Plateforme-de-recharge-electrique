-- ============================================================================
-- PROJET URBANWATT - sql/03_requetes.sql (Questions 01 à 08 - Mathieu)
-- ============================================================================

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