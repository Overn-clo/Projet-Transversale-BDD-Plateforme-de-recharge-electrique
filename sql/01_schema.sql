-- ============================================================================
-- PROJET URBANWATT - 01_schema.sql
-- Création du rôle applicatif, des tables, contraintes d'intégrité et index
-- ============================================================================

-- 1. Sécurité : Création du rôle applicatif à privilèges minimaux
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'urbanwatt_app') THEN
        CREATE ROLE urbanwatt_app WITH LOGIN PASSWORD 'CHANGEME_IN_ENV';
    END IF;
END
$$;

-- Nettoyage préalable
DROP TABLE IF EXISTS paiements CASCADE;
DROP TABLE IF EXISTS sessions_recharge CASCADE;
DROP TABLE IF EXISTS interventions CASCADE;
DROP TABLE IF EXISTS incidents CASCADE;
DROP TABLE IF EXISTS techniciens CASCADE;
DROP TABLE IF EXISTS vehicules CASCADE;
DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS bornes CASCADE;
DROP TABLE IF EXISTS stations CASCADE;

-- 2. Création des tables

CREATE TABLE stations (
    id_station INTEGER PRIMARY KEY,
    code_station VARCHAR(20) NOT NULL UNIQUE,
    nom_station VARCHAR(100) NOT NULL,
    ville VARCHAR(80) NOT NULL,
    adresse VARCHAR(200) NOT NULL,
    date_ouverture DATE NOT NULL
);

CREATE TABLE bornes (
    id_borne INTEGER PRIMARY KEY,
    id_station INTEGER NOT NULL REFERENCES stations(id_station) ON DELETE RESTRICT,
    code_borne VARCHAR(20) NOT NULL UNIQUE,
    puissance_kw INTEGER NOT NULL CHECK (puissance_kw > 0),
    connecteur VARCHAR(20) NOT NULL CHECK (connecteur IN ('Type2', 'CCS')),
    etat VARCHAR(20) NOT NULL CHECK (etat IN ('disponible', 'maintenance', 'hors_service'))
);

CREATE TABLE clients (
    id_client INTEGER PRIMARY KEY,
    prenom VARCHAR(80) NOT NULL,
    nom VARCHAR(80) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    ville VARCHAR(80) NOT NULL,
    date_inscription DATE NOT NULL
);

CREATE TABLE vehicules (
    id_vehicule INTEGER PRIMARY KEY,
    id_client INTEGER NOT NULL REFERENCES clients(id_client) ON DELETE RESTRICT,
    immatriculation VARCHAR(30) NOT NULL UNIQUE,
    marque VARCHAR(50) NOT NULL,
    modele VARCHAR(50) NOT NULL,
    capacite_batterie_kwh INTEGER NOT NULL CHECK (capacite_batterie_kwh > 0)
);

CREATE TABLE techniciens (
    id_technicien INTEGER PRIMARY KEY,
    prenom VARCHAR(80) NOT NULL,
    nom VARCHAR(80) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE incidents (
    id_incident INTEGER PRIMARY KEY,
    id_borne INTEGER NOT NULL REFERENCES bornes(id_borne) ON DELETE RESTRICT,
    date_signalement TIMESTAMP NOT NULL,
    date_resolution TIMESTAMP NULL,
    categorie VARCHAR(30) NOT NULL CHECK (categorie IN ('defaut_reseau', 'erreur_paiement', 'surchauffe', 'panne_connecteur')),
    gravite VARCHAR(20) NOT NULL CHECK (gravite IN ('faible', 'moyenne', 'haute')),
    statut VARCHAR(20) NOT NULL CHECK (statut IN ('ouvert', 'resolu')),
    description TEXT NOT NULL,
    CONSTRAINT chk_incident_dates CHECK (
        (statut = 'ouvert' AND date_resolution IS NULL) OR
        (statut = 'resolu' AND date_resolution IS NOT NULL AND date_resolution >= date_signalement)
    )
);

CREATE TABLE interventions (
    id_intervention INTEGER PRIMARY KEY,
    id_incident INTEGER NOT NULL REFERENCES incidents(id_incident) ON DELETE RESTRICT,
    id_technicien INTEGER NOT NULL REFERENCES techniciens(id_technicien) ON DELETE RESTRICT,
    date_debut TIMESTAMP NOT NULL,
    date_fin TIMESTAMP NULL,
    statut VARCHAR(20) NOT NULL CHECK (statut IN ('en_cours', 'terminee')),
    compte_rendu TEXT NOT NULL,
    CONSTRAINT chk_intervention_dates CHECK (
        (statut = 'en_cours' AND date_fin IS NULL) OR
        (statut = 'terminee' AND date_fin IS NOT NULL AND date_fin >= date_debut)
    )
);

CREATE TABLE sessions_recharge (
    id_session INTEGER PRIMARY KEY,
    id_borne INTEGER NOT NULL REFERENCES bornes(id_borne) ON DELETE RESTRICT,
    id_vehicule INTEGER NOT NULL REFERENCES vehicules(id_vehicule) ON DELETE RESTRICT,
    debut_session TIMESTAMP NOT NULL,
    fin_session TIMESTAMP NULL,
    energie_kwh NUMERIC(8,2) NULL CHECK (energie_kwh >= 0),
    cout_eur NUMERIC(8,2) NULL CHECK (cout_eur >= 0),
    statut VARCHAR(20) NOT NULL CHECK (statut IN ('terminee', 'interrompue', 'annulee')),
    CONSTRAINT chk_session_coherence CHECK (
        (statut = 'annulee' AND fin_session IS NULL AND energie_kwh IS NULL AND cout_eur IS NULL) OR
        (statut IN ('terminee', 'interrompue') AND fin_session IS NOT NULL AND fin_session >= debut_session AND energie_kwh IS NOT NULL AND cout_eur IS NOT NULL)
    )
);

CREATE TABLE paiements (
    id_paiement INTEGER PRIMARY KEY,
    id_session INTEGER NOT NULL UNIQUE REFERENCES sessions_recharge(id_session) ON DELETE RESTRICT,
    date_paiement TIMESTAMP NOT NULL,
    montant_eur NUMERIC(8,2) NOT NULL CHECK (montant_eur >= 0),
    mode_paiement VARCHAR(20) NOT NULL CHECK (mode_paiement IN ('abonnement', 'carte', 'application')),
    statut VARCHAR(20) NOT NULL CHECK (statut IN ('accepte', 'refuse', 'en_attente'))
);

-- ============================================================================
-- 3. Optimisation par Indexation
-- ============================================================================



-- ============================================================================
-- 4. Attribution des droits stricts au rôle applicatif
-- ============================================================================
GRANT CONNECT ON DATABASE urbanwatt TO urbanwatt_app;
GRANT USAGE ON SCHEMA public TO urbanwatt_app;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO urbanwatt_app;
-- Le portail web n'a pas besoin de supprimer des données, mais d'insérer des incidents.
GRANT INSERT, UPDATE ON incidents TO urbanwatt_app;