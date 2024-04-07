/// Implements this if the object need to be able to converted to a JSON primitive.
/// Possible [T] are:
/// - [null]
/// - [bool]
/// - [num]
///   - [int]
///   - [double]
/// - [String]
/// - [List] where the element is [num], [String], [bool], [Map], or [List]
/// - [Map] where the key is [String] and the value is [num], [String], [bool], [Map], or [List]
abstract interface class JsonSerializable<T> {
  T toJson();

  static auto<V>(V? value) {
    switch (value) {
      case EnumValue e:
        return e.value;
      case null:
      case bool _:
      case num _:
      case String _:
        return value;
      case List list:
        return list.map((e) => JsonSerializable.auto(e)).toList();
      case Map map:
        return map.map(
          (k, v) => MapEntry(
            k.toString(),
            JsonSerializable.auto(v),
          ),
        );
      case JsonSerializable json:
        return json.toJson();
      default:
        throw Exception('Unsupported type: $value');
    }
  }
}

/// Implements this on the [enum] class.
/// Possible [E] are:
/// - [int]
/// - [String]
abstract class EnumValue<E> implements JsonSerializable<E> {
  final E value;
  EnumValue(this.value);

  // factory _.fromJson(E value) =>
  //     values.firstWhere((e) => e.value == value);
}
