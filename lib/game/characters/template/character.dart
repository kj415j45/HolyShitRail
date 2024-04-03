import 'package:holyshitrail/game/base_definitions.dart';
import 'package:holyshitrail/game/characters/character.dart';

final class TemplateCharacter extends Character {
  TemplateCharacter()
      : super(
          path: CharacterPath.destruction,
          combatType: CombatType.physical,
          id: 'template',
          name: 'template',
          staticStats: const TemplateCharacterStaticStats(),
        ) {
    currentState = TemplateCharacterCurrentState(
        staticStats as TemplateCharacterStaticStats);
    abilities.addAll([
      // TODO add abilities
    ]);
  }
}

final class TemplateCharacterStaticStats extends CharacterStaticStats {
  const TemplateCharacterStaticStats()
      : super(
          level: 80,
          maxHp: 1203,
          atk: 620.93,
          def: 460.85,
          spd: 100,
          maxEnergy: 120,
          crt: 0.05,
          crtDmg: 0.5,
          taunt: 125,
        );
}

class TemplateCharacterCurrentState extends CharacterCurrentState {
  TemplateCharacterCurrentState(
    TemplateCharacterStaticStats super.stat,
  );
}
