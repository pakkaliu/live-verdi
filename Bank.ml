open Printf
open Opts

let _ =
  let _ =
    try
      parse Sys.argv
    with
    | Arg.Help msg ->
      printf "%s: %s" Sys.argv.(0) msg;
      exit 2
    | Arg.Bad msg ->
      eprintf "%s" msg;
      exit 2
  in

  let _ =
    try
      validate ()
    with Arg.Bad msg ->
      eprintf "%s: %s." Sys.argv.(0) msg;
      prerr_newline ();
      exit 2
  in

  (* TODO: How exactly does OrderedShim differ from Shim? It was just simpler to use. *)
  let open Bank_Arrangement in
  let module BankShim = OrderedShim.Shim(BankArrangement(DebugParams)) in

  (* FIXME: Not sure how verdi-raft and verdi-aggregation map `int` to `name` *)
  let name id = if id = 0 then Bank_Coq.Server else Bank_Coq.Client in
  let named_cluster = List.map (fun (id, addr) -> ((name id) , addr)) !cluster in
  let named_me = name !me in

  let open BankShim in
    main { cluster = named_cluster
         ; me = named_me
         ; port = !port
         }