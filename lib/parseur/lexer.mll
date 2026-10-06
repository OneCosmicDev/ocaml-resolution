{
  open Parser

  exception Erreur_lexicale of string
}

let lettre = ['a'-'z' 'A'-'Z']
let chiffre = ['0'-'9']
let ident = lettre (lettre | chiffre | '_')*
let blanc = [' ' '\t' '\n' '\r']

rule token = parse
  | blanc+        { token lexbuf }
  | "(*"          { commentaire lexbuf; token lexbuf }
  | "("           { LPAREN }
  | ")"           { RPAREN }
  | ";"           { SEMICOLON }
  | "<=>"         { EQU }
  | "=>"          { IMP }
  | ['v' 'V']['r' 'R']['a' 'A']['i' 'I']
                  { VRAI }
  | ['f' 'F']['a' 'A']['u' 'U']['x' 'X']
                  { FAUX }
  | ['n' 'N']['o' 'O']['n' 'N']
                  { NON }
  | ['e' 'E']['t' 'T']
                  { ET }
  | ['o' 'O']['u' 'U']
                  { OU }
  | ident as s    { IDENT (String.lowercase_ascii s) }
  | eof           { EOF }
  | _ as c        { raise (Erreur_lexicale (Printf.sprintf "Caractère inattendu: '%c'" c)) }

and commentaire = parse
  | "*)"          { () }
  | eof           { raise (Erreur_lexicale "Commentaire non fermé") }
  | _             { commentaire lexbuf }
