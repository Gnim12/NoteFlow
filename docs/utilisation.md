# 📖 Guide d'utilisation de NoteFlow

## Introduction

Bienvenue dans **NoteFlow** !

Ce guide présente les principales fonctionnalités de l'application et explique comment les utiliser.

NoteFlow permet de créer, organiser et gérer des notes de manière simple, rapide et intuitive, même sans connexion Internet.

---

# Sommaire

1. Création d'un compte
2. Connexion
3. Tableau de bord
4. Ajouter une note
5. Modifier une note
6. Rechercher une note
7. Ajouter une note aux favoris
8. Épingler une note
9. Supprimer une note
10. Exporter les notes en PDF
11. Modifier son profil
12. Paramètres
13. Déconnexion

---

# 1. Création d'un compte

Au premier lancement de l'application, l'utilisateur peut créer un nouveau compte.

### Étapes

- Ouvrir l'écran de connexion.
- Cliquer sur **Créer un compte**.
- Remplir les informations demandées :
  - Nom complet
  - Adresse e-mail
  - Mot de passe
  - Confirmation du mot de passe
- Cliquer sur **Créer le compte**.

### Résultat

Le compte est enregistré localement dans la base de données SQLite.

📷 **Capture d'écran**

> `docs/captures/register.png`

---

# 2. Connexion

Après avoir créé un compte :

- saisir son adresse e-mail ;
- saisir son mot de passe ;
- cliquer sur **Se connecter**.

En cas de succès, l'utilisateur est redirigé vers la page d'accueil.

📷 **Capture d'écran**

> `docs/captures/login.png`

---

# 3. Tableau de bord

La page d'accueil affiche :

- le profil utilisateur ;
- le nombre total de notes ;
- le nombre de favoris ;
- le nombre de notes créées aujourd'hui ;
- la liste complète des notes.

Le tableau de bord permet également d'accéder rapidement aux différentes catégories de notes.

📷 **Capture d'écran**

> `docs/captures/home.png`

---

# 4. Ajouter une note

Pour créer une nouvelle note :

- appuyer sur le bouton **+** ;
- saisir le titre ;
- saisir la description ;
- choisir une couleur ;
- sélectionner **Favori** si nécessaire ;
- cliquer sur **Enregistrer**.

La note apparaît immédiatement dans la liste.

📷 **Capture d'écran**

> `docs/captures/add_note.png`

---

# 5. Modifier une note

Pour modifier une note existante :

- ouvrir la note ;
- sélectionner **Modifier** ;
- apporter les changements souhaités ;
- enregistrer les modifications.

Les informations sont mises à jour dans la base de données.

📷 **Capture d'écran**

> `docs/captures/edit_note.png`

---

# 6. Rechercher une note

La barre de recherche permet de retrouver rapidement une note.

La recherche s'effectue :

- sur le titre ;
- sur le contenu de la note.

Elle est réalisée en temps réel pendant la saisie.

📷 **Capture d'écran**

> `docs/captures/search.png`

---

# 7. Ajouter une note aux favoris

Une note importante peut être ajoutée aux favoris.

Pour cela :

- ouvrir le menu de la note ;
- sélectionner **Ajouter aux favoris**.

Une étoile apparaît sur la note.

Les favoris peuvent ensuite être affichés depuis le tableau de bord.

📷 **Capture d'écran**

> `docs/captures/favorites.png`

---

# 8. Épingler une note

Les notes importantes peuvent être épinglées.

Les notes épinglées apparaissent toujours en haut de la liste.

Pour épingler une note :

- ouvrir le menu ;
- choisir **Épingler**.

📷 **Capture d'écran**

> `docs/captures/pinned.png`

---

# 9. Supprimer une note

Pour supprimer une note :

- ouvrir le menu ;
- choisir **Supprimer** ;
- confirmer la suppression.

La note est définitivement supprimée de la base de données.

📷 **Capture d'écran**

> `docs/captures/delete_note.png`

---

# 10. Exporter les notes en PDF

Depuis les paramètres :

- ouvrir **Exporter les notes (PDF)** ;
- attendre la génération du document.

Un fichier PDF contenant toutes les notes est créé.

📷 **Capture d'écran**

> `docs/captures/export_pdf.png`

---

# 11. Modifier son profil

Depuis les paramètres :

- ouvrir **Mon profil** ;
- modifier :
  - le nom ;
  - l'adresse e-mail ;
  - le mot de passe ;
  - la photo de profil (si disponible) ;
- enregistrer les modifications.

Les nouvelles informations sont immédiatement prises en compte.

📷 **Capture d'écran**

> `docs/captures/profile.png`

---

# 12. Paramètres

Le menu Paramètres permet de :

- activer ou désactiver le mode sombre ;
- consulter les notes épinglées ;
- exporter les notes en PDF ;
- supprimer toutes les notes ;
- accéder au profil utilisateur ;
- consulter les informations de l'application ;
- se déconnecter.

📷 **Capture d'écran**

> `docs/captures/settings.png`

---

# 13. Déconnexion

Pour quitter sa session :

- ouvrir **Paramètres** ;
- sélectionner **Déconnexion**.

L'utilisateur est redirigé vers l'écran de connexion.

📷 **Capture d'écran**

> `docs/captures/logout.png`

---

# Conseils d'utilisation

Pour une meilleure expérience :

- organiser les notes par couleur ;
- utiliser les favoris pour les notes importantes ;
- épingler les notes fréquemment consultées ;
- effectuer régulièrement un export PDF ;
- protéger son compte avec un mot de passe sécurisé.

---

# Conclusion

Grâce à son interface moderne, son fonctionnement hors ligne et ses nombreuses fonctionnalités, **NoteFlow** permet d'organiser efficacement ses idées, tâches et informations personnelles de manière simple et sécurisée.