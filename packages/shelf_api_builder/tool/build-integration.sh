#!/bin/bash
set -eo pipefail

echo "::group::Build example server"
cd example

dart pub get
dart compile exe lib/main.dart -o "${RUNNER_TEMP:-/tmp}/shelf-api-builder-example-server.exe"
rm -rf build

echo ::endgroup::
