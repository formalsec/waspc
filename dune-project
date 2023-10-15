(lang dune 3.0)

(using dune_site 0.1)

(name waspc)

(generate_opam_files true)

(source
 (github wasp-platform/waspc))

(authors "WASP Platform")

(maintainers "WASP Platform")

(license "Apache-2.0")

(package
 (name waspc)
 (synopsis "TODO")
 (description "TODO")
 (depends ocaml dune re2 bos pyml cmdliner dune-site)
 (sites (share py) (share bin) (share lib)))
