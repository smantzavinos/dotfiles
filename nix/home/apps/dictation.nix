{ pkgs }:

let
  # Create simple dictation script that uses whisper-input (already available)
  dictation-script = pkgs.writeShellScriptBin "dictation-toggle" ''
    #!/usr/bin/env bash
    
    STATE_FILE="/tmp/dictation-state"
    
    if [ -f "$STATE_FILE" ]; then
      # Stop dictation
      pkill -f whisper-input || true
      rm -f "$STATE_FILE"
      ${pkgs.libnotify}/bin/notify-send "Dictation" "Stopped" --icon=audio-input-microphone
      echo "Dictation stopped"
    else
      # Start dictation
      whisper-input &
      touch "$STATE_FILE"
      ${pkgs.libnotify}/bin/notify-send "Dictation" "Started - Speak now" --icon=audio-input-microphone
      echo "Dictation started"
    fi
  '';

in
dictation-script