# US3 音频 — 2026-10-19

已实现：7个原创本地PCM音样、严格Resource/总线校验、固定8播放器、优先级与合并窗口、真实攻击/接受伤害事实、挂载后升级去重/FIFO、所有暂停token、失焦/离场/结束/重开清理。声音不写玩法或读取4个玩法RNG。

## 执行证据

- [red](red/)：可加载最小接口下7个预期行为失败；没有以解析失败代替red。
- [integration-v1](integration-v1/)：音频开关与完整最终状态复放通过；后续新增音色变化、全部token/旧generation、DoT/重复请求/范围多杀/所有职业分支检查。
- [最终完整回归](../final/regression-v4/)：默认包含pacing、combat_audio、combat_feedback及强制debug_panel；源码、实际Debug图形、实际Release拒绝与M4发布图形通过。
- [追加夹具回归](../final/fixture-regression-v1/)：pacing281（含旧场边/固定零输入75秒的真实rush/shot）、combat_audio168、debug_panel126断言均0失败；不是自然9局。
- [隔离DEV导出](../us3-debug-v2/)：原生126、源码与实际Debug图形各118、实际Release拒绝41断言0失败。
- [当前WASAPI回环](../us3-audio-v4/)：三职业真实攻击、8声部合成最坏混音、无敌/重复致死/暂停/升级/重开场景；未经归一化的本机默认render端点原始录音。未检测到削波，详见loopback.json，事件对照在audio-events.json。回环可能含其他应用声音；可听性/盲听仍需人工。旧[v1](../us3-audio-v1/)与[v2](../us3-audio-v2/)保留。
- [工具参数拒绝](entrypoint-negatives.log)与[hash/漏样本/缺组拒绝](tool-contract/results.log)。完整Record/Replay自然9组仍未执行；没有生成假自然轨迹。

## 限制与失败记录

原PCM导入默认压缩导致green-v1内容失败，已显式compress/mode=0；green-v2暴露weapon_mode需StringName及固定fps不能代替混音墙钟，已修复。异步原生播放清理增加250ms测试退出等待，仍检查全部ERROR。regression-v1的raw loopback误导入以证据目录.gdignore修复；v2/v3/v4及final/regression-v1保留图形清理/缩进/受控焦点/旧截图写入失败。现有M3/M4图形脚本已纳入manifest，发布截图写独立证据目录；旧历史PNG已恢复，新的探针PNG保存在[备份](../final/legacy-capture-preservation/restoration.json)。不以失败或阻塞算通过。

T052自然9对、T053的人工试听、T059–T061真实人员/物理操作保持开放。盲听题序与离线页已准备，未代填答案。性能另见[performance](../performance/)，不使用历史Q1数字。


首波可见性补查发现seed303被HUD部分遮挡，已用世界跟随CanvasLayer2修正；原候选/RNG/预警不变。[独立red/green与截图](../final/visibility.md)及最终regression-v4验证通过。修复后重新导出acceptance-release-v4并重新采样声音/性能，保留先前样本。
