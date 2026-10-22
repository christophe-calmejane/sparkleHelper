# SparkleHelper Changelog
All notable changes will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
- First public version

### Changed
- Updated WinSparkle to 0.9.4 (ARM64 support)
- Windows updates are now signed using EdDSA (ed25519) keys, like macOS (legacy DSA keys are still supported but deprecated by WinSparkle)
- `generate_dsa_keys.sh` generates EdDSA keys on Windows (files are still named dsa_pub.pem and dsa_priv.pem for backward compatibility), and checks openssl supports EdDSA (OpenSSL 1.1.1 or later required)
- `generate_appcast.sh` signs Windows installers with EdDSA (`sparkle:edSignature`), or with DSA (`sparkle:dsaSignature`) if a legacy DSA private key is provided
- `setup_fresh_env.sh` reinstalls WinSparkle when the installed version is not the expected one, and can use curl if wget is not available

### Fixed
- Automatic update is now disabled on Windows if the public key is invalid (WinSparkle would otherwise accept unsigned updates)
