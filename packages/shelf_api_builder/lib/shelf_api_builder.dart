import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/endpoint_generator.dart';

/// The [EndpointGenerator] builder
Builder shelfApiBuilder(BuilderOptions options) => PartBuilder(
      [EndpointGenerator(options)],
      '.api.dart',
    );