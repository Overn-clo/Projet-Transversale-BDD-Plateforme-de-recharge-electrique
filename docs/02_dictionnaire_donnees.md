# 2. Modèle Logique de Données (MLD) et Dictionnaire des données — URBANWATT

## 2.1. Présentation du Modèle Logique de Données (MLD)

Le Modèle Logique de Données (MLD) est obtenu à partir du Modèle Conceptuel de Données (MCD) validé. Il permet de traduire les entités et les associations du MCD en tables relationnelles.

Le modèle relationnel URBANWATT comporte 9 tables. Chaque table possède une clé primaire (PK) permettant d'identifier chaque enregistrement de manière unique. Les relations entre les tables sont assurées par des clés étrangères (FK), garantissant l'intégrité référentielle.

### 2.1.1. Schéma relationnel

Le schéma relationnel est organisé comme suit :

- **STATIONS** (id_station, code_station, nom_station, ville, adresse, date_ouverture)
- **BORNES** (id_borne, id_station, code_borne, puissance_kw, connecteur, etat)
- **CLIENTS** (id_client, prenom, nom, email, ville, date_inscription)
- **VEHICULES** (id_vehicule, id_client, immatriculation, marque, modele, capacite_batterie_kwh)
- **SESSIONS_RECHARGE** (id_session, id_borne, id_vehicule, debut_session, fin_session, energie_kwh, cout_eur, statut)
- **PAIEMENTS** (id_paiement, id_session, date_paiement, montant_eur, mode_paiement, statut)
- **INCIDENTS** (id_incident, id_borne, date_signalement, date_resolution, categorie, gravite, statut, description)
- **TECHNICIENS** (id_technicien, prenom, nom, email)
- **INTERVENTIONS** (id_intervention, id_incident, id_technicien, date_debut, date_fin, statut, compte_rendu)

### 2.1.2. Identification des clés primaires et étrangères

| stations | id_station | Aucune |
| bornes | id_borne | id_station |
| clients | id_client | Aucune |
| vehicules | id_vehicule | id_client |
| sessions_recharge | id_session | id_borne, id_vehicule |
| paiements | id_paiement | id_session |
| incidents | id_incident | id_borne |
| techniciens | id_technicien | Aucune |
| interventions | id_intervention | id_incident, id_technicien |

### 2.1.3. Règles de gestion des relations

Les clés étrangères matérialisent les associations définies dans le MCD :

| HEBERGER | STATIONS (1,N) – BORNES (1,1) | id_station dans bornes |
| POSSEDER | CLIENTS (0,N) – VEHICULES (1,1) | id_client dans vehicules |
| ALIMENTER | BORNES (0,N) – SESSIONS_RECHARGE (1,1) | id_borne dans sessions_recharge |
| EFFECTUER | VEHICULES (0,N) – SESSIONS_RECHARGE (1,1) | id_vehicule dans sessions_recharge |
| GENERER | SESSIONS_RECHARGE (0,1) – PAIEMENTS (1,1) | id_session dans paiements, UNIQUE |
| SUBIR | BORNES (0,N) – INCIDENTS (1,1) | id_borne dans incidents |
| DECLENCHER | INCIDENTS (0,N) – INTERVENTIONS (1,1) | id_incident dans interventions |
| REALISER | TECHNICIENS (0,N) – INTERVENTIONS (1,1) | id_technicien dans interventions |

La clé étrangère `id_session` dans la table PAIEMENTS possède une contrainte UNIQUE afin de garantir qu'une session ne puisse pas être associée à plusieurs paiements.

Les clés étrangères utilisent la règle de suppression `ON DELETE RESTRICT` afin de protéger les données historiques et d'éviter la suppression d'enregistrements encore référencés.

---

## 2.2. Dictionnaire des données

Le dictionnaire des données présente l'ensemble des attributs des 9 tables de la base de données URBANWATT.

Pour chaque attribut, sont précisés son nom, son type SQL, ses contraintes d'intégrité et sa signification métier.

### Conventions utilisées

- **PK (Primary Key)** : clé primaire, identifiant unique d'un enregistrement.
- **FK (Foreign Key)** : clé étrangère, référence vers une autre table.
- **NOT NULL** : valeur obligatoire.
- **UNIQUE** : valeur unique dans la table.
- **CHECK** : contrainte vérifiant une condition sur la valeur.
- **NULL** : valeur facultative pouvant être absente.

---

### 2.2.1. Table STATIONS

**Description :** Cette table contient les informations relatives aux stations de recharge du réseau URBANWATT. Chaque station possède un identifiant technique et un code métier unique.

| id_station | INTEGER | PK, NOT NULL | Identifiant technique unique de la station. |
| code_station | VARCHAR(20) | NOT NULL, UNIQUE | Code métier unique de la station (ex : ST-LIL). |
| nom_station | VARCHAR(100) | NOT NULL | Nom de la station de recharge. |
| ville | VARCHAR(80) | NOT NULL | Ville dans laquelle se situe la station. |
| adresse | VARCHAR(200) | NOT NULL | Adresse postale de la station. |
| date_ouverture | DATE | NOT NULL | Date de mise en service de la station. |

**Contraintes métier :**
- Chaque station possède un identifiant unique.
- Le code de chaque station doit être unique.
- Une station doit regrouper au moins une borne dans le réseau opérationnel.

### 2.2.2. Table BORNES

**Description :** Cette table répertorie les bornes de recharge installées dans les différentes stations. Chaque borne est obligatoirement rattachée à une station.

| id_borne | INTEGER | PK, NOT NULL | Identifiant technique unique de la borne. |
| id_station | INTEGER | FK, NOT NULL | Identifiant de la station à laquelle appartient la borne. |
| code_borne | VARCHAR(20) | NOT NULL, UNIQUE | Code métier unique de la borne (ex : BR-LIL-01). |
| puissance_kw | INTEGER | NOT NULL, CHECK (> 0) | Puissance électrique nominale de la borne exprimée en kW. |
| connecteur | VARCHAR(20) | NOT NULL, CHECK | Type de connecteur disponible (Type2 ou CCS). |
| etat | VARCHAR(20) | NOT NULL, CHECK | État opérationnel de la borne. |

**Contraintes métier :**
- Chaque borne appartient à une seule station.
- Le code de chaque borne doit être unique.
- La puissance électrique doit être strictement positive.
- Le connecteur doit être égal à `Type2` ou `CCS`.
- L'état doit être égal à `disponible`, `maintenance` ou `hors_service`.

**Clé étrangère :** `id_station` référence `stations(id_station)`.

### 2.2.3. Table CLIENTS

**Description :** Cette table contient les informations personnelles et administratives des clients inscrits au service URBANWATT.

| id_client | INTEGER | PK, NOT NULL | Identifiant unique du client. |
| prenom | VARCHAR(80) | NOT NULL | Prénom du client. |
| nom | VARCHAR(80) | NOT NULL | Nom de famille du client. |
| email | VARCHAR(150) | NOT NULL, UNIQUE | Adresse électronique unique du client. |
| ville | VARCHAR(80) | NOT NULL | Ville de résidence du client. |
| date_inscription | DATE | NOT NULL | Date d'inscription du client au service. |

**Contraintes métier :**
- Chaque client possède un identifiant unique.
- Chaque adresse email doit être unique.
- Les informations obligatoires du client doivent être renseignées.

### 2.2.4. Table VEHICULES

**Description :** Cette table répertorie les véhicules électriques enregistrés par les clients. Chaque véhicule appartient obligatoirement à un seul client.

| id_vehicule | INTEGER | PK, NOT NULL | Identifiant unique du véhicule. |
| id_client | INTEGER | FK, NOT NULL | Identifiant du client propriétaire du véhicule. |
| immatriculation | VARCHAR(30) | NOT NULL, UNIQUE | Numéro d'immatriculation unique du véhicule. |
| marque | VARCHAR(50) | NOT NULL | Marque du véhicule électrique. |
| modele | VARCHAR(50) | NOT NULL | Modèle du véhicule électrique. |
| capacite_batterie_kwh | INTEGER | NOT NULL, CHECK (> 0) | Capacité de la batterie exprimée en kWh. |

**Contraintes métier :**
- Chaque véhicule appartient à un seul client.
- Un client peut enregistrer zéro, un ou plusieurs véhicules.
- L'immatriculation doit être unique.
- La capacité de la batterie doit être strictement positive.

**Clé étrangère :** `id_client` référence `clients(id_client)`.

### 2.2.5. Table SESSIONS_RECHARGE

**Description :** Cette table enregistre l'historique des sessions de recharge réalisées sur le réseau URBANWATT. Chaque session concerne un véhicule et une borne.

| id_session | INTEGER | PK, NOT NULL | Identifiant unique de la session de recharge. |
| id_borne | INTEGER | FK, NOT NULL | Identifiant de la borne utilisée pour la recharge. |
| id_vehicule | INTEGER | FK, NOT NULL | Identifiant du véhicule ayant effectué la recharge. |
| debut_session | TIMESTAMP | NOT NULL | Date et heure de début de la session. |
| fin_session | TIMESTAMP | NULL | Date et heure de fin de la session. |
| energie_kwh | NUMERIC(10,2) | NULL | Quantité d'énergie délivrée pendant la session, exprimée en kWh. |
| cout_eur | NUMERIC(10,2) | NULL | Coût valorisé de la session, exprimé en euros. |
| statut | VARCHAR(20) | NOT NULL, CHECK | État final de la session de recharge. |

**Contraintes métier :**
- Chaque session concerne une seule borne et un seul véhicule.
- Une borne peut être associée à plusieurs sessions au fil du temps.
- Un véhicule peut effectuer plusieurs sessions de recharge.
- Le statut doit être égal à `terminee`, `interrompue` ou `annulee`.
- Pour une session annulée, les champs `fin_session`, `energie_kwh` et `cout_eur` doivent être NULL.
- Pour une session terminée ou interrompue, la date de fin doit être renseignée et supérieure ou égale à la date de début.
- Pour une session terminée ou interrompue, l'énergie et le coût doivent être renseignés et supérieurs ou égaux à zéro.

**Clés étrangères :**
- `id_borne` référence `bornes(id_borne)`.
- `id_vehicule` référence `vehicules(id_vehicule)`.

### 2.2.6. Table PAIEMENTS

**Description :** Cette table conserve les informations relatives aux transactions financières associées aux sessions de recharge. Elle permet de suivre les paiements et de distinguer les transactions acceptées, refusées et en attente.

| id_paiement | INTEGER | PK, NOT NULL | Identifiant unique du paiement. |
| id_session | INTEGER | FK, NOT NULL, UNIQUE | Identifiant de la session de recharge associée au paiement. |
| date_paiement | TIMESTAMP | NOT NULL | Date et heure de réalisation du paiement. |
| montant_eur | NUMERIC(10,2) | NOT NULL, CHECK (>= 0) | Montant de la transaction exprimé en euros. |
| mode_paiement | VARCHAR(20) | NOT NULL, CHECK | Mode de règlement utilisé. |
| statut | VARCHAR(20) | NOT NULL, CHECK | Résultat de la transaction financière. |

**Contraintes métier :**
- Chaque paiement est associé à une seule session de recharge.
- Une session peut avoir au maximum un paiement.
- L'identifiant de session doit être unique dans cette table.
- Le montant doit être supérieur ou égal à zéro.
- Le mode de paiement doit être égal à `abonnement`, `carte` ou `application`.
- Le statut doit être égal à `accepte`, `refuse` ou `en_attente`.
- Seuls les paiements dont le statut est `accepte` sont considérés comme des encaissements réels et entrent dans le calcul du chiffre d'affaires.
- Les sessions annulées ou interrompues ne possèdent pas de paiement associé selon les règles métier du projet.

**Clé étrangère :** `id_session` référence `sessions_recharge(id_session)`.

**Remarque :** La contrainte UNIQUE sur `id_session` garantit qu'une même session ne peut pas générer plusieurs enregistrements de paiement.

### 2.2.7. Table INCIDENTS

**Description :** Cette table permet de recenser les incidents techniques signalés sur les bornes de recharge. Chaque incident est obligatoirement associé à une seule borne.

| id_incident | INTEGER | PK, NOT NULL | Identifiant unique de l'incident. |
| id_borne | INTEGER | FK, NOT NULL | Identifiant de la borne concernée par l'incident. |
| date_signalement | TIMESTAMP | NOT NULL | Date et heure du signalement de l'incident. |
| date_resolution | TIMESTAMP | NULL | Date et heure de résolution de l'incident. |
| categorie | VARCHAR(30) | NOT NULL, CHECK | Catégorie de l'incident technique. |
| gravite | VARCHAR(20) | NOT NULL, CHECK | Niveau de gravité de l'incident. |
| statut | VARCHAR(20) | NOT NULL, CHECK | État de traitement de l'incident. |
| description | TEXT | NOT NULL | Description détaillée du problème rencontré. |

**Contraintes métier :**
- Chaque incident concerne une seule borne.
- Une borne peut faire l'objet de zéro à plusieurs signalements.
- La catégorie doit être égale à `defaut_reseau`, `erreur_paiement`, `surchauffe` ou `panne_connecteur`.
- La gravité doit être égale à `faible`, `moyenne` ou `haute`.
- Le statut doit être égal à `ouvert` ou `resolu`.
- La date de résolution doit rester NULL tant que l'incident est ouvert.

**Clé étrangère :** `id_borne` référence `bornes(id_borne)`.

### 2.2.8. Table TECHNICIENS

**Description :** Cette table contient les informations relatives aux techniciens chargés de la maintenance et du traitement des incidents techniques du réseau URBANWATT.

| id_technicien | INTEGER | PK, NOT NULL | Identifiant unique du technicien. |
| prenom | VARCHAR(80) | NOT NULL | Prénom du technicien. |
| nom | VARCHAR(80) | NOT NULL | Nom de famille du technicien. |
| email | VARCHAR(150) | NOT NULL, UNIQUE | Adresse électronique unique du technicien. |

**Contraintes métier :**
- Chaque technicien possède un identifiant unique.
- L'adresse email de chaque technicien doit être unique.
- Un technicien peut réaliser zéro, une ou plusieurs interventions.

### 2.2.9. Table INTERVENTIONS

**Description :** Cette table conserve l'historique des interventions techniques réalisées à la suite des incidents signalés. Chaque intervention est associée à un incident et réalisée par un technicien.

| id_intervention | INTEGER | PK, NOT NULL | Identifiant unique de l'intervention technique. |
| id_incident | INTEGER | FK, NOT NULL | Identifiant de l'incident concerné par l'intervention. |
| id_technicien | INTEGER | FK, NOT NULL | Identifiant du technicien ayant réalisé l'intervention. |
| date_debut | TIMESTAMP | NOT NULL | Date et heure de début de l'intervention. |
| date_fin | TIMESTAMP | NULL | Date et heure de fin de l'intervention. |
| statut | VARCHAR(20) | NOT NULL, CHECK | État d'avancement de l'intervention. |
| compte_rendu | TEXT | NOT NULL | Compte rendu détaillé des opérations effectuées. |

**Contraintes métier :**
- Chaque intervention concerne un seul incident.
- Chaque intervention est réalisée par un seul technicien.
- Un incident peut déclencher zéro à plusieurs interventions.
- Un technicien peut réaliser zéro à plusieurs interventions.
- Le statut doit être égal à `en_cours` ou `terminee`.
- La date de fin doit être NULL lorsque l'intervention est en cours.

**Clés étrangères :**
- `id_incident` référence `incidents(id_incident)`.
- `id_technicien` référence `techniciens(id_technicien)`.

---

## 2.3. Synthèse des contraintes d'intégrité

Les contraintes d'intégrité permettent de garantir la cohérence, la fiabilité et la qualité des données enregistrées dans la base de données URBANWATT.

### 2.3.1. Contraintes d'unicité

Les attributs suivants doivent obligatoirement posséder des valeurs uniques :

| stations | id_station | Identifiant unique de chaque station. |
| stations | code_station | Code métier unique de chaque station. |
| bornes | id_borne | Identifiant unique de chaque borne. |
| bornes | code_borne | Code métier unique de chaque borne. |
| clients | id_client | Identifiant unique de chaque client. |
| clients | email | Une adresse email par client. |
| vehicules | id_vehicule | Identifiant unique de chaque véhicule. |
| vehicules | immatriculation | Une immatriculation par véhicule. |
| sessions_recharge | id_session | Identifiant unique de chaque session. |
| paiements | id_paiement | Identifiant unique de chaque paiement. |
| paiements | id_session | Un seul paiement maximum par session. |
| incidents | id_incident | Identifiant unique de chaque incident. |
| techniciens | id_technicien | Identifiant unique de chaque technicien. |
| techniciens | email | Une adresse email par technicien. |
| interventions | id_intervention | Identifiant unique de chaque intervention. |

### 2.3.2. Contraintes de domaine

Les valeurs des attributs doivent respecter les domaines autorisés définis dans les règles de gestion.

| bornes | puissance_kw | Strictement supérieur à 0 |
| bornes | connecteur | Type2, CCS |
| bornes | etat | disponible, maintenance, hors_service |
| vehicules | capacite_batterie_kwh | Strictement supérieur à 0 |
| sessions_recharge | statut | terminee, interrompue, annulee |
| sessions_recharge | energie_kwh | Supérieur ou égal à 0 lorsqu'il est renseigné |
| sessions_recharge | cout_eur | Supérieur ou égal à 0 lorsqu'il est renseigné |
| paiements | montant_eur | Supérieur ou égal à 0 |
| paiements | mode_paiement | abonnement, carte, application |
| paiements | statut | accepte, refuse, en_attente |
| incidents | categorie | defaut_reseau, erreur_paiement, surchauffe, panne_connecteur |
| incidents | gravite | faible, moyenne, haute |
| incidents | statut | ouvert, resolu |
| interventions | statut | en_cours, terminee |

### 2.3.3. Contraintes de cohérence temporelle et conditionnelle

Certaines règles métier nécessitent des vérifications supplémentaires :

- Une session terminée ou interrompue doit obligatoirement posséder une date de fin supérieure ou égale à sa date de début.
- Une session annulée ne doit posséder ni date de fin, ni énergie délivrée, ni coût.
- Un incident ouvert ne doit pas posséder de date de résolution.
- Une intervention en cours ne doit pas posséder de date de fin.
- Une session ne peut pas être associée à plusieurs paiements.
- Le montant d'un paiement doit toujours être positif ou nul.

Ces conditions doivent être contrôlées au niveau de la base de données à l'aide de contraintes SQL `CHECK` lorsque cela est possible, et de mécanismes complémentaires lorsque plusieurs tables sont concernées.

---

## 2.4. Conclusion

Le Modèle Logique de Données et le dictionnaire des données permettent de définir précisément la structure relationnelle de la base de données URBANWATT.

Les 9 tables identifiées reprennent les entités du MCD et intègrent les clés primaires, les clés étrangères ainsi que les contraintes nécessaires au respect des règles de gestion métier.

Le dictionnaire des données apporte une description complète des attributs, de leurs types SQL, de leurs contraintes et de leur signification fonctionnelle.

Cette étape constitue la base de la future implémentation physique de la base de données. Elle garantit une structure cohérente, une bonne intégrité référentielle et une meilleure maîtrise des données exploitées par le système URBANWATT.