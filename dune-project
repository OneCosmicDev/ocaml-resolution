(lang dune 3.17)

; Version du langage dune.
; - Le numéro 3.17 correspond à la version minimale de dune pour laquelle la  
;   syntaxe utilisée dans les fichiers «dune» dans ce projet sera correcte.
; - IMPORTANT: Cette directive DOIT être en première ligne (pas de commentaire 
;   avant).

(name tp1)

; Nom du projet.
; - Utilisé pour identifier le projet dans les messages d'erreur.
; - Requis pour générer la documentation (`dune build @doc`).

(using menhir 2.1)

; Active le support de Menhir (générateur de parseurs LR(1)).
; - Le numéro 2.1 est la version de l'extension dune pour Menhir, pas la version
;   de Menhir lui-même. 

; =============================================================================
; Fichier dune-project - Configuration globale du projet
; =============================================================================
; Ce fichier définit la configuration minimale du projet dune.
; IMPORTANT: La directive (lang ...) DOIT être en première ligne.
; Documentation: https://dune.readthedocs.io/en/stable/reference/dune-project.html
; =============================================================================
