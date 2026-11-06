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
                c_include_path = pkgs.lib.makeSearchPathOutput "dev" "include" libs;
                library_path = pkgs.lib.makeSearchPathOutput "out" "lib" libs;
              in ''
              export C_INCLUDE_PATH="${c_include_path}"
              export LIBRARY_PATH="${library_path}"

              ${./setup.sh} --cache-dir "$HOME"/.cache/wsl2-minix-fs "$@"
            '';
          };
        }
      );
    };
}
