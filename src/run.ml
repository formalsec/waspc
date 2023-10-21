open Bos_setup

let ( let* ) = Rresult.R.bind

let list_map f lst =
  let exception E of Rresult.R.msg in
  try
    Ok
      (List.map
         (fun x -> match f x with Ok x' -> x' | Error e -> raise (E e))
         lst )
  with E e -> Error e

let pre_patterns : (Re2.t * string) array =
  Array.map
    (fun (regex, template) -> (Re2.create_exn regex, template))
    [| ( "void\\s+reach_error\\(\\)\\s*\\{.*\\}"
       , "void reach_error() { owi_assert(0); }" )
       (* ugly: Hack to solve duplicate errors on compilation *)
       (* ; ("void\\s+(assert|assume)\\(", "void old_\\1(") *)
    |]

let patch_with_regex ~patterns (data : string) : string =
  Array.fold_left
    (fun data (regex, template) -> Re2.rewrite_exn regex ~template data)
    data patterns

let patch ~(src : Fpath.t) ~(dst : Fpath.t) =
  let* data = OS.File.read src in
  let data = patch_with_regex ~patterns:pre_patterns data in
  let data =
    String.concat ~sep:"\n"
      [ "#define __attribute__(x)"
      ; "#define __extension__"
      ; "#define __restrict"
      ; "#define __inline"
      ; "#include <owi.h>"
      ; data
      ]
  in
  let* () = OS.File.write dst data in
  Ok ()

let copy ~src ~dst =
  let* data = OS.File.read src in
  let* () = OS.File.write dst data in
  Ok dst

let instrument_file ?(skip = false) ~(includes : string list)
  ~(workspace : Fpath.t) (file : string) =
  let file = Fpath.v file in
  let dst = Fpath.(workspace // file) in
  if skip then copy ~src:file ~dst
  else begin
    Logs.app (fun m -> m "instrumenting %a" Fpath.pp file);
    let* () = patch ~src:file ~dst in
    let pypath = String.concat ~sep:":" Share.py_location in
    let* () = OS.Env.set_var "PYTHONPATH" (Some pypath) in
    begin
      try
        Py.initialize ();
        Instrumentor.instrument (Fpath.to_string dst) includes;
        Py.finalize ()
      with Py.E (errtype, errvalue) ->
        let pp = Py.Object.format in
        Logs.warn (fun m -> m "instrumentor: %a: %a" pp errtype pp errvalue)
    end;
    Ok dst
  end

let clang ~flags ~out file = Cmd.(v "clang" %% flags % "-o" % p out % p file)
let opt file = Cmd.(v "opt" % "-O1" % "-o" % p file % p file)

let llc ~bc ~obj =
  let flags = Cmd.of_list [ "-O1"; "-march=wasm32"; "-filetype=obj"; "-o" ] in
  Cmd.(v "llc" %% flags % p obj % p bc)

let ld ~flags ~out files =
  let libc = Share.get_libc () |> Option.get in
  let files = List.fold_left (fun acc f -> Cmd.(acc % p f)) Cmd.empty files in
  Cmd.(v "wasm-ld" %% flags % "-o" % p out %% files % libc)

let wasm2wat ~out bin = Cmd.(v "wasm2wat" % "-o" % p out % p bin)

let compile (file : Fpath.t) ~(includes : string list) =
  Logs.app (fun m -> m "compiling %a" Fpath.pp file);
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
  Ok obj

let link ~workspace (files : Fpath.t list) =
  let ldflags ~entry =
    let stack_size = 8 * (1024 * 1024) in
    Cmd.(
      of_list
        [ "-z"; "stack-size=" ^ string_of_int stack_size; "--entry=" ^ entry ] )
  in
  let wasm = Fpath.(workspace / "a.out.wasm") in
  let wat = Fpath.(workspace / "a.out.wat") in
  let* () = OS.Cmd.run @@ ld ~flags:(ldflags ~entry:"_start") ~out:wasm files in
  let* () = OS.Cmd.run @@ wasm2wat ~out:wat wasm in
  Ok wat

let cleanup dir =
  OS.Path.fold ~elements:`Files
    (fun path _acc ->
      if not (Fpath.has_ext ".wat" path || Fpath.has_ext ".wasm" path) then
        match OS.Path.delete path with
        | Ok () -> ()
        | Error (`Msg e) -> Logs.warn (fun m -> m "%s" e) )
    () [ dir ]
  |> Logs.on_error_msg ~level:Logs.Warning ~use:Fun.id

let run ~workspace:_ _file =
  Logs.app (fun m -> m "running ...");
  Ok 0

let main debug testcomp output includes files =
  if debug then Logs.set_level (Some Debug);
  let workspace = Fpath.v output in
  let includes = Share.lib_location @ includes in
  let ret =
    let* _ = OS.Dir.create workspace in
    (* skip instrumentation if not in test-comp mode *)
    let skip = not testcomp in
    let* files = list_map (instrument_file ~skip ~includes ~workspace) files in
    let* objects = list_map (compile ~includes) files in
    let* module_ = link ~workspace objects in
    cleanup workspace;
    run ~workspace module_
  in
  Logs.on_error_msg ~level:Logs.Error ~use:(fun () -> 1) ret
