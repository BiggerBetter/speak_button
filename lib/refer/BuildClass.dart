import 'package:flutter/material.dart';

void main() {
  runApp(const BuildClass());
}

class BuildClass extends StatelessWidget {
  const BuildClass({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Layout Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('界面分区示例'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const HeaderSection(), // ① 顶部区域
            const SizedBox(height: 8),
            Expanded(
              // ② 中间滚动内容
              child: ContentSection(),
            ),
            const BottomSection(), // ③ 底部操作区
          ],
        ),
      ),
    );
  }
}

/// 顶部区域：标题 + 简要说明
class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '设置面板',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '这里演示如何把页面分成几个部分，每部分包含按钮和文本框。',
          ),
        ],
      ),
    );
  }
}

/// 中间内容：多个小卡片，每个卡片里有按钮 + 文本框
class ContentSection extends StatelessWidget {
  const ContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: const [
        SettingCard(
          title: '用户信息',
          children: [
            TextField(
              decoration: InputDecoration(labelText: '昵称'),
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(labelText: '邮箱'),
            ),
          ],
        ),
        SettingCard(
          title: '偏好设置',
          children: [
            _ButtonRow(), // 自定义一个小 Row，放几个按钮
          ],
        ),
        SettingCard(
          title: '高级选项',
          children: [
            Text('这里可以放一些开关 / 说明文字等'),
          ],
        ),
      ],
    );
  }
}

/// 卡片组件：标题 + 内部若干控件
class SettingCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// 一个按钮横排的小组件
class _ButtonRow extends StatelessWidget {
  const _ButtonRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // TODO: 写你的逻辑
            },
            child: const Text('明亮主题'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // TODO: 写你的逻辑
            },
            child: const Text('暗黑主题'),
          ),
        ),
      ],
    );
  }
}

/// 底部操作区域
class BottomSection extends StatelessWidget {
  const BottomSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // 总保存按钮逻辑
        },
        child: const Text('保存'),
      ),
    );
  }
}
