# SparkleHelper

Copyright (C) 2020'21, Christophe Calmejane

## What is SparkleHelper

SparkleHelper is a lightweight and easy to use c++ library to handle software automatic updates.

Under the hood the library uses either Sparkle (macOS) or WinSparkle (windows).

## Minimum requirements for compilation

- CMake 3.13
- Visual Studio 2019 16.3 (using platform toolset v142), Xcode 10, gcc 8.2.1

## Compilation

- Clone this repository
- Run the setup_fresh_env.sh script that should properly setup your working copy (in the scripts folder)
- Use CMake to generate a build solution
- Open the generated solution
- Compile everything

## Versioning

We use [SemVer](http://semver.org/) for versioning.

## License

See the [LICENSE](LICENSE) file for details.

## Third party

SparkleHelper uses the following 3rd party resources:
- [Sparkle](https://sparkle-project.org) and [WinSparkle](https://github.com/vslavik/winsparkle)
