import 'package:shelf_api/shelf_api.dart';

@ApiEndpoint('/params')
class ParamsEndpoint extends ShelfEndpoint {
  ParamsEndpoint(super.request);

  @Get('/query')
  Map<String, dynamic> get({
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
        'uValue': uValue,
        'dtValue': dtValue,
        's2Value': s2Value,
      };

  @Get('/query/list')
  Map<String, dynamic> getList({
    required List<String> sValue,
    List<int>? oValue,
    List<double> dValue = const [4, 2, 0],
    required List<Uri> uValue,
    List<DateTime>? dtValue,
    List<String> s2Value = const ['s2'],
  }) =>
      {
        'sValue': sValue,
        'oValue': oValue,
        'dValue': dValue,
        'uValue': uValue,
        'dtValue': dtValue,
        's2Value': s2Value,
      };

  @Get('/query/custom')
  Map<String, dynamic> getCustom({
    @QueryParam(name: 'named_value') required String namedValue,
    @QueryParam(parse: parseString) required String parsedValue,
    @QueryParam(
      name: 'list_value',
      parse: parseStringList,
    )
    required List<String> parsedListValue,
  }) =>
      {
        'namedValue': namedValue,
        'parsedValue': parsedValue,
        'parsedListValue': parsedListValue,
      };

  static String parseString(String s) => s * 3;

  static List<String> parseStringList(List<String> s) =>
      s.map(parseString).toList();
}
