(** {1 Module Resolution}

    Module principal pour la résolution de problèmes logiques par la méthode de
    résolution. Ce module implémente l'algorithme de résolution en logique
    propositionnelle qui permet de déterminer si un ensemble d'hypothèses
    implique une conclusion.

    {2 Travail à réaliser}

    Les fonctions à implémenter sont réparties en deux catégories :

    {3 Fonctions utilitaires polymorphes (30 pts)}

    Ces fonctions sont génériques et indépendantes du domaine de la résolution.
    Elles illustrent la puissance du polymorphisme paramétrique en OCaml.
    - {!produit_cartesien} (15 pts)
    - {!paires} (15 pts)

    {3 Fonctions de résolution (70 pts)}
    
    - {!enonce_vers_proposition} (10 pts)
    - {!mise_en_forme_clausale} (20 pts)
    - {!resolutions} (20 pts)
    - {!decision} (20 pts)

    Total: 100 points

    @author IFT-3000 - Hiver 2026 *)

(** {2 Types} *)

type proposition = Tp_types.proposition
(** Type des propositions logiques.

    Une proposition peut être :
    - [Vrai] ou [Faux]: constantes booléennes
    - [Var id]: variable propositionnelle
    - [Non p]: négation (non p)
    - [Et (p1, p2)]: conjonction (p1 et p2)
    - [Ou (p1, p2)]: disjonction (p1 ou p2)
    - [Imp (p1, p2)]: implication (p1 => p2)
    - [Equ (p1, p2)]: équivalence (p1 <=> p2) *)

type enonce_probleme = Tp_types.enonce_probleme
(** Type des énoncés de problèmes.

    Un énoncé est un couple [(hypothèses, conclusion)] où :
    - [hypothèses] est une liste de propositions H1, H2, ..., Hn
    - [conclusion] est la proposition C à démontrer *)

type clause = Tp_types.clause
(** Type des clauses.

    Une clause est une liste de littéraux (variables ou négations de variables).
    Les littéraux sont implicitement reliés par des disjonctions (OU).

    Exemple : [\[a; ¬b; c\]] représente a ∨ ¬b ∨ c *)

type forme_clausale = Tp_types.forme_clausale
(** Type des formes clausales.

    Une forme clausale est une liste de clauses. Les clauses sont implicitement
    reliées par des conjonctions (ET).

    Exemple : [\[\[a; b\]; \[¬a; c\]\]] représente (a ∨ b) ∧ (¬a ∨ c) *)

(** {2 Exception} *)

exception Non_Implante of string
(** Exception levée lorsqu'une fonction n'est pas encore implantée.

    Utilisez [raise (Non_Implante "nom_fonction")] pour signaler qu'une fonction
    n'est pas encore programmée. *)

(** {2 Fonctions fournies (pré-implémentées)}

    Ces fonctions sont fournies et peuvent être utilisées dans votre code. Vous
    n'avez pas à les implémenter. *)

val ( ++ ) : 'a list -> 'a list -> 'a list
(** [l1 ++ l2] retourne l'union des listes [l1] et [l2] sans doublons. *)

val enleve : 'a -> 'a list -> 'a list
(** [enleve x lst] retourne la liste [lst] sans les occurrences de [x]. *)

val anti_litteral : proposition -> proposition
(** [anti_litteral p] retourne l'anti-littéral de [p], c'est-à-dire [Non(Var id)]
    si [p = Var id], ou [Var id] si [p = Non(Var id)].

    @raise LitteralIllegal si [p] n'est pas un littéral valide. *)

val succes : forme_clausale -> bool
(** [succes fc] retourne [true] si [fc] contient la clause vide [[]]. *)

val clause_vraie : clause -> bool
(** [clause_vraie c] retourne [true] si [c] contient un littéral et son
    anti-littéral (par exemple [Var "a"] et [Non(Var "a")]). *)

val enleve_clauses_vraies : forme_clausale -> forme_clausale
(** [enleve_clauses_vraies fc] retourne une forme clausale dérivée de [fc] dans
    laquelle les clauses vraies ont été supprimées. *)

(** {2 Fonctions utilitaires polymorphes à implémenter (30 pts)}

    Ces fonctions sont génériques (polymorphes) et peuvent être utilisées avec
    n'importe quel type de données. Elles ne dépendent pas des types spécifiques
    au projet (proposition, clause, etc.) et illustrent la puissance de la
    généricité en programmation fonctionnelle. *)

(** {3 produit_cartesien (15 pts)} *)

val produit_cartesien : 'a list list -> 'a list list -> 'a list list
(** [produit_cartesien ll1 ll2] calcule le produit cartésien de deux listes de
    listes [ll1] et [ll2] passées en paramètres.

    Pour chaque liste [l1] de [ll1] et [l2] de [ll2], crée une nouvelle liste
    qui est l'union de [l1] et [l2].

    {b Pré-conditions}:
    - Aucune

    {b Post-conditions}:
    {b Post-conditions}:
    - Si [ll1] ou [ll2] est une liste vide, alors le résultat est la liste vide 
      aussi
    - Chaque liste du résultat est l'union d'une liste de [ll1] avec une liste 
      de [ll2]
    - Le résultat ne contient pas de doublons

    {b Exemples}:
    {[
      (* Avec des entiers *)
      # produit_cartesien [[1]] [[1];[1]];;
      - : int list list = [[1]]
      
      # produit_cartesien [[1]] [[1];[2]];;
      - : int list list = [[1]; [1; 2]]      
      
      # produit_cartesien [[1; 2]; [3]] [[4]; [5; 6]];;
      - : int list list = [[1; 2; 4]; [1; 2; 5; 6]; [3; 4]; [3; 5; 6]]

      # produit_cartesien [[1; 2]; [3]] [[4; 3; 4]; [5; 6; 1]];;
      - : int list list = [[1; 2; 4; 3]; [1; 2; 5; 6]; [3; 4]; [3; 5; 6; 1]]

      # produit_cartesien [[1; 2]; [3]] [[4; 3; 4]; []];;
      - : int list list = [[1; 2; 4; 3]; [1; 2]; [3; 4]; [3]]

      (* Avec des chaînes *)
      # produit_cartesien [["a"]; ["b"]] [["c"; "d"]];;
      - : string list list = [["a"; "c"; "d"]; ["b"; "c"; "d"]]

      (* Application au projet: avec des clauses *)
      # produit_cartesien [[Var "a"]; [Var "b"]] [[Var "c"]; [Var "d"]];;
      - : Tp_types.proposition list list =
      [[Var "a"; Var "c"]; [Var "a"; Var "d"]; [Var "b"; Var "c"]; [Var "b"; Var "d"]]
    ]} *)

(** {3 paires (15 pts)} *)

val paires : 'a list -> (('a * 'a) * 'a list) list
(** [paires lst] génère toutes les paires d'éléments de la liste
    [lst] passée en argument, accompagnées du reste de la liste.

    {b Pré-conditions}:
    - Aucune

    {b Post-conditions}:
    - Génère toutes les paires d'éléments à des positions distinctes de la liste 
      [lst]
    - Pour chaque triplet [((x1, x2), reste)], [reste] contient exactement les
      éléments de [lst] qui ne font pas partie de la paire

    {b Exemples}:
    {[
      (* Avec des entiers *)
      # paires [1];;
      - : ((int * int) * int list) list = []

      # paires [1;1];;
      - : ((int * int) * int list) list = [((1, 1), [])]

      # paires [1;1;1];;
      - : ((int * int) * int list) list =
      [((1, 1), []); ((1, 1), []); ((1, 1), [])]

      # paires [1; 2; 1];;
      - : ((int * int) * int list) list =
      [((1, 2), []); ((1, 1), [2]); ((2, 1), [])]

      # paires [1;2];;
      - : ((int * int) * int list) list = [((1, 2), [])]

      # paires [1; 2; 3];;
      - : ((int * int) * int list) list =
      [((1, 2), [3]); ((1, 3), [2]); ((2, 3), [1])]

      (* Avec des chaînes *)
      # paires ["a"; "b"; "c"];;
      - : ((string * string) * string list) list =
      [(("a", "b"), ["c"]); (("a", "c"), ["b"]); (("b", "c"), ["a"])]

      (* Application au projet: avec des clauses *)
      # paires [[Var "a"]; [Var "b"]; [Var "c"]];;
      - : ((Tp_types.proposition list * Tp_types.proposition list)
           * Tp_types.proposition list list) list = ...
    ]} *)

(** {2 Fonctions de résolution à implémenter (70 pts)}

    Ces fonctions sont spécifiques à l'algorithme de résolution et utilisent les
    types du projet (proposition, clause, forme_clausale, etc.). *)

(** {3 enonce_vers_proposition (10 pts)} *)

val enonce_vers_proposition : enonce_probleme -> proposition
(** [enonce_vers_proposition enonce] convertit l'énoncé [enonce], passé en
    argument, en une proposition unique.

    Transforme [(H1; H2; ...; Hn, C)] en [H1 ∧ H2 ∧ ... ∧ Hn ∧ ¬C]. Cette forme
    permet de vérifier si les hypothèses impliquent la conclusion : si cette
    proposition est une contradiction, alors les hypothèses impliquent C.

    {b Pré-conditions}:
    - Aucune

    {b Post-conditions}:
    - Si [hypothèses = []], alors le résultat est [Non conclusion]
    - Si [hypothèses = [H]], alors le résultat est [Et(H, Non conclusion)]
    - Sinon, le résultat est [Et(H1, Et(H2, ..., Et(Hn, Non C)...))]
    - La structure est toujours associative à droite

    {b Exemple}:
    {[
      # enonce_vers_proposition ([], Var "c");;
      - : Resolution.proposition = Non (Var "c")

      # enonce_vers_proposition ([Var "b"], Var "c");;
      - : Resolution.proposition = Et (Var "b", Non (Var "c"))

      # enonce_vers_proposition ([Var "a"; Var "b"], Var "c");;
      - : Resolution.proposition = Et (Var "a", Et (Var "b", Non (Var "c")))
    ]} *)

(** {3 mise_en_forme_clausale (20 pts)} *)

val mise_en_forme_clausale : proposition -> forme_clausale
(** [mise_en_forme_clausale p] convertit la proposition [p], passée en argument,
    en sa forme clausale (mise en Forme Clausale). Applique les règles de
    transformation pour obtenir une forme normale conjonctive puis la représente
    comme liste de clauses. En particulier, si [p = Vrai], alors le résultat est 
    la liste vide (tautologie); si [p = Faux], alors le résultat est une liste 
    qui contient la liste vide (représentant la clause vide).

    {b Pré-conditions}:
    - Aucune

    {b Post-conditions}:
    - Chaque clause contient uniquement des littéraux ([Var id] ou [Non(Var id)])

    {b Exemples}:
    {[
      # mise_en_forme_clausale (Ou (Var "a", Var "b"));;
      - : Resolution.forme_clausale = [[Var "a"; Var "b"]]

      # mise_en_forme_clausale (Et (Var "a", Var "b"));;
      - : Resolution.forme_clausale = [[Var "a"]; [Var "b"]]

      # mise_en_forme_clausale (Imp (Var "a", Var "b"));;
      - : Resolution.forme_clausale =  [[Non (Var "a"); Var "b"]]
    ]} *)

(** {3 resolutions (20 pts)} *)

val resolutions : clause -> clause -> clause list
(** [resolutions c1 c2] applique la règle de résolution entre les deux clauses
    [c1] et [c2] passées en arguments.

    Pour chaque littéral [l] de [c1] tel que [¬l] est dans [c2], produit une
    nouvelle clause [(c1 \ {l}) ∪ (c2 \ {¬l})].

    {b Pré-conditions}:
    - Chaque élément de [c1] et [c2] est un littéral ([Var id] ou [Non(Var id)])

    {b Post-conditions}:
    - Si aucun littéral de [c1] n'a son anti-littéral dans [c2], le résultat est
      la liste vide
    - Le résultat contient une clause pour chaque paire de littéraux 
      complémentaires trouvée entre [c1] et [c2]
    - Chaque clause résultante ne contient pas les littéraux qui ont permis la 
      résolution
    - Si [c1] et [c2] contiennent chacune un seul littéral et que ces littéraux 
      sont complémentaires, le résultat contient la clause vide

    {b Exemple}:
    {[
      # resolutions [Var "a"; Var "b"] [Non (Var "a"); Var "c"];;
      - : Resolution.clause list = [[Var "b"; Var "c"]]
    ]} *)

(** {3 decision (20 pts)} *)

val decision : proposition -> bool
(** [decision p] détermine si la proposition [p], passée en argument, est une
    contradiction.

    Utilise l'algorithme de résolution. En particulier:
    - Si on peut dériver la clause vide [], alors la proposition est 
      insatisfiable (est une contradiction).
    - Pour une tautologie [t], [decision (Non t)] retourne [true]
    - [decision (Et (Var x, Non (Var x)))] retourne [true] pour tout [x]
    - [decision (Ou (Var x, Non (Var x)))] retourne [false] pour tout [x]

    {b Pré-conditions}:
    - Aucune

    {b Post-conditions}:
    - Aucune

    {b Exemples}:
    {[
      # decision (Et (Var "a", Non (Var "a")));;
      - : bool = true

      # decision (Ou (Var "a", Non (Var "a")));;
      - : bool = false
    ]} *)

(** {3 decision_avec_trace (10 pts)} *)

val decision_avec_trace : proposition -> bool * forme_clausale list
(** [decision_avec_trace p] comme [decision], mais retourne aussi la trace de
    résolution pour la proposition [p] passée en argument. *)
