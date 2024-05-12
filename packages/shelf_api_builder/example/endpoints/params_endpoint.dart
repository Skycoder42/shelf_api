import 'package:shelf_api/shelf_api.dart';

@ApiEndpoint('/params')
class ParamsEndpoint extends ShelfEndpoint {
  ParamsEndpoint(super.request);

  @Get(r'/path/simple/<p1>/sub/<p2|\d+>')
  List<dynamic> getPathSimple(String p1, int p2) => [p1, p2];

  @Get(r'/path/custom/<c1>/sub/<c2|[^\/].*>')
  List<dynamic> getPathCustom(
    @PathParam(parse: parseString, stringify: stringifyString) String c1,
    Uri c2,
  ) =>
      [c1, c2.toString()];

  @Get('/query')
  Map<String, dynamic> getQuery({
    required String sValue,
    int? oValue,
    double dValue = 42.0,
    required Uri uValue,
    DateTime? dtValue,
    String s2Value = 's2',
  }) =>
      {
        'sValue': sValue,
        'oValue': oValue,
        'dValue': dValue,
        'uValue': uValue.toString(),
        'dtValue': dtValue?.toIso8601String(),
        's2Value': s2Value,
      };

  @Get('/query/list')
  Map<String, dynamic> getQueryList({
    required List<String> sValue,
    required List<Uri> uValue,
    List<int> iValue = const [1, 2, 3],
    List<DateTime> dtValue = const [],
    List<String> s2Value = const ['s2'],
  }) =>
      {
        'sValue': sValue,
        'uValue': uValue.toString(),
        'iValue': iValue,
        'dtValue': dtValue.toString(),
        's2Value': s2Value,
      };

  @Get('/query/custom')
  Map<String, dynamic> getQueryCustom({
    @QueryParam(name: 'named_value') required String namedValue,
    @QueryParam(parse: parseString, stringify: stringifyString)
    required String parsedValue,
    @QueryParam(
      name: 'list_value',
      parse: parseStringList,
      stringify: stringifyStringList,
    )
    List<String> parsedListValue = const ['unparsed', 'values'],
  }) =>
      {
        'namedValue': namedValue,
        'parsedValue': parsedValue,
        'parsedListValue': parsedListValue,
      };

  @Get('/combined/<p1>')
  Map<String, dynamic> getCombined(
    double p1, {
    required int precision,
    bool roundDown = false,
  }) =>
      {
        'p1': p1,
        'precision': precision,
        'roundDown': roundDown,
      };

  static String parseString(String s) => s * 3;

  static String stringifyString(String s) => s.toUpperCase();

  static List<String> parseStringList(List<String> s) =>
      s.map(parseString).toList();

  static List<String> stringifyStringList(List<String> s) =>
      s.map(stringifyString).toList();
}
