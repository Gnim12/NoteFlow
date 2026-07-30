# 📥 Guide d'installation de NoteFlow

## Introduction

Ce document explique les étapes nécessaires pour installer, configurer et exécuter l'application **NoteFlow** sur un environnement de développement Flutter.

---

# Prérequis

Avant de commencer, assurez-vous que les logiciels suivants sont installés sur votre ordinateur.

| Logiciel | Version recommandée |
|----------|----------------------|
| Flutter SDK | 3.x ou supérieur |
| Dart SDK | Inclus avec Flutter |
| Android Studio | Dernière version stable |
| Visual Studio Code | Dernière version |
| Git | Dernière version |
| JDK | Version 17 ou supérieure |

---

# Vérification de Flutter

Après l'installation de Flutter, ouvrez un terminal puis exécutez :

```bash
flutter doctor
```

Toutes les vérifications doivent apparaître avec une coche verte.

Exemple :

```
[✓] Flutter
[✓] Android toolchain
[✓] Android Studio
[✓] VS Code
[✓] Connected device
```

---

# Cloner le projet

Depuis un terminal :

```bash
git clone <https://github.com/Gnim12/NoteFlow>
```

Puis entrer dans le dossier :

```bash
cd noteflow
```

---

# Installer les dépendances

Installer toutes les dépendances Flutter :

```bash
flutter pub get
```

Cette commande télécharge automatiquement toutes les bibliothèques utilisées par le projet.

---

# Vérifier les appareils disponibles

Connecter un téléphone Android ou démarrer un émulateur puis exécuter :

```bash
flutter devices
```

L'appareil connecté doit apparaître dans la liste.

---

# Lancer l'application

Exécuter :

```bash
flutter run
```

Flutter compile automatiquement le projet puis installe l'application sur l'appareil connecté.

---

# Générer une version Release

Pour générer un APK optimisé localement :

```bash
flutter build apk --release
```

L'APK est généré dans :

```
build/app/outputs/flutter-apk/app-release.apk
```

Pour publier sur le Play Store, préfère un Android App Bundle :

```bash
flutter build appbundle --release
```

Le fichier sera généré dans :

```text
build/app/outputs/bundle/release/app-release.aab
```

## Signature de release

Avant de compiler la version Play Store, crée un fichier `android/key.properties` à partir de `android/key.properties.example` et renseigne les champs suivants :

- `storePassword` : mot de passe du keystore
- `keyPassword` : mot de passe de la clé
- `keyAlias` : alias de la clé
- `storeFile` : chemin absolu vers le fichier `.jks`

Exemple Windows :

```properties
storePassword=monMotDePasseStore
keyPassword=monMotDePasseCle
keyAlias=upload
storeFile=C:\Users\brice\keystores\noteflow-upload.jks
```

Si le fichier `android/key.properties` est absent, Gradle utilise encore la signature debug pour ne pas bloquer le développement local. Pour la publication, il faut absolument fournir un vrai keystore.

## Créer le keystore

Tu peux le générer avec la commande Java `keytool` :

```bash
keytool -genkeypair -v -keystore noteflow-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Place ensuite le `.jks` dans un dossier sûr, hors du projet si possible, puis référence son chemin dans `android/key.properties`.

---

# Nettoyer le projet

En cas de problème de compilation :

```bash
flutter clean
```

Puis :

```bash
flutter pub get
```

Enfin :

```bash
flutter run
```

---

# Dépendances principales

Le projet utilise notamment les packages suivants :

- flutter
- sqflite
- provider
- shared_preferences
- google_fonts
- intl
- image_picker
- path_provider
- pdf
- printing
- flutter_launcher_icons
- flutter_native_splash

Les dépendances sont définies dans le fichier **pubspec.yaml**.

---

# Structure du projet

```
lib/
│
├── database/
├── models/
├── providers/
├── screens/
├── services/
├── utils/
└── widgets/

assets/
│
├── backgrounds/
├── icons/
└── images/

docs/
```

---

# Résolution des problèmes courants

## Flutter Doctor signale des erreurs

Exécuter :

```bash
flutter doctor
```

Puis corriger les éléments signalés.

---

## Les dépendances ne sont pas reconnues

Exécuter :

```bash
flutter clean
flutter pub get
```

---

## Le projet ne compile plus

Essayer :

```bash
flutter pub get
flutter clean
flutter run
```

---

## L'application ne détecte pas le téléphone

Vérifier que :

- le mode développeur est activé ;
- le débogage USB est activé ;
- les pilotes USB sont installés.

---

# Installation terminée

Si toutes les étapes précédentes ont été réalisées avec succès, l'application NoteFlow est maintenant prête à être utilisée.