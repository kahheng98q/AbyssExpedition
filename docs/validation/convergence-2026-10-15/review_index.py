"""Reconcile evidence references; never infer acceptance from checked tasks."""
import json
import re
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]


def read(path):
    return (ROOT / path).read_text(encoding="utf-8-sig")


sources = {
    1: ["scripts/combat/player_controller.gd", "scripts/combat/spawn_director.gd", "scripts/core/run_manager.gd", "scripts/ui/run_results.gd", "scenes/app/app.tscn"],
    2: ["scripts/combat/attack_executor.gd", "scripts/combat/status_effects.gd", "scripts/combat/damage_service.gd", "scripts/progression/upgrade_effects.gd", "scripts/progression/upgrade_offer_service.gd", "data/upgrades"],
    3: ["scripts/ui/combat_hud.gd", "scripts/combat/boss_controller.gd", "scripts/core/replay_trace.gd", "scripts/core/simulation_coordinator.gd", "scripts/core/app_router.gd"],
    4: ["scripts/progression/permanent_progression.gd", "scripts/progression/promotion_service.gd", "scripts/ui/promotion.gd", "scripts/persistence/save_coordinator.gd", "data/professions"],
    5: ["scripts/characters/roster_service.gd", "scripts/characters/companion_controller.gd", "scripts/characters/passive_executor.gd", "scripts/combat/actor.gd"],
    6: ["scripts/ui/guild.gd", "scripts/collection/rescue_objective.gd", "scripts/progression/permanent_progression.gd", "scripts/abyss/event_director.gd", "data/characters"],
    7: ["scripts/collection/recruitment_service.gd", "scripts/collection/draw_rng.gd", "scripts/collection/token_exchange_service.gd", "scripts/collection/recruitment_history.gd", "scripts/ui/recruitment.gd"],
    8: ["scripts/abyss/corruption_service.gd", "scripts/abyss/event_effects.gd", "scripts/data/wave_schedule.gd", "scripts/ui/corruption_summary.gd", "data/events"],
    9: ["scripts/abyss/event_director.gd", "scripts/abyss/event_effects.gd", "scripts/core/choice_coordinator.gd", "scripts/progression/permanent_progression.gd", "scripts/world/coast_field.gd"],
}
suites = {1: ["unit", "scene_smoke", "integration_m1", "full_run"], 2: ["unit", "abilities", "integration_m1"], 3: ["scene_smoke", "replay", "integration_m2"], 4: ["progression", "abilities", "integration_m2", "persistence"], 5: ["abilities", "integration_m2"], 6: ["recruitment", "integration_m3"], 7: ["recruitment", "integration_m3", "persistence"], 8: ["integration_m4"], 9: ["integration_m4"]}
for paths in sources.values():
    for path in paths:
        assert (ROOT / path).exists(), path

spec = read("specs/001-abyss-expedition-mvp/spec.md")
acceptance = []
story = 0
for line_number, line in enumerate(spec.splitlines(), 1):
    match = re.match(r"### User Story (\d+)", line)
    if match:
        story = int(match[1])
    match = re.match(r"(\d+)\. \*\*Given\*\*", line)
    if match:
        acceptance.append({"id": f"US{story}/AC{match[1]}", "spec_line": line_number, "criterion": line, "implementation_entry_points": sources[story], "executed_evidence": [f"final-replay-disclosure/{s}.log" for s in suites[story]], "status": "相关实现与自动行为已核对；完整自然操作验收未关闭", "limitation": "当前M4回归不替代保留M1/M2/M3的独立人工验收；体验/辨识/显示延迟需对应SC实测"})
assert len(acceptance) == 38

edge_groups = [(1, "unit"), (2, "unit"), (2, "unit"), (2, "integration_m1"), (2, "unit"), (1, "unit"), (1, "integration_m1"), (4, "integration_m2"), (3, "integration_m2"), (4, "abilities"), (4, "progression"), (5, "abilities"), (6, "integration_m3"), (6, "integration_m3"), (7, "integration_m3"), (7, "integration_m3"), (4, "persistence"), (4, "persistence"), (8, "integration_m4"), (9, "integration_m4")]
edges = []
for line in spec.split("### Edge Cases", 1)[1].split("## Requirements", 1)[0].splitlines():
    if not line.startswith("| ") or line.startswith(("| Case", "| ---")):
        continue
    cells = [cell.strip() for cell in line.strip("|").split("|")]
    index = len(edges)
    group, suite = edge_groups[index]
    paths = sources[group] if index not in [16, 17] else ["scripts/persistence/profile_store.gd", "scripts/persistence/profile_loader.gd", "scripts/persistence/save_coordinator.gd"]
    edges.append({"id": f"EDGE-{index + 1:02d}", "case": cells[0], "required_behavior": cells[1], "implementation_entry_points": paths, "executed_evidence": f"final-replay-disclosure/{suite}.log", "status": "代码及相关自动边界用例已核对；人工操作观察未替代"})
assert len(edges) == 20

principle_notes = [
    ("核心循环已存在，本轮缺口修复未扩新系统", "人工乐趣/体验与普通通关仍未验收"),
    ("UI消费状态，效果/阵位/事务在服务，Resource校验已补", "无新确认违规"),
    ("原创程序占位，有provenance与替换路径", "正式美术未实现，不属于新增范围"),
    ("13组原生、source/release受控图形与实际日志，保留失败记录", "人工/设备条件仍显式开放"),
    ("复用VisualSet整数2x，真实release预览/封顶截图已目视检查", "密集辨识/显示延迟待实测"),
    ("真实压力采样后修复无敌期无效hit分配，无减负荷/猜测性pooling", "帧预算未达，参考机与延迟未验收"),
    ("无backend/付费gacha/外部依赖，规格/计划hash不变", "无新确认违规"),
    ("修复有实际运行证据，文档同步，保留历史build/失败", "此前明确授权的M2–M4激活不代表原gate自动关闭"),
]
principles = []
for index, line in enumerate(line for line in read(".specify/memory/constitution.md").splitlines() if re.match(r"### [IVX]+\.", line)):
    principles.append({"principle": line[4:], "assessment": principle_notes[index][0], "remaining": principle_notes[index][1]})
assert len(principles) == 8

plan_groups = [
    ("引擎/离线依赖", ["project.godot", "export_presets.cfg"], "final-replay-disclosure/import.log", "固定4.5/Compatibility，无新增依赖"),
    ("模块/场景所有权", ["scripts/core/app_router.gd", "scenes/app/app.tscn"], "audit-final.log", "UI不承载战斗/事务规则"),
    ("Resource/校验", ["scripts/data/content_catalog.gd", "tests/unit/test_content_contract.gd"], "final-replay-disclosure/unit.log", "类型/ID/引用/范围/能力负例"),
    ("效果配置", ["scripts/data/effect_definition.gd", "tests/unit/test_configured_upgrades.gd"], "final-replay-disclosure/unit.log", "预览与执行同源"),
    ("固定tick/暂停", ["scripts/core/run_clock.gd", "scripts/core/choice_coordinator.gd"], "final-replay-disclosure/integration_m1.log", "冻结/恢复边界"),
    ("攻击/伤害", ["scripts/combat/damage_service.gd", "scripts/core/run_manager.gd"], "final-replay-disclosure/integration_m2.log", "45tick/同tick/Bastion保持，无敌期提前拒绝无效分配"),
    ("生成规则", ["scripts/data/wave_schedule.gd", "scripts/combat/spawn_director.gd"], "final-replay-disclosure/integration_m4.log", "早期母体/阈值/数量安全"),
    ("队伍", ["scripts/characters/companion_controller.gd"], "final-replay-disclosure/abilities.log", "四边四角阵位及安全重定位"),
    ("成长/事务", ["scripts/progression/permanent_progression.gd", "scripts/persistence/profile_loader.gd"], "final-replay-disclosure/persistence.log", "异常工件不静默新档，trace不入receipt"),
    ("收集", ["scripts/collection/recruitment_service.gd", "scripts/collection/rescue_objective.gd"], "final-replay-disclosure/integration_m3.log", "顺序结果/中断/费用/历史"),
    ("腐化/事件", ["scripts/abyss/corruption_service.gd", "scripts/abyss/event_director.gd"], "final-replay-disclosure/integration_m4.log", "阈值/事件/章节/所有权调度"),
    ("随机/回放", ["scripts/core/replay_trace.gd", "scripts/core/simulation_coordinator.gd"], "final-replay-disclosure/replay.log", "实际7400tick输入回放+二十对，不承诺跨版本物理一致"),
    ("视觉/UI", ["scripts/ui/promotion.gd", "scripts/ui/run_results.gd"], "release-final-replay/m4-prior-m2-release.log", "真实占位预览+每人XP，人工辨识仍开放"),
    ("性能", ["tests/performance/benchmark_capture.gd", "tools/run_benchmarks.ps1"], "benchmark-checks.json", "捕获有效但预算未达，T180开放"),
    ("导出/阶段gate", ["export_presets.cfg", "tools/run_m4_release_regressions.ps1"], "release-final-replay/runtime.json", "实际EXE受控流程通过，T183/T190和原gate开放"),
]
plans = [dict(group=group, implementation_entry_points=paths, executed_evidence=evidence, assessment=assessment) for group, paths, evidence, assessment in plan_groups]
for row in plans:
    for path in row["implementation_entry_points"]:
        assert (ROOT / path).exists(), path
    assert (BASE / row["executed_evidence"]).exists(), row
task_rows = re.findall(r"^- \[([ xX])\] (T\d+) ", read("specs/001-abyss-expedition-mvp/tasks.md"), re.M)
assert len(task_rows) == 191
original_open = [task for state, task in task_rows if state == " " and int(task[1:]) <= 175]
new_open = [task for state, task in task_rows if state == " " and int(task[1:]) > 175]
assert len(original_open) == 26 and new_open == ["T180", "T181", "T182", "T183", "T190"]
output = {"review_date": "2026-10-16", "meaning": "代码/Resource/场景及实际证据索引，不从勾选推导验收，不宣称完成人类体验/自然操作/参考机验收", "acceptance_scenarios": acceptance, "edge_cases": edges, "constitution_review": principles, "technical_plan_groups": plans, "original_open_tasks": original_open, "new_open_tasks": new_open, "all_task_count": len(task_rows), "open_task_count": len(original_open) + len(new_open), "full_convergence": False}
(BASE / "acceptance-review.json").write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print("38 AC / 20 edges / 8 principles / 15 plan groups; 191 tasks, 31 remain open")
