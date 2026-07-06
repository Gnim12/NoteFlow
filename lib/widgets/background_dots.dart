import 'package:flutter/material.dart';

class BackgroundDots extends StatelessWidget {
  const BackgroundDots({super.key});

  Widget dots() {
    return SizedBox(
      width: 48,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          16,
          (_) => Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.45),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        const Positioned(
          left: 25,
          top: 120,
          child: IgnorePointer(
            child: SizedBox(
              child: _DotsWidget(),
            ),
          ),
        ),

        const Positioned(
          right: 25,
          top: 360,
          child: IgnorePointer(
            child: SizedBox(
              child: _DotsWidget(),
            ),
          ),
        ),
      ],
    );
  }
}

class _DotsWidget extends StatelessWidget {
  const _DotsWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          16,
          (_) => Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white54,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}