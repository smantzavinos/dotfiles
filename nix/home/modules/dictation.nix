{ config, lib, pkgs, ... }:

let
  cfg = config.programs.dictation;

  whisperModel = pkgs.fetchurl {
    url = cfg.model.url;
    sha256 = cfg.model.sha256;
  };

  dictationStart = pkgs.writeShellScriptBin "dictation-start" ''
    set -euo pipefail
    
    # Absolute paths for all binaries
    NOTIFY_SEND="${pkgs.libnotify}/bin/notify-send"
    XDOTOOL="${pkgs.xdotool}/bin/xdotool"
    SOX="${pkgs.sox}/bin/rec"
    
    RDIR="''${XDG_RUNTIME_DIR:-/tmp}/dictation"
    PIDFILE="$RDIR/rec.pid"
    WAVFILE="$RDIR/in.wav"
    ACTIVE_WINDOW_FILE="$RDIR/active_window"
    
    # Enhanced debug logging
    DEBUG_LOG="/tmp/dictation-debug.log"
    echo "=== $(date): dictation-start called ===" >> "$DEBUG_LOG"
    echo "Environment: DISPLAY=''${DISPLAY:-UNSET}, WAYLAND_DISPLAY=''${WAYLAND_DISPLAY:-UNSET}" >> "$DEBUG_LOG"
    
    mkdir -p "$RDIR"
    
    # Check if already recording
    if [ -f "$PIDFILE" ] && ps -p "$(cat "$PIDFILE")" >/dev/null 2>&1; then
      echo "Already recording, sending notification" >> "$DEBUG_LOG"
      $NOTIFY_SEND -a Dictation "Already recording" "Use Stop to transcribe."
      exit 0
    fi

    # Store the currently active window for text insertion later
    # Handle both X11 and Wayland contexts
    ACTIVE_WINDOW=""
    
    if [ -n "''${WAYLAND_DISPLAY:-}" ] || [ "''${XDG_SESSION_TYPE:-}" = "wayland" ]; then
      echo "Wayland session detected - window storage not available" >> "$DEBUG_LOG"
      # On Wayland, we can't reliably get/store window IDs across processes
      # Focus will be handled differently in dictation-stop
    else
      echo "X11 session detected - storing active window" >> "$DEBUG_LOG"
      ACTIVE_WINDOW="$($XDOTOOL getactivewindow 2>> "$DEBUG_LOG" || echo "")"
      if [ -n "$ACTIVE_WINDOW" ]; then
        echo "$ACTIVE_WINDOW" > "$ACTIVE_WINDOW_FILE"
        echo "Stored active window ID: $ACTIVE_WINDOW" >> "$DEBUG_LOG"
      else
        echo "WARNING: Could not get active window ID" >> "$DEBUG_LOG"
      fi
    fi

    # Clean up any existing audio file
    rm -f "$WAVFILE" 2>/dev/null || true

    # Start recording with enhanced error handling
    echo "Starting audio recording..." >> "$DEBUG_LOG"
    
    # Start sox recording in background and capture PID properly
    $SOX -q -c 1 -r 16000 -b 16 -e signed-integer "$WAVFILE" >/dev/null 2>> "$DEBUG_LOG" &
    REC_PID=$!
    
    # Brief delay to check if sox started successfully
    sleep 0.1
    if ! ps -p "$REC_PID" >/dev/null 2>&1; then
      echo "ERROR: Audio recording process failed to start or crashed immediately" >> "$DEBUG_LOG"
      $NOTIFY_SEND -a Dictation "Recording Failed" "Check microphone permissions/availability"
      exit 1
    fi
    
    echo $REC_PID > "$PIDFILE"
    
    echo "Recording started with PID: $REC_PID" >> "$DEBUG_LOG"
    $NOTIFY_SEND -a Dictation "Dictation started" "${cfg.hint}"
  '';

  dictationStop = pkgs.writeShellScriptBin "dictation-stop" ''
    set -euo pipefail
    
    # Absolute paths for all binaries to avoid PATH issues
    NOTIFY_SEND="${pkgs.libnotify}/bin/notify-send"
    SOPS="${pkgs.sops}/bin/sops"
    YQ="${pkgs.yq-go}/bin/yq"
    CURL="${pkgs.curl}/bin/curl"
    XDOTOOL="${pkgs.xdotool}/bin/xdotool"
    XCLIP="${pkgs.xclip}/bin/xclip"
    STAT="${pkgs.coreutils}/bin/stat"
    NPROC="${pkgs.coreutils}/bin/nproc"
    
    # Enhanced debug logging with environment diagnostics
    DEBUG_LOG="/tmp/dictation-debug.log"
    echo "=== $(date): dictation-stop called ===" >> "$DEBUG_LOG"
    echo "Environment: PWD=$PWD, USER=$(whoami)" >> "$DEBUG_LOG"
    echo "X11/Wayland: DISPLAY=''${DISPLAY:-UNSET}, WAYLAND_DISPLAY=''${WAYLAND_DISPLAY:-UNSET}" >> "$DEBUG_LOG"
    echo "Auth: XAUTHORITY=''${XAUTHORITY:-UNSET}, XDG_SESSION_TYPE=''${XDG_SESSION_TYPE:-UNSET}" >> "$DEBUG_LOG"
    echo "DBus: DBUS_SESSION_BUS_ADDRESS=''${DBUS_SESSION_BUS_ADDRESS:-UNSET}" >> "$DEBUG_LOG"
    echo "Runtime: XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-UNSET}" >> "$DEBUG_LOG"
    
    # Detect session type for proper tool selection
    IS_WAYLAND="false"
    if [ -n "''${WAYLAND_DISPLAY:-}" ] || [ "''${XDG_SESSION_TYPE:-}" = "wayland" ]; then
      IS_WAYLAND="true"
      echo "Detected Wayland session" >> "$DEBUG_LOG"
    else
      echo "Detected X11 session" >> "$DEBUG_LOG"
    fi
    
    RDIR="''${XDG_RUNTIME_DIR:-/tmp}/dictation"
    PIDFILE="$RDIR/rec.pid"
    WAVFILE="$RDIR/in.wav"
    ACTIVE_WINDOW_FILE="$RDIR/active_window"
    
    echo "Files: PIDFILE=$PIDFILE, WAVFILE=$WAVFILE" >> "$DEBUG_LOG"
    
    # Check if recording was started
    if [ ! -f "$PIDFILE" ]; then
      echo "ERROR: PIDFILE not found: $PIDFILE" >> "$DEBUG_LOG"
      $NOTIFY_SEND -a Dictation "Not recording" "Press Start first."
      exit 1
    fi

    # Stop recording process
    PID="$(cat "$PIDFILE")"
    if ps -p "$PID" >/dev/null 2>&1; then
      echo "Stopping recording process $PID" >> "$DEBUG_LOG"
      kill -INT "$PID" 2>/dev/null || true
      # Wait for graceful shutdown with timeout
      for i in $(seq 1 50); do
        if ! ps -p "$PID" >/dev/null 2>&1; then break; fi
        sleep 0.05
      done
      # Force kill if still running
      if ps -p "$PID" >/dev/null 2>&1; then
        kill -9 "$PID" 2>/dev/null || true
        sleep 0.1
      fi
    fi
    rm -f "$PIDFILE"

    # Check audio file with minimum duration requirement
    if [ ! -s "$WAVFILE" ]; then
      echo "ERROR: No audio file or empty: $WAVFILE" >> "$DEBUG_LOG"
      $NOTIFY_SEND -a Dictation "No audio captured" "Try recording longer (2+ seconds)."
      exit 1
    fi
    
    WAVFILE_SIZE="$($STAT -c%s "$WAVFILE")"
    echo "Audio file: $WAVFILE_SIZE bytes" >> "$DEBUG_LOG"
    
    # Minimum file size check (roughly 1.5 seconds at 16kHz mono 16-bit)
    MIN_SIZE=48000
    if [ "$WAVFILE_SIZE" -lt "$MIN_SIZE" ]; then
      echo "WARNING: Audio file too small ($WAVFILE_SIZE < $MIN_SIZE), may produce empty transcription" >> "$DEBUG_LOG"
    fi
    
    $NOTIFY_SEND -a Dictation "Transcribing..." "Processing audio..."

    # Transcription with hardened API key loading
    if [ "${lib.boolToString cfg.useAPI}" = "true" ]; then
      echo "Using API transcription: ${cfg.apiProvider}" >> "$DEBUG_LOG"
      
      # Load API keys with absolute paths and proper error handling
      SECRETS_FILE="/home/spiros/dotfiles/nix/secrets/ai-api-keys.sops.yaml"
      SOPS_KEY_FILE="/home/spiros/.config/sops/age/keys.txt"
      
      if [ ! -f "$SECRETS_FILE" ]; then
        echo "ERROR: Secrets file not found: $SECRETS_FILE" >> "$DEBUG_LOG"
        $NOTIFY_SEND -a Dictation "Error" "Secrets file missing"
        exit 1
      fi
      
      if [ ! -f "$SOPS_KEY_FILE" ]; then
        echo "ERROR: SOPS key file not found: $SOPS_KEY_FILE" >> "$DEBUG_LOG"
        $NOTIFY_SEND -a Dictation "Error" "SOPS key file missing"
        exit 1
      fi
      
      # Decrypt and load API keys
      echo "Loading API keys from $SECRETS_FILE" >> "$DEBUG_LOG"
      if ! API_KEYS="$(SOPS_AGE_KEY_FILE="$SOPS_KEY_FILE" $SOPS -d "$SECRETS_FILE" 2>> "$DEBUG_LOG")"; then
        echo "ERROR: Failed to decrypt secrets" >> "$DEBUG_LOG"
        $NOTIFY_SEND -a Dictation "Error" "Failed to decrypt API keys"
        exit 1
      fi
      
      if ! eval "$(echo "$API_KEYS" | $YQ eval -r '. | to_entries | .[] | "export \(.key)=\(.value)"')" 2>> "$DEBUG_LOG"; then
        echo "ERROR: Failed to parse API keys" >> "$DEBUG_LOG"
        $NOTIFY_SEND -a Dictation "Error" "Failed to parse API keys"
        exit 1
      fi
      
      echo "API keys loaded successfully" >> "$DEBUG_LOG"
      
      # API transcription with provider-specific handling
      case "${cfg.apiProvider}" in
        "openai")
          if [ -z "''${OPENAI_API_KEY:-}" ]; then
            echo "ERROR: OpenAI API key not found" >> "$DEBUG_LOG"
            $NOTIFY_SEND -a Dictation "Error" "OpenAI API key missing"
            exit 1
          fi
          
          echo "Making OpenAI API call (key length: ''${#OPENAI_API_KEY})" >> "$DEBUG_LOG"
          
          API_RESPONSE="$($CURL -s -w "\nHTTP_CODE:%{http_code}" -X POST \
            -H "Authorization: Bearer $OPENAI_API_KEY" \
            -H "Content-Type: multipart/form-data" \
            -F "file=@$WAVFILE" \
            -F "model=whisper-1" \
            -F "response_format=text" \
            https://api.openai.com/v1/audio/transcriptions 2>> "$DEBUG_LOG")"
          
          HTTP_CODE="$(echo "$API_RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)"
          OUT="$(echo "$API_RESPONSE" | sed '/HTTP_CODE:/d' | sed -e 's/^[[:space:]]*//; s/[[:space:]]*$//')"
          
          echo "OpenAI response: HTTP $HTTP_CODE, text: '$OUT'" >> "$DEBUG_LOG"
          
          if [ "$HTTP_CODE" != "200" ]; then
            echo "ERROR: OpenAI API HTTP error $HTTP_CODE" >> "$DEBUG_LOG"
            $NOTIFY_SEND -a Dictation "API Error" "OpenAI HTTP $HTTP_CODE"
            exit 1
          fi
          ;;
          
        "groq")
          if [ -z "''${GROQ_API_KEY:-}" ]; then
            echo "ERROR: Groq API key not found" >> "$DEBUG_LOG"
            $NOTIFY_SEND -a Dictation "Error" "Groq API key missing"
            exit 1
          fi
          
          echo "Making Groq API call" >> "$DEBUG_LOG"
          
          API_RESPONSE="$($CURL -s -w "\nHTTP_CODE:%{http_code}" -X POST \
            -H "Authorization: Bearer $GROQ_API_KEY" \
            -H "Content-Type: multipart/form-data" \
            -F "file=@$WAVFILE" \
            -F "model=whisper-large-v3" \
            -F "response_format=text" \
            https://api.groq.com/openai/v1/audio/transcriptions 2>> "$DEBUG_LOG")"
          
          HTTP_CODE="$(echo "$API_RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)"
          OUT="$(echo "$API_RESPONSE" | sed '/HTTP_CODE:/d' | sed -e 's/^[[:space:]]*//; s/[[:space:]]*$//')"
          
          echo "Groq response: HTTP $HTTP_CODE, text: '$OUT'" >> "$DEBUG_LOG"
          
          if [ "$HTTP_CODE" != "200" ]; then
            echo "ERROR: Groq API HTTP error $HTTP_CODE" >> "$DEBUG_LOG"
            $NOTIFY_SEND -a Dictation "API Error" "Groq HTTP $HTTP_CODE"
            exit 1
          fi
          ;;
          
        *)
          echo "ERROR: Unknown API provider: ${cfg.apiProvider}" >> "$DEBUG_LOG"
          $NOTIFY_SEND -a Dictation "Error" "Unknown API provider"
          exit 1
          ;;
      esac
      
      # Validate transcription result
      if [ -z "$OUT" ]; then
        echo "WARNING: Empty transcription result (audio too short/quiet?)" >> "$DEBUG_LOG"
        $NOTIFY_SEND -a Dictation "Empty Result" "Try speaking louder/longer"
        exit 1
      fi
      
      if echo "$OUT" | grep -qi "error"; then
        echo "ERROR: API returned error: $OUT" >> "$DEBUG_LOG"
        $NOTIFY_SEND -a Dictation "API Error" "Transcription failed"
        exit 1
      fi
      
    else
      echo "Using local whisper.cpp processing" >> "$DEBUG_LOG"
      OUT="$(${cfg.whisperPackage}/bin/whisper-cpp \
        -m ${whisperModel} \
        -f "$WAVFILE" \
        -t "$($NPROC)" \
        -bs 5 \
        -ng -nt -np 2>> "$DEBUG_LOG" | sed -e 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    fi

    echo "Transcription result (''${#OUT} chars): '$OUT'" >> "$DEBUG_LOG"

    # Enhanced text insertion with focus management and session type awareness
    TEXT_INSERTED="false"
    
    # Get stored active window from recording start
    WINDOW_ID=""
    if [ -f "$ACTIVE_WINDOW_FILE" ]; then
      WINDOW_ID="$(cat "$ACTIVE_WINDOW_FILE")"
      echo "Stored window ID: $WINDOW_ID" >> "$DEBUG_LOG"
    fi
    
    # Clear any stuck modifiers from global shortcut
    if [ "$IS_WAYLAND" = "false" ]; then
      $XDOTOOL keyup Super_L Super_R shift ctrl alt 2>> "$DEBUG_LOG" || true
      sleep 0.1
    fi
    
    # Method 1: Clipboard paste (most reliable for shortcuts)
    echo "Attempting clipboard paste method..." >> "$DEBUG_LOG"
    
    if [ "$IS_WAYLAND" = "true" ]; then
      # Wayland clipboard handling
      if command -v wl-copy >/dev/null 2>&1; then
        echo -n "$OUT" | wl-copy 2>> "$DEBUG_LOG"
        sleep 0.2
        # Use wtype for Wayland if available, otherwise try xdotool (XWayland)
        if command -v wtype >/dev/null 2>&1; then
          wtype -P ctrl -p v 2>> "$DEBUG_LOG" && TEXT_INSERTED="true"
        else
          $XDOTOOL key --delay 50 --clearmodifiers ctrl+v 2>> "$DEBUG_LOG" && TEXT_INSERTED="true"
        fi
      fi
    else
      # X11 clipboard handling with multiple clipboard targets
      if echo -n "$OUT" | $XCLIP -selection clipboard 2>> "$DEBUG_LOG"; then
        # Also set primary selection
        echo -n "$OUT" | $XCLIP -selection primary 2>> "$DEBUG_LOG" || true
        sleep 0.2
        
        # Focus stored window if available
        if [ -n "$WINDOW_ID" ]; then
          echo "Focusing stored window $WINDOW_ID" >> "$DEBUG_LOG"
          $XDOTOOL windowfocus "$WINDOW_ID" 2>> "$DEBUG_LOG" || true
          sleep 0.3
        fi
        
        # Paste with proper modifier clearing
        if $XDOTOOL key --delay 50 --clearmodifiers ctrl+v 2>> "$DEBUG_LOG"; then
          TEXT_INSERTED="true"
          echo "Clipboard paste successful" >> "$DEBUG_LOG"
        fi
      fi
    fi
    
    # Method 2: KDE/DBus clipboard integration
    if [ "$TEXT_INSERTED" = "false" ] && command -v qdbus >/dev/null 2>&1; then
      echo "Trying KDE DBus clipboard method..." >> "$DEBUG_LOG"
      if qdbus org.kde.klipper /klipper setClipboardContents "$OUT" 2>> "$DEBUG_LOG"; then
        sleep 0.2
        if [ -n "$WINDOW_ID" ]; then
          $XDOTOOL windowfocus "$WINDOW_ID" 2>> "$DEBUG_LOG" || true
          sleep 0.3
        fi
        if $XDOTOOL key --delay 50 --clearmodifiers ctrl+v 2>> "$DEBUG_LOG"; then
          TEXT_INSERTED="true"
          echo "KDE clipboard paste successful" >> "$DEBUG_LOG"
        fi
      fi
    fi
    
    # Method 3: Direct typing (fallback for apps that block paste)
    if [ "$TEXT_INSERTED" = "false" ] && [ "$IS_WAYLAND" = "false" ]; then
      echo "Attempting direct typing fallback..." >> "$DEBUG_LOG"
      
      if [ -n "$WINDOW_ID" ]; then
        if $XDOTOOL windowfocus "$WINDOW_ID" 2>> "$DEBUG_LOG"; then
          sleep 0.3
          if $XDOTOOL type --delay 10 --clearmodifiers -- "$OUT" 2>> "$DEBUG_LOG"; then
            TEXT_INSERTED="true"
            echo "Direct typing successful" >> "$DEBUG_LOG"
          fi
        fi
      fi
    fi
    
    # Method 4: Current window typing
    if [ "$TEXT_INSERTED" = "false" ] && [ "$IS_WAYLAND" = "false" ]; then
      echo "Attempting current window typing..." >> "$DEBUG_LOG"
      CURRENT_WINDOW="$($XDOTOOL getactivewindow 2>/dev/null || echo "")"
      if [ -n "$CURRENT_WINDOW" ]; then
        if $XDOTOOL windowfocus "$CURRENT_WINDOW" 2>> "$DEBUG_LOG"; then
          sleep 0.3
          if $XDOTOOL type --delay 10 --clearmodifiers -- "$OUT" 2>> "$DEBUG_LOG"; then
            TEXT_INSERTED="true"
            echo "Current window typing successful" >> "$DEBUG_LOG"
          fi
        fi
      fi
    fi
    
    # Clean up
    rm -f "$WAVFILE" "$ACTIVE_WINDOW_FILE" 2>/dev/null || true

    # Final status and notifications
    preview="$(printf '%s' "$OUT" | head -c 120)"
    
    if [ "$TEXT_INSERTED" = "true" ]; then
      echo "SUCCESS: Text insertion completed" >> "$DEBUG_LOG"
      [ -n "$preview" ] && $NOTIFY_SEND -a Dictation "Text Inserted" "$preview"
    else
      echo "WARNING: All text insertion methods failed" >> "$DEBUG_LOG"
      # Keep text in clipboard for manual paste
      if [ "$IS_WAYLAND" = "true" ]; then
        command -v wl-copy >/dev/null 2>&1 && echo -n "$OUT" | wl-copy 2>> "$DEBUG_LOG" || true
      else
        echo -n "$OUT" | $XCLIP -selection clipboard 2>> "$DEBUG_LOG" || true
      fi
      $NOTIFY_SEND -a Dictation "Text Ready" "Copied to clipboard: $preview"
    fi
    
    echo "=== $(date): dictation-stop completed (inserted=$TEXT_INSERTED) ===" >> "$DEBUG_LOG"
    echo "" >> "$DEBUG_LOG"
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
    enable = lib.mkEnableOption "voice dictation via whisper.cpp or API (type into active window)";

    useAPI = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use API-based transcription instead of local processing (faster but requires internet).";
    };

    apiProvider = lib.mkOption {
      type = lib.types.enum [ "openai" "groq" ];
      default = "openai";
      description = "API provider for transcription (openai or groq).";
    };

    model.url = lib.mkOption {
      type = lib.types.str;
      default = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin";
      description = "URL to a ggml/gguf Whisper model (used only when useAPI = false).";
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
      description = "Package providing whisper-cli (used only when useAPI = false).";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      sox
      xdotool
      libnotify
      coreutils
      dictationStart
      dictationStop
    ] ++ lib.optionals cfg.useAPI [
      curl         # For API calls
      sops         # For decrypting API keys
      yq-go        # For parsing YAML secrets
      xclip        # For X11 clipboard operations
      wl-clipboard # For Wayland clipboard operations
      libsForQt5.qttools # For qdbus (KDE clipboard integration)
    ] ++ lib.optionals (!cfg.useAPI) [
      cfg.whisperPackage  # Only include whisper.cpp if not using API
    ];

    # Install launchers for KDE global shortcuts
    home.file.".local/share/applications/dictation-start.desktop".text = startDesktop;
    home.file.".local/share/applications/dictation-stop.desktop".text  = stopDesktop;
  };
}