import 'package:meta/meta.dart';

@immutable
class BasicModel {
  final int value;

  const BasicModel(this.value);

  factory BasicModel.fromJson(Map<String, dynamic> json) =>
      BasicModel(json['value'] as int);

  dynamic toJson() => {'value': value};

  @override
  String toString() => 'BasicModel($value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else if (other is! BasicModel) {
      return false;
    } else {
      return value == other.value;
    }
  }

  @override
  int get hashCode => value.hashCode;

  // ignore: prefer_constructors_over_static_methods for code generation
  static BasicModel fromJsonX(dynamic value) => BasicModel(value as int);

  static int toJsonX(BasicModel model) => model.value;
}
