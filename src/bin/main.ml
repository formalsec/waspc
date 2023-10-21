open Owic
open Cmdliner

let debug =
  let doc = "debug mode" in
  Arg.(value & flag & info [ "debug" ] ~doc)

let testcomp =
  let doc = "test-comp mode" in
  Arg.(value & flag & info [ "testcomp" ] ~doc)

let output =
  let doc = "write results to dir" in
  Arg.(value & opt string "owi-out" & info [ "output"; "o" ] ~doc)

let includes =
  let doc = "headers path" in
  Arg.(value & opt_all string [] & info [ "I" ] ~doc)

let files =
  let doc = "source files" in
  Arg.(value & pos_all file [] & info [] ~doc)

let cli =
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
  Cmd.v info
    Term.(const Run.main $ debug $ testcomp $ output $ includes $ files)

let () = exit @@ Cmd.eval' cli
