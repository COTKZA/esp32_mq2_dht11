import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beautiful Gauge Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GaugePage(),
    );
  }
}

class GaugePage extends StatefulWidget {
  @override
  _GaugePageState createState() => _GaugePageState();
}

class _GaugePageState extends State<GaugePage> {
  double _currentValue = 50; // ตั้งค่าเริ่มต้น

  String _getLabel(double value) {
    if (value <= 25) {
      return 'แก๊สน้อย';
    } else if (value <= 50) {
      return 'ปานกลาง';
    } else if (value <= 75) {
      return 'ค่อนข้างมาก';
    } else {
      return 'อันตราย';
    }
  }

  Color _getColor(double value) {
    if (value <= 25) {
      return Colors.green;
    } else if (value <= 50) {
      return Colors.yellow;
    } else if (value <= 75) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beautiful Gauge 1-100'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Value: ${_currentValue.toInt()} (${_getLabel(_currentValue)})',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CustomPaint(
              size: Size(200, 200),
              painter: GaugePainter(_currentValue, _getColor(_currentValue)),
            ),
          ],
        ),
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double value;
  final Color color;

  GaugePainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radius = size.width / 2;

    Paint outerCircle = Paint()
      ..shader = LinearGradient(
        colors: [Colors.grey[400]!, Colors.grey[300]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: Offset(centerX, centerY), radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    Paint valueArc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..shader = RadialGradient(
        colors: [color.withOpacity(0.8), color],
      ).createShader(Rect.fromCircle(center: Offset(centerX, centerY), radius: radius));

    canvas.drawCircle(Offset(centerX, centerY), radius, outerCircle);

    // ปรับการคำนวณมุมสำหรับเกจเต็ม 100 หน่วย (ใช้แค่ 180 องศา)
    double angle = (value / 100) * 3.1416; // 180 องศา

    // วาด Arc ที่แสดงค่า
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      3.1416, // เริ่มจากซ้ายสุด (180 องศา)
      angle,
      false,
      valueArc,
    );

    // วาดตัวเลขที่ตรงกลาง
    TextSpan span = new TextSpan(
      style: new TextStyle(color: Colors.black, fontSize: 48, fontWeight: FontWeight.bold),
      text: '${value.toInt()}',
    );
    TextPainter tp = new TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(centerX - tp.width / 2, centerY - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}