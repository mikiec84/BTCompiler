
(* This module contains two implementations for the BT data type.
   Both are parameterized over the signature BT_SIG, which defines
   a set whose members are the basic skills available and a function
   mapping each skill to its name (a string). *)

Require Import String.

Module Type BT_SIG.
  
  Parameter SkillSet: Set.
  Parameter SkillName: SkillSet -> string.
  
End BT_SIG.

(* First implementation: trees with binary branching only *)

Module BT_binary (X: BT_SIG).
  
  Inductive NodeKind: Set :=
    Sequence | Fallback | Parallel1 | Parallel2.

  Inductive DecKind: Set :=
    Not | IsRunning. (* | IsEnabled. *)

  (* Other decorators with memory, like the "max-N-tries" and the
     "max-T-sec" decorators described in the book by Colledanchise
     and Ogren, are best implemented as composite BTs which manage
     the state via some skills implementing a suitable interface,
     e.g. communication with a parameter server. *)
  
  Inductive btree: Set :=
  | Skill: X.SkillSet -> btree
  | TRUE: btree
  | Node: NodeKind -> string -> btree -> btree -> btree
  | Dec: DecKind -> string -> btree -> btree.

  (* Utility functions *)

  Fixpoint count_skills (t: btree) :=
    match t with
    | Skill _ => 1
    | TRUE => 0
    | Node _ _ t1 t2 => count_skills t1 + count_skills t2
    | Dec _ _ t => count_skills t
    end.

End BT_binary.

(* Second implementation: trees with arbitrary branching *)

Module BT_general (X: BT_SIG).

  Inductive NodeKind: Set :=
  | Sequence: NodeKind
  | Fallback: NodeKind
  | Parallel: nat -> NodeKind.

  Inductive DecKind: Set :=
    Not | IsRunning. (* | IsEnabled. *)

  Inductive btree: Set :=
  | Skill: X.SkillSet -> btree
  | TRUE: btree
  | Node: NodeKind -> string -> btforest -> btree
  | Dec: DecKind -> string -> btree -> btree
  with btforest: Set :=
  | child: btree -> btforest              (* a forest has at least one tree *)
  | add: btree -> btforest -> btforest.

  (* Instantiation of the correct mutual induction principles *)

  Scheme btree_mind := Induction for btree Sort Prop
  with btforest_mind := Induction for btforest Sort Prop.

  (* Utility functions *)

  Fixpoint len (f: btforest) :=
    match f with
    | child t => 1
    | add t1 rest => S (len rest)
    end.

  Fixpoint count_skills (t: btree) :=
    match t with
    | Skill _ => 1
    | TRUE => 0
    | Node _ _ f => cs_forest f
    | Dec _ _ t => count_skills t
    end
  with cs_forest (f: btforest) :=
    match f with
    | child t => count_skills t
    | add t tl => count_skills t + cs_forest tl
    end.

  (* The following function replaces inner nodes with a single child with
     the child tree itself. We may prove later that this operation does not
     alter the semantics of the BT. *)

  Fixpoint normalize (t: btree) :=
    match t with
    | Skill s => Skill s
    | TRUE => TRUE
    | Node k n f => match k with
(* original implementation:
                    | Parallel 0 => TRUE
                    | _ => match f with
                           | child t => t
                           | _ => Node k n (normalize_forest f)
                           end
                    end
   this cannot be proved correct because of meaningless thresholds in
   parallel nodes. So we leave parallel nodes alone: *)
                    | Sequence =>
                      match f with
                      | child t => t
                      | _ => Node k n (normalize_forest f)
                      end
                    | Fallback =>
                      match f with
                      | child t => t
                      | _ => Node k n (normalize_forest f)
                      end
                    | _ => Node k n (normalize_forest f)
                    end
    | Dec k n t => match k with
                   | Not => match t with
                            | Dec Not _ t' => t'      (* Not is an involution *)
                            | _ => Dec Not n (normalize t)
                            end
                   | _ => Dec k n (normalize t)
                   end
    end
  with normalize_forest (f: btforest) :=
    match f with
    | child t => child (normalize t)
    | add t ts => add (normalize t) (normalize_forest ts)
    end.


End BT_general.

