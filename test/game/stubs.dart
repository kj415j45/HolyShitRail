import 'package:holyshitrail/game/base_definitions.dart';
import 'package:holyshitrail/game/characters/character.dart';

final class StubCharacter extends Character {
  StubCharacter({
    super.id = 'stub',
    super.name = 'Stub',
    super.path = CharacterPath.destruction,
    super.combatType = CombatType.physical,
  }) : super(
          staticStats: const StubCharacterStaticStats(),
        );
}

final class StubCharacterStaticStats<S> extends CharacterStaticStats {
  const StubCharacterStaticStats()
      : super(
          level: 80,
          maxHp: 1000,
          atk: 100,
          def: 50,
          spd: 100,
          maxEnergy: 100,
          crt: 0.05,
          crtDmg: 0.5,
          taunt: 100,
        );
}

class StubCharacterCurrentState extends CharacterCurrentState {
  StubCharacterCurrentState(StubCharacterStaticStats super.stat);
}
