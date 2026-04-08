# slitherlinkR

##  Projet
Projet de programmation R – Université de Montpellier

Ce projet consiste à développer un package R ainsi qu’une application Shiny interactive pour le jeu Slitherlink.

---

##  Groupe 5

- Hadjer Benaissa
- Myriam El-Idrissi

---

##  Objectif

L’objectif est de :

- créer un package R structuré
- implémenter la logique du jeu Slitherlink
- développer une application Shiny interactive
- permettre à l’utilisateur de jouer en choisissant un niveau de difficulté

---

##  Règles du jeu Slitherlink

- certaines cases contiennent des nombres (0 à 4)
- chaque nombre indique combien de côtés doivent être tracés
- le joueur doit former une seule boucle fermée
- la boucle :
  - ne doit pas se croiser
  - ne doit pas se ramifier

---

##  Fonctionnement de l’application

L’utilisateur peut :

- choisir un niveau de difficulté (facile, moyen, difficile)
- lancer une nouvelle partie
- tracer ou effacer des arêtes
- vérification automatique de la solution

---

## Aperçu de l'application

[mettre un screen de l'appli qd finish]

---

##  Structure du projet

Le projet est organisé de la manière suivante :

- `R/` : contient les fonctions du package  
- `man/` : documentation des fonctions  
- `inst/shiny/` : application Shiny  
- `DESCRIPTION` : informations du package  
- `NAMESPACE` : export des fonctions  
- `README.md` : présentation du projet  
---

##  Lancer le projet

Pour exécuter le projet :

1. Ouvrir RStudio dans le dossier du projet

2. Charger le package :
devtools::load_all()

3. Lancer l’application Shiny :
shiny::runApp("inst/shiny")
---

##  Organisation Git

- main → version stable
- dev → développement

---

##  Technologies utilisées

- R
- Shiny
- ggplot2
- Git / GitHub

---

##  État du projet

Projet en cours de développement.
