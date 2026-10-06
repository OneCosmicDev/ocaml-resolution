(** {1 Module Demo}

    Module de démonstration pour afficher la trace d'exécution de la résolution
    de problèmes logiques.

    @author IFT-3000 - Hiver 2026 *)

val executer_resolution : string -> unit
(** [executer_resolution entree] analyse et résout un énoncé logique, puis
    affiche la trace de résolution sur la sortie standard.

    @param entree chaîne contenant l'énoncé au format "H1; H2; ...; Hn; C"

    {b Exemple}:
    {[
      # executer_resolution "a => b; non b; non a";;
      Hypotheses (H):
              (a => b) et (non b)
      ...
    ]} *)

val executer_resolution_fichier : string -> unit
(** [executer_resolution_fichier nom_fichier] lit un énoncé depuis un fichier et
    exécute la résolution.

    @param nom_fichier chemin vers le fichier contenant l'énoncé *)
