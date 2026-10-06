(** {1 Module Resolution}

    TP1 - IFT-3000 - Hiver 2026

    Implémentation de l'algorithme de résolution en logique propositionnelle
    pour déterminer si un ensemble d'hypothèses implique une conclusion.

    @author Juan Jose Castilla *)

(* -------------------------------------------------------------------------- *)
(* ----------------------- TP1 - IFT-3000 - Hiver 2026 ---------------------- *)
(* -------------------------------------------------------------------------- *)
(* -------------------------------------------------------------------------- *)
(* -- PRINCIPAL FICHIER DU TP: FONCTIONS À IMPLÉMENTER ---------------------- *)
(* -------------------------------------------------------------------------- *)

(** {2 Rappels}

    {3 Énoncés des problèmes}
    Ils sont représentés par un couple contenant:
    - une liste de propositions (les Hi);
    - une proposition (le C).

    Chaque proposition est représentée à l'aide du type [proposition].

    {3 Formes clausales}
    - Une forme clausale est une liste de clauses; implicitement, il y a un «et»
      logique entre les clauses.
    - Une clause est une liste de littéraux; implicitement, il y a un «ou»
      logique entre les littéraux.
    - Un littéral est une proposition de la forme [Var id] ou [Non (Var id)]. *)

(******************************************************************************)
(* Implémentation                                                             *)
(******************************************************************************)
open Tp_types
open List

type proposition = Tp_types.proposition
type enonce_probleme = Tp_types.enonce_probleme
type clause = Tp_types.clause
type forme_clausale = Tp_types.forme_clausale

exception Non_Implante of string
(** Exception levée lorsqu'une fonction n'est pas encore implantée. *)

(******************************************************************************)
(* SECTION 1: FONCTIONS FOURNIES                                              *)
(******************************************************************************)
let ( ++ ) l1 l2 =
  fold_left (fun acc e -> if mem e acc then acc else acc @ [ e ]) [] (l1 @ l2)

let enleve x lst = filter (fun y -> y <> x) lst

exception LitteralIllegal

let anti_litteral p =
  match p with
  | Var id -> Non (Var id)
  | Non (Var id) -> Var id
  | _ -> raise LitteralIllegal

let succes (fs : forme_clausale) = mem [] fs

let clause_vraie (c : clause) : bool =
  exists (fun lit -> mem (anti_litteral lit) c) c

let enleve_clauses_vraies (forme_clausale : forme_clausale) : forme_clausale =
  filter (fun c -> not (clause_vraie c)) forme_clausale

(******************************************************************************)
(* SECTION 2: FONCTIONS UTILITAIRES POLYMORPHES À IMPLÉMENTER (30 pts)        *)
(* Ces fonctions sont génériques et indépendantes du domaine de résolution.   *)
(******************************************************************************)

(* -- À IMPLÉMENTER (15 PTS) ------------------------------------------------ *)
let produit_cartesien ll1 ll2 =
  concat (map (fun l1 -> map (fun l2 -> l1 ++ l2) ll2) ll1)

(* -- À IMPLÉMENTER (15 PTS) ------------------------------------------------ *)
let paires lst =
  let n = length lst in
  if n < 2 then []
  else
    let arr = Array.of_list lst in
    let rec aux i acc =
      if i >= n - 1 then acc
      else
        let acc' =
          let rec inner j acc2 =
            if j >= n then acc2
            else
              let reste = filteri (fun k _ -> k <> i && k <> j) lst in
              inner (j + 1) (((arr.(i), arr.(j)), reste) :: acc2)
          in
          inner (i + 1) acc
        in
        aux (i + 1) acc'
    in
    rev (aux 0 [])

(******************************************************************************)
(* SECTION 3: FONCTIONS DE RÉSOLUTION À IMPLÉMENTER, SAUF LA DERNIÈRE (70 pts)*)
(******************************************************************************)

(* -- À IMPLÉMENTER (10 PTS) ------------------------------------------------ *)
let enonce_vers_proposition (enonce : enonce_probleme) : proposition =
  let (hypotheses, conclusion) = enonce in
  fold_right (fun h acc -> Et (h, acc)) hypotheses (Non conclusion)

(* -- À IMPLÉMENTER (20 PTS) ------------------------------------------------ *)
let rec mise_en_forme_clausale (p : proposition) : forme_clausale =
  match p with
  | Vrai -> []
  | Faux -> [ [] ]
  | Var id -> [ [ Var id ] ]
  | Non (Var id) -> [ [ Non (Var id) ] ]
  | Non (Non p1) -> mise_en_forme_clausale p1
  | Non Vrai -> [ [] ]
  | Non Faux -> []
  | Et (p1, p2) ->
    mise_en_forme_clausale p1 @ mise_en_forme_clausale p2
  | Ou (p1, p2) ->
    produit_cartesien (mise_en_forme_clausale p1) (mise_en_forme_clausale p2)
  | Imp (p1, p2) ->
    mise_en_forme_clausale (Ou (Non p1, p2))
  | Equ (p1, p2) ->
    mise_en_forme_clausale (Et (Imp (p1, p2), Imp (p2, p1)))
  | Non (Et (p1, p2)) ->
    mise_en_forme_clausale (Ou (Non p1, Non p2))
  | Non (Ou (p1, p2)) ->
    mise_en_forme_clausale (Et (Non p1, Non p2))
  | Non (Imp (p1, p2)) ->
    mise_en_forme_clausale (Et (p1, Non p2))
  | Non (Equ (p1, p2)) ->
    mise_en_forme_clausale (Ou (Et (p1, Non p2), Et (Non p1, p2)))

(* -- À IMPLÉMENTER (20 PTS) ------------------------------------------------ *)
let resolutions (c1 : clause) (c2 : clause) : forme_clausale =
  filter_map
    (fun l ->
      let al = anti_litteral l in
      if mem al c2 then
        Some (enleve l c1 ++ enleve al c2)
      else
        None)
    c1

(* -- À IMPLÉMENTER (20 PTS) ------------------------------------------------ *)
let decision (p : proposition) : bool =
  let rec resoudre (fc : forme_clausale) : bool =
    if succes fc then true
    else
      let fc_nette = enleve_clauses_vraies fc in
      let paires_fc = paires fc_nette in
      if paires_fc = [] then false
      else
        let fc_new =
          fold_left
            (fun acc ((c1, c2), _) -> acc ++ resolutions c1 c2)
            fc
            paires_fc
        in
        if fc_new = fc then false
        else resoudre fc_new
  in
  resoudre (mise_en_forme_clausale p)

(* -- Fonction fournie ------------------------------------------------------ *)
let rec decision_avec_trace (p : proposition) : bool * forme_clausale list =
  aux (mise_en_forme_clausale p)

and aux fc =
  if succes fc then (true, [ fc ] @ if length fc = 1 then [] else [ [ [] ] ])
  else
    let ps = paires (enleve_clauses_vraies fc) in
    if ps = [] then (false, [ fc ])
    else
      match essayer_paires fc ps with
      | Some trace -> (true, fc :: trace)
      | None -> (false, continuer_trace fc ps)

and essayer_paires fc = function
  | [] -> None
  | ((c1, c2), clauses) :: reste -> (
      match essayer_resolutions clauses (resolutions c1 c2) with
      | Some trace -> Some trace
      | None -> essayer_paires fc reste)

and essayer_resolutions clauses = function
  | [] -> None
  | c3 :: reste ->
      let ok, trace = aux ([ c3 ] ++ clauses) in
      if ok then Some trace else essayer_resolutions clauses reste

and continuer_trace fc = function
  | [] -> [ fc ]
  | ((c1, c2), clauses) :: reste -> (
      match resolutions c1 c2 with
      | [] -> continuer_trace fc reste
      | c3 :: _ ->
          let _, trace = aux ([ c3 ] ++ clauses) in
          fc :: trace)
