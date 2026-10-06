(** {1 Exécutable Resolution}

    Point d'entrée CLI pour la résolution de problèmes logiques. Utilise le
    module [Arg] pour le parsing des arguments.

    @author IFT-3000 - Hiver 2026 *)

open Demo

(* -------------------------------------------------------------------------- *)
(* Configuration                                                               *)
(* -------------------------------------------------------------------------- *)

(** Référence pour le fichier à lire *)
let fichier = ref None

(** Référence pour l'expression directe *)
let expression = ref None

(** Référence pour le mode verbeux *)
let verbeux = ref false

(* -------------------------------------------------------------------------- *)
(* Spécifications des arguments                                                *)
(* -------------------------------------------------------------------------- *)

let message_usage =
  {|Usage: main [OPTIONS] [expression | fichier]

Résout un problème logique par la méthode de résolution.
|}

let message_format =
  {|
Format de l'expression:
  H1 ; H2 ; ... ; Hn ; C
  où les Hi sont les hypothèses et C la conclusion.

Propositions:
  id       variable propositionnelle (a, b, p, ...)
  vrai     constante vraie
  faux     constante fausse

Opérateurs:
  non      négation
  et       conjonction
  ou       disjonction
  =>       implication
  <=>      équivalence

Exemples:
  dune exec bin/main.exe -- "a => b; non b; a"
  dune exec bin/main.exe -- -f exemples/test1.txt
|}

let specs_ref = ref []

let afficher_aide () =
  Arg.usage (Arg.align !specs_ref) message_usage;
  exit 0

let specs =
  [
    ( "-f",
      Arg.String (fun s -> fichier := Some s),
      "<fichier> Lire l'expression depuis un fichier" );
    ("--file", Arg.String (fun s -> fichier := Some s), " Alias pour -f");
    ("-v", Arg.Set verbeux, " Mode verbeux (affiche plus de détails)");
    ("--verbose", Arg.Set verbeux, " Alias pour -v");
    ("-h", Arg.Unit afficher_aide, " Afficher l'aide");
    ("--help", Arg.Unit afficher_aide, " Alias pour -h");
    ("-help", Arg.Unit afficher_aide, "");
  ]

let () = specs_ref := specs

(** Fonction pour gérer les arguments anonymes (expression directe) *)
let traiter_anonyme arg =
  match !expression with
  | None -> expression := Some arg
  | Some _ ->
      raise (Arg.Bad "Plusieurs expressions fournies. N'en fournissez qu'une.")

(* -------------------------------------------------------------------------- *)
(* Point d'entrée                                                              *)
(* -------------------------------------------------------------------------- *)

let () =
  (* Parser les arguments avec gestion des erreurs *)
  (try
     Arg.parse_argv Sys.argv (Arg.align specs) traiter_anonyme message_usage
   with
  | Arg.Bad _ ->
      Printf.eprintf "Erreur: option inconnue.\n";
      Arg.usage (Arg.align specs) message_usage;
      exit 1
  | Arg.Help _ -> afficher_aide ());

  (* Déterminer quoi faire selon les options *)
  match (!fichier, !expression) with
  | Some f, None ->
      (* Lecture depuis fichier *)
      if !verbeux then Printf.printf "Lecture du fichier: %s\n%!" f;
      executer_resolution_fichier f
  | None, Some expr ->
      (* Expression directe *)
      if !verbeux then Printf.printf "Expression: %s\n%!" expr;
      executer_resolution expr
  | Some _, Some _ ->
      Printf.eprintf
        "Erreur: spécifiez soit -f <fichier> soit une expression, pas les deux.\n";
      Printf.eprintf "%s\n" message_format;
      exit 1
  | None, None ->
      (* Aucune entrée: afficher l'aide *)
      Arg.usage (Arg.align specs) message_usage;
      print_string message_format
