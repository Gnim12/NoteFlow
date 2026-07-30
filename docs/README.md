# 📒 NoteFlow

> Application moderne de prise de notes développée avec Flutter.

---

## Présentation

NoteFlow est une application mobile permettant de créer, organiser et gérer des notes de manière simple et intuitive.

Elle offre une interface moderne inspirée des applications professionnelles tout en fonctionnant entièrement hors ligne grâce à SQLite.

Le projet a été développé dans le cadre de la formation **DCLIC** afin de mettre en pratique les compétences acquises en développement mobile avec Flutter.

---

## Fonctionnalités

- Authentification utilisateur
- Création d'un compte
- Connexion
- Gestion du profil utilisateur
- Modification des informations personnelles
- Changement de photo de profil
- Ajout de notes
- Modification de notes
- Suppression de notes
- Suppression de toutes les notes
- Notes favorites
- Notes épinglées
- Recherche en temps réel
- Tri des notes
- Export PDF
- Mode sombre / clair
- Tableau de bord avec statistiques
- Base de données SQLite
- Fonctionnement hors connexion

## Données et sécurité

- Chaque note est associée à son compte utilisateur et les opérations de lecture,
  modification, suppression et export sont filtrées par propriétaire.
- La session active est conservée localement et peut être supprimée via
  **Se déconnecter**.
- Les nouveaux mots de passe sont dérivés avec PBKDF2-SHA256 et un sel aléatoire.
  Les anciens comptes sont migrés lors de leur prochaine connexion.
- Le code de réinitialisation est une démonstration locale : une mise en production
  nécessite un service d’envoi sécurisé (email ou SMS).

---

## Captures d'écran

*(Les captures seront ajoutées dans le dossier `docs/captures/`.)*

| Écran | Capture |
|--------|---------|
| Splash Screen | splash.png |
| Connexion | login.png |
| Inscription | register.png |
| Accueil | home.png |
| Nouvelle note | add_note.png |
| Modifier une note | edit_note.png |
| Profil | profile.png |
| Paramètres | settings.png |

---

## Technologies utilisées

- Flutter
- Dart
- SQLite
- Sqflite
- Provider
- SharedPreferences
- Google Fonts
- PDF
- Image Picker

---

## Architecture

Le projet est organisé selon une architecture modulaire :
lib/
│
├── database/
├── models/
├── providers/
├── screens/
├── services/
├── utils/
├── widgets/

---

## Auteur

**Brice BIGNAN**

Projet réalisé dans le cadre de la formation **DCLIC**.

---

## Licence

Projet académique développé à des fins pédagogiques.
