import 'package:holyshitrail/game/base_definitions.dart';
import 'package:holyshitrail/game/battle_context.dart';
import 'package:holyshitrail/game/battle_event.dart';
import 'package:holyshitrail/game/battle_events.dart';
import 'package:holyshitrail/game/characters/character.dart';

final class AcheronCharacter extends Avatar {
  AcheronCharacter({
    super.id = CharacterId.acheron,
    super.name = 'Acheron',
    super.staticStats = const AcheronCharacterStaticStats(),
    required super.path,
    required super.combatType,
  }) {
    currentState = AcheronCharacterCurrentState(
      staticStats as AcheronCharacterStaticStats,
    );
  }
}

final class AcheronBattleCharacter extends BattleCharacter<AcheronCharacter> {
  AcheronBattleCharacter(super.character) {
    abilities.addAll([
      //
    ]);
  }

  @override
  void onJoinBattle(BattleContext ctx) {
    eidolon6(ctx);
  }

  eidolon6(BattleContext ctx) {
    ctx.addTransformer(BattleEventTransformer.fromFunction((event) {
      if (event.source != this) return event;
      // 造成的终结技伤害全属性抗性穿透提高20%
      if (event is TakeDamageEvent) {
        final damage = event.payload.value!;
        if (damage.base.damageTypes.contains(DamageType.ultimate)) {
          damage.resist -= 0.2;
        }
      }
      return event;
    }));
  }
}

final class AcheronCharacterStaticStats extends CharacterStaticStats {
  const AcheronCharacterStaticStats()
      : super(
          level: 80,
          maxHp: 1125,
          atk: 698.54,
          def: 436.59,
          spd: 101,
          maxEnergy: 9,
          crt: 0.05,
          crtDmg: 0.5,
          taunt: 100,
        );
}

class AcheronCharacterCurrentState extends CharacterCurrentState {
  AcheronCharacterCurrentState(
    AcheronCharacterStaticStats super.stat,
  );
}
