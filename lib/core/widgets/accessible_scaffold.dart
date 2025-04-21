import 'package:flutter/material.dart';
import '../constants/accessibility_styles.dart';

class AccessibleScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showAppBar;
  final Color? backgroundColor;

  const AccessibleScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.showAppBar = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: showAppBar
          ? AppBar(
              title: title != null
                  ? Text(
                      title!,
                      style: AccessibilityStyles.accessibleTitleLarge,
                    )
                  : null,
              actions: actions,
              elevation: 0,
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AccessibilityStyles.spacingMedium),
          child: body,
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
