import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shelf_api/shelf_api.dart';

part 'date_time_provider.g.dart';

@Riverpod(keepAlive: true)
DateTime dateTimeSingleton(DateTimeSingletonRef ref) => DateTime.now();

@Riverpod(keepAlive: false)
DateTime dateTimeFactory(DateTimeFactoryRef ref) => DateTime.now();

@Riverpod(dependencies: [shelfRequest])
DateTime requestDateTimeSingleton(RequestDateTimeSingletonRef ref) =>
    DateTime.now();

@Riverpod(dependencies: [shelfRequest])
DateTime requestDateTimeFactory(RequestDateTimeFactoryRef ref) =>
    DateTime.now();
