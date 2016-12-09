open Ast
open TypedAst
open Format

type equation = Eq of typ * typ

(******************************************************************************)
(** type substitution *********************************************************)
(******************************************************************************)

(**
 * These are useful functions for applying a substitution of a type for a type
 * variable
 *)

(** A substitution of a type for a type variable *)
type substitution = talpha * typ

(** apply a type substitution to a type *)
let rec subst_typ ((x,t'):substitution) (t:typ) =
  match t with
  | TAlpha y
      -> if y = x then t' else TAlpha y
  | TUnit | TInt | TBool | TString
      -> t
  | TArrow (t1,t2)
      -> TArrow (subst_typ (x,t') t1, subst_typ (x,t') t2)
  | TStar (t1,t2)
      -> TStar (subst_typ (x,t') t1, subst_typ (x,t') t2)
  | TVariant (ts, name)
      -> TVariant (List.map (subst_typ (x,t')) ts, name)

(** apply a type substitution to a list of equations *)
let subst_eqn (s : substitution) (eqns : equation list) : equation list =
  List.map (fun (Eq (t1,t2)) -> Eq(subst_typ s t1, subst_typ s t2)) eqns

(** apply a type substitution to an annotated expression
    we deliberately violate the 80-column restriction here to make the
    parallelism in the definition clearer, hence easier to read *)
let rec subst_expr (s : substitution) (e : annotated_expr) : annotated_expr =
  match e with
  | AVar      (t,x)            -> AVar      (subst_typ s t, x)
  | AApp      (t,e1,e2)        -> AApp      (subst_typ s t, subst_expr s e1, subst_expr s e2)
  | AFun      (t,(x,tx),e)     -> AFun      (subst_typ s t, (x, subst_typ s tx), subst_expr s e)
  | ALet      (t,(x,tx),e1,e2) -> ALet      (subst_typ s t, (x, subst_typ s tx), subst_expr s e1, subst_expr s e2)
  | ALetRec   (t,(x,tx),e1,e2) -> ALetRec   (subst_typ s t, (x, subst_typ s tx), subst_expr s e1, subst_expr s e2)
  | AUnit     (t)              -> AUnit     (subst_typ s t)
  | AInt      (t,n)            -> AInt      (subst_typ s t, n)
  | ABool     (t,b)            -> ABool     (subst_typ s t, b)
  | AString   (t,k)            -> AString   (subst_typ s t, k)
  | AVariant  (t,c,e)          -> AVariant  (subst_typ s t, c, subst_expr s e)
  | APair     (t,e1,e2)        -> APair     (subst_typ s t, subst_expr s e1, subst_expr s e2)
  | ABinOp    (t,op,e1,e2)     -> ABinOp    (subst_typ s t, op, subst_expr s e1, subst_expr s e2)
  | AIf       (t,e1,e2,e3)     -> AIf       (subst_typ s t, subst_expr s e1, subst_expr s e2, subst_expr s e3)
  | AMatch    (t,e,ps)         -> AMatch    (subst_typ s t, subst_expr s e, List.map (subst_case s) ps)
and subst_case s (p,e) = subst_pat s p, subst_expr s e
and subst_pat  s = function
  | APUnit    (t)              -> APUnit    (subst_typ s t)
  | APInt     (t,n)            -> APInt     (subst_typ s t, n)
  | APBool    (t,b)            -> APBool    (subst_typ s t, b)
  | APString  (t,k)            -> APString  (subst_typ s t, k)
  | APVar     (t,x)            -> APVar     (subst_typ s t, x)
  | APVariant (t,c,p)          -> APVariant (subst_typ s t, c, subst_pat s p)
  | APPair    (t,p1,p2)        -> APPair    (subst_typ s t, subst_pat s p1, subst_pat s p2)

(******************************************************************************)
(** helper functions **********************************************************)
(******************************************************************************)

(* you may find it helpful to implement these or other helper
 * functions, but they are not required.  Feel free to implement them if you
 * need them, change their types or arguments, delete them, whatever.
 *)
 (* Exceptions *)
 (* When collecting expressions and occurences of a variable do not match *)
 exception VTM (*Variable Type Mismatch*)
 exception VNF (*Variable Not Found*)
 exception PatternFail of string

(* Find if a variable is bound in the given dictionary *)
let member k d = List.exists (fun (mem, _) -> mem = k) d

(* Returns the binding for a variable in a given dictionary
 * Ensures that the variable k is in the dictionary *)
let rec get_member k d =
match d with
| [] -> raise VNF
| (a,b)::t -> if a=k then b else get_member k t

(** Format a list of equations for printing. *)
let rec print_helper (eqn: typ) : unit =
   match eqn with
   | TUnit -> print_string "Type Unit\n";
   | TInt -> print_string "Type Int\n";
   | TString -> print_string "Type String\n";
   | TBool -> print_string "Type Bool\n";
   | TAlpha(t) ->
      print_string "Type Alpha ";
      print_string t;
      print_string "\n";
   | TArrow(a,b) ->
      let () = print_helper a in
      print_string " -> ";
      print_helper b;
      print_string "\n";
   | TStar(a,b) ->
      let () = print_helper a in
      print_string " * ";
      print_helper b;
      print_string "\n";
   | TVariant(a,b) ->
      print_string "---- Start of Variant ----\nVariant Type: ";
      print_string "\n";
      print_string b;
      print_string "\n";
      let rec inside_printer my_type =
         match my_type with
         | [] ->
            print_string "\n";
            print_string "---- End of Variant ----\n"
         | h::t ->
            let () = print_helper h in
            print_string "\n";
            inside_printer t
      in
      inside_printer a

let rec format_eqns (f : Format.formatter) (eqns : equation list) : unit =
   failwith "Unimplemented"
  (* see the comment in Eval.format_value for guidance implementing hints *)
  (* You will probably want to call Format.fprint f f <format string> <args>.
   *
   * Format.fprintf f <format string> has a different type depeding on the format
   * string. For example, Format.fprintf f "%s" has type string -> unit, while
   * Format.fprintf f "%i" has type int -> unit.
   *
   * Format.fprintf f "%a" is also useful. It has type
   *   (Format.formatter -> 'a -> unit) -> 'a -> unit
   * which is useful for recursively formatting values.
   *
   * Format strings can contain multiple flags and also other things to be
   * printed. For example (Format.fprintf f "result: %i %s") has type
   * int -> string -> unit, so you can write
   *
   *  Format.fprintf f "result: %i %s" 3 "blind mice"
   *
   * to output "result: 3 blind mice"
   *
   * See the documentation of the OCaml Printf module for the list of % flags,
   * and see the printer.ml for some (complicated) examples. Printer, format_type is
   * a nice example.
   *)
   (* match eqns with
   | [] -> print_string "-- Finished Equation List --";
   | Eq(a,b)::t ->
      print_string "( ";
      print_helper a;
      print_string " , ";
      print_helper b;
      print_string " )";
      format_eqns f t *)


(** use format_eqns to print a value to the console *)
let print_eqns = format_eqns std_formatter

(** use format_value to convert a value to a string *)
let string_of_eqns  = Printer.make_string_of format_eqns

(** generate an unused type variable *)
let next_var = ref 0
let newvar () : typ =
   next_var := 1 + !next_var;
   TAlpha (Format.sprintf "tt%02i" !next_var)

let argtype (t:typ) =
   match t with
   | TArrow (t1,t2) -> t1
   | other_type -> other_type


(* return the constraints for a binary operator *)
let collect_binop (t:typ) (op:operator) (tl:typ) (tr:typ) : equation list =
  match op with
  | Plus | Minus | Times ->
     Eq(tl,tr)::Eq(tl,t)::Eq(tr,t)::Eq(tl,TInt)::Eq(tr,TInt)::Eq(t,TInt)::[]
  | Gt | Lt | Eq | GtEq | LtEq | NotEq  ->
     Eq(tl,tr)::Eq(TBool,t)::[]
  | Concat ->
     Eq(tl,tr)::Eq(tl,t)::Eq(tr,t)::Eq(tl,TString)::Eq(tr,TString)::Eq(t,TString)::[]

(* Looks through a variant_spec list to return info on a variant *)
let rec variant_collect specs e =
match specs with
| [] -> raise VNF
| h::t ->
   if (List.mem_assoc e (h.constructors))
   then
   (* Returning the typ of the constructor we matched on *)
      (h.vars,h.name, (List.assoc e (h.constructors)))
   else
      variant_collect t e

(** return the constraints for an expr
  * vars refers to a data structure that stores the types of each of the variables
  * that have been defined.
  * It is completely your decision what type of data structure you want to use for vars
  *)
let rec collect_expr (specs:variant_spec list) vars (e : annotated_expr)
                     : equation list =
   match e with
   | AVar(t,a) ->
      if member a vars
      then
         let pair = get_member a vars in
            Eq(t,pair)::[]
      else
         []
   | AApp(t,e1,e2) ->
      let e1e = collect_expr specs vars e1 in
      let e2e = collect_expr specs vars e2 in
      Eq(typeof e1, TArrow(typeof e2, t))::[]@e1e@e2e
   | AFun(t,(a,b),e1) ->
      (* fun x -> 0 | 'a -> int | TArrow() & Recursive call *)
      let nVar = AVar(b,a) in
      let new_vars = (a,b)::vars in
      let eVar = collect_expr specs vars nVar in
      let e1e = collect_expr specs new_vars e1 in
      Eq(t, TArrow(b,typeof e1))::[]@e1e@eVar
   | ALet(t,(a,b),e1,e2) ->
      let e1e = collect_expr specs vars e1 in
      let e2e = collect_expr specs ((a,b)::vars) e2 in
      Eq(t, typeof e2)::Eq(b, typeof e1)::[]@e1e@e2e
   | ALetRec(t,(a,b),e1,e2) ->
      let e1e = collect_expr specs ((a,b)::vars) e1 in
      let e2e = collect_expr specs ((a,b)::vars) e2 in
      Eq(t, typeof e2)::Eq(b, typeof e1)::[]@e1e@e2e
   | AUnit(t) -> Eq(t,TUnit)::[]
   | AInt(t,_) -> Eq(t, TInt)::[]
   | AString(t,_) -> Eq(t,TString)::[]
   | ABool(t,_) -> Eq(t, TBool)::[]
   | AVariant(t,a,e1) ->
      let e1e = collect_expr specs vars e1 in
      let (vars,names,constructors) = variant_collect specs a in
      let sub_all_vars = List.map (fun x -> (x, newvar ())) vars in
      let tae = (List.fold_right (fun x acc -> (subst_typ x acc)) sub_all_vars constructors) in
      (Eq (t, TVariant((List.map snd sub_all_vars), names)))::[Eq (tae, typeof e1)]@e1e
   | APair(t,e1,e2) ->
   (* Tstar of e1 e2 has type t *)
      let e1e = collect_expr specs vars e1 in
      let e2e = collect_expr specs vars e2 in
      Eq(t, TStar(typeof e1, typeof e2))::[]@e1e@e2e
   | ABinOp(t,op,e1,e2) ->
      let e1e = collect_expr specs vars e1 in
      let e2e = collect_expr specs vars e2 in
      let coll_bin = collect_binop t op (typeof e1) (typeof e2) in
      coll_bin @ e1e @ e2e
   | AIf(t,e1,e2,e3) ->
   (* recursively call collect_expr for e1 e2 e3 and concat all the lists *)
      let e1e = collect_expr specs vars e1 in
      let e2e = collect_expr specs vars e2 in
      let e3e = collect_expr specs vars e3 in
      Eq(TBool, typeof e1)::Eq(typeof e2, typeof e3)::Eq(t, typeof e2)::Eq(t, typeof e3)::[]@e1e@e2e@e3e
  | AMatch (t, e1 , (p,e2)::tail ) ->
      let collect_patterns = collect_pat specs p in
      let cnstr = fst(collect_patterns) in
      let vals = snd(collect_patterns) in
      let e1e = collect_expr specs vars e1 in
      let e2e = collect_expr specs (vals@vars) e2 in
      let recur = collect_expr specs vars (AMatch(t,e1,tail)) in
      Eq(t, typeof e2)::[]@e1e@e2e@recur@cnstr
  | _ -> []

(** return the constraints for a match cases
  * tconst refers to the type of the parameters of the specific constructors
  * tvariant refers to the type of the variant as a whole
  *)
and collect_case specs vs tconst tvariant ((p:annotated_pattern),(e:annotated_expr)) =
  failwith "unimplemented"

(** return the constraints and variables for a pattern *)
and collect_pat specs (p:annotated_pattern) =
  match p with
  | APUnit(t)-> (Eq (t, TUnit)::[], [])
  | APInt(t, n)-> (Eq (t, TInt)::[], [])
  | APBool(t, b)-> (Eq (t, TBool)::[], [])
  | APString(t, s)-> (Eq (t, TString)::[], [])
  | APVar(t, x)-> ([] , [(x, t)] )
  | APPair(t1, p1, p2) ->
     let p1p = collect_pat specs p1 in
     let p2p = collect_pat specs p2 in
     (Eq(t1, TStar(typeof_pat p1, typeof_pat p2))::[]@(fst(p1p))@(fst(p2p)),(snd(p1p))@(snd(p2p)))
  | APVariant (t, c, ap) ->
     let p1p = collect_pat specs ap in
     let (vars,names,constructors) = variant_collect specs c in
     let sub_all_vars = List.map (fun x -> (x, newvar ())) vars in
     let tae = (List.fold_right (fun x acc -> (subst_typ x acc)) sub_all_vars constructors) in
     ((Eq (t, TVariant((List.map snd sub_all_vars), names)))::[Eq (tae, typeof_pat ap)]@(fst(p1p)),[]@(snd(p1p)))

(******************************************************************************)
(** constraint generation                                                    **)
(******************************************************************************)

(**
 * collect traverses an expression e and returns a list of equations that must
 * be satisfied for e to typecheck.
 *)
let collect specs e =
  collect_expr specs [] e

(******************************************************************************)
(** constraint solver (unification)                                          **)
(******************************************************************************)

let rec occurs_in x = function
  | TAlpha y
      -> x = y
  | TArrow (t1,t2) | TStar (t1,t2)
      -> occurs_in x t1 || occurs_in x t2
  | TVariant (ts,_)
      -> List.exists (occurs_in x) ts
  | TUnit | TInt | TBool | TString
      -> false

(**
 * unify solves a system of equations and returns a list of
 * definitions for the type variables.
 *)
let rec unify eqns = match eqns with
  | [] -> []

  | Eq (t1,t2)::tl when t1 = t2
     -> unify tl

  | Eq ((TAlpha x as t1), (t as t2))::tl
  | Eq ((t as t1), (TAlpha x as t2))::tl
     -> if occurs_in x t
        then failwith (Format.asprintf "circular type constraint %a = %a"
                                       Printer.format_type t1
                                       Printer.format_type t2)
        else (x,t)::(unify (subst_eqn (x,t) tl))

  | Eq (TArrow (t1,t1'), TArrow (t2,t2'))::tl
  | Eq (TStar  (t1,t1'), TStar  (t2,t2'))::tl
     -> unify ((Eq (t1,t2))::(Eq (t1',t2'))::tl)

  | Eq ((TVariant (t1s, n1) as t1), (TVariant (t2s, n2) as t2))::tl
     -> if n1 <> n2
        then failwith (Format.asprintf "can't unify %a and %a"
                                       Printer.format_type t1
                                       Printer.format_type t2)
        else unify ((List.map2 (fun t1 t2 -> Eq (t1,t2)) t1s t2s)
                    @ tl)

  | Eq (t1,t2)::tl
     -> failwith (Format.asprintf "can't unify %a and %a"
                                  Printer.format_type t1
                                  Printer.format_type t2)

(******************************************************************************)
(** inference                                                                **)
(******************************************************************************)

(**
 * rename the type variables so that the first is "a", the
 * second "b", and so on.  Example:
 *
 *  rename_vars ('t23 -> 't17 -> 't23 -> int)
 *  is          ('a   -> 'b   -> 'a   -> int)
 *)
let rec simplify e =
  let rec alpha_of_int i =
    let let_of_int i = String.make 1 (char_of_int (i - 1 + int_of_char 'a')) in
    if i <= 0 then "" else (alpha_of_int (i/26))^(let_of_int (i mod 26))
  in

  let next_var  = ref 0 in

  let newvar () =
    next_var := 1 + !next_var;
    TAlpha (alpha_of_int !next_var)
  in

  let rec subst vars = function
    | TAlpha x -> if List.mem_assoc x vars then vars else (x,newvar())::vars
    | TUnit | TInt | TBool | TString -> vars
    | TArrow (t1,t2) | TStar (t1,t2) -> let vars' = subst vars t1 in
                                        subst vars' t2
    | TVariant (ts,_) -> List.fold_left subst vars ts
  in

  subst [] e

(**
 * given an expression, return the type for that expression,
 * failing if it cannot be typed.
 *)
let infer defs e =
  let annotated = annotate e in
  let eqns      = collect defs annotated in
  let solution  = unify eqns in
  let newtype   = List.fold_left (fun e s -> subst_expr s e) annotated solution in
  let simplify  = simplify (typeof newtype) in
  List.fold_right subst_expr simplify newtype