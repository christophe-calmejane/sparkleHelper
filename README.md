# SparkleHelper

Copyright (C) 2020-2025, Christophe Calmejane

## What is SparkleHelper

SparkleHelper is a lightweight and easy to use c++ library to handle software automatic updates.

Under the hood the library uses either Sparkle (macOS) or WinSparkle (windows).

## Updates signature

Updates are signed using EdDSA (ed25519) keys on both macOS and Windows:
- `scripts/generate_dsa_keys.sh <Output Folder>` generates the keys (once per project). The public key (base64) is written to `dsa_pub.pem`. On Windows, the private key is written to `dsa_priv.pem` (requires OpenSSL 1.1.1 or later), on macOS it is stored in the Keychain
- `scripts/generate_appcast.sh` signs the installer and generates the appcast item (at each release)

### Migrating from DSA keys (Windows)

DSA keys are deprecated by WinSparkle. They are still supported (a PEM public key passed to `Sparkle::init` is used as a DSA key), but changing the key is a breaking change: already deployed versions only accept updates signed with their own key.
To migrate, remove both `dsa_pub.pem` and `dsa_priv.pem` files, run `scripts/generate_dsa_keys.sh` again, and publish the new version using a new appcast.

## Versioning

We use [SemVer](http://semver.org/) for versioning.

## License

See the [LICENSE](LICENSE) file for details.

## Third party

SparkleHelper uses the following 3rd party resources:
- [Sparkle](https://sparkle-project.org) and [WinSparkle](https://github.com/vslavik/winsparkle)
