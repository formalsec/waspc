(lang dune 3.0)

(using dune_site 0.1)
(using directory-targets 0.1)

(name owic)
(version test-comp24)

(generate_opam_files true)

(source
 (github wasp-platform/waspc))

(authors "TODO")

(maintainers "TODO")

(license "Apache-2.0")

(package
 (name owic)
 (synopsis "TODO")
 (description "TODO")
 (depends ocaml dune re2 bos pyml cmdliner dune-site xmlm sha)
 (sites (share py) (share bin) (share lib)))
