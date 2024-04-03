import 'package:holyshitrail/game/battle_context.dart';
import 'package:holyshitrail/game/unit.dart';
import 'package:holyshitrail/utils/enum_value.dart';

abstract base class Ability<U extends BattleUnit> {
  final String id;
  final String name;
  final AbilityType type;
  final List<AbilityTargetType> targetType;
  final U owner;

  Ability({
    required this.id,
    required this.name,
    required this.owner,
    required this.type,
    required this.targetType,
  });

  /// 是否可以启动
  /// 默认方法只检查是否有目标可选择
  bool canActive(BattleContext context) {
    if (getPossibleTargets(context).isEmpty) {
      return false;
    }
    return true;
  }

  /// 获取可能的目标
  List<Unit> getPossibleTargets(BattleContext context);
  void cast(BattleContext context, Unit target);
}

enum AbilityType implements EnumValue<int> {
  /// 其他，如敌人的攻击、场地效果
  other(0),

  /// 普通攻击
  normalAttack(1),

  /// 战技
  skill(2),

  /// 终结技
  ultimate(3),
  ;

  @override
  final int value;
  const AbilityType(this.value);

  @override
  toJson() => value;
}

enum AbilityTargetType implements EnumValue<int> {
  /// 玩家单位
  teammate(-2),

  /// 敌方单位
  enemy(-1),

  /// 单体
  single(0),

  /// 扩散
  blast(1),

  /// 群攻
  aoe(2),

  /// 弹射
  bounce(3),
  ;

  @override
  final int value;
  const AbilityTargetType(this.value);

  @override
  toJson() => value;
}
