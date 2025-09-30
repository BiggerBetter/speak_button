核心目录
	•	lib/
你的应用逻辑和界面写在这里。main.dart 就是入口文件。绝大部分 Flutter 代码都放在这个目录。
	•	macos/
跟 macOS 平台相关的工程配置和原生代码。Flutter 会在这里生成 Runner 工程，调用 Xcode 构建。
	•	test/
自动化测试代码放这里。里面默认有一个 widget_test.dart，是示例单元测试。

⸻

工具/生成目录
	•	.dart_tool/
Dart/Flutter 工具链生成的缓存，存放编译信息、依赖解析结果。你一般不用改。
	•	build/
构建产物输出目录，每次 flutter build 或 flutter run 时会生成/更新。可以随时删掉重新生成。
	•	.idea/
这是 IntelliJ/Android Studio 用的项目配置文件。如果只用 VS Code，可以忽略。

⸻

配置文件
	•	pubspec.yaml
最重要的配置文件，声明项目用的依赖包、资源（图片、字体）、版本号等。
改完要运行 flutter pub get 来下载依赖。
	•	pubspec.lock
锁定依赖的具体版本，确保团队协作时大家环境一致。
	•	analysis_options.yaml
Dart 静态分析/代码规范的配置，影响 IDE 的提示和警告。
	•	.gitignore
告诉 Git 哪些文件不需要提交（比如 build/ 目录）。
	•	.metadata
Flutter 工具内部使用，记录项目创建信息、SDK 版本。
	•	speak_button.iml
IntelliJ/Android Studio 的项目模块文件，VS Code 可以忽略。
	•	README.md
工程说明文档，你可以在这里写项目介绍。