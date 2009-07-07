module Hashtbl = struct include Hashtbl

let to_list tbl =
	Hashtbl.fold (fun k v acc -> (k, v) :: acc) tbl []

let fold_keys tbl =
	Hashtbl.fold (fun k v acc -> k :: acc) tbl []

let fold_values tbl =
	Hashtbl.fold (fun k v acc -> v :: acc) tbl []

let add_empty tbl k v =
	if not (Hashtbl.mem tbl k) then
		Hashtbl.add tbl k v

let add_list tbl l =
	List.iter (fun (k, v) -> Hashtbl.add tbl k v) l

let of_list l =
	let tbl = Hashtbl.create (List.length l) in
	add_list tbl l;
	tbl
end