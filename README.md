# slitherlinkR

## 📌 Projet
Projet de programmation R – Université de Montpellier

Ce projet consiste à développer un package R ainsi qu’une application Shiny interactive pour le jeu Slitherlink.

---

## 👥 Groupe 5

- Hadjer Benaissa
- Myriam El-Idrissi

---

## 🎯 Objectif

L’objectif est de :

- créer un package R structuré
- implémenter la logique du jeu Slitherlink
- développer une application Shiny interactive
- permettre à l’utilisateur de jouer en choisissant un niveau de difficulté

---

## 🧩 Règles du jeu Slitherlink

- certaines cases contiennent des nombres (0 à 3)
- chaque nombre indique combien de côtés doivent être tracés
- le joueur doit former une seule boucle fermée
- la boucle :
  - ne doit pas se croiser
  - ne doit pas se ramifier

---

## 🎮 Fonctionnement de l’application

L’utilisateur peut :

- choisir un niveau de difficulté (facile, moyen, difficile)
- lancer une nouvelle partie
- tracer ou effacer des arêtes
- vérifier si la solution est correcte

---

## ⚙️ Structure du projet

slitherlinkR/
├── R/
├── man/
├── inst/shiny/
├── DESCRIPTION
├── NAMESPACE
└── README.md

---

## 🚀 Lancer le projet

Dans R :

devtools::load_all()

Puis :

shiny::runApp("inst/shiny")

---

## 🔀 Organisation Git

- main → version stable
- dev → développement

---

## 📚 Technologies utilisées

- R
- Shiny
- ggplot2
- Git / GitHub

---

## ✅ État du projet

Projet en cours de développement.