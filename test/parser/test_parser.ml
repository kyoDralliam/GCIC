open Parsing.Ast
open Parsing.Lex_and_parse

let name (id : string) = Common.Id.Name.of_string id
let var (id : string) : term = Var (Common.Id.Name.of_string id)
let arg (id : string) = Some (name id)

let funt dom body = Prod ([(None, dom)], body)

let term =
  let pprint_term ppf t = Format.pp_print_string ppf (to_string t) in
  Alcotest.testable pprint_term eq_term

let pterm = Alcotest.(result term string)

let tests_application () =
  Alcotest.check pterm
    "nullary application"
    (Ok (Universe 0))
    (parse_term "Type0");
  Alcotest.check pterm
    "unary application"
    (Ok (App (Unknown 1, Unknown 0)))
    (parse_term "?1 ?0");
  Alcotest.check pterm
    "n-ary application"
    (Ok (App (App (App (var "f", Universe 0), var "x"), var "y")))
    (parse_term "f Type0 x y")

let product_notation () =
  Alcotest.check pterm
    "non-dependent product notation"
    (Ok (funt (Universe 0) (Universe 1)))
    (parse_term "Type0 -> Type1");
  Alcotest.check pterm
    "dependent product forall notation"
    (Ok (Prod ([(arg "x", Universe 0)], var "x")))
    (parse_term "forall (x : Type0), x");
  Alcotest.check pterm
    "n-ary non-dependent product"
    (Ok (funt (Universe 0) (funt (funt (Universe 1) (Universe 2)) (Universe 3))))
    (parse_term "Type0 -> (Type1 -> Type2) -> Type3");
  Alcotest.check pterm
    "n-ary non-dependent product"
    (Ok (Prod ([(arg "x", Unknown 0); (arg "y", funt (Unknown 1) (Universe 2))], Universe 3)))
    (parse_term "forall (x : ?0) (y : ?1 -> Type2), Type3")

let tests_let () =
  Alcotest.check pterm
    "let binding"
    (Ok (LetIn (name "x", Universe 0, Unknown 0, var "x")))
    (parse_term "let x : Type0 = ?0 in x");
  Alcotest.(check bool)
    "let is reserved"
    true
    (parse_term "let" |> Result.is_error);
  Alcotest.(check bool)
    "in is reserved"
    true
    (parse_term "in" |> Result.is_error)


let tests_unicode () =
  Alcotest.check pterm
    "universe"
    (Ok (Universe 0))
    (parse_term "□0");
  Alcotest.check pterm
    "lambda"
    (Ok (Lambda ([(arg "x", var "a")], var "x")))
    (parse_term "λ(x:a).x");
  Alcotest.check pterm
    "forall"
    (Ok (Prod ([(arg "x", var "a")], var "x")))
    (parse_term "∀(x:a),x");
  Alcotest.check pterm
    "arrow"
    (Ok (Prod ([(None, var "a")], var "b")))
    (parse_term "a->b")

let tests =
  [
    ("products", `Quick, product_notation );
    ("application", `Quick, tests_application);
    ("let binding", `Quick, tests_let);
    ("unicode", `Quick, tests_unicode);
  ]

let () = Alcotest.run "Parser tests" [ ("Parser module", tests); ]