import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/client_generator.dart';
import 'src/endpoint_generator.dart';

/// The [EndpointGenerator] builder
Builder shelfApiBuilder(BuilderOptions options) => LibraryBuilder(
      EndpointGenerator(options),
      generatedExtension: '.api.dart',
      options: options,
    );

/// The [ClientGenerator] builder
Builder shelfApiClientBuilder(BuilderOptions options) => LibraryBuilder(
      ClientGenerator(options),
      generatedExtension: '.client.dart',
      options: options,
    );
