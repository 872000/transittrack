import 'package:flutter/material.dart';
import '../../models/transit_route.dart';

/// Small colored dot identifying a route.
class RouteDot extends StatelessWidget {
  const RouteDot({super.key, required this.route, this.size = 36});

  final TransitRoute route;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('FF${route.colorHex}', radix: 16));
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        route.shortName.replaceAll('Line ', ''),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.32,
        ),
      ),
    );
  }
}
