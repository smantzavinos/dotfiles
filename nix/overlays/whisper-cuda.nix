final: prev: {
  openai-whisper-cpp-cuda = prev.openai-whisper-cpp.overrideAttrs (old: {
    pname = "openai-whisper-cpp-cuda";
    
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ 
      prev.cudaPackages.cuda_nvcc 
    ];
    
    buildInputs = (old.buildInputs or []) ++ [
      prev.cudaPackages.cudatoolkit
      prev.cudaPackages.libcublas
      prev.cudaPackages.libcurand
      prev.cudaPackages.libcufft
    ];
    
    # Enable CUDA support
    cmakeFlags = (old.cmakeFlags or []) ++ [
      "-DWHISPER_CUBLAS=ON"
      "-DGGML_CUDA=ON"
    ];
    
    # Set environment variables for build
    WHISPER_CUBLAS = "1";
    GGML_CUDA = "1";
    
    meta = (old.meta or {}) // {
      description = (old.meta.description or "OpenAI Whisper C++ implementation") + " (with CUDA support)";
    };
  });
}