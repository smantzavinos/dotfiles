#!/nix/store/mjhcjikhxps97mq5z54j4gjjfzgmsir5-bash-5.2p37/bin/bash
set -euo pipefail
RDIR="${XDG_RUNTIME_DIR:-/tmp}/dictation"
PIDFILE="$RDIR/rec.pid"
WAVFILE="$RDIR/in.wav"

if [ ! -f "$PIDFILE" ]; then
  notify-send -a Dictation "Not recording" "Press Start first."
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
  notify-send -a Dictation "No audio captured" "Try again."
  exit 1
fi

# Transcribe with whisper.cpp using base model
OUT="$(whisper-cpp \
  -m ./ggml-base.en.bin \
  -f "$WAVFILE" \
  -t 4 \
  -ng -nt 2>/dev/null | sed -e 's/^[[:space:]]*//; s/[[:space:]]*$//')"

# Type into active X11 window (no clipboard)
xdotool type --delay 0 --clearmodifiers -- "$OUT"

rm -f "$WAVFILE" || true

preview="$(printf '%s' "$OUT" | head -c 120)"
[ -n "$preview" ] && notify-send -a Dictation "Inserted text" "$preview"
