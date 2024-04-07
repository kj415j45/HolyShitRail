import 'dart:convert';

import 'package:holyshitrail/game/base_definitions.dart';
import 'package:holyshitrail/game/battle_event.dart';
import 'package:holyshitrail/game/battle_events.dart';
import 'package:holyshitrail/game/characters/character.dart';
import 'package:holyshitrail/game/enemies/enemy.dart';
import 'package:holyshitrail/game/unit.dart';
import 'package:holyshitrail/global_configs.dart';
import 'package:logger/logger.dart';

final logger = Logger(filter: DevelopmentFilter(), level: logLevel);

class BattleContext {
  final List<BattleCharacter> teammates;
  final List<BattleEnemy> enemies;

  final List<BattleEvent> events = [];
  final List<BattleEventListener> listeners = [];
  final List<BattleEventTransformer> transformers = [];

  int currentActionTimer = 0;

  BattleContext()
      : teammates = [],
        enemies = [];

  void dispatch(BattleEvent event) {
    if (transformers.isNotEmpty) {
      logger.t("Transformers: ${transformers.length}");
      logger.t(event.prettyLog());
      for (var transformer in transformers) {
        event = transformer.transform(event);
        logger.t(event.prettyLog());
      }
      logger.t("Transform end");
    }

    for (var listener in listeners) {
      listener.preBattleEvent(event);
    }

    events.add(event);
    switch (event.type) {
      case BattleEventType.log:
        logger.d(event.prettyLog());
        break;
      case BattleEventType.error:
        logger.e(event.prettyLog());
        break;
      case BattleEventType.serverWait:
      case BattleEventType.clientIndicator:
        logger.w(event.prettyLog());
        break;
      default:
        logger.i(event.prettyLog());
    }
    for (var listener in listeners) {
      listener.postBattleEvent(event);
    }
    switch (event.type) {
      case BattleEventType.unitDamage:
        var table = event.payload.value as DamageTable;
        table.damages.forEach((target, value) {
          // 锁定输出端暴击情况
          value.lockDamage;
          final report = target.takeDamage(value);
          dispatch(TakeDamageEvent(event.source, target, report));
        });
        break;
      default:
    }
  }

  void addListener(BattleEventListener listener) {
    listeners.add(listener);
  }

  void removeListener(BattleEventListener listener) {
    listeners.remove(listener);
  }

  void addTransformer(BattleEventTransformer transformer) {
    transformers.add(transformer);
  }

  void removeTransformer(BattleEventTransformer transformer) {
    transformers.remove(transformer);
  }

  void addTeammate(BattleCharacter character) {
    teammates.add(character);
    character.onJoinBattle(this);
    // TODO event
  }

  void addEnemy(BattleEnemy enemy) {
    enemies.add(enemy);
    // TODO event
  }

  List<U> getBlastTargets<U extends BattleUnit>(
    U source, {
    skipNotSelectable = true,
  }) {
    var pool = (source is BattleCharacter ? teammates : enemies) as List<U>;
    if (skipNotSelectable) {
      pool = pool.where((e) => e.selectable).toList();
    }
    final index = pool.indexOf(source);
    final List<U> result = [];
    if (index - 1 >= 0) result.add(pool[index - 1]);
    if (index + 1 < pool.length) result.add(pool[index + 1]);
    return result;
  }

  BattleUnit getUnitById(String id) {
    return [...teammates.cast<BattleUnit>(), ...enemies.cast<BattleUnit>()]
        .firstWhere((e) => e.id == id);
  }
}

extension BattleEventLog on BattleEvent {
  String prettyLog() {
    return """Type: ${type.value}
Source: ${source.name} (${source.id})
Target: [${target.map((e) => "${e.name} (${e.id})").join(", ")}]
Payload: ${jsonEncode(payload.toJson())}""";
  }
}
