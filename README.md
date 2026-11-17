# Projet URBANWATT — Plateforme de gestion et supervision de bornes de recharge

## 1. Présentation du Projet
URBANWATT exploite un réseau national de 120 stations et 600 bornes de recharge pour véhicules électriques. Ce dépôt contient le prototype opérationnel centralisant la gestion des stations, bornes, clients, véhicules, sessions de recharge, paiements, incidents et interventions techniques sous PostgreSQL, accompagné d'une API REST et d'un portail de supervision web.

## 2. Arborescence du Dépôt
├── README.md                       # Présentation générale, guide de démarrage et répartition
├── docs/                           # Documentation fonctionnelle, modélisation et tests
│   ├── 01_regles_et_modeles.md     # Règles de gestion, MCD (Mermaid), MLD et justification
│   ├── 02_dictionnaire_donnees.md  # Dictionnaire complet des 9 tables
│   ├── 03_plan_taches.md           # Répartition des tâches de l'équipe projet
│   └── 04_strategie_et_tests.md    # Cahier de tests (5 scénarios + sécurité) et analyse des risques
│   └── schema_relationnel_urbanwatt.png    # Schéma relationnel des tables de la BDD
├── sql/                            # Scripts SQL PostgreSQL
│   ├── 01_schema.sql               # Création des tables, contraintes (PK, FK, CHECK, UNIQUE) et index
│   ├── 02_import_et_verif.sql      # Procédure d'import ordonnée des 9 CSV et contrôles d'intégrité
│   └── 03_requetes.sql             # Catalogue complet des 31 requêtes SQL commentées
├── app/                            # Portail Web minimal (Backend FastAPI + Frontend HTML/JS)
│   ├── main.py                     # Serveur API PostgreSQL avec requêtes paramétrées
│   ├── requirements.txt            # Dépendances Python
│   └── static/
│       └── index.html              # Interface de consultation des stations et bornes
├── infra/                          # Déploiement et configuration sécurisée
│   ├── docker-compose.yml          # Conteneurisation PostgreSQL + pgAdmin + API
│   └── .env.example                # Modèle de variables d'environnement sans secret réel
└── sauvegardes/                    # Continuité d'activité
    └── procedure_sauvegarde.md     # Procédure pg_dump, restauration sur base de test et preuves

## 3. Membres du Groupe et Répartition des Contributions
Projet réalisé en binôme:
* **Mathieu :** Conception MCD/MLD & justification 3NF, script `sql/01_schema.sql` (tables, contraintes, index), requêtes SQL Q01–Q08, Q16–Q19, Q25–Q27, requêtes paramétrées de l'API, configuration du rôle `urbanwatt_app` et tests T01/T05.
* **Thomas :** Initialisation Git & `.gitignore`, dictionnaire de données, script `sql/02_import_et_verif.sql`, requêtes SQL Q09–Q15, Q20–Q24, Q28–Q31, développement du portail Web (FastAPI + interface HTML/JS), Docker/env, sauvegarde `pg_dump`/`pg_restore` et tests T02/T03/T04/T06.

*(Voir le détail complet dans `docs/03_plan_taches.md`)*