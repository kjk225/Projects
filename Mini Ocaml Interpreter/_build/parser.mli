type token =
  | ASSIGN
  | MATCH
  | WITH
  | PIPE
  | FALSE
  | TRUE
  | IF
  | THEN
  | ELSE
  | PLUS
  | MINUS
  | MULT
  | CONCAT
  | LET
  | REC
  | IN
  | GT
  | LT
  | LTQ
  | GTQ
  | EQ
  | NEQ
  | AND
  | COMMA
  | VAR of (string)
  | CONSTR of (string)
  | STRING of (string)
  | INT of (string)
  | LPAREN
  | RPAREN
  | ARROW
  | FUN
  | UNIT
  | EOF
  | TYPE
  | OF
  | TVAR of (string)
  | TUNIT
  | TINT
  | TBOOL
  | TSTRING
  | TCONS

val expr :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.expr
val typ :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> TypedAst.typ
val variant_spec :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> TypedAst.variant_spec
val tvar_list :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> string list
val constr_list :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> (string * TypedAst.typ) list
