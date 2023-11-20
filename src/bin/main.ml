open Owic
open Cmdliner

let debug =
  let doc = "debug mode" in
  Arg.(value & flag & info [ "debug" ] ~doc)

let arch =
  let doc = "data model" in
  Arg.(value & opt int 32 & info [ "arch"; "m" ] ~doc)

let property =
  let doc = "property file" in
  Arg.(value & opt (some string) None & info [ "property"; "p" ] ~doc)

let testcomp =
  let doc = "test-comp mode" in
  Arg.(value & flag & info [ "testcomp" ] ~doc)

let output =
  let doc = "write results to dir" in
  Arg.(value & opt string "owi-out" & info [ "output"; "o" ] ~doc)

let workers =
  let doc = "number workers to use in owi" in
  Arg.(value & opt int 8 & info [ "workers"; "w" ] ~doc)

let opt_lvl =
  let doc = "specify which optimization level to use" in
  Arg.(value & opt string "0" & info [ "O" ] ~doc)

let includes =
  let doc = "headers path" in
  Arg.(value & opt_all dir [] & info [ "I" ] ~doc)

let files =
  let doc = "source files" in
  Arg.(value & pos_all non_dir_file [] & info [] ~doc)

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
  let info = Cmd.info "owic" ~version:"%%VERSION%%" ~doc ~man in
  Cmd.v info
    Term.(
      const Run.main $ debug $ arch $ property $ testcomp $ output $ workers
      $ opt_lvl $ includes $ files )

let () = exit @@ Cmd.eval' cli
