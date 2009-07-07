external _exit : int -> unit = "unix_exit"
val unlink_safe : string -> unit
val mkdir_safe : string -> Unix.file_perm -> unit
val mkdir_rec : string -> Unix.file_perm -> unit
val pidfile_write : string -> unit
val pidfile_read : string -> int option
val daemonize : unit -> unit
val with_file : string -> Unix.open_flag list -> Unix.file_perm -> (Unix.file_descr -> 'a) -> 'a
val with_directory : string -> (Unix.dir_handle -> 'a) -> 'a
val readfile_line : (string -> 'a) -> string -> unit
val read_whole_file : int -> int -> Unix.file_descr -> string
val read_whole_file_to_string : string -> string
val atomic_write_to_file : string -> (Unix.file_descr -> 'a) -> 'a
val write_string_to_file : string -> string -> unit
val execv_get_output : string -> string array -> int * Unix.file_descr
val copy_file : ?limit:int64 -> Unix.file_descr -> Unix.file_descr -> int64

(** Returns true if and only if a file exists at the given path. *)
val file_exists : string -> bool

(** Sets both the access and modification times of the file *)
(** at the given path to the current time. Creates an empty *)
(** file at the given path if no such file already exists.  *)
val touch_file : string -> unit

(** Returns true if and only if an empty file exists at the given path. *)
val is_empty_file : string -> bool

(** Safely deletes a file at the given path if (and only if) the  *)
(** file exists and is empty. Returns true if a file was deleted. *)
val delete_empty_file : string -> bool

exception Host_not_found of string
val open_connection_fd : string -> int -> Unix.file_descr
val open_connection_unix_fd : string -> Unix.file_descr
type endpoint = {
  fd : Unix.file_descr;
  mutable buffer : string;
  mutable buffer_len : int;
}
exception Process_still_alive
val kill_and_wait : ?signal:int -> ?timeout:float -> int -> unit
val make_endpoint : Unix.file_descr -> endpoint
val proxy : Unix.file_descr -> Unix.file_descr -> unit
val really_read : Unix.file_descr -> string -> int -> int -> unit
val really_read_string : Unix.file_descr -> int -> string
val really_read_bigbuffer : Unix.file_descr -> Bigbuffer.t -> int64 -> unit
val really_write : Unix.file_descr -> string -> int -> int -> unit
val really_write_string : Unix.file_descr -> string -> unit
exception Timeout
val time_limited_write : Unix.file_descr -> int -> string -> float -> unit
val time_limited_read : Unix.file_descr -> int -> float -> string
val read_data_in_chunks : (string -> int -> unit) -> ?block_size:int -> ?max_bytes:int -> Unix.file_descr -> int
val spawnvp :
  ?pid_callback:(int -> unit) ->
  string -> string array -> Unix.process_status
val double_fork : (unit -> unit) -> unit
external set_tcp_nodelay : Unix.file_descr -> bool -> unit
  = "stub_unixext_set_tcp_nodelay"
external fsync : Unix.file_descr -> unit = "stub_unixext_fsync"
external get_max_fd : unit -> int = "stub_unixext_get_max_fd"
val int_of_file_descr : Unix.file_descr -> int
val file_descr_of_int : int -> Unix.file_descr
val close_all_fds_except : Unix.file_descr list -> unit
val get_process_output : ?handler:(string -> int -> string) -> string -> string
val resolve_dot_and_dotdot : string -> string

val seek_to : Unix.file_descr -> int -> int
val seek_rel : Unix.file_descr -> int -> int
val current_cursor_pos : Unix.file_descr -> int

type statfs_t = {
	statfs_type: int64;
	statfs_bsize: int;
	statfs_blocks: int64;
	statfs_bfree: int64;
	statfs_bavail: int64;
	statfs_files: int64;
	statfs_ffree: int64;
	statfs_namelen: int;
}

val statfs: string -> statfs_t

module Fdset : sig
	type t
	external of_list : Unix.file_descr list -> t = "stub_fdset_of_list"
	external is_set : t -> Unix.file_descr -> bool = "stub_fdset_is_set"
	external is_set_and_clear : t -> Unix.file_descr -> bool = "stub_fdset_is_set_and_clear"
	external is_empty : t -> bool = "stub_fdset_is_empty"
	external set : t -> Unix.file_descr -> unit = "stub_fdset_set"
	external clear : t -> Unix.file_descr -> unit = "stub_fdset_clear"

	val select : t -> t -> t -> float -> t * t * t
	val select_ro : t -> float -> t
	val select_wo : t -> float -> t
end

(** Download a file via an HTTP GET *)
val http_get: open_tcp:(server:string -> (in_channel * out_channel)) -> uri:string -> filename:string -> server:string -> unit
(** Upload a file via an HTTP PUT *)
val http_put: open_tcp:(server:string -> (in_channel * out_channel)) -> uri:string -> filename:string -> server:string -> unit