{
  inputs = {
    #! replace this with unstable or the latest version if you want to 
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        #! fill out desktop information
        desktop_item = pkgs.makeDesktopItem {
          name = "my_pkg";
          desktopName = "my_pkg";
          exec = " %u";
          mimeTypes = [ "" ];
        };
      in
      {
        defaultPackage = pkgs.rustPlatform.buildRustPackage rec {
          #! add info here as well
          pname = "my_pkg";
          version = "0.1";
          src = self;

          nativeBuildInputs = with pkgs; [
            # basic
            rustc
            cargo

            # this hook is needed for desktop items
            copyDesktopItems
          ];

          desktopItems = [ desktop_item ];
          #! add actual sha256 from error here
          cargoSha256 = pkgs.lib.fakesha256;
        };

        devShells.default = pkgs.mkShell {
          # this is needed to run cargoabout on commit
          shellHook = ''
            git config core.hooksPath .githooks
          '';
          buildInputs = with pkgs;
            [
              # basic
              rustc
              cargo

              # for development
              rustfmt

              # custom
              cargo-about
              upx

              #! needed for SSL, uncomment if you want it
              #openssl
              #pkg-config

              git
              convco
            ];

          RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
        };


      }
    );
}
