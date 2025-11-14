import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const PagesApp());
}

class PagesApp extends StatelessWidget {
  const PagesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: true,
      title: 'Pages Demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const Pages(),
    );
  }
}

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  final List<TextEditingController> _controllers = [];

  final FlutterTts _tts = FlutterTts();

  bool _didInitPosition = false;
  final List<Offset> _positions = [];
  final List<Size> _sizes = [];

  @override
  void initState() {
    super.initState();
    _configureTts();
    _addBundle();
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('zh-CN');
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.4); // 速度
    await _tts.setPitch(1.0); // 音高
  }

  Future<void> _speak(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    await _tts.stop();
    await _tts.speak(t);
  }

  void _addBundle() {
    setState(() {
      _controllers.add(TextEditingController(text: '这是属于我们的光荣'));
      _positions.add(Offset.zero);
      _sizes.add(Size.zero);
      _didInitPosition = false; // 让下次 build 重新计算初始位置
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double textBoxHeight = constraints.maxHeight / 5;
          final double boxWidth = constraints.maxWidth * 0.3;

          if (!_didInitPosition) {
            final double left = (constraints.maxWidth - boxWidth) / 2;
            final double topStart = 40;
            for (int i = 0; i < _controllers.length; i++) {
              final double top = topStart + i * (textBoxHeight + 80);
              _positions[i] = Offset(left, top);
            }
            _didInitPosition = true;
          }

          final List<Widget> bundles = [];
          for (int i = 0; i < _controllers.length; i++) {
            bundles.add(
              _DraggableBundle(
                leftTop: _positions[i],
                width: boxWidth,
                textHeight: textBoxHeight,
                controller: _controllers[i],
                onPlay: () => _speak(_controllers[i].text),
                onDrag: (delta) {
                  setState(() {
                    _positions[i] = _clamp(_positions[i] + delta, _sizes[i], constraints);
                  });
                },
                onSized: (size) {
                  if (_sizes[i] != size) {
                    setState(() => _sizes[i] = size);
                  }
                },
              ),
            );
          }

          return Stack(
            children: bundles,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBundle,
        child: const Icon(Icons.add),
      ),
    );
  }

  // 约束组件不超出可视区域
  Offset _clamp(Offset next, Size size, BoxConstraints c) {
    final double maxX = (c.maxWidth - size.width).clamp(0, double.infinity);
    final double maxY = (c.maxHeight - size.height).clamp(0, double.infinity);
    final double nx = next.dx.clamp(0.0, maxX);
    final double ny = next.dy.clamp(0.0, maxY);
    return Offset(nx, ny);
  }
}

class _DraggableBundle extends StatelessWidget {
  final Offset leftTop;
  final double width;
  final double textHeight;
  final TextEditingController controller;
  final VoidCallback onPlay;
  final ValueChanged<Offset> onDrag; // 传回 delta
  final ValueChanged<Size> onSized;

  const _DraggableBundle({
    required this.leftTop,
    required this.width,
    required this.textHeight,
    required this.controller,
    required this.onPlay,
    required this.onDrag,
    required this.onSized,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: leftTop.dx,
      top: leftTop.dy,
      width: width,
      child: _SizeObserver(
        onChanged: onSized,
        child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onPanUpdate: (details) => onDrag(details.delta), // 鼠标/触控拖动
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('播放'),
                    onPressed: onPlay,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: textHeight,
                    child: TextField(
                      controller: controller,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                        hintText: '在此输入要朗读的文本',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SizeObserver extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onChanged;
  const _SizeObserver({required this.child, required this.onChanged});

  @override
  State<_SizeObserver> createState() => _SizeObserverState();
}

class _SizeObserverState extends State<_SizeObserver> {
  Size _last = Size.zero;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = context.size;
      if (size != null && size != _last) {
        _last = size;
        widget.onChanged(size);
      }
    });
    return widget.child;
  }
}