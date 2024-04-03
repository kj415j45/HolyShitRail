import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:holyshitrail/game/battle_context.dart';
import 'package:holyshitrail/game/battle_event.dart';
import 'package:holyshitrail/game/battle_events.dart';
import 'package:holyshitrail/game/characters/1.0/trailblazer_destruction/character.dart';
import 'package:holyshitrail/game/enemies/other/dummy.dart';

import 'stubs.dart';

void main() {
  test("Battle event basic test", () {
    final ctx = BattleContext();
    final character = StubCharacter();

    final flag = Random().nextInt(114514).toString();
    int counter = 0;

    final handler = BattleEventListener.fromFunction((event) {
      expect(event.payload.value, flag);
    });

    ctx.addListener(handler);
    ctx.addListener(BattleEventListener.fromFunction((event) {
      counter++;
    }));

    ctx.dispatch(
      LogEvent(character, flag),
    );
    expect(counter, 1);

    ctx.removeListener(handler);

    ctx.dispatch(
      LogEvent(character, "Test"),
    );
    expect(counter, 2);
  });

  test("Battle with Character", () {
    final ctx = BattleContext();
    final char1 = TrailblazerDBattleCharacter();
    final enemy1 = DummyBattleEnemy();
    final enemy2 = DummyBattleEnemy();
    final enemy3 = DummyBattleEnemy();

    ctx.addTeammate(char1);
    ctx.addEnemy(enemy1);
    ctx.addEnemy(enemy2);
    ctx.addEnemy(enemy3);

    final ability = char1.getAbility("8002_skill_2");
    ability.cast(ctx, enemy1);

    ctx.dispatch(LogEvent(char1, "Hello!"));
  });
}
