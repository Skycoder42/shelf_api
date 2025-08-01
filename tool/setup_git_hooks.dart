#!/usr/bin/env dart

import 'dart:io';

Future<void> main() async {
  final preCommitHook = File('.git/hooks/pre-commit');
  await preCommitHook.parent.create();
  await preCommitHook.writeAsString('''
#!/bin/bash
set -eo pipefail

pushd packages/shelf_api > /dev/null
dart run dart_pre_commit
popd > /dev/null

pushd packages/shelf_api_builder > /dev/null
dart run dart_pre_commit
popd > /dev/null
''');

  if (!Platform.isWindows) {
    final result = await Process.run('chmod', ['a+x', preCommitHook.path]);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    exitCode = result.exitCode;
  }
}
