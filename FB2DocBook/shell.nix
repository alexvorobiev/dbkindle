{ pkgs ? import <nixpkgs> {} }:
with pkgs;
mkShell {
  DBLATEX_CONFIG_FILES="/home/alex/src/dbkindle";

  # nativeBuildInputs is usually what you want -- tools you need to run
  nativeBuildInputs = [
    (python3.withPackages (ps: with python3Packages; [ pillow lxml cssutils ipython ]))
    docbook_xml_xslt
    docbook_xml_dtd_44
    dblatex
    libxslt
    texlive.combined.scheme-full
  ];
}
