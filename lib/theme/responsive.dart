import 'package:flutter/material.dart';

/// Shared responsive breakpoints for the app. Mobile-first: anything below
/// [tablet] is treated as a phone, [tablet]-[desktop] as a tablet / small
/// window, and >= [desktop] as a desktop/web viewport.
class Breakpoints {
  Breakpoints._();

  static const double tablet = 600;
  static const double desktop = 1024;

  /// A second, wider desktop tier — used sparingly to add an extra column
  /// or a bit more breathing room on very large monitors.
  static const double wide = 1440;
}

enum ScreenSize { mobile, tablet, desktop }

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  ScreenSize get screenSize {
    final w = screenWidth;
    if (w >= Breakpoints.desktop) return ScreenSize.desktop;
    if (w >= Breakpoints.tablet) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  bool get isMobile => screenSize == ScreenSize.mobile;
  bool get isTablet => screenSize == ScreenSize.tablet;
  bool get isDesktop => screenSize == ScreenSize.desktop;

  /// True for tablet *or* desktop — handy for the common "not a phone"
  /// check that most existing `isTablet` bools in this codebase actually
  /// meant to express.
  bool get isWide => screenWidth >= Breakpoints.tablet;

  /// Picks a value based on the current breakpoint, falling back to the
  /// next-smallest tier when a size isn't specified.
  T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    switch (screenSize) {
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.mobile:
        return mobile;
    }
  }
}

/// Computes how many grid columns fit a given width, given a minimum tile
/// width. Used by both [ResponsiveGrid] and sliver grids that need a column
/// count up front.
int responsiveColumns(
  double width, {
  double minTileWidth = 300,
  int maxColumns = 4,
}) {
  final columns = (width / minTileWidth).floor();
  return columns.clamp(1, maxColumns);
}

/// Centers content and caps its width on large screens so layouts don't
/// stretch full-bleed across wide/desktop viewports. Wrap the scrollable
/// body (or a sliver's content) of a screen in this to keep it readable on
/// desktop/web while leaving mobile layouts untouched (the cap only ever
/// kicks in once the viewport is wider than [maxWidth]).
class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final AlignmentGeometry alignment;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 1100,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// A `SliverToBoxAdapter`-friendly version of [ResponsiveContent], for
/// dropping straight into a `CustomScrollView`'s `slivers` list.
class SliverResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const SliverResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 1100,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ResponsiveContent(maxWidth: maxWidth, child: child),
    );
  }
}

/// A simple width-aware wrap-grid for turning a stretched single-column
/// list of cards into a multi-column layout on tablet/desktop. Each child
/// is given equal width; height is intrinsic (driven by the child itself),
/// so this works well for cards of varying content length.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minTileWidth;
  final double spacing;
  final double runSpacing;
  final int maxColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minTileWidth = 320,
    this.spacing = 16,
    this.runSpacing = 16,
    this.maxColumns = 3,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = responsiveColumns(
          constraints.maxWidth,
          minTileWidth: minTileWidth,
          maxColumns: maxColumns,
        );
        if (columns <= 1) {
          return Column(
            children: [
              for (final child in children) ...[
                child,
                if (child != children.last) SizedBox(height: runSpacing),
              ],
            ],
          );
        }
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (final child in children)
              SizedBox(width: tileWidth, child: child),
          ],
        );
      },
    );
  }
}
