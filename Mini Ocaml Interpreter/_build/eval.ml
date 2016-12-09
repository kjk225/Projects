open Ast

(******************************************************************************)
(** types (see .mli) **********************************************************)
(******************************************************************************)

type value =
  | VUnit | VInt of int | VBool of bool | VString of string
  | VClosure of var * expr * environment
  | VVariant of constructor * value
  | VPair of value * value
  | VError of string
and environment = (var * value ref) list

(******************************************************************************)
(** (optional) helper functions ***********************************************)
(******************************************************************************)

(** you may find it helpful to implement these or other helper
 * functions, but they are not required. Feel free to implement them if you
 * need them, change their types or arguments, delete them, whatever.
 *)

exception InvalidOperands of string
exception UnboundVariable of string
exception InvalidApplication of string
exception PatternFail of string

 (*
  * try to match a value against a pattern. If the match succeeds, return an
  * environment containing all of the bindings. If it fails, return None.
  *)
let rec find_match (p : pattern) (v : value) : environment option =
  match p,v with
  | PVar x, _ -> Some [(x, ref v)]
  | PUnit, VUnit -> Some []
  | PInt i1, VInt i2 when i1 = i2 -> Some []
  | PBool b1, VBool b2 when b1 = b2 -> Some []
  | PString s1, VString s2 when s1 = s2 ->  Some []
  | PVariant (cons1, patt1), VVariant (cons2, val1) when cons1 = cons2 -> 
                                                        find_match patt1 val1
  | PPair (patt1, patt2), VPair (val1, val2) -> 
                      (match find_match patt1 val1,  find_match patt2 val2 with 
                       |Some x, Some y -> Some (x @ y)
                       |Some x, None -> Some x
                       |None, Some y -> Some y
                       |None , None -> None)
  | _,_ -> None

let eval_operator (v1 : value) (op : operator) (v2 : value) : value =
  match v1,v2 with
  | VUnit, VUnit -> raise (InvalidOperands "You cannot operate on units")
  | VInt x , VInt y -> 
    (match op with
    | Plus-> VInt (x+y)
    | Minus -> VInt (x-y)
    | Times -> VInt (x*y)
    | Gt -> VBool (x>y)
    | Lt -> VBool (x<y)
    | Eq -> VBool (x=y)
    | GtEq -> VBool (x>=y)
    | LtEq -> VBool (x<=y)
    | NotEq -> VBool (x<>y)
    | _ -> raise 
          (InvalidOperands "This operation does not support type VInts"))

  | VBool x, VBool y ->
    (match op with
    | Gt -> VBool (x>y)
    | Lt -> VBool (x<y)
    | Eq -> VBool (x=y)
    | GtEq -> VBool (x>=y)
    | LtEq -> VBool (x<=y)
    | NotEq -> VBool (x<>y)
    | _ -> raise 
          (InvalidOperands "This operation does not support type VBool"))

  | VString x, VString y  -> 
    (match op with
    | Gt -> VBool (x>y)
    | Lt -> VBool (x<y)
    | Eq -> VBool (x=y)
    | GtEq -> VBool (x>=y)
    | LtEq -> VBool (x<=y)
    | NotEq -> VBool (x<>y)
    | Concat -> VString (x^y)
    | _ -> raise 
          (InvalidOperands "This operation does not support type VStrings"))
  | _,_ -> raise 
          (InvalidOperands "Expressions not of the same type or of invalid types")


let same_vtype (v1:value) (v2:value) : bool = 
    match v1, v2 with 
    | VUnit, VUnit -> true
    | VInt x , VInt y -> true
    | VBool p , VBool z -> true
    | VString w, VString r -> true
    | VClosure (var1, expr1, env1) , VClosure (var2, expr2, env2) -> true 
    | VVariant(cons1,val1) , VVariant(cons2,val2) -> true
    | VPair (val1, val2), VPair (val3, val4) -> true
    | _,_ -> raise (InvalidOperands "Operands do not have the same types")


let eval_var (env:environment) (v:var) : value =
  try(
    !(List.assoc v env)
  )
   with Not_found -> raise (UnboundVariable ("Unbound variable " ^ v))


(** Format a value for printing. *)
let rec format_value (f : Format.formatter) (v : value) : unit =
  failwith "unimplemented"

(** use format_value to print a value to the console *)
let print_value = Printer.make_printer format_value

(** use format_value to convert a value to a string *)
let string_of_value = Printer.make_string_of format_value

(******************************************************************************)
(** eval **********************************************************************)
(******************************************************************************)

let evaluate_sub eval env e =
try(
  match e with
  | Unit -> VUnit

  | Int i -> VInt i

  | Bool b -> VBool b

  | String s -> VString s

  | BinOp (opr, expr1,  expr2) ->
      let v1 = eval env expr1 in
      let v2 = eval env expr2 in
      eval_operator v1 opr v2

  | If (expr1, expr2, expr3) ->
      let t_or_f = eval env expr1 in
      (match t_or_f with
      | VBool true -> eval env expr2
      | VBool false -> eval env expr3 
      | _ -> raise 
            (InvalidOperands "An expression was expected of type VBool"))

  | Var v -> eval_var env v

  | Pair (expr1, expr2) ->
      let v1 = eval env expr1 in
      let v2 = eval env expr2 in
      VPair(v1, v2)

  | Variant (cons, expr1) -> VVariant (cons, (eval env expr1))

  | Let (vari, expr1, expr2) ->
      let v1 = eval env expr1 in
      eval ((vari, ref v1)::env) expr2

  | Fun (vari,  expr1) -> VClosure (vari, expr1, env)

  | App (expr1, expr2) ->
        let v1 = eval env expr1 in
        let v2 = eval env expr2 in
      (match v1 with
         | VClosure (fun_var,fun_expr,fun_env) -> 
                    eval ((fun_var, ref v2)::fun_env) fun_expr
         | _ -> raise (InvalidApplication "This is an Invalid Application"))

  | LetRec (vari, expr1, expr2) -> 
    let dummyv = ref (VString "Dummy Value") in 
    let new_env = ((vari, dummyv)::env) in 
    let v1 = eval new_env expr1 in 
    let update_env () = (dummyv := v1) in update_env (); eval new_env expr2
    
  | Match (expr1, patt_exp_list) -> 
    let v1 = eval env expr1 in
    let rec matcher list = 
    match list with
    | [] -> raise 
            (PatternFail "match expression doesn't contain a matching pattern")
    | (patt2, expr2)::tail -> 
                             match find_match patt2 v1 with
                            | None -> matcher tail
                            | Some bindings -> eval (bindings @ env) expr2 in

                            matcher patt_exp_list
)

with
| InvalidOperands x -> VError x
| UnboundVariable x -> VError x
| InvalidApplication x -> VError x
| PatternFail x -> VError x
| _ -> VError "Syntax Error"

let rec eval (env:environment) (e:expr) : value = evaluate_sub eval env e

