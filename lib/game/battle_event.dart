import 'package:holyshitrail/game/unit.dart';
import 'package:holyshitrail/utils/enum_value.dart';

/// 战斗事件
///
/// 用于描述战斗。完整文档见 [战斗事件](docs/battle_event.md)
base class BattleEvent<PayloadType> {
  /// 事件类型
  final BattleEventType type;

  /// 事件源
  final Unit source;

  /// 事件目标
  final List<Unit> target;

  /// 事件数据
  final BattleEventPayload<PayloadType> payload;

  BattleEvent(
    this.type,
    this.source,
    this.target, [
    this.payload = const BattleEventPayload(null),
  ]);
}

class BattleEventPayload<T> implements JsonSerializable {
  final T? value;
  const BattleEventPayload(this.value);

  @override
  toJson() => JsonSerializable.auto(value);
}

typedef BattleEventHandler = void Function(BattleEvent event);

abstract interface class BattleEventListener {
  /// 在事件转换后，提交前执行
  void preBattleEvent(BattleEvent event);

  /// 在事件提交后执行
  void postBattleEvent(BattleEvent event);

  /// 通过此种形式创建的 [BattleEventListener] 只能在事件提交后执行
  /// 如果需要在事件提交前执行其他操作，应自行实现 [BattleEventListener]
  factory BattleEventListener.fromFunction(BattleEventHandler onBattleEvent) {
    return _BattleEventListener(onBattleEvent);
  }
}

class _BattleEventListener implements BattleEventListener {
  final BattleEventHandler f;

  _BattleEventListener(this.f);

  @override
  void postBattleEvent(BattleEvent event) {
    f(event);
  }

  @override
  void preBattleEvent(BattleEvent event) {}
}

/// 战斗事件转换器
/// 转换发生在事件提交之前
abstract interface class BattleEventTransformer {
  /// 转换事件
  /// 根据需要，对 [event] 进行转换，返回转换后的事件
  BattleEvent transform(BattleEvent event);

  factory BattleEventTransformer.fromFunction(
    BattleEvent Function(BattleEvent) transform,
  ) {
    return _BattleEventTransformer(transform);
  }
}

class _BattleEventTransformer implements BattleEventTransformer {
  final BattleEvent Function(BattleEvent) f;

  _BattleEventTransformer(this.f);

  @override
  BattleEvent transform(BattleEvent event) {
    return f(event);
  }
}

enum BattleEventType implements EnumValue<int> {
  /// 日志、注释
  log(0),

  /// 错误
  error(1),

  /// 战斗开始
  startOfBattle(2),

  /// 战斗结束
  endOfBattle(3),

  /// 回合开始
  startOfTurn(4),

  /// 回合结束
  endOfTurn(5),

  /// 轮次开始
  startOfCycle(6),

  /// 轮次结束
  endOfCycle(7),

  /// 波次开始
  startOfWave(8),

  /// 波次结束
  endOfWave(9),

  /// 战斗单位执行行动
  unitAction(10),

  /// 战斗单位发动攻击
  unitAttack(11),

  /// 战斗单位攻击命中
  unitAttackHit(12),

  /// 战斗单位造成伤害（输出端）
  unitDamage(13),

  /// 战斗单位被施加状态
  applyBuff(14),

  /// 战斗单位被解除状态
  removeBuff(15),

  /// 战斗单位加入战斗
  unitJoinBattle(16),

  /// 服务器等待
  serverWait(17),

  /// 客户端指示
  clientIndicator(18),

  /// 战斗单位受到伤害（接收端）
  unitTakeDamage(19),
  ;

  @override
  final int value;
  const BattleEventType(this.value);

  @override
  int toJson() {
    return value;
  }
}
