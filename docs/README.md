# 📒 NoteFlow V2

> Application de prise de notes connectée, développée avec Flutter, Firebase et SQLite.

---

## Présentation

NoteFlow V2 est l'évolution d'une application mobile de prise de notes. La V1 était
purement locale ; la V2 transforme NoteFlow en une application connectée et
synchronisée grâce à Firebase, tout en conservant un fonctionnement hors ligne
complet via SQLite.

Le projet a été développé dans le cadre de la formation **DCLIC** (niveau
approfondi), en respectant une architecture **MVC** (Model – View – Controller).

---

## Fonctionnalités

### Comptes et profil
- Inscription / connexion par email et mot de passe (Firebase Authentication)
- Connexion avec Google (Google Sign-In)
- Réinitialisation du mot de passe par email
- Modification du profil (nom, email, mot de passe, photo)

### Notes
- Créer, modifier, supprimer, épingler, mettre en favori
- Corbeille : restaurer ou supprimer définitivement, vider la corbeille
- Historique des modifications avec restauration d'une version précédente
- Catégories personnalisées et tags multiples
- Recherche (titre, contenu, tags), tri (création, modification, titre, favoris, couleur)
- Filtrage par catégorie, favoris, épinglées, date du jour
- Export PDF de toutes les notes
- Mode sombre / clair

### Pièces jointes et localisation
- Images depuis la galerie ou l'appareil photo, fichiers quelconques
- Stockage sur Firebase Storage, métadonnées sur Firestore
- Localisation associée à une note : position actuelle, recherche de lieu,
  sélection sur une carte (OpenStreetMap via `flutter_map`), ouverture dans
  une application de navigation

### Rappels
- Rappels ponctuels ou récurrents (quotidien, hebdomadaire, mensuel, personnalisé)
- Notifications locales programmées, ouverture directe de la note au tap
- Écran global listant tous les rappels programmés

### Partage
- Partage d'une note avec un autre utilisateur (par email)
- Permission lecture seule ou lecture/écriture, révocable à tout moment
- Écran "Notes partagées avec moi"

### Synchronisation et hors ligne
- Toutes les opérations sur les notes fonctionnent hors ligne (SQLite)
- File de synchronisation qui rejoue automatiquement les opérations vers
  Firestore dès que la connexion revient
- Indicateur visuel de l'état de synchronisation sur l'accueil

---

## Sécurité et confidentialité

- Chaque utilisateur n'a accès qu'à ses propres données (règles de sécurité
  Firestore et Storage basées sur `request.auth.uid`), sauf partage explicite
- L'authentification et le stockage des mots de passe sont entièrement gérés
  par Firebase Authentication (aucun mot de passe en clair ni dérivé
  maison n'est stocké par l'application)
- Un utilisateur ne peut lire/modifier une note d'un autre utilisateur que si
  celui-ci l'a explicitement partagée

---

## Technologies utilisées

| Domaine | Technologie |
|---|---|
| Framework | Flutter / Dart |
| Authentification | Firebase Authentication, Google Sign-In |
| Base de données cloud | Cloud Firestore |
| Stockage de fichiers | Firebase Storage |
| Base de données locale | SQLite (sqflite) |
| Notifications | flutter_local_notifications |
| Cartographie | flutter_map (OpenStreetMap), geolocator, geocoding |
| État global | Provider |
| Autres | intl, image_picker, file_picker, pdf, printing, url_launcher |

---

## Architecture (MVC)

```
lib/
├── models/          # Note, User, Category, Attachment, Reminder, Location, SharedNote...
├── views/            # Écrans, organisés par domaine (auth, home, notes, categories,
│                     #   reminders, shared, location, profile, settings, splash)
├── controllers/      # Logique de présentation : AuthController, NoteController,
│                     #   CategoryController, AttachmentController, ReminderController,
│                     #   LocationController, SharingController...
├── services/         # Accès techniques : SqliteService, FirestoreService, StorageService,
│                     #   FirebaseAuthService, NotificationService, LocationService,
│                     #   SyncService, SharingService...
├── widgets/           # Composants réutilisables
├── providers/         # Gestion d'état (thème)
├── utils/             # Couleurs, styles, thème
└── core/errors/       # Modèle d'erreurs applicatif
```

Voir aussi les règles de sécurité : [`firestore.rules`](../firestore.rules) et
[`storage.rules`](../storage.rules).

---

## Auteur

**Brice BIGNAN**

Projet réalisé dans le cadre de la formation **DCLIC**.

---

## Licence

Projet académique développé à des fins pédagogiques.
