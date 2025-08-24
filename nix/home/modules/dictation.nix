{ config, lib, pkgs, ... }:

let
  cfg = config.programs.dictation;

  whisperModel = pkgs.fetchurl {
    url = cfg.model.url;
    sha256 = cfg.model.sha256;
  };

  dictationStart = pkgs.writeShellScriptBin "dictation-start" ''
    set -euo pipefail
    RDIR="''${XDG_RUNTIME_DIR:-/tmp}/dictation"
    PIDFILE="$RDIR/rec.pid"
    WAVFILE="$RDIR/in.wav"
    
    mkdir -p "$RDIR"
    if [ -f "$PIDFILE" ] && ps -p "$(cat "$PIDFILE")" >/dev/null 2>&1; then
      ${pkgs.libnotify}/bin/notify-send -a Dictation "Already recording" "Use Stop to transcribe."
      exit 0
    fi
    # 16 kHz mono PCM WAV (ideal for Whisper)
    ${pkgs.sox}/bin/rec -q -c 1 -r 16000 -b 16 -e signed-integer "$WAVFILE" >/dev/null 2>&1 &
    echo $! > "$PIDFILE"
    ${pkgs.libnotify}/bin/notify-send -a Dictation "Dictation started" "${cfg.hint}"
  '';

  dictationStop = pkgs.writeShellScriptBin "dictation-stop" ''
    set -euo pipefail
    RDIR="''${XDG_RUNTIME_DIR:-/tmp}/dictation"
    PIDFILE="$RDIR/rec.pid"
    WAVFILE="$RDIR/in.wav"
    
    if [ ! -f "$PIDFILE" ]; then
      ${pkgs.libnotify}/bin/notify-send -a Dictation "Not recording" "Press Start first."
      exit 1
    fi

    PID="$(cat "$PIDFILE")"
    if ps -p "$PID" >/dev/null 2>&1; then
      # graceful stop to finalize WAV
      kill -INT "$PID" 2>/dev/null || true
      for i in $(seq 1 50); do
        if ! ps -p "$PID" >/dev/null 2>&1; then break; fi
        sleep 0.05
      done
    fi
    rm -f "$PIDFILE"

    if [ ! -s "$WAVFILE" ]; then
      ${pkgs.libnotify}/bin/notify-send -a Dictation "No audio captured" "Try again."
      exit 1
    fi

    # Transcribe with whisper.cpp (CPU), fully threaded + beam search for quality
    OUT="$(${cfg.whisperPackage}/bin/whisper-cli \
      -m ${whisperModel} \
      -f "$WAVFILE" \
      -t "$(${pkgs.coreutils}/bin/nproc)" \
      -bs 5 \
      -otxt -of - 2>/dev/null | sed -e 's/^[[:space:]]*//; s/[[:space:]]*$//')"

    # Type into active X11 window (no clipboard)
    ${pkgs.xdotool}/bin/xdotool type --delay 0 --clearmodifiers -- "$OUT"

    rm -f "$WAVFILE" || true

    preview="$(printf '%s' "$OUT" | head -c 120)"
    [ -n "$preview" ] && ${pkgs.libnotify}/bin/notify-send -a Dictation "Inserted text" "$preview"
  '';

  startDesktop = ''
    [Desktop Entry]
    Type=Application
    Name=Dictation Start
    Exec=${dictationStart}/bin/dictation-start
    Icon=media-record
    NoDisplay=true
    X-KDE-Shortcuts=${cfg.shortcuts.start}
  '';

  stopDesktop = ''
    [Desktop Entry]
    Type=Application
    Name=Dictation Stop & Type
    Exec=${dictationStop}/bin/dictation-stop
    Icon=media-playback-stop
    NoDisplay=true
    X-KDE-Shortcuts=${cfg.shortcuts.stop}
  '';
in
{
  options.programs.dictation = {
    enable = lib.mkEnableOption "voice dictation via whisper.cpp (type into active window)";

    model.url = lib.mkOption {
      type = lib.types.str;
      default = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.en.bin";
      description = "URL to a ggml/gguf Whisper model (default: medium.en for accuracy).";
    };

    model.sha256 = lib.mkOption {
      type = lib.types.str;
      example = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      description = "sha256 of the model (obtain via: nix-prefetch-url <url>).";
    };

    hint = lib.mkOption {
      type = lib.types.str;
      default = "Recording… press Stop to transcribe & type.";
      description = "Notification text shown when recording starts.";
    };

    shortcuts.start = lib.mkOption {
      type = lib.types.str;
      default = "Meta+V";
      description = "KDE global shortcut for Start.";
    };

    shortcuts.stop = lib.mkOption {
      type = lib.types.str;
      default = "Meta+Shift+V";
      description = "KDE global shortcut for Stop & Type.";
    };

    whisperPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.openai-whisper-cpp;
      description = "Package providing whisper-cli (CPU build by default).";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      cfg.whisperPackage
      sox
      xdotool
      libnotify
      coreutils
      dictationStart
      dictationStop
    ];

    # Install launchers for KDE global shortcuts
    home.file.".local/share/applications/dictation-start.desktop".text = startDesktop;
    home.file.".local/share/applications/dictation-stop.desktop".text  = stopDesktop;
  };
}