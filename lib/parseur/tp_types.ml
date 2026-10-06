(** {1 Module Types}

    Définition des types utilisés pour représenter les propositions logiques et
    les énoncés de problèmes.

    @author IFT-3000 - Hiver 2026 *)

(** {2 Syntaxe de l'entrée}

    Format général : [H1 ; H2 ; ... ; Hn ; C]

    où les [Hi] sont les hypothèses et [C] la conclusion. On peut fournir aucune
    hypothèse, auquel cas il y a seulement [C] en entrée (pour tester si [C] est
    une tautologie).

    {3 Grammaire des propositions}
    {[
      P ::= A "<=>" P | A
      A ::= B "=>" A | B
      B ::= C "ou" B | C
      C ::= D "et" C | D
      D ::= "non" E | E
      E ::= "(" P ")" | "vrai" | "faux" | I
      I ::= identificateur (lettre suivie de lettres, chiffres ou "_")
    ]}

    {3 Commentaires}

    Les commentaires sont délimités par [(*] et [*)], comme en OCaml (non
    imbriqués). L'analyseur lexical ne distingue pas les majuscules des
    minuscules. *)

(** {2 Types principaux} *)

(** Type des propositions logiques.

    - [Vrai] et [Faux] : constantes booléennes
    - [Non p] : négation
    - [Et (p1, p2)] : conjonction
    - [Ou (p1, p2)] : disjonction
    - [Imp (p1, p2)] : implication (p1 → p2)
    - [Equ (p1, p2)] : équivalence (p1 ↔ p2)
    - [Var id] : variable propositionnelle *)
type proposition =
  | Vrai
  | Faux
  | Non of proposition
  | Et of proposition * proposition
  | Ou of proposition * proposition
  | Imp of proposition * proposition
  | Equ of proposition * proposition
  | Var of string

type enonce_probleme = proposition list * proposition
(** Type des énoncés de problèmes.

    Un énoncé est un couple [(hypothèses, conclusion)] où :
    - [hypothèses] est une liste de propositions H1, H2, ..., Hn
    - [conclusion] est la proposition C à démontrer *)

type clause = proposition list
(** Type des clauses.

    Une clause est une liste de littéraux (variables ou négations de variables).
    Les littéraux sont implicitement reliés par des disjonctions (OU). *)

type forme_clausale = clause list
(** Type des formes clausales.

    Une forme clausale est une liste de clauses. Les clauses sont implicitement
    reliées par des conjonctions (ET). *)
