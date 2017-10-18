{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.orgExport;
  emacs = (pkgsemacsPackagesNgGen emacs).emacsWithPackages (epkgs: [ epkgs.htmlize ]);
  env = { buildInputs = [ pkgs.git pkgs.emacs ]; };
  script = ''
    ln -s "${cfg.source}" ./init.org;
    emacs -Q --script ${./org-export.el} -f export-init-to-html;
    mv init.html index.html
    git init;
    git checkout -b gh-pages
    git remote add origin "${cfg.giturl}"
    git add index.html;
    git commit -m "autodeploy";
    git push --force origin gh-pages;
    cp ./index.html $out;
  '';
  result = pkgs.runCommand "exportOrg" env script;

in {

  options.programs.orgExport = {
    enable = mkEnableOption "Orgfile Github-Pages Export";
    source = mkOption {
      type = types.path;
      description = ''
        The source orgfile to export to Github-Pages.
      '';
    };
    giturl = mkOption {
      type = types.str;
      description = ''
        The Git URL of the Github-Pages repository.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.file.".emacs.d/init.html".source = result;
  };
}
