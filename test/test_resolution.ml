(* -------------------------------------------------------------------------- *)
(* ----------------------- TP1 - IFT-3000 - Hiver 2026 ---------------------- *)
(* -------------------------------------------------------------------------- *)
(** Fichier permettant de tester les fonctions implantées du TP.

    Ce fichier contient:
    - Des fonctions utilitaires pour comparer les résultats (section 1)
    - Des jeux de données pour chaque fonction à tester (section 2)
    - Un testeur générique avec gestion du timeout (section 3)
    - Les fonctions tests et corrige pour exécuter les tests (section 4) *)
(* -------------------------------------------------------------------------- *)

open Tp_types
open Resolution
open Parseur
open List

(* ========================================================================== *)
(* SECTION 1: Fonctions utilitaires pour la comparaison des résultats         *)
(* ========================================================================== *)

(** [trier l] trie une liste [l] selon l'ordre standard de comparaison. *)
let trier l = fast_sort Stdlib.compare l

(** [normaliser trier_elem ll] normalise une liste de listes en triant. *)
let normaliser trier_elem ll = ll |> map trier_elem |> trier

(** [normaliser_fc fc] normalise une forme clausale. *)
let normaliser_fc = normaliser trier

(** [egal_apres_normalisation normaliser x y] compare après normalisation. *)
let egal_apres_normalisation normaliser x y = normaliser x = normaliser y

(** [egal_fc fc1 fc2] compare deux formes clausales pour l'égalité. *)
let egal_fc = egal_apres_normalisation normaliser_fc

(** [egal_paires lpaires1 lpaires2] compare deux listes de paires. *)
let egal_paires lpaires1 lpaires2 =
  let normaliser_paire ((c1, c2), fc) =
    ((trier c1, trier c2), normaliser_fc fc)
  in
  trier (map normaliser_paire lpaires1) = trier (map normaliser_paire lpaires2)

(* ========================================================================== *)
(* SECTION 2: Jeux de données pour les tests                                  *)
(* ========================================================================== *)

type ('entree, 'sortie) cas_test = {
  entree : 'entree;
  attendu : 'sortie;
  desc : string;
}
(** Type d'un cas de test individuel. *)

type ('entree, 'sortie) jeu_tests = {
  comparer : 'entree -> 'sortie -> bool;
  cas : ('entree, 'sortie) cas_test list;
  cas_exception : (('entree -> 'sortie) * ('entree * string) list) option;
}
(** Type d'un jeu de tests complet pour une fonction. *)

(* -------------------------------------------------------------------------- *)

(** Jeu de tests pour [produit_cartesien]. *)
let jeu_produit_cartesien () :
    (forme_clausale * forme_clausale, forme_clausale) jeu_tests =
  {
    comparer = (fun (ll1, ll2) res -> egal_fc (produit_cartesien ll1 ll2) res);
    cas =
      [
        { entree = ([], []); attendu = []; desc = {| produit_cartesien [] []|} };
        {
          entree = ([ [ Var "p" ] ], []);
          attendu = [];
          desc = {| produit_cartesien [ [ Var "p" ] ] []|};
        };
        {
          entree = ([], [ [ Var "p" ] ]);
          attendu = [];
          desc = {| produit_cartesien [] [ [ Var "p" ] ]|};
        };
        {
          entree = ([ [] ], [ [] ]);
          attendu = [ [] ];
          desc = {| produit_cartesien [ [] ] [ [] ]|};
        };
        {
          entree = ([ [ Var "p" ] ], [ [] ]);
          attendu = [ [ Var "p" ] ];
          desc = {| produit_cartesien [ [ Var "p" ] ] [ [] ]|};
        };
        {
          entree = ([ [] ], [ [ Var "p" ] ]);
          attendu = [ [ Var "p" ] ];
          desc = {| produit_cartesien [ [] ] [ [ Var "p" ] ]|};
        };
        {
          entree = ([ [ Var "p" ] ], [ [ Var "q" ] ]);
          attendu = [ [ Var "p"; Var "q" ] ];
          desc = {| produit_cartesien [ [ Var "p" ] ] [ [ Var "q" ] ]|};
        };
        {
          entree = ([ [ Var "p"; Var "q" ] ], [ [ Var "r" ] ]);
          attendu = [ [ Var "p"; Var "q"; Var "r" ] ];
          desc = {| produit_cartesien [ [ Var "p"; Var "q" ] ] [ [ Var "r" ] ]|};
        };
        {
          entree = ([ [ Var "a" ] ], [ [ Var "b" ]; [ Var "c" ] ]);
          attendu = [ [ Var "a"; Var "b" ]; [ Var "a"; Var "c" ] ];
          desc =
            {| produit_cartesien [ [ Var "a" ] ] [ [ Var "b" ]; [ Var "c" ] ]|};
        };
        {
          entree = ([ [ Var "a" ]; [ Var "b" ] ], [ [ Var "c" ] ]);
          attendu = [ [ Var "a"; Var "c" ]; [ Var "b"; Var "c" ] ];
          desc =
            {| produit_cartesien [ [ Var "a" ]; [ Var "b" ] ] [ [ Var "c" ] ]|};
        };
        {
          entree = ([ [ Var "a" ]; [ Var "b" ] ], [ [ Var "c" ]; [ Var "d" ] ]);
          attendu =
            [
              [ Var "a"; Var "c" ];
              [ Var "a"; Var "d" ];
              [ Var "b"; Var "c" ];
              [ Var "b"; Var "d" ];
            ];
          desc =
            {| produit_cartesien [ [ Var "a" ]; [ Var "b" ] ] [ [ Var "c" ]; [ Var "d" ] ]|};
        };
      ];
    cas_exception = None;
  }

(* -------------------------------------------------------------------------- *)

(** Jeu de tests pour [paires]. *)
let jeu_paires () :
    (forme_clausale, ((clause * clause) * forme_clausale) list) jeu_tests =
  {
    comparer = (fun lst res -> egal_paires (paires lst) res);
    cas =
      [
        { entree = []; attendu = []; desc = {| paires []|} };
        {
          entree = [ [ Var "a" ] ];
          attendu = [];
          desc = {| paires [ [ Var "a" ] ]|};
        };
        {
          entree = [ [ Var "a" ]; [ Var "b" ] ];
          attendu = [ (([ Var "a" ], [ Var "b" ]), []) ];
          desc = {| paires [ [ Var "a" ]; [ Var "b" ] ]|};
        };
        {
          entree = [ [ Var "a" ]; [ Var "b" ]; [ Var "c" ] ];
          attendu =
            [
              (([ Var "a" ], [ Var "b" ]), [ [ Var "c" ] ]);
              (([ Var "a" ], [ Var "c" ]), [ [ Var "b" ] ]);
              (([ Var "b" ], [ Var "c" ]), [ [ Var "a" ] ]);
            ];
          desc = {| paires [ [ Var "a" ]; [ Var "b" ]; [ Var "c" ] ]|};
        };
        {
          entree = [ [ Var "a" ]; [ Var "b" ]; [ Var "c" ]; [ Var "d" ] ];
          attendu =
            [
              (([ Var "a" ], [ Var "b" ]), [ [ Var "c" ]; [ Var "d" ] ]);
              (([ Var "a" ], [ Var "c" ]), [ [ Var "b" ]; [ Var "d" ] ]);
              (([ Var "a" ], [ Var "d" ]), [ [ Var "b" ]; [ Var "c" ] ]);
              (([ Var "b" ], [ Var "c" ]), [ [ Var "a" ]; [ Var "d" ] ]);
              (([ Var "b" ], [ Var "d" ]), [ [ Var "a" ]; [ Var "c" ] ]);
              (([ Var "c" ], [ Var "d" ]), [ [ Var "a" ]; [ Var "b" ] ]);
            ];
          desc =
            {| paires [ [ Var "a" ]; [ Var "b" ]; [ Var "c" ]; [ Var "d" ] ]|};
        };
        {
          entree =
            [ [ Non (Var "a"); Var "b" ]; [ Non (Var "b") ]; [ Var "a" ] ];
          attendu =
            [
              (([ Non (Var "a"); Var "b" ], [ Non (Var "b") ]), [ [ Var "a" ] ]);
              (([ Non (Var "a"); Var "b" ], [ Var "a" ]), [ [ Non (Var "b") ] ]);
              (([ Non (Var "b") ], [ Var "a" ]), [ [ Non (Var "a"); Var "b" ] ]);
            ];
          desc =
            {| paires [ [ Non (Var "a"); Var "b" ]; [ Non (Var "b") ]; [ Var "a" ] ]|};
        };
      ];
    cas_exception = None;
  }

(* -------------------------------------------------------------------------- *)

(** Jeu de tests pour [enonce_vers_proposition]. *)
let jeu_enonce_vers_proposition () : (enonce_probleme, proposition) jeu_tests =
  {
    comparer = (fun enonce res -> enonce_vers_proposition enonce = res);
    cas =
      [
        {
          entree = ([], Var "a");
          attendu = Non (Var "a");
          desc = {| enonce_vers_proposition ([], Var "a")|};
        };
        {
          entree = ([], Ou (Var "a", Non (Var "a")));
          attendu = Non (Ou (Var "a", Non (Var "a")));
          desc = {| enonce_vers_proposition ([], Ou (Var "a", Non (Var "a")))|};
        };
        {
          entree = ([ Var "a" ], Var "a");
          attendu = Et (Var "a", Non (Var "a"));
          desc = {| enonce_vers_proposition ([ Var "a" ], Var "a")|};
        };
        {
          entree = ([ Imp (Var "a", Var "b") ], Var "b");
          attendu = Et (Imp (Var "a", Var "b"), Non (Var "b"));
          desc =
            {| enonce_vers_proposition ([ Imp (Var "a", Var "b") ], Var "b")|};
        };
        {
          entree = ([ Imp (Var "a", Var "b"); Non (Var "b") ], Non (Var "a"));
          attendu =
            Et (Imp (Var "a", Var "b"), Et (Non (Var "b"), Non (Non (Var "a"))));
          desc =
            {| enonce_vers_proposition ([ Imp (Var "a", Var "b"); Non (Var "b") ], 
            Non (Var "a"))|};
        };
        {
          entree = ([ Et (Var "a", Var "b") ], Var "a");
          attendu = Et (Et (Var "a", Var "b"), Non (Var "a"));
          desc =
            {| enonce_vers_proposition ([ Et (Var "a", Var "b") ], Var "a")|};
        };
      ];
    cas_exception = None;
  }

(* -------------------------------------------------------------------------- *)

(** Jeu de tests pour [mise_en_forme_clausale]. *)
let jeu_mise_en_forme_clausale () : (proposition, forme_clausale) jeu_tests =
  {
    comparer = (fun p res -> egal_fc (mise_en_forme_clausale p) res);
    cas =
      [
        { entree = Vrai; attendu = []; desc = {| mise_en_forme_clausale Vrai|} };
        {
          entree = Faux;
          attendu = [ [] ];
          desc = {| mise_en_forme_clausale Faux|};
        };
        {
          entree = Var "a";
          attendu = [ [ Var "a" ] ];
          desc = {| mise_en_forme_clausale (Var "a")|};
        };
        {
          entree = Non (Var "a");
          attendu = [ [ Non (Var "a") ] ];
          desc = {| mise_en_forme_clausale (Non (Var "a"))|};
        };
        {
          entree = Non Vrai;
          attendu = [ [] ];
          desc = {| mise_en_forme_clausale (Non Vrai)|};
        };
        {
          entree = Non Faux;
          attendu = [];
          desc = {| mise_en_forme_clausale (Non Faux)|};
        };
        {
          entree = Non (Non (Var "a"));
          attendu = [ [ Var "a" ] ];
          desc = {| mise_en_forme_clausale (Non (Non (Var "a")))|};
        };
        {
          entree = Et (Var "a", Var "b");
          attendu = [ [ Var "a" ]; [ Var "b" ] ];
          desc = {| mise_en_forme_clausale (Et (Var "a", Var "b"))|};
        };
        {
          entree = Ou (Var "a", Var "b");
          attendu = [ [ Var "a"; Var "b" ] ];
          desc = {| mise_en_forme_clausale (Ou (Var "a", Var "b"))|};
        };
        {
          entree = Imp (Var "a", Var "b");
          attendu = [ [ Non (Var "a"); Var "b" ] ];
          desc = {| mise_en_forme_clausale (Imp (Var "a", Var "b"))|};
        };
        {
          entree = Equ (Var "a", Var "b");
          attendu = [ [ Non (Var "a"); Var "b" ]; [ Non (Var "b"); Var "a" ] ];
          desc = {| mise_en_forme_clausale (Equ (Var "a", Var "b"))|};
        };
        {
          entree = Non (Et (Var "a", Var "b"));
          attendu = [ [ Non (Var "a"); Non (Var "b") ] ];
          desc = {| mise_en_forme_clausale (Non (Et (Var "a", Var "b")))|};
        };
        {
          entree = Non (Ou (Var "a", Var "b"));
          attendu = [ [ Non (Var "a") ]; [ Non (Var "b") ] ];
          desc = {| mise_en_forme_clausale (Non (Ou (Var "a", Var "b")))|};
        };
        {
          entree = Non (Imp (Var "a", Var "b"));
          attendu = [ [ Var "a" ]; [ Non (Var "b") ] ];
          desc = {| mise_en_forme_clausale (Non (Imp (Var "a", Var "b")))|};
        };
        {
          entree = Et (Ou (Var "a", Var "b"), Non (Et (Var "a", Non (Var "b"))));
          attendu = [ [ Var "a"; Var "b" ]; [ Non (Var "a"); Var "b" ] ];
          desc =
            {| mise_en_forme_clausale (Et (Ou (Var "a", Var "b"), Non (Et (Var "a", Non (Var "b")))))|};
        };
      ];
    cas_exception = None;
  }

(* -------------------------------------------------------------------------- *)

(** Jeu de tests pour [resolutions]. *)
let jeu_resolutions () : (clause * clause, forme_clausale) jeu_tests =
  {
    comparer = (fun (c1, c2) res -> egal_fc (resolutions c1 c2) res);
    cas =
      [
        {
          entree = ([ Var "a" ], [ Var "b" ]);
          attendu = [];
          desc = {| resolutions [ Var "a" ] [ Var "b" ]|};
        };
        {
          entree = ([ Non (Var "a") ], [ Non (Var "b") ]);
          attendu = [];
          desc = {| resolutions [ Non (Var "a") ] [ Non (Var "b") ]|};
        };
        {
          entree = ([ Var "a" ], [ Non (Var "a") ]);
          attendu = [ [] ];
          desc = {| resolutions [ Var "a" ] [ Non (Var "a") ]|};
        };
        {
          entree = ([ Non (Var "b") ], [ Var "b" ]);
          attendu = [ [] ];
          desc = {| resolutions [ Non (Var "b") ] [ Var "b" ]|};
        };
        {
          entree = ([ Non (Var "a"); Var "b" ], [ Var "a" ]);
          attendu = [ [ Var "b" ] ];
          desc = {| resolutions [ Non (Var "a"); Var "b" ] [ Var "a" ]|};
        };
        {
          entree = ([ Non (Var "a"); Var "b" ], [ Non (Var "b") ]);
          attendu = [ [ Non (Var "a") ] ];
          desc = {| resolutions [ Non (Var "a"); Var "b" ] [ Non (Var "b") ]|};
        };
        {
          entree = ([ Var "a"; Var "b"; Var "c" ], [ Non (Var "b"); Var "d" ]);
          attendu = [ [ Var "a"; Var "c"; Var "d" ] ];
          desc =
            {| resolutions [ Var "a"; Var "b"; Var "c" ] [ Non (Var "b"); Var "d" ]|};
        };
        {
          entree = ([ Non (Var "a"); Var "b" ], [ Non (Var "b"); Var "a" ]);
          attendu = [ [ Var "b"; Non (Var "b") ]; [ Non (Var "a"); Var "a" ] ];
          desc =
            {| resolutions [ Non (Var "a"); Var "b" ] [ Non (Var "b"); Var "a" ]|};
        };
        {
          entree =
            ( [ Var "p"; Non (Var "q"); Var "r"; Non (Var "s") ],
              [ Var "r"; Non (Var "p"); Var "q"; Var "t" ] );
          attendu =
            [
              [ Non (Var "q"); Var "r"; Non (Var "s"); Var "q"; Var "t" ];
              [ Var "p"; Var "r"; Non (Var "s"); Non (Var "p"); Var "t" ];
            ];
          desc =
            {| resolutions [ Var "p"; Non (Var "q"); Var "r"; Non (Var "s") ] [ Var "r"; Non (Var "p"); Var "q"; Var "t" ]|};
        };
      ];
    cas_exception = None;
  }

(* -------------------------------------------------------------------------- *)

(** Jeu de tests pour [decision]. *)
let jeu_decision () : (proposition, bool) jeu_tests =
  {
    comparer = (fun p res -> decision p = res);
    cas =
      [
        {
          entree = enonce_vers_proposition (analyser_chaine "a ou non a");
          attendu = true;
          desc = {| decision (... "a ou non a")|};
        };
        {
          entree =
            enonce_vers_proposition (analyser_chaine "(a => b) ou (b => a)");
          attendu = true;
          desc = {| decision (... "(a => b) ou (b => a)")|};
        };
        {
          entree = enonce_vers_proposition (analyser_chaine "; p => p");
          attendu = true;
          desc = {| decision (... "; p => p")|};
        };
        {
          entree = enonce_vers_proposition (analyser_chaine "a => b; a; b");
          attendu = true;
          desc = {| decision (... "a => b; a; b")|};
        };
        {
          entree =
            enonce_vers_proposition (analyser_chaine "a => b; non b; non a");
          attendu = true;
          desc = {| decision (... "a => b; non b; non a")|};
        };
        {
          entree =
            enonce_vers_proposition (analyser_chaine "a => b; b => c; a => c");
          attendu = true;
          desc = {| decision (... "a => b; b => c; a => c")|};
        };
        {
          entree =
            enonce_vers_proposition
              (analyser_chaine "p <=> q; q <=> r; p <=> r");
          attendu = true;
          desc = {| decision (... "p <=> q; q <=> r; p <=> r")|};
        };
        {
          entree =
            enonce_vers_proposition
              (analyser_chaine "n => p; p => (non f); (non n) => (non f); non f");
          attendu = true;
          desc =
            {| decision (... "n => p; p => (non f); (non n) => (non f); non f")|};
        };
        {
          entree = enonce_vers_proposition (analyser_chaine "a => b; non b; a");
          attendu = false;
          desc = {| decision (... "a => b; non b; a")|};
        };
      ];
    cas_exception = None;
  }

(* ========================================================================== *)
(* SECTION 3: Testeur générique                                               *)
(* ========================================================================== *)

type etat_test = { commentaires : string list; exception_levee : bool }

let etat_initial = { commentaires = []; exception_levee = false }

let executer_un_test etat f { entree; attendu; desc } =
  match f entree attendu with
  | true -> etat
  | false ->
      {
        etat with
        commentaires = etat.commentaires @ [ desc ^ " --> incorrect!" ];
      }
  | exception Non_Implante _ -> raise (Non_Implante "")
  | exception e ->
      {
        commentaires =
          etat.commentaires
          @ [ desc ^ " - Exception: «" ^ Printexc.to_string e ^ "»" ];
        exception_levee = true;
      }

let executer_tests_exception etat f' jeu_donnees_exception =
  List.fold_left
    (fun et (p, cas_test) ->
      try
        ignore (f' p);
        {
          et with
          commentaires =
            et.commentaires
            @ [ cas_test ^ " --> incorrect! Devrait soulever exception!" ];
        }
      with
      | Failure _ -> et
      | e ->
          {
            commentaires =
              et.commentaires
              @ [
                  cas_test ^ " --> Devrait soulever Failure, pas "
                  ^ Printexc.to_string e;
                ];
            exception_levee = true;
          })
    etat jeu_donnees_exception

let executer_jeu_tests nom jeu_thunk =
  try
    let jeu = jeu_thunk () in
    let etat =
      try
        List.fold_left
          (fun et test -> executer_un_test et jeu.comparer test)
          etat_initial jeu.cas
      with Non_Implante _ ->
        { etat_initial with commentaires = [ "Fonction non implémentée!" ] }
    in
    let non_implante =
      List.exists (fun c -> c = "Fonction non implémentée!") etat.commentaires
    in
    if non_implante then (nom, etat.commentaires, true, etat.exception_levee)
    else
      let etat_final =
        match jeu.cas_exception with
        | None -> etat
        | Some (f', jeu_donnees_exception) ->
            executer_tests_exception etat f' jeu_donnees_exception
      in
      (nom, etat_final.commentaires, false, etat_final.exception_levee)
  with
  | Non_Implante _ -> (nom, [ "Fonction non implémentée!" ], true, false)
  | e -> (nom, [ "Exception: « " ^ Printexc.to_string e ^ " »" ], false, true)

(* ========================================================================== *)
(* SECTION 4: Exécution des tests et affichage des résultats                  *)
(* ========================================================================== *)

type resultat_test = string * string list * bool * bool

let tests () : resultat_test list =
  [
    executer_jeu_tests "produit_cartesien" jeu_produit_cartesien;
    executer_jeu_tests "paires" jeu_paires;
    executer_jeu_tests "enonce_vers_proposition" jeu_enonce_vers_proposition;
    executer_jeu_tests "mise_en_forme_clausale" jeu_mise_en_forme_clausale;
    executer_jeu_tests "resolutions" jeu_resolutions;
    executer_jeu_tests "decision" jeu_decision;
  ]

let corrige () =
  print_endline "Resultats:";
  print_endline "----------\n";
  List.iter
    (fun (nom_f, commentaires, _, _) ->
      if commentaires = [] then Printf.printf "%s : OK\n" nom_f
      else (
        Printf.printf "%s :\n" nom_f;
        List.iter (fun c -> print_endline ("\t" ^ c)) commentaires))
    (tests ());
  print_newline ()

let _ = corrige ()
