open Waspc

let debug =
  let doc = "debug mode" in
  Cmdliner.Arg.(value & flag & info [ "debug" ] ~doc)

let output =
  let doc = "write results to dir" in
  Cmdliner.Arg.(value & opt string "owi-out" & info [ "output"; "o" ] ~doc)

let includes =
  let doc = "headers path" in
  Cmdliner.Arg.(value & opt_all string [] & info [ "I" ] ~doc)

let files =
  let doc = "source files" in
  Cmdliner.Arg.(value & pos_all file [] & info [] ~doc)

let cli =
  let open Cmdliner in
  let doc = "A C to Wasm Compiler to integrate with OWI" in
  let man =
    [ `S Manpage.s_description
    ; `P
        "'$(mname)'  is a C to WebAssembly (Wasm) compiler that integrates \
         with OCamlPro's OWI interpreter."
    ; `S Manpage.s_bugs
    ; `P "Email them to TODO"
    ]
  in
  let info = Cmd.info "owic" ~version:"test-comp24" ~doc ~man in
  Cmd.v info Term.(const Run.main $ debug $ output $ includes $ files)

let () = exit @@ Cmdliner.Cmd.eval' cli
