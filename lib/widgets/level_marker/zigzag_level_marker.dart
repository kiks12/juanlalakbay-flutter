import 'package:flutter/material.dart';

class ZigZagLevelMarker extends StatelessWidget {
  final int index;
  final Widget marker;

  const ZigZagLevelMarker({
    super.key,
    required this.index,
    required this.marker,
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = index.isEven;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: isLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (!isLeft) const Spacer(),
          marker,
          if (isLeft) const Spacer(),
        ],
      ),
    );
  }
}
