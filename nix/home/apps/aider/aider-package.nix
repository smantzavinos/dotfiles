{ lib, pkgs }:

let
  overlay = import /home/spiros/dotfiles/nix/home/apps/aider/aider-overlay.nix;
  pkgs = import <nixpkgs> { overlays = [ overlay ]; };
  poetry2nix = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "nix-community";
    repo = "poetry2nix";
    rev = "2024.8.145710";
    sha256 = "6FVPz1WzHak65xJQg8tRjVyFEWMesGxfskKaCxDUnRk=";
  }) {};
in
poetry2nix.mkPoetryEnv {
  projectDir = /home/spiros/dotfiles/nix/home/apps/aider;
  extraPackages = ep: (with ep; [
    hatchling
    fsspec
  ]);
}

# let
#   overlay = import /home/spiros/dotfiles/nix/home/apps/aider/overlays/aider-overlay.nix;
#   pkgs = import <nixpkgs> { overlays = [ overlay ]; };
#   poetry2nix = pkgs.callPackage (pkgs.fetchFromGitHub {
#     owner = "nix-community";
#     repo = "poetry2nix";
#     rev = "2024.8.145710";  # Use the latest release
#     sha256 = "your-correct-hash-here";  # Corrected sha256 hash from nix-prefetch-github
#   }) {};
# in
# poetry2nix.mkPoetryEnv {
#   projectDir = /home/spiros/dotfiles/nix/home/apps/aider;  # Path to the directory containing pyproject.toml
# }




# { pkgs, lib, buildPythonPackage, fetchPypi, python3Packages }:
# { lib, pkgs }:

# let
#   python3Packages = pkgs.python311Packages;
# in
# python3Packages.buildPythonPackage rec {
#   pname = "aider";
#   version = "0.2.4";

#   src = pkgs.fetchPypi {
#     inherit pname version;
#     sha256 = "1f0xfr2x5a687z6384p5rj8zdfbs1fxqa4agw9qgwk5mr6qgb8f8";
#   };

#   propagatedBuildInputs = with python3Packages; [
#     aiohttp
#     aiohappyeyeballs
#     aiosignal
#     annotated-types
#     anyio
#     attrs
#     backoff
#     beautifulsoup4
#     certifi
#     cffi
#     charset-normalizer
#     click
#     configargparse
#     diff-match-patch
#     diskcache
#     distro
#     filelock
#     flake8
#     frozenlist
#     fsspec
#     gitdb
#     gitpython
#     # grep-ast
#     h11
#     httpcore
#     httpx
#     huggingface-hub
#     idna
#     importlib-metadata
#     importlib-resources
#     jinja2
#     jsonschema
#     jsonschema-specifications
#     litellm
#     markdown-it-py
#     markupsafe
#     mccabe
#     mdurl
#     multidict
#     networkx
#     numpy
#     openai
#     packaging
#     pathspec
#     pillow
#     prompt-toolkit
#     pycodestyle
#     pycparser
#     pydantic
#     pydantic-core
#     pyflakes
#     pygments
#     pypandoc
#     python-dotenv
#     pyyaml
#     referencing
#     regex
#     requests
#     rich
#     rpds-py
#     scipy
#     smmap
#     sniffio
#     sounddevice
#     soundfile
#     soupsieve
#     tiktoken
#     tokenizers
#     tqdm
#     tree-sitter
#     tree-sitter-languages
#     typing-extensions
#     urllib3
#     wcwidth
#     yarl
#     zipp
#   ];

#   meta = with lib; {
#     description = "Aider is AI pair programming in your terminal.";
#     homepage = "https://aider.chat";
#     license = licenses.asl20; # Apache 2.0 License
#     maintainers = with maintainers; [ smantzavinos ];
#   };
# }
