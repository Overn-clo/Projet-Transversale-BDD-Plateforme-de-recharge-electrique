# ============================================================================
# PROJET URBANWATT - app/queries.py
# Requêtes SQL pour l'API
# ============================================================================

# 1. GET /api/stations (sans filtre)
# Liste les 120 stations avec le nombre total de bornes et le compteur de bornes disponibles.
QUERY_LIST_STATIONS = """
    SELECT
        s.id_station,
        s.code_station,
        s.nom_station,
        s.ville,
        s.adresse,
        COUNT(b.id_borne) AS total_bornes,
        COUNT(b.id_borne) FILTER (WHERE b.etat = 'disponible') AS bornes_disponibles,
        COUNT(b.id_borne) FILTER (WHERE b.etat = 'maintenance') AS bornes_maintenance,
        COUNT(b.id_borne) FILTER (WHERE b.etat = 'hors_service') AS bornes_hors_service
    FROM stations s
    LEFT JOIN bornes b ON s.id_station = b.id_station
    GROUP BY s.id_station, s.code_station, s.nom_station, s.ville, s.adresse
    ORDER BY s.code_station ASC;
"""

# 2. GET /api/stations?ville=... (avec filtre paramétré %s)
# Filtre insensible à la casse sur la ville via ILIKE %s.
# Paramètre attendu : (f"%{ville}%",)
QUERY_LIST_STATIONS_BY_VILLE = """
    SELECT
        s.id_station,
        s.code_station,
        s.nom_station,
        s.ville,
        s.adresse,
        COUNT(b.id_borne) AS total_bornes,
        COUNT(b.id_borne) FILTER (WHERE b.etat = 'disponible') AS bornes_disponibles,
        COUNT(b.id_borne) FILTER (WHERE b.etat = 'maintenance') AS bornes_maintenance,
        COUNT(b.id_borne) FILTER (WHERE b.etat = 'hors_service') AS bornes_hors_service
    FROM stations s
    LEFT JOIN bornes b ON s.id_station = b.id_station
    WHERE s.ville ILIKE %s
    GROUP BY s.id_station, s.code_station, s.nom_station, s.ville, s.adresse
    ORDER BY s.code_station ASC;
"""

# 3a. GET /api/stations/{id}/bornes — Vérification de la station
# Permet à l'API de renvoyer un code HTTP 404 propre si l'id_station n'existe pas.
# Paramètre attendu : (station_id,)
QUERY_GET_STATION_BY_ID = """
    SELECT
        id_station,
        code_station,
        nom_station,
        ville,
        adresse,
        date_ouverture
    FROM stations
    WHERE id_station = %s;
"""

# 3b. GET /api/stations/{id}/bornes — Liste des bornes de la station
# Récupère les bornes d'une station donnée, triées par puissance décroissante puis par code.
# Paramètre attendu : (station_id,)
QUERY_LIST_BORNES_BY_STATION = """
    SELECT
        id_borne,
        code_borne,
        puissance_kw,
        connecteur,
        etat
    FROM bornes
    WHERE id_station = %s
    ORDER BY puissance_kw DESC, code_borne ASC;
"""

# 4. BONUS — Statistiques globales du réseau (pour le bandeau du portail)
QUERY_NETWORK_STATS = """
    SELECT
        (SELECT COUNT(*) FROM stations) AS total_stations,
        (SELECT COUNT(*) FROM bornes) AS total_bornes,
        (SELECT COUNT(*) FROM bornes WHERE etat = 'disponible') AS bornes_disponibles,
        (SELECT COUNT(*) FROM incidents WHERE statut = 'ouvert') AS incidents_ouverts;
"""