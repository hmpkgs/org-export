{ pkgs, ... }:

let
  emacs = (pkgs.emacsPackagesNgGen pkgs.emacs).emacsWithPackages (epkgs: [ epkgs.htmlize ]);

{
  orgExport = { infile, giturl }:
  let
      inpath = toPath infile;
      env = { buildInputs = [ emacs pkgs.git ]; };
      script = ''
        ln -s "${infile}" ./init.org;
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
    in pkgs.runCommand "${infile}-org-export" env script;
}
