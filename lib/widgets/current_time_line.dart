import 'dart:async';
import 'package:flutter/material.dart';

class CurrentTimeLine extends StatefulWidget {
  final double hourHeight;
  const CurrentTimeLine({super.key, required this.hourHeight});

  @override
  State<CurrentTimeLine> createState() => _CurrentTimeLineState();
}

class _CurrentTimeLineState extends State<CurrentTimeLine> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _now.hour * 60 + _now.minute;
    final offset = -35.0;
    final top = (minutes * (widget.hourHeight / 60)) + offset;
    final horaTexto = TimeOfDay.fromDateTime(_now).format(context);

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Container(
            height: 41,
            alignment: Alignment.center, // 🔥 centra el stack verticalmente
            child: Stack(
              clipBehavior: Clip.none, // 🔧 permite que el triángulo sobresalga
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: -5, // visible justo debajo del container
                  child: ClipPath(
                    clipper: _TriangleClipper(),
                    child: Container(
                      width: 10,
                      height: 6,
                      color: Colors.red.withOpacity(0.5),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    horaTexto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 10,
            alignment: Alignment.topCenter,
            child: Container(
              height: 3,
              color: Colors.red.withOpacity(1), // 🎯 más visible
            ),
          ),



        ],
      ),
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
