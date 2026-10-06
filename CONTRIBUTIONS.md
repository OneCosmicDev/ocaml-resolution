# Mes contributions — Résolution logique en OCaml

J’ai implémenté les fonctions demandées dans [lib/resolution.ml](lib/resolution.ml).

- J’ai écrit `produit_cartesien` et `paires`, les fonctions utilitaires utilisées pour combiner les clauses et sélectionner leurs paires.
- J’ai construit la proposition à résoudre à partir d’un énoncé avec `enonce_vers_proposition`.
- J’ai implémenté les transformations logiques de `mise_en_forme_clausale`.
- J’ai écrit `resolutions` pour produire les résolvantes de deux clauses.
- J’ai assemblé ces étapes dans la procédure de décision `decision`.

## Repères dans le code

- [lib/resolution.ml](lib/resolution.ml)
- [test/test_resolution.ml](test/test_resolution.ml)

## Références de mon travail

Je conserve ci-dessous les références de mes contributions. Elles renvoient aux dépôts de cours ; leur consultation peut demander un accès. Les liens vers les fichiers ci-dessus sont accessibles dans ce dépôt public.

- [f558d77](https://github.com/OneCosmicDev/tp1-ift3000/commit/f558d77)
- [1ed0aa9](https://github.com/OneCosmicDev/tp1-ift3000/commit/1ed0aa9)
- [90533ff](https://github.com/OneCosmicDev/tp1-ift3000/commit/90533ff)

## Code fourni par le cours

J’ai travaillé à partir du matériel pédagogique du cours IFT-3000. Le squelette, les types, le parseur, les interfaces CLI et web, les exemples, les tests et les fonctions indiquées comme fournies appartiennent à cette base. Ma contribution correspond aux fonctions à compléter dans le module de résolution.
