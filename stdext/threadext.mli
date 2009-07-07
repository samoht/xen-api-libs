module Mutex :
  sig
    type t = Mutex.t
    val create : unit -> t
    val lock : t -> unit
    val try_lock : t -> bool
    val unlock : t -> unit
    val execute : Mutex.t -> (unit -> 'a) -> 'a
  end
module Thread_loop :
  functor (Tr : sig type t val delay : unit -> float end) ->
    sig
      val start : Tr.t -> (unit -> unit) -> unit
      val stop : Tr.t -> unit
      val update : Tr.t -> (unit -> unit) -> unit
    end
val thread_iter_all_exns: ('a -> unit) -> 'a list -> ('a * exn) list
val thread_iter: ('a -> unit) -> 'a list -> unit

module Delay :
  sig
    type t
    val make : unit -> t
    (** Blocks the calling thread for a given period of time with the option of 
	returning early if someone calls 'signal'. Returns true if the full time
	period elapsed and false if signalled. Note that multple 'signals' are 
	coalesced; 'signals' sent before 'wait' is called are not lost. *)
    val wait : t -> float -> bool
    (** Sends a signal to a waiting thread. See 'wait' *)
    val signal : t -> unit
  end