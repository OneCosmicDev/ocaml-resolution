# ocaml-resolution

Résolution de problèmes de logique propositionnelle avec conversion en forme clausale et procédure de décision.

**OCaml · Dune · Menhir · js_of_ocaml**

Copie portfolio d’un projet scolaire de Juan José Castilla Manrique ([OneCosmicDev](https://github.com/OneCosmicDev)). Les contributions de l’équipe et le matériel fourni par le cours sont crédités ci-dessous.

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


Les références de PR et de commits pointent vers les dépôts pédagogiques d’origine, dont l’accès peut être restreint. La présente copie possède son propre historique de publication.

## Démarrer le projet

Prérequis : OCaml 4.14 ou supérieur, Dune 3.17 ou supérieur, Menhir, js_of_ocaml et js_of_ocaml-ppx.

```sh
opam install dune menhir js_of_ocaml js_of_ocaml-ppx
dune build
dune runtest
```

Le cœur de ma contribution se trouve dans `lib/resolution.ml`. Le parseur et les interfaces fournis permettent d’expérimenter avec les propositions ; les jeux d’exemples sont conservés dans `exemples/`.

## État de cette publication

Cette version présente le travail scolaire et ses limites. Elle ne correspond pas à un service hébergé ni à un engagement de maintenance. Voir [PROVENANCE.md](PROVENANCE.md) pour la source, les adaptations de publication et les références vers le code.

## Vérifications du 6 octobre 2026

Sources inspectées, mais compilation et tests non exécutés : OCaml et Dune ne sont pas installés dans l’environnement de préparation.
