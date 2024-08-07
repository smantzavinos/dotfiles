# self: super: {
#   python3Packages = super.python3Packages // {
#     fsspec = super.python3Packages.fsspec.overrideAttrs (oldAttrs: rec {
#       nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ self.python3Packages.hatchling ];
#     });
#   };
# }

self: super: {
  python3Packages = super.python3Packages // {
    fsspec = super.python3Packages.fsspec.overrideAttrs (oldAttrs: rec {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ self.python3Packages.hatchling ];
      buildInputs = (oldAttrs.buildInputs or []) ++ [ self.python3Packages.hatchling ];
    });
    hatchling = super.python3Packages.hatchling.overridePythonAttrs (old: {
      buildInputs = (old.buildInputs or []) ++ [ self.python3Packages.setuptools-scm ];
    });
  };
}
