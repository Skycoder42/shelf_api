#!/bin/bash
set -eo pipefail

echo "::group::Build example server"
cd example

dart pub get
dart run build_runner build --delete-conflicting-outputs
dart compile exe lib/main.dart -o "${RUNNER_TEMP:-/tmp}/shelf-api-example-server.exe"
rm -rf build

echo ::endgroup::
