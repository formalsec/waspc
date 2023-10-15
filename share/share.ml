let py_location = Share_site.Sites.py

let bin_location = Share_site.Sites.bin

let lib_location = Share_site.Sites.lib

let find location file =
  List.find_map
    (fun dir ->
      let filename = Filename.concat dir file in
      if Sys.file_exists filename then Some filename else None )
    location

let get_libc () = find bin_location "libc.wasm"
