(** This module specifies the operational semantics *)

open Ast
open Elaboration

type reduction_error =
  [ `Err_not_enough_fuel
  | `Err_stuck_term of term
  | `Err_free_const
  ]

val string_of_error : reduction_error -> string

(** Reduces a term *)
val reduce : term -> (term, [> reduction_error | elaboration_error ]) result

(** One step reduction *)
val step : term -> (term, [> reduction_error | elaboration_error ]) result
