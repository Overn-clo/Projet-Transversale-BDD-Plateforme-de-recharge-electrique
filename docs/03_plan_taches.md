# Plan de Répartition des Tâches et Organisation — Projet URBANWATT

## 1. Équipe Projet
* **Mathieu** — Architecte Base de Données, Modélisation Conceptuelle & Exploitation SQL
* **Thomas** — Backend/Portail, Intégration des Données, Sécurité & Continuité

---

## 2. Tableau de Répartition par Livrable

| Phase du projet | Livrables associés | Mathieu | Thomas |
| :--- | :--- | :--- | :--- |
| **1. Initialisation & Analyse CSV** | Dépôt Git, `README.md`, `.gitignore`, `docs/03_plan_taches.md` | Exploration des CSV (`stations`, `bornes`, `incidents`, `interventions`, `techniciens`). Rédaction du `README.md` et du plan de tâches. | Initialisation du dépôt Git, création de l'arborescence, configuration du `.gitignore`. Exploration des CSV (`clients`, `vehicules`, `sessions_recharge`, `paiements`). |
| **2. Modélisation & Dictionnaire** | `docs/01_regles_et_modeles.md`, `docs/02_dictionnaire_donnees.md` | Formalisation des règles de gestion (RG1 à RG5), construction du MCD (Mermaid/Looping) et justification de la normalisation en 3NF. | Dérivation du MLD relationnel et rédaction complète du dictionnaire de données des 9 tables (types, domaines, contraintes). |
| **3. Déploiement & Import SQL** | `sql/01_schema.sql`, `sql/02_import_et_verif.sql` | Écriture de `01_schema.sql` (`CREATE TABLE`, PK, FK, `UNIQUE`, `CHECK`), conception et justification des index B-Tree de performance. | Écriture de la procédure d'importation ordonnée (`\copy`), gestion des cellules vides (`NULL`) et écriture des contrôles post-import (`02_import_et_verif.sql`). |
| **4. Exploitation SQL (Catalogue)** | `sql/03_requetes.sql` (31 requêtes) | **15 requêtes :** Questions obligatoires **Q01 à Q08**, questions d'agrégation **Q16 à Q19**, et questions de synthèse **Q25 à Q27**. | **16 requêtes :** Questions obligatoires **Q09 à Q15**, questions d'analyse **Q20 à Q24**, et questions de synthèse **Q28 à Q31**. |
| **5. Portail Web & API** | `app/main.py`, `app/static/index.html`, `requirements.txt` | Écriture des requêtes SQL paramétrées pour `/api/stations` et `/api/stations/{id}/bornes`, tests des requêtes et revue de code. | Développement du serveur FastAPI, gestion des erreurs HTTP (404/503) et création de l'interface web interactive (HTML/CSS/JS). |
| **6. Sécurité & Sauvegarde** | `infra/docker-compose.yml`, `.env.example`, `sauvegardes/` | Création du rôle PostgreSQL à moindre privilège (`urbanwatt_app`) et attribution stricte des droits (`GRANT SELECT`). | Configuration Docker Compose, fichier `.env.example`, exécution de `pg_dump` / `pg_restore` sur `urbanwatt_restore_test` et preuves. |
| **7. Tests & Validation** | `docs/04_strategie_et_tests.md` | Exécution, validation et captures des scénarios **T01** (intégrité import) et **T05** (contrôle de sécurité des privilèges SQL). | Exécution, validation et captures des scénarios **T02**, **T03** (Portail/API), **T04** (restauration), **T06** (injection SQL) et analyse des risques. |

---

## 3. Répartition détaillée du Catalogue SQL (`sql/03_requetes.sql`)

* **Mathieu (15 requêtes) :**
  * *Socle obligatoire (8) :* Q01 (Clients ST-LIL), Q02 (Bornes ST-TOU), Q03 (Historique ESSAI-0001), Q04 (Clients sans annulation/interruption), Q05 (Sessions terminées ST-LYO), Q06 (Sessions client n°10), Q07 (Incidents gravité haute), Q08 (Incidents et interventions ST-BOR).
  * *Intermédiaires & Avancées (4) :* Q16 (Sessions ESSAI-0007), Q17 (Utilisateurs BR-NAN-01), Q18 (Bornes avec >= 2 incidents), Q19 (Division relationnelle sur toutes les stations).
  * *Synthèse & Approfondissement (3) :* Q25 (Bornes sans incident), Q26 (Record d'énergie par véhicule), Q27 (Bilan par station sans double comptage via CTE).

* **Thomas (16 requêtes) :**
  * *Socle obligatoire (7) :* Q09 (Sessions annulées/interrompues ST-NAN), Q10 (Clients > 30 kWh), Q11 (États des bornes par station), Q12 (Session max ST-LIL), Q13 (Véhicules distincts par station), Q14 (Énergie moyenne par véhicule), Q15 (Record d'énergie et borne par station).
  * *Intermédiaires & Avancées (5) :* Q20 (Classement et rang des clients), Q21 (Clients avec >= 2 interruptions), Q22 (Chiffre d'affaires encaissé par station), Q23 (Vérification booléenne ESSAI-0007 à ST-BOR), Q24 (Top 10 des paiements acceptés).
  * *Synthèse & Approfondissement (4) :* Q28 (Bilan d'heures des techniciens), Q29 (Jours records de sessions terminées), Q30 (Top 5 bornes par taux d'interruption), Q31 (Comparaison avec la session précédente via `LAG`).

---

## 4. Organisation de la Soutenance Orale (10 minutes + 5 minutes de questions)

1. **Partie 1 — Mathieu (00:00 à 05:00) :**
   * Présentation du contexte URBANWATT, des règles de gestion et justification du MCD/MLD en 3NF (1 min 30).
   * Démonstration du schéma PostgreSQL (`01_schema.sql`), des contraintes `CHECK` (sessions annulées) et justification des index (1 min 30).
   * Exécution en direct d'une requête complexe du catalogue (ex: Q15 ou Q27 avec CTE et fenêtrage) (2 min).
2. **Partie 2 — Thomas (05:00 à 10:00) :**
   * Démonstration du portail Web : recherche par ville, affichage des bornes d'une station et gestion d'erreur 404 sur une station inconnue (2 min).
   * Présentation de la sécurité (`.env.example`, `.gitignore`, rôle `urbanwatt_app`, requêtes paramétrées) (1 min 30).
   * Démonstration de la restauration (`pg_dump` / `pg_restore` sur `urbanwatt_restore_test`) et synthèse du cahier de tests (1 min 30).