import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/client_generator.dart';
import 'src/endpoint_generator.dart';

/// The [EndpointGenerator] builder.
///
/// It supports the following configuration options:
/// Key              | Type   | Default Value | Description
///------------------|--------|---------------|-------------
/// `generateApi`    | `bool` | `true`        | Enables or disables it
Builder shelfApiBuilder(BuilderOptions options) => LibraryBuilder(
  EndpointGenerator(options),
  generatedExtension: '.api.dart',
  options: options,
);

/// The [ClientGenerator] builder
///
/// It supports the following configuration options:
/// Key                 | Type   | Default Value | Description
///---------------------|--∞------|---------------|-------------
/// `generateClient`    | `bool` | `true`        | Enables or disables it
Builder shelfApiClientBuilder(BuilderOptions options) => LibraryBuilder(
  ClientGenerator(options),
  generatedExtension: '.client.dart',
  options: options,
);
