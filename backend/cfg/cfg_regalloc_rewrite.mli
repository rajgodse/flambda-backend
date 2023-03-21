[@@@ocaml.warning "+a-4-30-40-41-42"]

open Cfg_regalloc_utils

module type State = sig
  type t

  val stack_slots : t -> StackSlots.t

  val get_and_incr_instruction_id : t -> Instruction.id
end

module type Utils = sig
  val debug : bool

  val invariants : bool Lazy.t

  val log :
    indent:int -> ?no_eol:unit -> ('a, Format.formatter, unit) format -> 'a

  val log_body_and_terminator :
    indent:int ->
    Cfg.basic Cfg.instruction Flambda_backend_utils.Doubly_linked_list.t ->
    Cfg.terminator Cfg.instruction ->
    liveness ->
    unit

  (* Tests whether the passed register is marked as "spilled". *)
  val is_spilled : Reg.t -> bool

  (* Sets the passed register as "spilled". *)
  val set_spilled : Reg.t -> unit
end

(* This is the `rewrite` function from IRC, parametrized by state, functions for
   debugging, and function to test/set the "spilled" state of a register. *)
val rewrite_gen :
  (module State with type t = 's) ->
  (module Utils) ->
  's ->
  Cfg_with_liveness.t ->
  Reg.t list ->
  Reg.t list

(* Runs the first steps common to register allocators, reinitializing registers,
   checking preconditions, and collecting information from the CFG. [f] is
   registered as the [on_fatal] callback. *)
val prelude :
  (module Utils) -> f:(unit -> unit) -> Cfg_with_liveness.t -> cfg_infos

(* Runs the last steps common to register allocators, updating the CFG (stack
   slots, live fields, and prologue), running [f], and checking
   postconditions. *)
val postlude :
  (module State with type t = 's) ->
  (module Utils) ->
  's ->
  f:(unit -> unit) ->
  Cfg_with_liveness.t ->
  unit
