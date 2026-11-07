{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        {
          setup = pkgs.writeShellApplication {
            name = "setup";
            runtimeInputs = with pkgs; [
              coreutils
              gnumake
              gnugrep
              gnused
              diffutils
              gawk
              bc
              bash
              git
              python3
              pkg-config
              gcc
              flex
              bison
              pahole
              cpio
              qemu-utils
              rsync

              kmod
            ];

            text =
              let
                libs = with pkgs; [ elfutils openssl zlib ];
                pkg_config_path = pkgs.lib.makeSearchPathOutput "dev" "lib/pkgconfig" libs;
                c_include_path = pkgs.lib.makeSearchPathOutput "dev" "include" libs;
                library_path = pkgs.lib.makeSearchPathOutput "out" "lib" libs;
              in ''
              export PKG_CONFIG_PATH="${pkg_config_path}"
              export C_INCLUDE_PATH="${c_include_path}"
              export LIBRARY_PATH="${library_path}"

              set -- --cache-dir "$HOME"/.cache/wsl2-minix-fs "$@"

              ${builtins.readFile ./setup.sh}
            '';
          };

          test = pkgs.writeShellApplication {
            name = "test";
            runtimeInputs = with pkgs; [
              coreutils
              util-linux
            ];
            text = builtins.readFile ./test.sh;
          };
        }
      );
    };
}
