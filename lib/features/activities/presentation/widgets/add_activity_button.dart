import 'package:flutter/material.dart';

class AddActivityButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddActivityButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: const Icon(Icons.add),
    );
  }
}
