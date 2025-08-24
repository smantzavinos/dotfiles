# Tasks

## Completed Tasks

### KDE X11 Push-to-Talk Dictation Implementation ✅
**Date**: 2025-08-23

Implemented a complete dictation system for KDE Plasma on X11 using whisper.cpp:

#### Core Implementation:
- [x] Created `home/modules/dictation.nix` Home Manager module with full configuration options
- [x] Fetched whisper model SHA256 hash: `0mj3vbvaiyk5x2ids9zlp2g94a01l4qar9w109qcg3ikg0sfjdyc`
- [x] Integrated dictation module into `home.nix` with default configuration
- [x] Built and validated configuration successfully

#### Features Delivered:
- [x] **Push-to-talk functionality**: Meta+V to start, Meta+Shift+V to stop and transcribe
- [x] **CPU-only whisper.cpp**: Uses nixpkgs prebuilt `openai-whisper-cpp` package
- [x] **High-quality transcription**: Uses `ggml-medium.en.bin` model with beam search (bs=5)
- [x] **Direct typing**: Uses `xdotool type --clearmodifiers` to inject text into active window
- [x] **Audio recording**: 16 kHz mono WAV recording with sox for optimal Whisper compatibility
- [x] **KDE integration**: Desktop files with X-KDE-Shortcuts for global hotkey support
- [x] **Notifications**: Status updates via notify-send for user feedback
- [x] **Error handling**: Graceful handling of recording states and audio capture issues

#### Documentation:
- [x] Created comprehensive `README-dictation.md` with setup, usage, and troubleshooting
- [x] Updated main `README.md` with dictation shortcuts reference
- [x] Documented GPU acceleration roadmap with CUDA overlay example

#### Future GPU Support:
- [x] Created `overlays/whisper-cuda.nix` overlay for NVIDIA GPU acceleration
- [x] Documented GPU enablement process and expected performance improvements
- [x] Provided runtime configuration for GPU offloading (`-ngl 99`)

#### Configuration Options:
```nix
programs.dictation = {
  enable = true;
  model.url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.en.bin";
  model.sha256 = "0mj3vbvaiyk5x2ids9zlp2g94a01l4qar9w109qcg3ikg0sfjdyc";
  shortcuts.start = "Meta+V";
  shortcuts.stop = "Meta+Shift+V";
  hint = "Recording… press Stop to transcribe & type.";
  whisperPackage = pkgs.openai-whisper-cpp;
};
```

#### Build Validation:
- [x] Home Manager configuration builds successfully
- [x] Desktop files created with correct shortcuts
- [x] Scripts generated with proper tool references
- [x] Whisper model downloaded and referenced correctly

## Future Tasks

### GPU Acceleration Enhancement 🔄
**Priority**: Medium
**Estimated Effort**: 2-3 hours

- [ ] Test CUDA overlay on systems with NVIDIA GPUs (t5600, x1, t7910)
- [ ] Benchmark performance improvements with GPU acceleration
- [ ] Create system-specific flag for GPU dictation (e.g., `enableDictationGPU`)
- [ ] Document actual performance metrics and VRAM usage

### Model Selection Improvements 🔄
**Priority**: Low
**Estimated Effort**: 1-2 hours

- [ ] Add helper function to automatically fetch SHA256 for different models
- [ ] Create predefined model configurations (tiny, base, small, medium, large)
- [ ] Add model size and performance comparison documentation
- [ ] Consider automatic model selection based on system capabilities

### Advanced Features 🔄
**Priority**: Low
**Estimated Effort**: 3-4 hours

- [ ] Add language detection and multi-language support
- [ ] Implement custom vocabulary/context injection for better accuracy
- [ ] Add audio preprocessing options (noise reduction, gain control)
- [ ] Create dictation history and correction interface
- [ ] Add support for punctuation commands ("period", "comma", etc.)

### Integration Enhancements 🔄
**Priority**: Low
**Estimated Effort**: 2-3 hours

- [ ] Add Wayland support using wtype instead of xdotool
- [ ] Create clipboard fallback option for applications that don't accept synthetic typing
- [ ] Add application-specific behavior configuration
- [ ] Integrate with system-wide spell checking

### Testing and Quality Assurance 🔄
**Priority**: Medium
**Estimated Effort**: 2-3 hours

- [ ] Create automated tests for dictation module
- [ ] Test on all target systems (nixos, x1, t5600, t7910, msi_gs66, msi_ms16, vbox)
- [ ] Validate audio device compatibility across different hardware
- [ ] Performance testing with different model sizes

## Notes

### Implementation Decisions:
- **CPU-first approach**: Prioritized compatibility and ease of setup over performance
- **Direct typing**: Chose xdotool over clipboard to avoid interference with user's clipboard
- **Medium model default**: Balanced accuracy vs. speed for general use
- **KDE-specific**: Focused on X11/KDE integration as specified in requirements

### Technical Considerations:
- **String interpolation**: Fixed Nix string interpolation issues in shell scripts
- **Runtime directory**: Uses XDG_RUNTIME_DIR with fallback to /tmp for temporary files
- **Process management**: Graceful recording termination with SIGINT and timeout handling
- **Error handling**: Comprehensive error checking and user feedback via notifications

### Architecture Benefits:
- **Declarative**: Fully reproducible configuration via Nix
- **Modular**: Self-contained module that can be easily enabled/disabled
- **Configurable**: Extensive options for customization without code changes
- **Maintainable**: Clear separation of concerns and well-documented code