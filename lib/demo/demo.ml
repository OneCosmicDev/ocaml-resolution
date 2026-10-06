(** {1 Module Demo}

    Module de démonstration pour afficher la trace d'exécution de la résolution
    de problèmes logiques.

    Ce module utilise le type [Result] pour une gestion propre des erreurs, sans
    propager d'exceptions vers le code appelant.

    @author IFT-3000 - Hiver 2026 *)

(* -------------------------------------------------------------------------- *)
(* Fonctions pour afficher la trace d'exécution pour la résolution de         *)
(* problèmes logiques                                                         *)
(* -------------------------------------------------------------------------- *)
open Parseur
open Resolution

(** Type d'erreur pour catégoriser les problèmes *)
type type_erreur =
  | Syntaxe of string
  | FichierIntrouvable of string
  | NonImplante of string
  | Interne of string
  | Systeme of string

(** Convertit une erreur en message lisible *)
let string_of_erreur = function
  | Syntaxe msg -> Printf.sprintf "Erreur de syntaxe: %s" msg
  | FichierIntrouvable msg -> msg
  | NonImplante nom -> Printf.sprintf "Fonction non implantée: %s" nom
  | Interne msg -> Printf.sprintf "Erreur interne: %s" msg
  | Systeme msg -> Printf.sprintf "Erreur système: %s" msg

(** Analyse une exception et retourne une erreur typée *)
let erreur_of_exception = function
  | Erreur_syntaxique msg -> Syntaxe msg
  | Fichier_introuvable msg -> FichierIntrouvable msg
  | Resolution.Non_Implante nom -> NonImplante nom
  | Stack_overflow -> Systeme "débordement de pile (formule trop complexe)"
  | Out_of_memory -> Systeme "mémoire insuffisante (formule trop grande)"
  | Failure msg -> Interne msg
  | e -> Interne (Printexc.to_string e)

(** [lire_fichier nom_fichier] lit le contenu d'un fichier.
    @param nom_fichier chemin vers le fichier à lire
    @return [Ok contenu] ou [Error erreur] *)
let lire_fichier nom_fichier =
  try
    let canal = open_in nom_fichier in
    Fun.protect
      ~finally:(fun () -> close_in canal)
      (fun () ->
        let n = in_channel_length canal in
        Ok (really_input_string canal n))
  with Sys_error _ ->
    Error
      (FichierIntrouvable (Printf.sprintf "Fichier introuvable: %s" nom_fichier))

(** [resoudre_chaine entree] analyse et résout un énoncé logique.
    @param entree chaîne contenant l'énoncé
    @return [Ok trace] ou [Error erreur] *)
let resoudre_chaine entree =
  try
    let ((hyps, concl) as enonce) = analyser_chaine entree in
    let proposition = enonce_vers_proposition enonce in
    let succes, clauses = decision_avec_trace proposition in
    Ok (string_of_trace (hyps, concl, clauses, succes))
  with e -> Error (erreur_of_exception e)

(** [resoudre_fichier nom_fichier] lit un fichier et résout l'énoncé.
    @param nom_fichier chemin vers le fichier
    @return [Ok trace] ou [Error erreur] *)
let resoudre_fichier nom_fichier =
  match lire_fichier nom_fichier with
  | Error e -> Error e
  | Ok contenu -> resoudre_chaine (String.trim contenu)

(** [executer_resolution entree] analyse et résout un énoncé, affiche le
    résultat.
    @param entree chaîne contenant l'énoncé *)
let executer_resolution entree =
  match resoudre_chaine entree with
  | Ok trace -> print_string trace
  | Error e -> Printf.eprintf "%s\n" (string_of_erreur e)

(** [executer_resolution_fichier nom_fichier] lit et résout depuis un fichier.
    @param nom_fichier chemin vers le fichier *)
let executer_resolution_fichier nom_fichier =
  match resoudre_fichier nom_fichier with
  | Ok trace -> print_string trace
  | Error e -> Printf.eprintf "%s\n" (string_of_erreur e)
