{
  lib,
  stdenv,
  buildPythonPackage,
  callPackage,
  setuptools,
  bcrypt,
  certifi,
  cffi,
  cryptography-vectors ? (callPackage ./vectors.nix { }),
  fetchFromGitHub,
  isPyPy,
  libiconv,
  libxcrypt,
  openssl,
  pkg-config,
  pretend,
  pytest-xdist,
  pytestCheckHook,
  pythonOlder,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "cryptography";
  version = "44.0.2"; # Also update the hash in vectors.nix
  pyproject = true;

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "pyca";
    repo = "cryptography";
    tag = version;
    hash = "sha256-nXwW6v+U47/+CmjhREHcuQ7QQi/b26gagWBQ3F16DuQ=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-HbUsV+ABE89UvhCRZYXr+Q/zRDKUy+HgCVdQFHqaP4o=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "--benchmark-disable" ""
  '';

  build-system = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    pkg-config
    setuptools
  ] ++ lib.optionals (!isPyPy) [ cffi ];

  buildInputs =
    [ openssl ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      libiconv
    ]
    ++ lib.optionals (pythonOlder "3.9") [ libxcrypt ];

  dependencies = lib.optionals (!isPyPy) [ cffi ];

  optional-dependencies.ssh = [ bcrypt ];

  nativeCheckInputs = [
    certifi
    cryptography-vectors
    pretend
    pytestCheckHook
    pytest-xdist
  ] ++ optional-dependencies.ssh;

  pytestFlagsArray = [ "--disable-pytest-warnings" ];

  disabledTestPaths = [
    # save compute time by not running benchmarks
    "tests/bench"
  ];

  passthru = {
    vectors = cryptography-vectors;
  };

  meta = with lib; {
    description = "Package which provides cryptographic recipes and primitives";
    longDescription = ''
      Cryptography includes both high level recipes and low level interfaces to
      common cryptographic algorithms such as symmetric ciphers, message
      digests, and key derivation functions.
    '';
    homepage = "https://github.com/pyca/cryptography";
    changelog =
      "https://cryptography.io/en/latest/changelog/#v" + replaceStrings [ "." ] [ "-" ] version;
    license = with licenses; [
      asl20
      bsd3
      psfl
    ];
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
