(** {1 Module Parseur}

    Module d'analyse lexicale et syntaxique pour les propositions logiques.
    Permet de convertir des chaînes de caractères ou des fichiers en structures
    de données manipulables par le module Resolution.

    {2 Syntaxe des entrées}

    Format général : [H1 ; H2 ; ... ; Hn ; C]

    où les [Hi] sont les hypothèses et [C] la conclusion.

    Cas particulier pour les tautologies (aucune hypothèse) : [; C]

    Cette syntaxe permet de vérifier directement si une proposition est une
    tautologie, sans avoir à spécifier d'hypothèses.

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
    imbriqués).

    @author IFT-3000 - Hiver 2026 *)

(** {2 Types}

    Les types utilisés par ce module sont définis dans {!Tp_types}. Vous devez
    donc ouvrir ce module pour accéder aux types :
    {[
      open Tp_types
    ]} *)

open Tp_types

(** {2 Exceptions} *)

exception Erreur_syntaxique of string
(** Exception levée lors d'une erreur de syntaxe.

    Le message contient la position (ligne, colonne) de l'erreur. *)

exception Fichier_introuvable of string
(** Exception levée lorsqu'un fichier à analyser n'existe pas.

    Le message contient le nom du fichier introuvable. *)

(** {2 Fonctions d'analyse} *)

val analyser_chaine : string -> enonce_probleme
(** [analyser_chaine s] analyse la chaîne [s], passée en argument, et retourne
    l'énoncé de problème correspondant.

    Combine {!aLex} et l'analyse syntaxique en une seule opération. C'est la
    fonction principale pour analyser une entrée textuelle.

    @raise Erreur_syntaxique si la syntaxe est incorrecte

    {b Exemples}:
    {[
      # analyser_chaine "a => b; non b; non a";;
      - : enonce_probleme =
        ([Imp (Var "a", Var "b"); Non (Var "b")], Non (Var "a"))

      # analyser_chaine "p <=> q; q <=> r; p <=> r";;
      - : enonce_probleme =
        ([Equ (Var "p", Var "q"); Equ (Var "q", Var "r")],
         Equ (Var "p", Var "r"))
    ]} *)

val analyser_fichier : string -> enonce_probleme
(** [analyser_fichier nom_fichier] analyse le contenu du fichier [nom_fichier],
    passé en argument, et retourne l'énoncé de problème correspondant.

    @raise Erreur_syntaxique si la syntaxe est incorrecte (avec nom du fichier)
    @raise Sys_error si le fichier n'existe pas ou n'est pas lisible

    {b Exemple}:
    {[
      # analyser_fichier "test1.txt";;
      - : enonce_probleme =
        ([Imp (Var "a", Var "b"); Non (Var "b")], Non (Var "a"))
    ]} *)

(** {2 Fonctions d'affichage} *)

val string_of_proposition : proposition -> string
(** [string_of_proposition p] convertit la proposition [p], passée en argument,
    en une chaîne de caractères lisible.

    {b Exemples}:
    {[
      # string_of_proposition (Imp (Var "a", Var "b"));;
      - : string = "(a -> b)"

      # string_of_proposition (Et (Var "a", Non (Var "b")));;
      - : string = "(a et (non b))"
    ]} *)

val string_of_propositions : proposition list -> string

val string_of_clause : clause -> string
(** [string_of_clause c] convertit la clause [c], passée en argument, en une
    chaîne de caractères lisible.

    Une clause est affichée entre accolades avec les littéraux séparés par des
    virgules.

    {b Exemple}:
    {[
      # string_of_clause [Var "a"; Non (Var "b")];;
      - : string = "{a, (non b)}"
    ]} *)

val string_of_forme_clausale : forme_clausale -> string
(** [string_of_forme_clausale fc] convertit la forme clausale [fc], passée en
    argument, en une chaîne de caractères lisible.

    Une forme clausale est affichée entre crochets avec les clauses séparées par
    des points-virgules.

    {b Exemple}:
    {[
      # string_of_forme_clausale [[Var "a"]; [Non (Var "b"); Var "c"]];;
      - : string = "[{a}; {(non b), c}]"
    ]} *)

val string_of_enonce : enonce_probleme -> string
(** [string_of_enonce e] convertit l'énoncé [e], passé en argument, en une
    chaîne de caractères lisible avec hypothèses et conclusion.

    {b Exemple}:
    {[
      # string_of_enonce ([Var "a"; Var "b"], Var "c");;
      - : string = "Hypothèses: [a; b]\nConclusion: c"
    ]} *)

val string_of_trace :
  proposition list * proposition * forme_clausale list * bool -> string

(** {2 Fonctions de conversion LaTeX} *)

val latex_of_proposition : proposition -> string
(** [latex_of_proposition p] convertit la proposition [p], passée en argument,
    en notation LaTeX.

    {b Exemples}:
    {[
      # latex_of_proposition (Imp (Var "a", Var "b"));;
      - : string = "(a \\Rightarrow b)"

      # latex_of_proposition (Non (Var "a"));;
      - : string = "\\neg a"
    ]} *)

val latex_of_propositions : proposition list -> string

val latex_of_clause : clause -> string
(** [latex_of_clause c] convertit la clause [c], passée en argument, en notation
    LaTeX. *)

val latex_of_forme_clausale : forme_clausale -> string
(** [latex_of_forme_clausale fc] convertit la forme clausale [fc], passée en
    argument, en notation LaTeX. *)

val latex_of_enonce : enonce_probleme -> string * string
(** [latex_of_enonce e] convertit l'énoncé [e], passé en argument, en une paire
    (hypothèses, conclusion) en notation LaTeX. *)

val latex_of_trace :
  proposition list * proposition * forme_clausale list * bool -> string
