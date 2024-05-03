import 'package:shelf_api/shelf_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'date_time_provider.g.dart';

@Riverpod(keepAlive: true)
DateTime dateTimeSingleton(DateTimeSingletonRef ref) => DateTime.now();

@Riverpod(keepAlive: false)
DateTime dateTimeFactory(DateTimeFactoryRef ref) => DateTime.now();

@Riverpod(dependencies: [requestContext])
DateTime requestDateTimeSingleton(RequestDateTimeSingletonRef ref) =>
    DateTime.now();

@Riverpod(dependencies: [requestContext])
DateTime requestDateTimeFactory(RequestDateTimeFactoryRef ref) =>
    DateTime.now();
