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
  final TextEditingController _controller1 =
      TextEditingController(text: '这是属于我们的光荣');
  final TextEditingController _controller2 =
      TextEditingController(text: '这是属于我们的光荣');

  final FlutterTts _tts = FlutterTts();

  Offset _pos1 = const Offset(0, 0);
  Offset _pos2 = const Offset(0, 0);
  bool _didInitPosition = false;
  Size _size1 = Size.zero; // 实际渲染后的尺寸
  Size _size2 = Size.zero; // 实际渲染后的尺寸

  @override
  void initState() {
    super.initState();
    _configureTts(); // todo 应该是这个功能需要一个初始配置
  }

  Future<void> _configureTts() async { // todo Future是什么，async是什么
    await _tts.setLanguage('zh-CN');
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.4); // 速度
    await _tts.setPitch(1.0); // 音高
  }

  Future<void> _speak(String text) async {// todo 为什么异步呢
    final t = text.trim();
    if (t.isEmpty) return;
    await _tts.stop();
    await _tts.speak(t);
  }

  @override
  void dispose() { // todo 这个是解构方法吗
    _controller1.dispose();
    _controller2.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder( // 会算算排布的位置参数，返回一个stack
        builder: (context, constraints) {
          final double textBoxHeight = constraints.maxHeight / 5; // 每个编辑框占可用高度的 1/5
          final double boxWidth = constraints.maxWidth * 0.3; // 适度留白

          // 初始位置：水平居中，垂直按顺序放置两个
          if (!_didInitPosition) {
            final double left = (constraints.maxWidth - boxWidth) / 2;
            final double top1 = 40;
            final double top2 = top1 + (textBoxHeight + 80); // 预估初始间距，后续用真实尺寸约束
            _pos1 = Offset(left, top1);
            _pos2 = Offset(left, top2);
            _didInitPosition = true;
          }

          return Stack(
            children: [
              _DraggableBundle(
                leftTop: _pos1,
                width: boxWidth,
                textHeight: textBoxHeight,
                controller: _controller1,
                onPlay: () => _speak(_controller1.text),
                onDrag: (delta) {
                  setState(() {
                    _pos1 = _clamp(_pos1 + delta, _size1, constraints);
                  });
                },
                onSized: (size) {
                  if (_size1 != size) {
                    setState(() => _size1 = size);
                  }
                },
              ),
              _DraggableBundle(
                leftTop: _pos2,
                width: boxWidth,
                textHeight: textBoxHeight,
                controller: _controller2,
                onPlay: () => _speak(_controller2.text),
                onDrag: (delta) {
                  setState(() {
                    _pos2 = _clamp(_pos2 + delta, _size2, constraints);
                  });
                },
                onSized: (size) {
                  if (_size2 != size) {
                    setState(() => _size2 = size);
                  }
                },
              ),
            ],
          );
        },
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