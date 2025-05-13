import 'package:flutter/material.dart';
import '../screens/create_time_block_screen.dart';
import '../../data/models/time_block_model.dart';

class EditTimeBlockScreen extends StatefulWidget {
  final TimeBlockModel timeBlock;

  const EditTimeBlockScreen({
    super.key,
    required this.timeBlock,
  });

  @override
  State<EditTimeBlockScreen> createState() => _EditTimeBlockScreenState();
}

class _EditTimeBlockScreenState extends State<EditTimeBlockScreen> {
  @override
  Widget build(BuildContext context) {
    return CreateTimeBlockScreen(timeBlock: widget.timeBlock);
  }
}
