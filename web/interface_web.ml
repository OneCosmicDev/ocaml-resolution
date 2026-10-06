(* -------------------------------------------------------------------------- *)
(* Interface Web pour le démonstrateur par résolution                         *)
(* IFT-3000 - Hiver 2026                                                      *)
(* -------------------------------------------------------------------------- *)

open Js_of_ocaml

(** Type d'erreur pour catégoriser les problèmes *)
type type_erreur = Syntaxe | NonImplante | Interne | Systeme

(** Convertit un type d'erreur en chaîne *)
let string_of_type_erreur = function
  | Syntaxe -> "syntaxe"
  | NonImplante -> "non_implante"
  | Interne -> "interne"
  | Systeme -> "systeme"

(** Échappe une chaîne pour JSON *)
let echapper_json s =
  let buf = Buffer.create (String.length s * 2) in
  String.iter
    (function
      | '"' -> Buffer.add_string buf "\\\""
      | '\\' -> Buffer.add_string buf "\\\\"
      | '\n' -> Buffer.add_string buf "\\n"
      | '\r' -> Buffer.add_string buf "\\r"
      | '\t' -> Buffer.add_string buf "\\t"
      | c -> Buffer.add_char buf c)
    s;
  Buffer.contents buf

(** Analyse une exception et retourne (type, message) *)
let analyser_erreur e =
  match e with
  | Parseur.Erreur_syntaxique msg -> (Syntaxe, msg)
  | Parseur.Fichier_introuvable msg -> (Systeme, msg)
  | Resolution.Non_Implante nom ->
      (NonImplante, Printf.sprintf "Fonction non implantée: %s" nom)
  | Stack_overflow -> (Systeme, "Débordement de pile (formule trop complexe)")
  | Out_of_memory -> (Systeme, "Mémoire insuffisante (formule trop grande)")
  | Failure msg -> (Interne, msg)
  | e -> (Interne, Printexc.to_string e)

(** Génère une réponse JSON de succès *)
let json_succes data =
  Printf.sprintf {|{"success": true, "data": "%s"}|} (echapper_json data)

(** Génère une réponse JSON d'erreur *)
let json_erreur type_err message =
  Printf.sprintf
    {|{"success": false, "error": {"type": "%s", "message": "%s"}}|}
    (string_of_type_erreur type_err)
    (echapper_json message)

(** Fonction exportée: pourra être utilisée dans script.js *)
let analyser entree =
  let resultat =
    try
      let _ = Parseur.analyser_chaine (Js.to_string entree) in
      json_succes "ok"
    with e ->
      let type_err, msg = analyser_erreur e in
      json_erreur type_err msg
  in
  Js.string resultat

(** Fonction exportée: pourra être utilisée dans script.js *)
let generer_trace entree =
  let resultat =
    try
      let ((hyps, concl) as enonce) =
        Parseur.analyser_chaine (Js.to_string entree)
      in
      let proposition = Resolution.enonce_vers_proposition enonce in
      let succes, clauses = Resolution.decision_avec_trace proposition in
      json_succes (Parseur.latex_of_trace (hyps, concl, clauses, succes))
    with e ->
      let type_err, msg = analyser_erreur e in
      json_erreur type_err msg
  in
  Js.string resultat

let () =
  Js.export "analyser" analyser;
  Js.export "generer_trace" generer_trace
