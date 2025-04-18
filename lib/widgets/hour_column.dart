import 'package:flutter/material.dart';

class HourColumn extends StatelessWidget {
  final double hourHeight;
  const HourColumn({super.key, required this.hourHeight});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(96, (i) {
        final hour = (i * 15) ~/ 60;
        final minute = (i * 15) % 60;
        final label = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

        return  SizedBox(
          height: hourHeight / 4,
          width: 60,
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 0, left: 6), // 🔥 Alineación exacta
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ),
        );

      }),
    );
  }
}
