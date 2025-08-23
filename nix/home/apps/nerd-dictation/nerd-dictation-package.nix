{ lib
, stdenv
, fetchFromGitHub
, python3
, xdotool
, pulseaudio
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "nerd-dictation";
  version = "unstable-2025-04-01";

  src = fetchFromGitHub {
    owner = "ideasman42";
    repo = "nerd-dictation";
    rev = "03ce043a6d569a5bb9a715be6a8e45d8ba0930fd";
    sha256 = "sha256-M/05SUAe2Fq5I40xuWZ/lTn1+mNLr4Or6o0yKfylVk8=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    python3
    xdotool
    pulseaudio
  ];

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/bin
    mkdir -p $out/share/nerd-dictation
    
    # Install the main script
    cp nerd-dictation $out/bin/
    chmod +x $out/bin/nerd-dictation
    
    # Install examples and other files
    if [ -d examples ]; then
      cp -r examples $out/share/nerd-dictation/
    fi
    if [ -f readme.rst ]; then
      cp readme.rst $out/share/nerd-dictation/
    fi
    
    # Wrap the script to ensure dependencies are available
    wrapProgram $out/bin/nerd-dictation \
      --prefix PATH : ${lib.makeBinPath [ python3 xdotool pulseaudio ]}
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Simple, hackable offline speech to text - using the VOSK-API";
    homepage = "https://github.com/ideasman42/nerd-dictation";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "nerd-dictation";
  };
}