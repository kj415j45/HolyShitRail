import 'package:flutter_test/flutter_test.dart';
import 'package:holyshitrail/game/base_definitions.dart';

final atk = LinearModifiableValue<double>(100);

final atkBuff =
    LinearValueModifier<double>.fromFunction((value) => value * 0.1);
final atkDebuff = LinearValueModifier<double>.fromFunction((value) => -1);
final complexAtkBuff =
    LinearValueModifier<double>.fromFunction((value) => value * 0.1 + 5);

void main() {
  test("Linear Modifiable Value", () {
    expect(atk.originalValue, 100);
    expect(atk.modifiedValue, 100);

    atk + atkBuff;
    expect(atk.modifiedValue, 110);
    atk - atkBuff;

    atk + atkDebuff;
    expect(atk.modifiedValue, 99);

    atk + complexAtkBuff;
    expect(atk.modifiedValue, 114);

    atk - complexAtkBuff;
    expect(atk.modifiedValue, 99);

    atk - atkDebuff;
    expect(atk.modifiedValue, 100);
  });
}
