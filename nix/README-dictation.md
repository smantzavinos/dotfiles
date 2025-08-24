# Dictation (KDE X11) with whisper.cpp — Push-to-Talk, Types into Active Window

**Hotkeys**: Start = Meta+V, Stop & Type = Meta+Shift+V

## How it works
- Start: begins mic capture with `sox` at 16 kHz mono WAV.
- Stop: finalizes WAV, transcribes with `whisper.cpp` (CPU), then **types** the result into the focused window using `xdotool type`.
- CPU-only now (cache-backed nixpkgs build). Model default: `ggml-medium.en.bin` for better accuracy.

## Install
1. `modules/dictation.nix` added; import it in `home.nix`.
2. Set:
   - `programs.dictation.enable = true;`
   - `model.url = https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.en.bin`
   - `model.sha256 = $(nix-prefetch-url <url>)`
3. `home-manager switch`
4. Verify shortcuts in KDE Settings (they're prefilled via desktop files).

## Usage
- Press **Meta+V**, speak; press **Meta+Shift+V** to transcribe and type.
- If an app behaves oddly with synthetic typing, try releasing modifiers fully before Stop. (Alternatively, switch to paste in the module by changing the stop script, but default remains typing.)

## Tuning
- Model: choose `small.en` for faster CPU, keep `medium.en` for accuracy.
- Threads: `-t $(nproc)` uses all cores.
- Quality: `-bs 5` (beam size) favors accuracy; reduce for speed.

## Roadmap: GPU (CUDA) later
To enable NVIDIA GPU acceleration you must build whisper.cpp with cuBLAS on Nix. This requires a small overlay and downloads of CUDA toolchains (multi-GB).

Create `overlays/whisper-cuda.nix`:
```nix
final: prev: {
  openai-whisper-cpp-cuda = prev.openai-whisper-cpp.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ prev.cudaPackages.cuda_nvcc ];
    buildInputs       = (old.buildInputs or [])       ++ [
      prev.cudaPackages.cudatoolkit
      prev.cudaPackages.libcublas
    ];
    WHISPER_CUBLAS = "1";
    GGML_CUDA = "1";
  });
}
```

Enable later (not now):

```nix
{
  nixpkgs.overlays = [ (import ./overlays/whisper-cuda.nix) ];
  programs.dictation.whisperPackage = pkgs.openai-whisper-cpp-cuda;
}
```

At runtime add `-ngl 99` to offload as many layers as possible:

```
... whisper-cli ... -ngl 99 -otxt -of - ...
```

**Notes**

* Expect ~2–6× speedups depending on GPU and model size.
* CUDA toolchains add several GB to the Nix store; the compile itself is quick.

## Configuration Options

The dictation module supports the following options in your `home.nix`:

```nix
programs.dictation = {
  enable = true;  # Enable the dictation system
  
  model.url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.en.bin";
  model.sha256 = "0mj3vbvaiyk5x2ids9zlp2g94a01l4qar9w109qcg3ikg0sfjdyc";
  
  hint = "Recording… press Stop to transcribe & type.";  # Notification text
  
  shortcuts.start = "Meta+V";        # Global shortcut to start recording
  shortcuts.stop = "Meta+Shift+V";   # Global shortcut to stop and transcribe
  
  whisperPackage = pkgs.openai-whisper-cpp;  # Package to use (CPU by default)
};
```

## Available Models

You can use different Whisper models by changing the `model.url` and updating the `model.sha256`:

- **tiny.en**: Fastest, least accurate
  - URL: `https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en.bin`
- **base.en**: Good balance of speed and accuracy
  - URL: `https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin`
- **small.en**: Better accuracy, moderate speed
  - URL: `https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin`
- **medium.en**: High accuracy, slower (default)
  - URL: `https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.en.bin`
- **large-v3**: Highest accuracy, slowest
  - URL: `https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin`

To change models:
1. Update the `model.url` in your configuration
2. Run `nix-prefetch-url <new-url>` to get the SHA256 hash
3. Update `model.sha256` with the new hash
4. Run `home-manager switch`

## Troubleshooting

### Audio Issues
- Ensure your microphone is working: `arecord -l` to list devices
- Test recording manually: `sox -d test.wav` (Ctrl+C to stop)
- Check PulseAudio/PipeWire mixer levels

### Shortcut Issues
- Verify shortcuts in KDE System Settings → Shortcuts → Custom Shortcuts
- Look for "Dictation Start" and "Dictation Stop & Type" entries
- If shortcuts don't work, try manually running the desktop files or scripts

### Transcription Issues
- Check if whisper model downloaded correctly: look in `/nix/store/` for the model file
- Test whisper manually: `whisper-cli -m /path/to/model -f audio.wav`
- Increase beam size (`-bs`) for better accuracy at cost of speed

### Typing Issues
- Ensure `xdotool` is working: `xdotool type "test"`
- Some applications may not accept synthetic typing; consider modifying the script to use clipboard instead
- Try releasing all modifier keys before pressing Stop shortcut