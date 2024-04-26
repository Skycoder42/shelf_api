#!/bin/bash
set -eo pipefail

echo "::group::Install dart_frog"
dart pub global activate dart_frog_cli
echo ::endgroup::

echo "::group::Build example server"
pushd "$(realpath "$(dirname "$0")/..")"

dart pub get
dart run build_runner build
dart pub global run dart_frog_cli:dart_frog build
pushd build
dart compile exe bin/server.dart -o bin/server.exe

popd
echo ::endgroup::
