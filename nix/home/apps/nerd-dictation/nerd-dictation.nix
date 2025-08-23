{ config, lib, pkgs, ... }:

let
  nerd-dictation = pkgs.callPackage ./nerd-dictation-package.nix { };
  
  # Create a wrapper script that installs VOSK on first run
  nerd-dictation-wrapped = pkgs.writeShellScriptBin "nerd-dictation" ''
    # Check if VOSK is installed
    if ! ${pkgs.python3}/bin/python3 -c "import vosk" 2>/dev/null; then
      echo "VOSK not found. Installing VOSK Python package..."
      
      # Create a local Python environment
      VOSK_DIR="$HOME/.local/lib/python3.11/site-packages"
      mkdir -p "$VOSK_DIR"
      
      # Install VOSK using pip
      ${pkgs.python3}/bin/pip install --user vosk
      
      echo "VOSK installation complete."
    fi
    
    # Set up Python path to include user packages
    export PYTHONPATH="$HOME/.local/lib/python3.11/site-packages:$PYTHONPATH"
    
    # Run the actual nerd-dictation
    exec ${nerd-dictation}/bin/nerd-dictation "$@"
  '';
  
  # VOSK model download script
  vosk-model-downloader = pkgs.writeShellScriptBin "nerd-dictation-setup-model" ''
    MODEL_DIR="$HOME/.config/nerd-dictation"
    MODEL_URL="https://alphacephei.com/kaldi/models/vosk-model-small-en-us-0.15.zip"
    MODEL_FILE="vosk-model-small-en-us-0.15.zip"
    MODEL_EXTRACTED="vosk-model-small-en-us-0.15"
    
    echo "Setting up VOSK language model for nerd-dictation..."
    
    mkdir -p "$MODEL_DIR"
    cd "$MODEL_DIR"
    
    if [ ! -d "model" ]; then
      echo "Downloading VOSK model..."
      ${pkgs.wget}/bin/wget "$MODEL_URL" -O "$MODEL_FILE"
      
      echo "Extracting model..."
      ${pkgs.unzip}/bin/unzip "$MODEL_FILE"
      
      echo "Setting up model directory..."
      mv "$MODEL_EXTRACTED" model
      
      echo "Cleaning up..."
      rm "$MODEL_FILE"
      
      echo "VOSK model setup complete!"
      echo "Model installed at: $MODEL_DIR/model"
    else
      echo "VOSK model already exists at: $MODEL_DIR/model"
    fi
  '';

in
{
  home.packages = [
    nerd-dictation-wrapped
    vosk-model-downloader
    pkgs.xdotool
    pkgs.pulseaudio
  ];
}