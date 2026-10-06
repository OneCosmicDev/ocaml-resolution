(* Ouverture des types *)
open Tp_types
open List

(* Exceptions *)
exception Erreur_syntaxique of string
exception Fichier_introuvable of string

(*****************************************************************************)
(* SECTION 1: Analyseur syntaxique                                            *)
(*****************************************************************************)

(* Analyse syntaxique depuis une chaine de caractères -> enonce_probleme *)
let analyser_chaine (s : string) : enonce_probleme =
  if String.trim s = "" then
    raise (Erreur_syntaxique "Entrée vide: veuillez saisir un énoncé logique")
  else
    let lexbuf = Lexing.from_string s in
    try Parser.enonce Lexer.token lexbuf with
    | Lexer.Erreur_lexicale msg ->
        raise (Erreur_syntaxique ("Erreur lexicale: " ^ msg))
    | Parser.Error ->
        let pos = lexbuf.Lexing.lex_curr_p in
        raise
          (Erreur_syntaxique
             (Printf.sprintf "Erreur de syntaxe ligne %d, colonne %d"
                pos.Lexing.pos_lnum
                (pos.Lexing.pos_cnum - pos.Lexing.pos_bol)))

(* Analyse syntaxique  depuis un fichier -> enonce_probleme *)
let analyser_fichier (nom_fichier : string) : enonce_probleme =
  let canal =
    try open_in nom_fichier
    with Sys_error _ ->
      raise
        (Fichier_introuvable
           (Printf.sprintf "Fichier introuvable: %s" nom_fichier))
  in
  Fun.protect
    ~finally:(fun () -> close_in canal)
    (fun () ->
      let lexbuf = Lexing.from_channel canal in
      lexbuf.Lexing.lex_curr_p <-
        { lexbuf.Lexing.lex_curr_p with Lexing.pos_fname = nom_fichier };
      try Parser.enonce Lexer.token lexbuf with
      | Lexer.Erreur_lexicale msg ->
          raise
            (Erreur_syntaxique
               (Printf.sprintf "Erreur lexicale dans %s: %s" nom_fichier msg))
      | Parser.Error ->
          let pos = lexbuf.Lexing.lex_curr_p in
          raise
            (Erreur_syntaxique
               (Printf.sprintf "Erreur de syntaxe dans %s, ligne %d, colonne %d"
                  nom_fichier pos.Lexing.pos_lnum
                  (pos.Lexing.pos_cnum - pos.Lexing.pos_bol))))

(******************************************************************************)
(* SECTION 2: Fonctions d'affichage                                           *)
(******************************************************************************)

(* Affichage d'une proposition *)
let rec string_of_proposition = function
  | Vrai -> "vrai"
  | Faux -> "faux"
  | Var s -> s
  | Non p -> Printf.sprintf "(non %s)" (string_of_proposition p)
  | Et (p1, p2) ->
      Printf.sprintf "(%s et %s)" (string_of_proposition p1)
        (string_of_proposition p2)
  | Ou (p1, p2) ->
      Printf.sprintf "(%s ou %s)" (string_of_proposition p1)
        (string_of_proposition p2)
  | Imp (p1, p2) ->
      Printf.sprintf "(%s => %s)" (string_of_proposition p1)
        (string_of_proposition p2)
  | Equ (p1, p2) ->
      Printf.sprintf "(%s <=> %s)" (string_of_proposition p1)
        (string_of_proposition p2)

(* Affichage d'une liste de propositions *)
let rec string_of_propositions l =
  match l with
  | [] -> "(aucune)"
  | [ p ] -> string_of_proposition p
  | p :: r -> string_of_proposition p ^ " et " ^ string_of_propositions r

(* Affichage d'une clause *)
let rec string_of_clause (clause : clause) : string =
  match clause with
  | [] -> "faux"
  | [ Var x ] -> x
  | [ Non p ] -> string_of_proposition (Non p)
  | lp -> "(" ^ string_of_clause_aux lp ^ ")"

and string_of_clause_aux l =
  match l with
  | [] -> ""
  | [ p ] -> string_of_proposition p
  | p :: r -> string_of_proposition p ^ " ou " ^ string_of_clause_aux r

(* Affichage d'une forme clausale *)
let rec string_of_forme_clausale (fc : forme_clausale) : string =
  match fc with
  | [] -> "vrai"
  | [ c ] -> string_of_clause c
  | c :: r -> string_of_clause c ^ " et " ^ string_of_forme_clausale r

(* Affichage d'un énoncé *)
let string_of_enonce ((hyps, concl) : enonce_probleme) : string =
  let hyps_str = String.concat "; " (map string_of_proposition hyps) in
  Printf.sprintf "Hypothèses: [%s]\nConclusion: %s" hyps_str
    (string_of_proposition concl)

let string_of_trace (hyps, concl, clauses, succes) =
  let est_tautologie = hyps = [] in
  "Hypotheses (H):\n\t"
  ^ string_of_propositions hyps
  ^ "\n\n" ^ "Conclusion (C):\n\t"
  ^ string_of_proposition concl
  ^ "\n\n"
  ^ (if est_tautologie then
       "Resolution: L'objectif est de montrer que (non C) => faux\n\n\t"
       ^ string_of_proposition (Non concl)
     else
       "Resolution: L'objectif est de montrer que (H et (non C)) => faux\n\n\t"
       ^ string_of_propositions (hyps @ [ Non concl ]))
  ^ "\n"
  ^ fold_left
      (fun acc clause -> acc ^ "\t=> " ^ string_of_forme_clausale clause ^ "\n")
      "" clauses
  ^ "\nDonc:\n\t"
  ^ (if est_tautologie then ""
     else string_of_propositions hyps ^ if succes then "  =>  " else "  =/=>  ")
  ^ string_of_proposition concl
  ^ (if est_tautologie then
       if succes then " est une tautologie" else " n'est pas une tautologie"
     else "")
  ^ "\n\n"

(* ========================================================================== *)
(* Fonctions de conversion LaTeX pour l'interface web                        *)
(* ========================================================================== *)

(* Affichage LaTeX d'une proposition *)
let rec latex_of_proposition = function
  | Vrai -> "1"
  | Faux -> "0"
  | Var s -> s
  | Non (Var s) -> "\\neg " ^ s
  | Non p -> "\\neg (" ^ latex_of_proposition p ^ ")"
  | Et (p1, p2) ->
      "(" ^ latex_of_proposition p1 ^ " \\land " ^ latex_of_proposition p2 ^ ")"
  | Ou (p1, p2) ->
      "(" ^ latex_of_proposition p1 ^ " \\lor " ^ latex_of_proposition p2 ^ ")"
  | Imp (p1, p2) ->
      "(" ^ latex_of_proposition p1 ^ " \\Rightarrow " ^ latex_of_proposition p2
      ^ ")"
  | Equ (p1, p2) ->
      "(" ^ latex_of_proposition p1 ^ " \\Leftrightarrow "
      ^ latex_of_proposition p2 ^ ")"

(* Affichage Latex d'une liste de propositions *)
let rec latex_of_propositions l =
  match l with
  | [] -> "\\emptyset"
  | [ p ] -> latex_of_proposition p
  | p :: r -> latex_of_proposition p ^ " \\wedge " ^ latex_of_propositions r

(* Affichage LaTeX d'une clause (disjonction de littéraux) *)
let rec latex_of_clause (clause : clause) : string =
  match clause with
  | [] -> "0"
  | [ Var x ] -> x
  | [ Non p ] -> latex_of_proposition (Non p)
  | lp -> "(" ^ latex_of_clause_aux lp ^ ")"

and latex_of_clause_aux l =
  match l with
  | [] -> ""
  | [ p ] -> latex_of_proposition p
  | p :: r -> latex_of_proposition p ^ " \\vee " ^ latex_of_clause_aux r

(* Affichage LaTeX d'une forme clausale (clauses liées par \wedge) *)
let rec latex_of_forme_clausale (fc : forme_clausale) : string =
  match fc with
  | [] -> "1" (* Forme clausale vide = vrai (conjonction vide) *)
  | [ c ] -> latex_of_clause c
  | c :: r -> latex_of_clause c ^ " \\wedge " ^ latex_of_forme_clausale r

(* Affichage LaTeX d'un énoncé *)
let latex_of_enonce ((hyps, concl) : enonce_probleme) : string * string =
  let hyps_latex = map latex_of_proposition hyps in
  let hyps_str = String.concat ", " hyps_latex in
  let concl_str = latex_of_proposition concl in
  (hyps_str, concl_str)

(*&egrave;*)
let latex_of_trace (hyps, concl, clauses, succes) =
  let est_tautologie = hyps = [] in
  "\\begin{array}{rl}" ^ "\\textbf{Hypothèses} \\ (\\textit{H}):&"
  ^ latex_of_propositions hyps ^ "\\\\\\\\"
  ^ "\\textbf{Conclusion} \\ (\\textit{C}):&" ^ latex_of_proposition concl
  ^ "\\\\\\\\" ^ "\\textbf{Résolution}:&" ^ "\\text{L'objectif est de montrer}"
  ^ (if est_tautologie then
       "\\ \\text{que} \\ (\\neg C) \\Rightarrow 0\\\\\\\\" ^ "& "
       ^ latex_of_proposition (Non concl)
     else
       "\\ \\text{que} \\ (H \\wedge \\neg C) \\Rightarrow 0\\\\\\\\" ^ "& "
       ^ latex_of_propositions (hyps @ [ Non concl ]))
  ^ "\\\\"
  ^ fold_left
      (fun acc clause ->
        acc ^ "& \\Rightarrow \\ " ^ latex_of_forme_clausale clause ^ "\\\\")
      "" clauses
  ^ "\\\\ \\textbf{Donc}: &"
  ^ (if est_tautologie then
       latex_of_proposition concl
       ^ Printf.sprintf "\\ \\ \\textcolor{blue}{\\textbf{%s}}"
           (if succes then "est une tautologie" else "n'est pas une tautologie")
     else
       latex_of_propositions hyps
       ^ Printf.sprintf "  \\ \\ \\textcolor{blue}{\\boldsymbol{%s}} \\ \\ "
           (if succes then "\\Rightarrow" else "\\nRightarrow")
       ^ latex_of_proposition concl)
  ^ "\\\\" ^ "\\end{array}"
