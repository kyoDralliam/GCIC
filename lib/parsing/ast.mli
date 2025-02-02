(** This module specifies the structure of the parsed AST *)
open Common.Id

(** Terms in GCIC *)
type term =
  | Var of Name.t
  | Universe of int
  | App of term * term
  | Lambda of (Name.t option * term) list * term
  | Prod of (Name.t option * term) list * term
  | Unknown of int
  | LetIn of (Name.t * term * term * term)
  (* Extras *)
  | Ascription of term * term
  | UnknownT of int

(** Returns the stringified version of a term *)
val to_string : term -> string

(** Equality predicate for terms *)
val eq_term : term -> term -> bool
