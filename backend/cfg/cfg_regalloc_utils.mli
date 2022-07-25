[@@@ocaml.warning "+a-4-30-40-41-42"]

module Array : module type of ArrayLabels

module List : module type of ListLabels

val on_fatal : f:(unit -> unit) -> unit

val fatal : ('a, Format.formatter, unit, 'b) format4 -> 'a

module Instruction : sig
  type id = int

  type t = Cfg.basic Cfg.instruction

  module Set : MoreLabels.Set.S with type elt = t

  module IdSet : MoreLabels.Set.S with type elt = id

  module IdMap : MoreLabels.Map.S with type key = id
end

val destroyed_at_basic : Cfg.basic -> Reg.t array

val destroyed_at_terminator : Cfg.terminator -> Reg.t array

val iter_instructions :
  Cfg_with_layout.t ->
  instruction:(Cfg.basic Cfg.instruction -> unit) ->
  terminator:(Cfg.terminator Cfg.instruction -> unit) ->
  unit

val fold_instructions :
  Cfg_with_layout.t ->
  instruction:('a -> Cfg.basic Cfg.instruction -> 'a) ->
  terminator:('a -> Cfg.terminator Cfg.instruction -> 'a) ->
  init:'a ->
  'a

type cfg_infos =
  { arg : Reg.Set.t;
    res : Reg.Set.t;
    max_instruction_id : Instruction.id
  }

val collect_cfg_infos : Cfg_with_layout.t -> cfg_infos

type liveness = Cfg_liveness.Liveness.domain Cfg_dataflow.Instr.Tbl.t

val liveness_analysis : Cfg_with_layout.t -> liveness

module Move : sig
  type t =
    | Plain
    | Fetch
    | Store

  val make_instr :
    t ->
    id:Instruction.id ->
    copy:_ Cfg.instruction ->
    from:Reg.t ->
    to_:Reg.t ->
    Instruction.t

  val to_string : t -> string
end

val same_reg : Reg.t -> Reg.t -> bool

val same_reg_class : Reg.t -> Reg.t -> bool

val make_temporary :
  same_class_and_base_name_as:Reg.t -> name_prefix:string -> Reg.t

val simplify_cfg : Cfg_with_layout.t -> Cfg_with_layout.t

val precondition : Cfg_with_layout.t -> unit

val postcondition : Cfg_with_layout.t -> unit

val save_cfg : string -> Cfg_with_layout.t -> unit

val update_stack_slots : Cfg_with_layout.t -> num_stack_slots:int array -> unit

val remove_prologue_if_not_required : Cfg_with_layout.t -> unit

val update_live_fields : Cfg_with_layout.t -> liveness -> unit

val update_spill_cost : Cfg_with_layout.t -> unit
