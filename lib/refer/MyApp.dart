import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyOfficeApp());
}

class MyOfficeApp extends StatelessWidget {
  const MyOfficeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '办公应用草稿',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        fontFamily: 'SF Pro Text', // macOS 上默认感觉更协调一点
      ),
      home: const WorkspaceShell(),
    );
  }
}

class WorkspaceShell extends StatefulWidget {
  const WorkspaceShell({super.key});

  @override
  State<WorkspaceShell> createState() => _WorkspaceShellState();
}

class _WorkspaceShellState extends State<WorkspaceShell> {
  // 顶栏任务列表（可以后续也做成配置）
  final List<String> _tasks = ['任务一', '任务二', '任务三'];
  int _currentTaskIndex = 0;

  // 左侧主题按钮配置 & 状态
  List<String> _topics = [];
  final Set<String> _selectedTopics = {};
  final TextEditingController _requirementController = TextEditingController();

  Timer? _resultWatcher;
  bool _isWaiting = false;
  String? _workspaceText;
  DateTime? _waitStartTime;

  @override
  void initState() {
    super.initState();
    _loadLocalConfig();
  }

  Future<void> _loadLocalConfig() async {
    // 假设在 assets/config/topics.json 中：
    // {"buttons":"主题1,主题2,主题3"}
    // 你需要在 pubspec.yaml 里把这个文件加到 assets。
    try {
      final jsonStr = await rootBundle.loadString('assets/config/topics.json');
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final raw = (map['buttons'] as String?) ?? '';
      final topics = raw
          .split(RegExp(r'[，,]')) // 支持中英文逗号
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      setState(() {
        _topics = topics;
      });
    } catch (e) {
      // 加载失败时，给一些默认值，方便开发阶段预览
      setState(() {
        _topics = ['默认主题1', '默认主题2', '默认主题3'];
      });
    }
  }

  void _toggleTopic(String topic) {
    setState(() {
      if (_selectedTopics.contains(topic)) {
        _selectedTopics.remove(topic);
      } else {
        _selectedTopics.add(topic);
      }
    });
  }

  void _switchTask(int index) {
    setState(() {
      _currentTaskIndex = index;
      // 根据需求：切换任务时要不要清空选项、文本框自己定义
      // _selectedTopics.clear();
      // _requirementController.clear();
    });
  }

  void _onStirWorldPressed() {
    // 点击“搅动这个世界”按钮后，进入 waiting 状态，并开始轮询本地目录
    setState(() {
      _isWaiting = true;
      _workspaceText = 'waiting';
      _waitStartTime = DateTime.now();
    });

    _resultWatcher?.cancel();
    _resultWatcher = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkForResultFile(timer);
    });
  }

  Future<void> _checkForResultFile(Timer timer) async {
    try {
      // 在 macOS 上这里使用本地文件系统目录，而不是 Flutter 的 assets bundle。
      final dir = Directory('assets/result');
      if (!await dir.exists()) {
        return;
      }

      final entities = await dir.list().toList();
      File? latestFile;
      DateTime? latestTime;

      for (final entity in entities) {
        if (entity is File && entity.path.toLowerCase().endsWith('.json')) {
          final stat = await entity.stat();
          final modified = stat.modified;

          // 只考虑按钮点击之后生成的文件
          if (_waitStartTime != null && modified.isBefore(_waitStartTime!)) {
            continue;
          }

          if (latestTime == null || modified.isAfter(latestTime)) {
            latestTime = modified;
            latestFile = entity;
          }
        }
      }

      if (latestFile != null) {
        final content = await latestFile.readAsString();
        setState(() {
          _workspaceText = content;
          _isWaiting = false;
        });
        timer.cancel();
        _resultWatcher = null;
      }
    } catch (e) {
      // 简单忽略错误，必要时可以在 UI 上提示
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildTopBar(context),
          const Divider(height: 1),
          Expanded(
            child: Row(
              children: [
                _buildLeftSidebar(context),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _buildWorkspace(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 顶栏：任务切换按钮区
  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          const Text(
            '我的办公应用',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 24),
          // 任务标签
          Wrap(
            spacing: 8,
            children: List.generate(_tasks.length, (index) {
              final isActive = index == _currentTaskIndex;
              return ChoiceChip(
                label: Text(_tasks[index]),
                selected: isActive,
                onSelected: (_) => _switchTask(index),
              );
            }),
          ),
          const Spacer(),
          // 右上角预留一些操作按钮，例如设置、帮助等
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
            tooltip: '设置',
          ),
        ],
      ),
    );
  }

  // 左侧副栏：要求输入区 + 主题按钮
  Widget _buildLeftSidebar(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '要求',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_topics.isNotEmpty) ...[
                    const Text(
                      '主题选择',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _topics.map((topic) {
                        final selected = _selectedTopics.contains(topic);
                        return FilterChip(
                          label: Text(topic),
                          selected: selected,
                          onSelected: (_) => _toggleTopic(topic),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const Text(
                    '其他说明',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _requirementController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: '在这里输入更详细的要求...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedTopics.isNotEmpty) ...[
                    const Text(
                      '已选择的主题：',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: _selectedTopics.map((t) {
                        return Chip(
                          label: Text(t, style: const TextStyle(fontSize: 11)),
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onStirWorldPressed,
              child: const Text('搅动这个世界'),
            ),
          ),
        ],
      ),
    );
  }

  // 主工作区：根据当前任务展示不同内容
  Widget _buildWorkspace(BuildContext context) {
    final taskName = _tasks[_currentTaskIndex];
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 工作区标题
          Row(
            children: [
              Text(
                '工作区 - $taskName',
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              // 可以加一些当前任务的小状态显示
              Text(
                '已选主题：${_selectedTopics.join("，")}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              alignment: Alignment.center,
              child: _isWaiting
                  ? const Text(
                      'waiting',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    )
                  : Text(
                      _workspaceText ??
                          '这里是 $taskName 的工作区内容区域。\n'
                          '后续可以替换成编辑器、列表、看板、AI 输出等组件。',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _resultWatcher?.cancel();
    _requirementController.dispose();
    super.dispose();
  }
}