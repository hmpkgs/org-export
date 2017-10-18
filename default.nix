{ config, pkgs, lib, ... }:

with lib;
with builtins;

rec {
  export = { source, giturl }: let
    # use the main emacs package
    pkgGen = pkgs.emacsPackagesNgGen pkgs.emacs;
    # install htmlize for emacs
    emacs = pkgGen.emacsWithPackages (epkgs: [ epkgs.htmlize ]);
    # export Orgmode file to HTML and upload to Github Pages
    env = { buildInputs = [ emacs pkgs.git ]; };
      script = ''
        ln -s "${source}" ./init.org;
        emacs -Q --script ${./org-export.el} -f export-init-to-html;
        mv init.html index.html
        git init;
        git checkout -b gh-pages
        git remote add origin "${giturl}"
        git add index.html;
        git commit -m "autodeploy";
        git push --force origin gh-pages;
        cp ./index.html $out;
      '';
  in pkgs.runCommand "org-export" env script;
}
