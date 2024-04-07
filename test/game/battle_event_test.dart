import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:holyshitrail/game/base_definitions.dart';
import 'package:holyshitrail/game/battle_context.dart';
import 'package:holyshitrail/game/battle_event.dart';
import 'package:holyshitrail/game/battle_events.dart';
import 'package:holyshitrail/game/characters/1.0/trailblazer_destruction/character.dart';
import 'package:holyshitrail/game/characters/2.1/acheron/character.dart';
import 'package:holyshitrail/game/characters/character.dart';
import 'package:holyshitrail/game/enemies/other/dummy.dart';
import 'package:holyshitrail/global_configs.dart';

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

  test("Battle with Character", () async {
    WidgetsFlutterBinding.ensureInitialized();
    await currentLocale.ready;
    final ctx = BattleContext();

    final characters = jsonDecode(
      await rootBundle.loadString("assets/game_data/characters.json"),
    );
    final trailblazer = TrailblazerDBattleCharacter(Avatar.fromJson(
      characters[CharacterId.trailblazerDestruction.value],
    ));
    final acheron = AcheronBattleCharacter(Avatar.fromJson(
      characters[CharacterId.acheron.value],
    ));
    // 暴击率提高45%
    trailblazer.character.currentState.crt + LinearValueModifier.from("+0.45");
    // 暴击伤害提高80%（来自转化值）
    trailblazer.character.currentState.crtDmg +
        LinearValueModifier.from("! +0.80");
    final enemy1 = DummyBattleEnemy();
    final enemy2 = DummyBattleEnemy();
    final enemy3 = DummyBattleEnemy();

    // 敌人2的防御降低60%
    enemy2.enemy.currentState.def + LinearValueModifier.from("! -60%");
    // 敌人3已韧性击破
    enemy3.broke = true;

    ctx.addTeammate(trailblazer);
    ctx.addEnemy(enemy1);
    ctx.addEnemy(enemy2);
    ctx.addEnemy(enemy3);

    ctx.addTransformer(BattleEventTransformer.fromFunction((event) {
      switch (event.type) {
        case BattleEventType.unitTakeDamage:
          // 敌人2受伤时
          if (event.target.contains(enemy2)) {
            final damage = event.payload.value as DefenderDamageDetail;
            // 受到的战技伤害提高50%
            if (damage.base.damageTypes.contains(DamageType.skill)) {
              damage.vulnerability += 0.5;
            }
            // 受到的暴击伤害提高10%
            if (damage.base.crit) {
              damage.vulnerability += 0.1;
            }
          }
          return event;
        default:
          return event;
      }
    }));

    final ability = trailblazer.getAbility("8002_skill_2");
    ability.cast(ctx, enemy2);

    ctx.dispatch(LogEvent(trailblazer, "Hello!"));
  });
}
