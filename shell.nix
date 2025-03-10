let
  pkgs = import <nixpkgs> { };
  # Unstable Nix
  unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {};
  # Rust toolchain
  fenix = import (fetchTarball "https://github.com/nix-community/fenix/archive/main.tar.gz") {};
  rust_toolchain = fenix.combine [
    fenix.complete.toolchain
    fenix.targets.wasm32-unknown-unknown.latest.rust-std
  ];
  # Get project directory.
  pd = builtins.toString ./.;
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    rust_toolchain
    pkg-config
    gobject-introspection
    cargo-tauri
    nodejs
  ];

  buildInputs = with pkgs; [
    at-spi2-atk
    atkmm
    cairo
    gdk-pixbuf
    glib
    gtk3
    harfbuzz
    librsvg
    libsoup_3
    pango
    webkitgtk_4_1
    openssl
    wasm-pack
    unstable.wasm-bindgen-cli_0_2_100
    cargo-generate
    # dioxus-cli
    unstable.dioxus-cli
    dart-sass
    sqlite
  ];

  # Cargo
  TMPDIR = "${pd}/.cargo/target";
  CARGO_HOME = "${pd}/.cargo";
  CARGO_TARGET_DIR = "${pd}/.cargo/target";
  # Bootstrap
  BOOTSTRAP = "${pd}/.bootstrap";
  # Dioxus 
  # IP = "192.168.1.4";
  PORT = "8080";
  # Libraries
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.openssl pkgs.sqlite ];

  shellHook = ''
    #### Scripts ####
    export PATH="$PATH:${pd}/.bin" # Have to put this here, otherwise shell doesn't pick up direnv's PATH

    #### Dioxus ####
    # Export the current IP address.
    . .bin/updateip

    #### Cargo ####
    if [ ! -d $TMPDIR ]; then 
      mkdir -p $TMPDIR
    fi

    #### Bootstrap ####
    if [ ! -d $BOOTSTRAP ]; then 
      git clone https://github.com/twbs/bootstrap/
      mv bootstrap .bootstrap
    fi
  '';
}
