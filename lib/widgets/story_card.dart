import 'package:flutter/material.dart';
import 'package:juanlalakbay/widgets/button.dart';
import 'package:juanlalakbay/widgets/text.dart';

class StoryCard extends StatefulWidget {
  final String title;
  final String story;
  final double width;
  final double height;
  final VoidCallback? onLastPageCallback;
  final VoidCallback? onNotLastPageCallback;

  const StoryCard({
    super.key,
    required this.title,
    required this.story,
    this.onLastPageCallback,
    this.onNotLastPageCallback,
    this.width = 450,
    this.height = 250,
  });

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  static const int charsPerPage = 200;
  late final List<String> pages;
  int currentPage = 0;
  int totalWords = 0;

  @override
  void initState() {
    super.initState();
    pages = _splitIntoPages(widget.story);

    // If there is only ONE page, notify parent AFTER build
    if (pages.length == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onLastPageCallback?.call();
      });
    }
  }

  List<String> _splitIntoPages(String text) {
    final words = text.split(RegExp(r'\s+'));
    final List<String> result = [];

    String currentPage = '';

    for (final word in words) {
      totalWords++;
      final nextLength = currentPage.isEmpty
          ? word.length
          : currentPage.length + 1 + word.length;

      if (nextLength <= charsPerPage) {
        currentPage = currentPage.isEmpty ? word : '$currentPage $word';
      } else {
        result.add(currentPage);
        currentPage = word;
      }
    }

    if (currentPage.isNotEmpty) {
      result.add(currentPage);
    }

    return result;
  }

  void nextPage() {
    if (currentPage == pages.length - 2) {
      // about to reach last page
      widget.onLastPageCallback?.call();
    }

    if (currentPage < pages.length - 1) {
      setState(() => currentPage++);
    }
  }

  void prevPage() {
    if (currentPage == pages.length - 1) {
      // leaving last page
      widget.onNotLastPageCallback?.call();
    }

    if (currentPage > 0) {
      setState(() => currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF59D), Color(0xFFFFE082)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 6),
            blurRadius: 6,
          ),
        ],
        border: Border.all(color: Colors.orange.shade700, width: 3),
      ),
      child: Column(
        children: [
          /// STORY TEXT
          Expanded(
            child: Center(
              child: GameText(text: pages[currentPage], fontSize: 17),
            ),
          ),

          const SizedBox(height: 12),

          /// PAGE INDICATOR
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == currentPage
                      ? Colors.orange.shade800
                      : Colors.orange.shade200,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// NAV BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GameButton(
                icon: Icons.arrow_back_ios_new,
                enabled: currentPage > 0,
                onPressed: prevPage,
                size: GameButtonSize.small,
              ),
              GameText(text: "Bilang ng salita: $totalWords", fontSize: 14),
              GameButton(
                icon: Icons.arrow_forward_ios,
                enabled: currentPage < pages.length - 1, // disable on last page
                onPressed: nextPage,
                size: GameButtonSize.small,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
