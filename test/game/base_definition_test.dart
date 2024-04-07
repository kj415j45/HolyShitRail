import 'package:flutter_test/flutter_test.dart';
import 'package:holyshitrail/game/base_definitions.dart';

final atk = LinearModifiableValue<double>(100);

final atkBuff = LinearValueModifier<double>.from("10%");
final atkDebuff = LinearValueModifier<double>.from("-1");
final complexAtkBuff = LinearValueModifier<double>.from("+10% +5");

void main() {
  test("Linear Modifiable Value", () {
    expect(atk.originalValue, closeTo(100, 0.0001));
    expect(atk.modifiedValue, closeTo(100, 0.0001));

    atk + atkBuff;
    expect(atk.modifiedValue, closeTo(110, 0.0001));
    atk - atkBuff;

    atk + atkDebuff;
    expect(atk.modifiedValue, closeTo(99, 0.0001));

    atk + complexAtkBuff;
    expect(atk.modifiedValue, closeTo(114, 0.0001));

    atk - complexAtkBuff;
    expect(atk.modifiedValue, closeTo(99, 0.0001));

    atk - atkDebuff;
    expect(atk.modifiedValue, closeTo(100, 0.0001));
  });
}
