open OUnit2
open Ast
open TypedAst
open Parse
open Eval
open Infer

let alpha_option =
  parse_variant_spec "type 'a option = Some of 'a | None of unit"

let alpha_option2 =
  parse_variant_spec "type 'a option = Some of 'a option | None of unit"
let writeup_example =
  parse_variant_spec "type 'a list = Cons of 'a * 'a list | Nil of unit"

let funky_option =
  parse_variant_spec "type ('a, 'b) abc = Funky of 'b * 'a"

let tests = "test suite" >::: [
  "eval_unit"  >::
    (fun _ -> assert_equal
      (VUnit)
      (eval [] (Unit)));

  "eval_int"  >::
    (fun _ -> assert_equal
      (VInt 3110)
      (eval [] (Int 3110)));

    "eval_boolt"  >::
    (fun _ -> assert_equal
      (VBool true)
      (eval [] (Bool true)));

    "eval_boolf"  >::
    (fun _ -> assert_equal
      (VBool false)
      (eval [] (Bool false)));

    "eval_string"  >::
    (fun _ -> assert_equal
      (VString "happy")
      (eval [] (String "happy")));

    "eval_binop +"  >::
    (fun _ -> assert_equal
      (VInt 4)
      (eval [] (BinOp (Plus, Int 2, Int 2))));

    "eval_binop -"  >::
    (fun _ -> assert_equal
      (VInt 3)
      (eval [] (BinOp (Minus, Int 5, Int 2))));

    "eval_binop *"  >::
    (fun _ -> assert_equal
      (VInt 6)
      (eval [] (BinOp (Times, Int 3, Int 2))));

    "eval_binop gt"  >::
    (fun _ -> assert_equal
      (VBool true)
      (eval [] (BinOp (Gt, Int 3, Int 2))));

    "eval_binop lt"  >::
    (fun _ -> assert_equal
      (VBool false)
      (eval [] (BinOp (Lt, Int 3, Int 2))));

    "eval_binop eq"  >::
    (fun _ -> assert_equal
      (VBool true)
      (eval [] (BinOp (Eq, Int 3, Int 3))));

     "eval_binop gteq"  >::
    (fun _ -> assert_equal
      (VBool false)
      (eval [] (BinOp (GtEq, Int 2, Int 3))));

    "eval_binop lteq"  >::
    (fun _ -> assert_equal
      (VBool true)
      (eval [] (BinOp (LtEq, Int 2, Int 3))));

    "eval_binop noteq"  >::
    (fun _ -> assert_equal
      (VBool true)
      (eval [] (BinOp (NotEq, String "hello", String "hi"))));

    "eval_pair"  >::
    (fun _ -> assert_equal
      (VPair (VInt 3, VString "happy"))
      (eval [] (Pair (Int 3, String "happy"))));

    "eval_Variant" >::
    (fun _ -> assert_equal
      (VVariant ("Cons", VString "happy"))
      (eval [] (Variant ("Cons", String "happy"))));

    "eval_if"   >::
    (fun _ -> assert_equal
      (VInt 15)
      (parse_expr "if false then 3 + 5 else 3 * 5" |> eval []));

    "eval_if2"   >::
    (fun _ -> assert_equal
      (VInt 3110)
      (parse_expr "if true then 3110 else (3+true) " |> eval []));

  "eval_7"  >::
    (fun _ -> assert_equal
      (VInt 4)
      (parse_expr "let x = 4 in x" |> eval []));

  "eval_6"  >::
    (fun _ -> assert_equal
      (VInt 10)
      (parse_expr "let rec sum_n = (fun n -> if n>0 then n + sum_n (n-1) else 0) in sum_n 4" |> eval []));

  "eval_4"  >::
    (fun _ -> assert_equal
      (VInt 8)
      (parse_expr "let x = 5 in let y = 3 in x + y" |> eval []));

  "eval_5"  >::
    (fun _ -> assert_equal
      (VClosure("x",BinOp(Plus, Int 3, Var "x"),[]))
      (parse_expr "fun x -> 3 + x" |> eval []));

    "eval_app"  >::
    (fun _ -> assert_equal
      (VInt 8)
      (parse_expr "(fun x -> 3 + x) 5" |> eval []));

    "eval_let"  >::
    (fun _ -> assert_equal
      (VInt 8)
      (parse_expr "let x = 5 in x + 3" |> eval []));

    "eval_letrec"  >::
    (fun _ -> assert_equal
      (VBool true)
      (parse_expr "let rec x = (fun y -> if y = 3 then true else x (y+1)) in x 0" |> eval []));

    "eval_match"  >::
    (fun _ -> assert_equal
      (VInt 3110)
      (parse_expr "match 7 with |6 -> 2110 |7 -> 3110 | _ -> 1110" |> eval []));

  "eval_2"  >::
    (fun _ -> assert_equal
      (VVariant ("Some",VInt 3))
      (parse_expr "match None () with | Some y -> Some y | None () -> Some 3" |> eval []));

  "eval_1"  >::
    (fun _ -> assert_equal
      (VClosure ("y", BinOp (Plus, BinOp (Minus, Int 12, Var "x"), Var "y"),[("x", {contents = VInt 10})]))
      (parse_expr "let z = (match 10 with | x -> (fun y -> 12 - x + y) | _ -> fun y -> y+2) in z" |> eval []));

  "infer_inc" >::
    (fun _ -> assert_equal
      (parse_type "int -> int")
      (parse_expr "fun x -> x + 1" |> infer [] |> typeof));

  "infer_inc" >::
    (fun _ -> assert_equal
      (parse_type "int -> int")
      (parse_expr "fun x -> 3 + x" |> infer [] |> typeof));

  "infer_app" >::
    (fun _ -> assert_equal
      (parse_type "int")
      (parse_expr "(fun x -> x + 2) 2" |> infer [] |> typeof));

  "infer_inc1" >::
    (fun _ -> assert_equal
      (parse_type "int -> int -> int")
      (parse_expr "fun x -> fun y -> 3 + x + y" |> infer [] |> typeof));

  "infer_if" >::
    (fun _ -> assert_equal
      (parse_type "int")
      (parse_expr "if false then 1 else 0" |> infer [] |> typeof));

  "infer_if2" >::
    (fun _ -> assert_equal
      (parse_type "int")
      (parse_expr "if false then 1+1 else 0+1" |> infer [] |> typeof));

  "infer_if3" >::
    (fun _ -> assert_equal
      (parse_type "'a -> int")
      (parse_expr "if false then fun x -> 0 else fun y -> 1" |> infer [] |> typeof));

  "infer_pair" >::
    (fun _ -> assert_equal
      (parse_type "int * int")
      (parse_expr "(4+1,4)" |> infer [] |> typeof));

   "infer_let" >::
    (fun _ -> assert_equal
      (parse_type "int")
      (parse_expr "let y = 1 in y + 1" |> infer [] |> typeof));

  "infer_variant" >::
    (fun _ -> assert_equal
      (parse_type "int option * string option")
      (parse_expr "(Some 1, Some \"where\")"
       |> infer [alpha_option]
       |> typeof));

 "infer_rec" >::
   (fun _ -> assert_equal
     (parse_type "int")
     (parse_expr "let rec sum_n = (fun n -> if n>0 then n + sum_n (n-1) else 0) in sum_n 4"
      |> infer []
      |> typeof));

"infer_fun" >::
  (fun _ -> assert_equal
    (parse_type "'a -> 'b")
    (parse_expr "fun x -> y"
     |> infer []
     |> typeof));

 "infer_variant2" >::
   (fun _ -> assert_equal
     (parse_type "int")
     (parse_expr "let x = Cons(1,Nil ()) in let y = Cons(true,Nil ()) in 42"
      |> infer [writeup_example]
      |> typeof));

  "infer_match" >::
    (fun _ -> assert_equal
      (parse_type "bool")
      (parse_expr "let x = 4 in match x with | 3 -> false | 4 -> true"
       |> infer []
       |> typeof));

 "infer_matchVariant" >::
   (fun _ -> assert_equal
     (parse_type "int")
     (parse_expr "match Nil() with |Nil(a) -> 0 |Cons(a,b) -> 1"
      |> infer [writeup_example]
      |> typeof));

  "infer_matchVariant2" >::
    (fun _ -> assert_equal
      (parse_type "int")
      (parse_expr "let x = Nil() in match x with |Nil(a) -> 0 |Cons(a,b) -> 1"
       |> infer [writeup_example]
       |> typeof));

   "infer_matchVariant2" >::
     (fun _ -> assert_equal
       (parse_type "'a option -> int")
       (parse_expr "let rec y = (fun x -> match x with |Some(a) -> 1 + y a | None() -> 1) in y"
        |> infer [alpha_option2]
        |> typeof));

    "infer_matchVariant2" >::
      (fun _ -> assert_equal
        (parse_type "'a option")
        (parse_expr "let y = None () in match y with | Some a -> Some a| None () -> None()"
         |> infer [alpha_option2]
         |> typeof));

     "variant_recursive1" >::
     (fun _ -> assert_equal
       (parse_type "int list option")
       (parse_expr "Some(Cons(1, Nil()))"
        |> infer [writeup_example;alpha_option]
        |> typeof));

    "variant_funky1" >::
    (fun _ -> assert_equal
      (parse_type "(int, bool) abc")
      (parse_expr "Funky(true, 5)"
       |> infer [funky_option]
       |> typeof));
]

let _ = run_test_tt_main tests
