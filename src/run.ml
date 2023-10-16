open Bos_setup

(* Just blowup for now, maybe bind later? *)
let ( let* ) r f =
  match r with
  | Error (`Msg e) ->
    Format.printf "%s@." e;
    exit 1
  | Ok v -> f v

let pre_patterns : (Re2.t * string) array =
  Array.map
    (fun (regex, template) -> (Re2.create_exn regex, template))
    [| ( "void\\s+reach_error\\(\\)\\s*\\{.*\\}"
       , "void reach_error() { owi_assert(0); }" )
       (* ugly: Hack to solve duplicate errors on compilation *)
       (* ; ("void\\s+(assert|assume)\\(", "void old_\\1(") *)
    |]

let patch_with_regex (file_data : string) ~patterns : string =
  Array.fold_left
    (fun data (regex, template) -> Re2.rewrite_exn regex ~template data)
    file_data patterns

let patch_gcc_ext (file_data : string) : string =
  String.concat ~sep:"\n"
    [ "#define __attribute__(x)"
    ; "#define __extension__"
    ; "#define __restrict"
    ; "#define __inline"
    ; "#include <owi.h>"
    ; file_data
    ]

let instrument_file (file : Fpath.t) (includes : string list) =
  Log.debug "instrumenting %a@." Fpath.pp file;
  let pypath = String.concat ~sep:":" Share.py_location in
  let* () = OS.Env.set_var "PYTHONPATH" (Some pypath) in
  let* data = OS.File.read file in
  let data = patch_gcc_ext data |> patch_with_regex ~patterns:pre_patterns in
  try
    Py.initialize ();
    let data = Instrumentor.instrument data includes in
    Py.finalize ();
    data
  with Py.E (err_type, _) ->
    Log.debug "warning : exception %a@." Py.Object.format err_type;
    data

let clang ~flags ~out file = Cmd.(v "clang" %% flags % "-o" % p out % p file)
let opt file = Cmd.(v "opt" % "-O1" % "-o" % p file % p file)

let llc ~bc ~obj =
  let flags = Cmd.of_list [ "-O1"; "-march=wasm32"; "-filetype=obj"; "-o" ] in
  Cmd.(v "llc" %% flags % p obj % p bc)

let ld ~flags ~out files =
  let libc = Share.get_libc () |> Option.get in
  let files = Cmd.of_list files in
  Cmd.(v "wasm-ld" %% flags % "-o" % p out % libc %% files)

let wasm2wat ~out bin = Cmd.(v "wasm2wat" % "-o" % p out % p bin)

let compile (file : Fpath.t) ~(includes : string list) =
  Log.debug "compiling %a@." Fpath.pp file;
  let cflags =
    let includes = Cmd.of_list ~slip:"-I" includes in
    let warnings =
      Cmd.of_list
        [ "-Wno-int-conversion"
        ; "-Wno-pointer-sign"
        ; "-Wno-string-plus-int"
        ; "-Wno-implicit-function-declaration"
        ; "-Wno-incompatible-library-redeclaration"
        ; "-Wno-incompatible-function-pointer-types"
        ; "-Wno-incompatible-pointer-types"
        ]
    in
    Cmd.(
      of_list [ "-O1"; "-g"; "-emit-llvm"; "--target=wasm32"; "-m32"; "-c" ]
      %% warnings %% includes )
  in
  let bc = Fpath.(file -+ ".bc") in
  let obj = Fpath.(file -+ ".o") in
  let* () = OS.Cmd.run @@ clang ~flags:cflags ~out:bc file in
  let* () = OS.Cmd.run @@ opt bc in
  let* () = OS.Cmd.run @@ llc ~bc ~obj in
  obj

let link (files : Fpath.t list) output : Fpath.t =
  let ldflags ~export =
    let stack_size = 8 * (1024 * 1024) in
    Cmd.(
      of_list
        [ "-z"; "stack-size=" ^ string_of_int stack_size; "--entry=" ^ export ] )
  in
  let wasm = Fpath.(output / "a.out.wasm") in
  let wat = Fpath.(output / "a.out.wat") in
  let files = List.map Fpath.to_string files in
  let* () =
    OS.Cmd.run @@ ld ~flags:(ldflags ~export:"_start") ~out:wasm files
  in
  let* () = OS.Cmd.run @@ wasm2wat ~out:wat wasm in
  wat

let cleanup dir =
  OS.Path.fold ~elements:`Files
    (fun path _acc ->
      if not (Fpath.has_ext ".wat" path || Fpath.has_ext ".wasm" path) then
        match OS.Path.delete path with
        | Ok () -> ()
        | Error (`Msg e) -> Logs.warn (fun m -> m "%s" e) )
    () [ dir ]
  |> Logs.on_error_msg ~level:Logs.Warning ~use:Fun.id

let run_file _file _output = Log.debug "running ...@."

let main debug output includes files =
  if debug then Logs.set_level (Some Debug);
  let output_dir = Fpath.v output in
  let includes = Share.lib_location @ includes in
  let* _ = OS.Dir.create output_dir in
  let instrumented_files =
    List.map
      (fun file ->
        let* file = OS.File.must_exist (Fpath.v file) in
        let data = instrument_file file includes in
        let file = Fpath.(output_dir // base file) in
        let* () = OS.File.write file data in
        file )
      files
  in
  let objects = List.map (compile ~includes) instrumented_files in
  let module_ = link objects output_dir in
  cleanup output_dir;
  run_file module_ output_dir
