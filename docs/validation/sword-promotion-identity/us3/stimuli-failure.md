# 材料工具早期失败保留

实际执行`Godot --headless --path . --check-only --script res://tests/sword_identity_stimuli.gd`时，首版通过继承另一个SceneTree脚本复用夹具，Godot4.5原生CrashHandler报告signal11。外层随后读取JSON掩盖了该命令退出码，因此未记录可靠退出码，不判通过。工具调用原始输出保留在会话中；未伪造本地crash日志。

改为自包含SceneTree测试harness后，[真实受控捕获](../stimuli-capture-20261021-v1/capture.log)2246断言0失败，完整M4解析亦通过。生产游戏代码未因该测试工具问题修改。
