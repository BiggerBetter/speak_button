import 'dart:io';
import 'package:flutter/material.dart';

// void main() {
//   runApp(const SpeakApp());
// }

class SpeakApp extends StatelessWidget {
  const SpeakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '按钮发音 - macOS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SpeakHomePage(),
    );
  }
}

class SpeakHomePage extends StatefulWidget {
  const SpeakHomePage({super.key});

  @override
  State<SpeakHomePage> createState() => _SpeakHomePageState();
}

class _SpeakHomePageState extends State<SpeakHomePage> {
  final TextEditingController _controller = TextEditingController(text: "你好，世界！");

  Future<void> _speak(String text) async {
    if (!Platform.isMacOS) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('此示例仅适用于 macOS。')),
      );
      return;
    }
    try {
      // 使用 macOS 自带的 `say` 命令发声；
      // 你也可以传入 -v VoiceName 自定义声音，如 ["-v", "Ting-Ting", text]
      final result = await Process.run('say', [text]);
      if (result.exitCode != 0) {
        // 输出错误信息到控制台，便于调试
        // ignore: avoid_print
        print('say failed: ${result.stderr}');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('发音失败，请查看控制台输出。')),
          );
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error running say: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('运行 say 出错：$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('macOS 按钮发音（零依赖版）')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: '要朗读的文本',
                    hintText: '输入你想让电脑说的话',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 1,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _speak(_controller.text.trim().isEmpty ? "你好，世界！" : _controller.text.trim()),
                  icon: const Icon(Icons.volume_up),
                  label: const Text('点我说话'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}