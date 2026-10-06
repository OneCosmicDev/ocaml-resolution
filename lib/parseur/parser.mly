%{
  open Tp_types
%}

%token VRAI FAUX NON ET OU IMP EQU
%token LPAREN RPAREN SEMICOLON
%token <string> IDENT
%token EOF

%start <Tp_types.enonce_probleme> enonce
%start <Tp_types.proposition> proposition_seule

%%

(* Énoncé: liste non vide de propositions séparées par ; *)
(* Le dernier élément est la conclusion, les précédents sont les hypothèses *)
(* Cas spécial: ";prop" signifie aucune hypothèse, juste une conclusion (tautologie) *)
enonce:
  | SEMICOLON p = prop_p EOF
    { ([], p) }
  | props = separated_nonempty_list(SEMICOLON, prop_p) EOF
    { match List.rev props with
      | [] -> assert false  (* impossible avec nonempty_list *)
      | concl :: hyps -> (List.rev hyps, concl) }

proposition_seule:
  | p = prop_p EOF { p }

(* P ::= A "<=>" P | A *)
prop_p:
  | a = prop_a EQU p = prop_p { Equ (a, p) }
  | a = prop_a { a }

(* A ::= B "=>" A | B *)
prop_a:
  | b = prop_b IMP a = prop_a { Imp (b, a) }
  | b = prop_b { b }

(* B ::= C "ou" B | C *)
prop_b:
  | c = prop_c OU b = prop_b { Ou (c, b) }
  | c = prop_c { c }

(* C ::= D "et" C | D *)
prop_c:
  | d = prop_d ET c = prop_c { Et (d, c) }
  | d = prop_d { d }

(* D ::= "non" E | E *)
prop_d:
  | NON e = prop_e { Non e }
  | e = prop_e { e }

(* E ::= "(" P ")" | "vrai" | "faux" | I *)
prop_e:
  | LPAREN p = prop_p RPAREN { p }
  | VRAI { Vrai }
  | FAUX { Faux }
  | id = IDENT { Var id }
