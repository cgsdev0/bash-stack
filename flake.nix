{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.systems.url = "github:nix-systems/default";

  outputs = { flake-parts, ... }@inputs: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;
    perSystem = { pkgs, ... }: {
      packages.default = pkgs.stdenv.mkDerivation {
        dontUnpack = true;
        name = "bash-stack";
        nativeBuildInputs = [ pkgs.makeWrapper ];
        installPhase = ''
          mkdir -p $out/bin $out/share
          cp ${./core.sh} $out/share/core.sh
          makeWrapper ${./start.sh} $out/bin/bash-stack \
            --set-default CORE_SH $out/share/core.sh \
            --suffix PATH : ${with pkgs; lib.makeBinPath [ ucspi-tcp ] }
        '';
      };
    };
  };
}
