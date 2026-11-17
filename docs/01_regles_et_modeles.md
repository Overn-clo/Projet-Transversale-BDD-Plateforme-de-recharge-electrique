# Conception et Modélisation des Données — Projet URBANWATT
**Auteur :** Mathieu (Pôle Architecture Base de Données & Modélisation)

---

## 1. Besoin Fonctionnel et Règles de Gestion Métier (RG)

L'objectif du système d'information URBANWATT est de remplacer les suivis manuels par une base de données relationnelle centralisée garantissant l'intégrité référentielle et la traçabilité de l'exploitation du réseau de recharge électrique.

### RG1 — Gestion du patrimoine : Stations et Bornes
* **RG1.1 :** Chaque station de recharge est identifiée de manière unique par un identifiant technique (`id_station`) et un code métier (`code_station`, ex: `ST-LIL`), et possède un nom, une ville, une adresse postale et une date d'ouverture.
* **RG1.2 :** Une station regroupe plusieurs bornes de recharge (**cardinalité 1,N** : au moins 1 borne par station dans le réseau opérationnel, soit 5 bornes par station dans le jeu de données).
* **RG1.3 :** Chaque borne possède un code métier unique (`code_borne`, ex: `BR-LIL-01`), une puissance électrique nominale exprimée en kW (`puissance_kw > 0`), un type de connecteur (`Type2` ou `CCS`) et un état opérationnel (`disponible`, `maintenance` ou `hors_service`).
* **RG1.4 :** Une borne est rattachée à **une et une seule station** (**cardinalité 1,1**).

### RG2 — Gestion du parc usagers : Clients et Véhicules
* **RG2.1 :** Chaque client est identifié par un numéro unique (`id_client`) et une adresse courriel unique (`email`), accompagnés de son prénom, son nom, sa ville et sa date d'inscription.
* **RG2.2 :** Un client peut enregistrer zéro, un ou plusieurs véhicules électriques (**cardinalité 0,N**).
* **RG2.3 :** Chaque véhicule est identifié par un identifiant unique (`id_vehicule`) et un numéro d'immatriculation unique (`immatriculation`, ex: `ESSAI-0001`), et possède une marque, un modèle et une capacité de batterie en kWh (`capacite_batterie_kwh > 0`).
* **RG2.4 :** Chaque véhicule appartient à **un et un seul client** (**cardinalité 1,1**).

### RG3 — Exploitation : Sessions de recharge et Statuts
* **RG3.1 :** Une session de recharge (`id_session`) concerne **un seul véhicule** (**cardinalité 1,1**) et **une seule borne** (**cardinalité 1,1**) à une date et heure de début précises (`debut_session`). Réciproquement, un véhicule et une borne peuvent être impliqués dans zéro à plusieurs sessions au fil du temps (**cardinalité 0,N**).
* **RG3.2 :** Toute session possède obligatoirement l'un des trois statuts suivants : `terminee`, `interrompue` ou `annulee`.
* **RG3.3 :** Une session au statut `annulee` ne comporte ni horodatage de fin (`fin_session IS NULL`), ni énergie délivrée (`energie_kwh IS NULL`), ni coût facturé (`cout_eur IS NULL`). À l'inverse, une session `terminee` ou `interrompue` doit obligatoirement renseigner une date de fin postérieure ou égale au début (`fin_session >= debut_session`), une énergie (`>= 0`) et un coût (`>= 0`).

### RG4 — Facturation : Paiements et Chiffre d'Affaires
* **RG4.1 :** Un paiement (`id_paiement`) est associé à **une et une seule session de recharge** (**cardinalité 1,1**), et une session de recharge donne lieu à au plus un enregistrement de paiement (**cardinalité 0,1**, les sessions annulées ou interrompues n'ayant pas de paiement associé).
* **RG4.2 :** Chaque paiement enregistre une date (`date_paiement`), un montant en euros (`montant_eur >= 0`), un mode de règlement (`abonnement`, `carte`, `application`) et un statut (`accepte`, `refuse`, `en_attente`).
* **RG4.3 :** **Règle comptable stricte :** Seuls les paiements dont le statut est `accepte` constituent un encaissement réel et entrent dans le calcul du chiffre d'affaires (les paiements `refuse` et `en_attente` en sont exclus).

### RG5 — Maintenance : Incidents et Interventions techniques
* **RG5.1 :** Une borne peut faire l'objet de zéro à plusieurs signalements d'incidents (**cardinalité 0,N**). Chaque incident (`id_incident`) concerne **une seule borne** (**cardinalité 1,1**).
* **RG5.2 :** Un incident est caractérisé par une date de signalement, une catégorie (`defaut_reseau`, `erreur_paiement`, `surchauffe`, `panne_connecteur`), un niveau de gravité (`faible`, `moyenne`, `haute`), un statut (`ouvert` ou `resolu`), une description et une date de résolution (`NULL` tant que le statut est `ouvert`).
* **RG5.3 :** Un incident peut déclencher **0 à N interventions** techniques. Chaque intervention (`id_intervention`) porte sur **un seul incident** (**cardinalité 1,1**) et est réalisée par **un seul technicien** (**cardinalité 1,1**). Un technicien (`id_technicien`, email unique) peut réaliser **0 à N interventions** (**cardinalité 0,N**), caractérisées par une date de début, une date de fin (`NULL` si le statut est `en_cours`), un statut (`en_cours`, `terminee`) et un compte rendu.

---

## 2. Modèle Conceptuel de Données (MCD)

### 2.1 Diagramme Entité-Association (Format Mermaid)

### 2.1 Diagramme Entité-Association (Format Mermaid)

mermaid
erDiagram
    STATIONS {
        int id_station PK
        varchar code_station UK
        varchar nom_station
        varchar ville
        varchar adresse
        date date_ouverture
    }
    BORNES {
        int id_borne PK
        varchar code_borne UK
        int puissance_kw
        varchar connecteur
        varchar etat
    }
    CLIENTS {
        int id_client PK
        varchar prenom
        varchar nom
        varchar email UK
        varchar ville
        date date_inscription
    }
    VEHICULES {
        int id_vehicule PK
        varchar immatriculation UK
        varchar marque
        varchar modele
        int capacite_batterie_kwh
    }
    SESSIONS_RECHARGE {
        int id_session PK
        timestamp debut_session
        timestamp fin_session
        numeric energie_kwh
        numeric cout_eur
        varchar statut
    }
    PAIEMENTS {
        int id_paiement PK
        timestamp date_paiement
        numeric montant_eur
        varchar mode_paiement
        varchar statut
    }
    INCIDENTS {
        int id_incident PK
        timestamp date_signalement
        timestamp date_resolution
        varchar categorie
        varchar gravite
        varchar statut
        text description
    }
    TECHNICIENS {
        int id_technicien PK
        varchar prenom
        varchar nom
        varchar email UK
    }
    INTERVENTIONS {
        int id_intervention PK
        timestamp date_debut
        timestamp date_fin
        varchar statut
        text compte_rendu
    }

    STATIONS ||--|{ BORNES : "HÉBERGE (1,N - 1,1)"
    CLIENTS ||--o{ VEHICULES : "POSSÈDE (0,N - 1,1)"
    BORNES ||--o{ SESSIONS_RECHARGE : "ALIMENTE (0,N - 1,1)"
    VEHICULES ||--o{ SESSIONS_RECHARGE : "EFFECTUE (0,N - 1,1)"
    SESSIONS_RECHARGE ||--o| PAIEMENTS : "GÉNÈRE / PAIE (0,1 - 1,1)"
    BORNES ||--o{ INCIDENTS : "SUBIT (0,N - 1,1)"
    INCIDENTS ||--o{ INTERVENTIONS : "NÉCESSITE (0,N - 1,1)"
    TECHNICIENS ||--o{ INTERVENTIONS : "INTERVIENT (0,N - 1,1)"
        
### 2.2 Récapitulatif des Associations et Cardinalités (Notation Merise)

| Association | Entité A | Cardinalité A | Entité B | Cardinalité B | Règle de dérivation MLD |
| :--- | :--- | :---: | :--- | :---: | :--- |
| **HÉBERGE** | STATIONS | `1,N` | BORNES | `1,1` | Migration de `#id_station` (`NOT NULL`) dans `bornes` |
| **POSSÈDE** | CLIENTS | `0,N` | VEHICULES | `1,1` | Migration de `#id_client` (`NOT NULL`) dans `vehicules` |
| **ALIMENTE** | BORNES | `0,N` | SESSIONS_RECHARGE | `1,1` | Migration de `#id_borne` (`NOT NULL`) dans `sessions_recharge` |
| **EFFECTUE** | VEHICULES | `0,N` | SESSIONS_RECHARGE | `1,1` | Migration de `#id_vehicule` (`NOT NULL`) dans `sessions_recharge` |
| **GÉNÈRE / PAIE**| SESSIONS_RECHARGE | `0,1` | PAIEMENTS | `1,1` | Migration de `#id_session` (`NOT NULL UNIQUE`) dans `paiements` |
| **SUBIT** | BORNES | `0,N` | INCIDENTS | `1,1` | Migration de `#id_borne` (`NOT NULL`) dans `incidents` |
| **NÉCESSITE** | INCIDENTS | `0,N` | INTERVENTIONS | `1,1` | Migration de `#id_incident` (`NOT NULL`) dans `interventions` |
| **INTERVIENT** | TECHNICIENS | `0,N` | INTERVENTIONS | `1,1` | Migration de `#id_technicien` (`NOT NULL`) dans `interventions` |

---

## 3. Justification des Relations `1,N`, Clés Étrangères et Contraintes d'Intégrité

1. **Absence d'associations `N,M` (Plusieurs-à-Plusieurs) non décomposées :**
   * Un véhicule peut utiliser plusieurs bornes au cours de sa vie, et une borne recharge plusieurs véhicules. Toutefois, un même véhicule pouvant recharger plusieurs fois sur la **même** borne à des dates différentes, la relation entre `VEHICULES` et `BORNES` est matérialisée par l'entité événementielle `SESSIONS_RECHARGE` dotée de son propre identifiant (`id_session`) et reliée par deux associations `1,N` (`BORNES -> SESSIONS_RECHARGE` et `VEHICULES -> SESSIONS_RECHARGE`).
   * De même, un technicien peut intervenir plusieurs fois sur un même incident ou sur des incidents différents : l'entité `INTERVENTIONS` (`id_intervention`) matérialise chaque déplacement technique avec ses propres dates et son compte rendu.
2. **Justification de la relation `0,1 - 1,1` entre `SESSIONS_RECHARGE` et `PAIEMENTS` :**
   * Dans le modèle URBANWATT, seules les sessions terminées possèdent un enregistrement dans `paiements` (1 paiement par session terminée). En plaçant la clé étrangère `id_session` dans la table `paiements` avec une contrainte `UNIQUE NOT NULL`, on évite d'avoir une valeur `NULL` dans la table `sessions_recharge` (pour les sessions annulées ou interrompues) tout en garantissant mathématiquement qu'une session ne peut jamais être facturée deux fois.
3. **Politique d'intégrité référentielle (`ON DELETE RESTRICT`) :**
   * Toutes les clés étrangères utilisent `ON DELETE RESTRICT` afin d'interdire la suppression accidentelle d'une station possédant des bornes, d'un client possédant un historique de véhicules, ou d'une borne rattachée à des sessions et à des incidents.

---

## 4. Vérification et Justification de la Normalisation (1NF, 2NF, 3NF)

Le modèle relationnel URBANWATT respecte strictement la **Troisième Forme Normale (3NF)** de Codd, garantissant l'absence de redondance de données et d'anomalies de mise à jour, d'insertion ou de suppression :

### 4.1 Première Forme Normale (1NF — Atomicité des attributs)
* **Critère :** Chaque table possède une clé primaire explicite et tous les attributs contiennent des valeurs atomiques (indivisibles), sans liste de valeurs ni groupes répétitifs.
* **Vérification :** Aucune colonne ne concatène plusieurs informations (par exemple, `prenom` et `nom` sont séparés dans `clients` et `techniciens` ; `marque` et `modele` sont séparés dans `vehicules` ; `ville` et `adresse` sont séparées dans `stations`). Les relations multivaluées (plusieurs bornes par station, plusieurs véhicules par client) sont isolées dans des tables dédiées.

### 4.2 Deuxième Forme Normale (2NF — Dépendance fonctionnelle pleine)
* **Critère :** Le modèle est en 1NF et tout attribut non-clé dépend de la totalité de la clé primaire (pas de dépendance partielle envers une sous-partie d'une clé composite).
* **Vérification :** Les 9 tables du schéma possèdent chacune une **clé primaire simple (mono-attribut)** (`id_station`, `id_borne`, `id_client`, `id_vehicule`, `id_session`, `id_paiement`, `id_incident`, `id_technicien`, `id_intervention`). Par propriété mathématique, toute table en 1NF dotée d'une clé primaire mono-attribut est automatiquement en **2NF**.

### 4.3 Troisième Forme Normale (3NF — Absence de dépendance transitive)
* **Critère :** Le modèle est en 2NF et aucun attribut non-clé ne dépend fonctionnellement d'un autre attribut non-clé (absence de dépendance transitive $PK \rightarrow X \rightarrow Y$).
* **Vérification table par table :**
  * **Séparation `bornes` / `stations` :** La ville ou l'adresse d'une borne dépend de sa station (`id_borne -> id_station -> ville, adresse`). Ces attributs ne sont pas dupliqués dans `bornes` mais stockés uniquement dans `stations`.
  * **Séparation `sessions_recharge` / `vehicules` / `clients` :** Dans une session de recharge, l'identité du client dépend du véhicule (`id_session -> id_vehicule -> id_client -> nom, prenom`). En ne stockant que `id_vehicule` dans `sessions_recharge` et `id_client` dans `vehicules`, toute modification du client s'effectue en un seul point dans la table `clients`.
  * **Cas particulier de `cout_eur` (session) vs `montant_eur` (paiement) :** `cout_eur` dans `sessions_recharge` représente le coût valorisé de la session (y compris pour les sessions `interrompue` non encaissées), tandis que `montant_eur` dans `paiements` trace le montant de la transaction bancaire. Il s'agit donc de deux faits métier distincts et non d'une dépendance transitive redondante.