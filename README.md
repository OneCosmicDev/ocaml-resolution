# Résolution logique en OCaml

J’ai réalisé ce travail de logique propositionnelle dans le cadre du cours IFT-3000 à l’Université Laval. J’y ai implémenté les fonctions de résolution nécessaires pour déterminer si un ensemble d’hypothèses implique une conclusion.

**Université Laval · IFT-3000 · Hiver 2026**

**Début documenté : 7 février 2026** — [repères chronologiques](PROVENANCE.md#repères-chronologiques)

**Technologies : OCaml · Dune · Menhir · js_of_ocaml**

## Ce que fait le projet

Le programme transforme les hypothèses et la négation de la conclusion en une forme clausale, puis applique la règle de résolution. L’obtention d’une clause vide établit une contradiction et permet de conclure que les hypothèses impliquent la conclusion. Le projet comprend un parseur, une interface en ligne de commande, une interface web et des exemples fournis pour expérimenter avec les propositions.

## Ma contribution

J’ai implémenté les fonctions demandées dans [lib/resolution.ml](lib/resolution.ml).

- J’ai écrit `produit_cartesien` et `paires`, les fonctions utilitaires utilisées pour combiner les clauses et sélectionner leurs paires.
- J’ai construit la proposition à résoudre à partir d’un énoncé avec `enonce_vers_proposition`.
- J’ai implémenté les transformations logiques de `mise_en_forme_clausale`.
- J’ai écrit `resolutions` pour produire les résolvantes de deux clauses.
- J’ai assemblé ces étapes dans la procédure de décision `decision`.

Je détaille les fichiers et les références de mon travail dans [CONTRIBUTIONS.md](CONTRIBUTIONS.md).

## Ce que j’ai appris

J’ai appris à passer de règles de logique formelle à un algorithme exécutable. La mise en forme clausale m’a demandé de manipuler les implications, les équivalences et les négations en conservant le sens des propositions. La résolution m’a permis de relier la démonstration d’une implication à la recherche d’une contradiction.

Ce travail a aussi renforcé ma pratique de la programmation fonctionnelle : types algébriques, filtrage par motifs, récursion et transformations de listes. J’ai appris à décomposer le raisonnement en petites fonctions, puis à vérifier leur composition à partir des exemples et des tests fournis.

## Code fourni par le cours

J’ai travaillé à partir du matériel pédagogique du cours IFT-3000. Le squelette, les types, le parseur, les interfaces CLI et web, les exemples, les tests et les fonctions indiquées comme fournies appartiennent à cette base. Ma contribution correspond aux fonctions à compléter dans le module de résolution.

## Lancer le projet

Prérequis : OCaml 4.14 ou supérieur, Dune 3.17 ou supérieur, Menhir, js_of_ocaml et js_of_ocaml-ppx.

```sh
opam install dune menhir js_of_ocaml js_of_ocaml-ppx
dune build
dune runtest
```

J’ai conservé les jeux d’exemples dans `exemples/` pour faciliter l’exploration des propositions.

## État du projet

Je fournis les commandes de compilation et les tests du cours. La compilation et les tests n’ont pas été revérifiés pour cette version.
