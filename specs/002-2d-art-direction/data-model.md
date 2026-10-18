# Presentation data model — proposed VD-01

不改存档、ActorHealth、StatBlock、技能/职业或模拟状态。制作记录是文档；运行时新增仅可选表现Resource。没有数据库/网络/新系统服务。

| Entity | Fields / relationships | Validation |
| --- | --- | --- |
| StyleBaseline | revision、palette_roles、viewport、camera_zoom、pixel_density、light_direction、outline/type/spacing、animation_policy | VD-01；640×360/1×；32px地砖；与ART_DIRECTION/SPRITE_SPEC一致 |
| VisualAssetRecord | asset_id、family、actor/profession/effect selector、current/fallback/source/export路径、revision、canvas/body_bounds/anchor、provenance、manifest、approval_id、evidence_ids | 当前/提案/缺失分栏；交付路径确实存在；权利未知不得approved；不虚构文件 |
| AnimationManifest | sheet_grid/cell_regions、state、applicable、reuse_of、distinct_effective_frames、authored_unique_cells、loop、fps、tick_window、event_origin_policy、flip | 五状态有条目；Thrall attack=N/A且说明contact；唯一格去重≤58；多帧不得重复同图凑数；锚点在画布内 |
| ActorVisualOverride（拟Resource） | selector_kind(hero/enemy)、definition_id、hero所需profession_id → VisualSet，默认空 | 仅hero aren+swordsman、enemy saltbound_thrall、enemy skittering_brinejaw三条；actor_overrides.tres显式引用三份VisualSet，Presentation查表；稳定ID不用display_name，缺资源/帧完整回退 |
| VisualSet（现有Resource拟扩展） | 保留id/silhouette/palette/idle/move/attack/hurt/death/directional_flip；增加可空sprite_frames、canvas_px、anchor_px、style_revision | 旧Resource不迁移；无frames仍按原validate/绘制；有frames才验证适用状态 |
| EnvironmentVisualSet | tile_set、static_props、corruption_overlay、painted_light_variant、revision | 只在Field视觉子树；无collision/nav/事件；不消费SeedStreams |
| UI component inputs | 只读value/max/label/state/icon、既有action callback | max=0安全；仅clamp条形比例，不改显示/源数值；不扣币/随机/保存 |
| MockupPackage | revision、exact_scope、reference_status、boards/strips/scale_views、estimate、FR/SC | G1包含combined HUD/四向/灰阶/0与100/无光；HTML不替代缺图 |
| ApprovalRecord | gate、package_revision、reviewer、date、approve/revise/reject、scope、restrictions、supersedes | 未知写pending；不把文档作者当owner；修订不自动继承批准 |
| AcceptanceEvidence | revision/build/hash、requirements、command/procedure、seed/snapshot/input/tick/camera、party/enemies/corruption、renderer/effects/hardware/display、files/results/limits | 区分历史/当前、source/release、机器/人工；成对fixture；不自动重设基线 |

制作状态：missing → proposed → approved → integrated → verified。旧程序资产独立标placeholder，不随提案晋级。approved需G1/G3，integrated需实际接线，verified需执行证据；人工验收单列。revise/reject保留旧revision及理由，新稿重新审批。

这不是第二套玩法状态机：表现从现有actor派生 death > hurt > attack/warning > move > idle，死亡/伤害/暂停依旧由原系统决定。

正常接线测试须确认三份预期新VisualSet/SpriteFrames实际使用；另用故障注入测试缺资源/无效帧回退。G1冻结P01边缘、P02额外容量、P03镜像及版本化识别协议；这些记录不进入profile或模拟状态。
