{ pkgs, dictation }:

let
  nerd-dictation = dictation.packages.x86_64-linux.nerd-dictation;
  
  dictation-hotkeys = pkgs.python3Packages.buildPythonPackage {
    pname = "dictation-hotkeys";
    version = "1.0";

    src = pkgs.fetchFromGitHub {
      owner = "jtara1";
      repo = "dictation";
      rev = "a67e577effba44689a497b99037f9e2bb52779f4";
      sha256 = "sha256-v6ifjX/NL8Z41cj2fMuh/mVi9S0btNTJybGDjKvQqCY=";
    };

    sourceRoot = "source/dictation/src";

    propagatedBuildInputs = with pkgs.python3Packages; [ pynput ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    postInstall = ''
      mkdir -p $out/lib

      cp dictation_hotkeys/hotkeys.py $out/lib/
      chmod +x $out/lib/hotkeys.py

      cp toggle-typing.sh $out/lib/
      chmod +x $out/lib/toggle-typing.sh

      wrapProgram $out/lib/toggle-typing.sh --prefix PATH : ${pkgs.lib.makeBinPath [ nerd-dictation pkgs.screen ]}
    '';

    meta = {
      description = "Press a button, computer types what you speak";
      maintainers = [ "jtara1" ];
      license = pkgs.lib.licenses.asl20;
    };
  };
in
dictation-hotkeys