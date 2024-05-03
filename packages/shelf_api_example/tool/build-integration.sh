#!/bin/bash
set -eo pipefail

echo "::group::Build example server"
cd "$(realpath "$(dirname "$0")/..")"

dart pub get
dart run build_runner build
dart compile exe bin/server.dart -o "${RUNNER_TEMP:-/tmp}/shelf-api-example-server.exe"
rm -rf build

echo ::endgroup::
