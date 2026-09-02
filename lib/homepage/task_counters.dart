import 'package:flutter/material.dart';
import 'package:app/theme/responsive.dart';

class Counters extends StatelessWidget {
  const Counters({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Task Counters',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255), // Set the new background color
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Capped/centered on wide screens so the three cards don't end
            // up scattered far apart across a desktop-width window; the
            // cards themselves grow a little on tablet/desktop too.
            ResponsiveContent(
              maxWidth: 640,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CounterCard(
                    title: 'Classes',
                    count: '5',
                    width: context.responsive(mobile: 100.0, tablet: 140.0),
                    height: context.responsive(mobile: 100.0, tablet: 120.0),
                  ),
                  CounterCard(
                    title: 'Assignments',
                    count: '3',
                    width: context.responsive(mobile: 100.0, tablet: 140.0),
                    height: context.responsive(mobile: 100.0, tablet: 120.0),
                  ),
                  CounterCard(
                    title: 'Exams',
                    count: '2',
                    width: context.responsive(mobile: 100.0, tablet: 140.0),
                    height: context.responsive(mobile: 100.0, tablet: 120.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CounterCard extends StatelessWidget {
  final String title;
  final String count;
  final double width;
  final double height;
  const CounterCard({
    super.key,
    required this.title,
    required this.count,
    this.width = 100,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    // Card scales with the width/height passed in (the caller sizes these
    // up a bit on tablet/desktop) instead of always rendering at a fixed
    // mobile size.
    final isCompact = width <= 110;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: isCompact ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: isCompact ? 16 : 17,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
