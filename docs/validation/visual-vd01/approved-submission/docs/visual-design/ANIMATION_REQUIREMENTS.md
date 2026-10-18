# 动画需求 · VD-01-M1（待审批）

[完整精灵规范](SPRITE_SPEC.md) · [实际概念帧清单](mockups/vd01/animation-manifest.json) · [离线播放器](mockups/vd01/motion-player.html)

| 对象 | Idle / Move / Attack或Warning / Hurt / Death | 独创格 | 原时序 |
| --- | --- | ---: | --- |
| Aren基础剑士 | 2 / 4 / 3 / 1复用 / 4 | 13 | idle6FPS、move10FPS、attack15FPS；攻击12ticks、hurt实际截止；死亡8FPS，终局可立即打断 |
| Saltbound Thrall | 1 / 2 / N/A接触型 / 1复用 / 3 | 6 | move8FPS、death8FPS；普通尸体24ticks清理 |
| Skittering Brinejaw | 1 / 2 / 1复用+橙警示 / 1复用 / 3 | 6 | move10FPS、warning45ticks、death8FPS；不改rush/recover |
| 基础剑弧 | 2个不同格 | 2 | reach48/100°；expires=tick+10，cleanup为tick>expires；升级reach回退程序弧 |
| 既有友方星 | 2个不同格 | 2 | 12FPS循环；原目标、命中和销毁时机；Milo使用，不给Aren新增法术 |

合计**29**，生产上限**58**。hurt/warning的复用不增加独创格；五状态条目不能省略。仅一个身体朝向+水平镜像，靠VFX/瞄准cue审查东南西北；不得旋转身体。若上/下识别不足，先记录失败并重审预算，不能自行增加四方向表。

优先级：death > hurt > attack/warning > move > idle。攻击起点=attack_until−12；死亡=有效dead_at或主角/同伴致死hurt_until−8；Brinejaw warning起点=deadline−45且仅warning态有效。hurt单姿闪烁至真实hurt_until（包括2tick抗性反馈），不能一律反推8tick。

迟到tick9应直接显示attack第3格；tick4–7被hurt打断，tick8恢复时继续第3格。不得重播首击、补播过期帧、延迟结算或等animation_finished才销毁。暂停冻结模拟tick；debug倍速只改变观察到的tick进度。循环起点与短事件起点分开。上述视频是设计示例，未验证Godot接线。

交付：RGBA透明PNG、固定格与脚锚（Aren/Thrall16,40；Brinejaw16,24），逐状态regions/unique hash/复用理由、可编辑源、作者/来源、原向镜像P03对照。无空白/同图重复凑最低帧；最终生产清稿及G0/G1仍待批准。
