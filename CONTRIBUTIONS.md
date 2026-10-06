# Résolution logique en OCaml — contribution et crédits

Ce travail du cours IFT-3000 à l'Université Laval, à l'hiver 2026, implémente des fonctions de résolution en logique propositionnelle. Elles permettent d'examiner si un ensemble d'hypothèses implique une conclusion.

## Ma contribution — Juan José Castilla Manrique

J'ai implémenté les fonctions demandées dans `lib/resolution.ml` :

- les fonctions utilitaires `produit_cartesien` et `paires` ;
- la transformation d'un énoncé en proposition avec `enonce_vers_proposition` ;
- la conversion en forme clausale avec `mise_en_forme_clausale` ;
- la production des résolvantes de deux clauses avec `resolutions` ;
- la procédure de décision par résolution avec `decision`.

Les commits [f558d77](https://github.com/OneCosmicDev/tp1-ift3000/commit/f558d77), [1ed0aa9](https://github.com/OneCosmicDev/tp1-ift3000/commit/1ed0aa9) et [90533ff](https://github.com/OneCosmicDev/tp1-ift3000/commit/90533ff) documentent cette progression. Le premier commit importe aussi des fichiers fournis : son auteur Git ne doit pas être interprété comme l'auteur de tout leur contenu.

## Crédits et code fourni

Le squelette du travail, les types, le parseur, les interfaces CLI et web, les exemples, les tests fournis et les fonctions identifiées comme fournies dans `resolution.ml` proviennent du matériel pédagogique du cours IFT-3000. Ma contribution porte sur les fonctions à compléter, pas sur l'ensemble de cet environnement.

Les anciens noms JuanAstroDev et The_OnlyJuanDev présents dans l'historique correspondent à [OneCosmicDev](https://github.com/OneCosmicDev).
