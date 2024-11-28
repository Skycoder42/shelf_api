import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shelf_api/shelf_api.dart';

part 'date_time_provider.g.dart';

@Riverpod(keepAlive: true)
DateTime dateTimeSingleton(Ref ref) => DateTime.now();

@Riverpod(keepAlive: false)
DateTime dateTimeFactory(Ref ref) => DateTime.now();

@Riverpod(dependencies: [shelfRequest])
DateTime requestDateTimeSingleton(Ref ref) => DateTime.now();

@Riverpod(dependencies: [shelfRequest])
DateTime requestDateTimeFactory(Ref ref) => DateTime.now();
