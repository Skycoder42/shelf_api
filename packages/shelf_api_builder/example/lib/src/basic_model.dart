class BasicModel {
  final int value;

  const BasicModel(this.value);

  factory BasicModel.fromJson(Map<String, dynamic> json) =>
      BasicModel(json['value'] as int);

  dynamic toJson() => {'value': value};

  // ignore: prefer_constructors_over_static_methods
  static BasicModel fromJsonX(dynamic value) => BasicModel(value as int);

  static int toJsonX(BasicModel model) => model.value;
}
