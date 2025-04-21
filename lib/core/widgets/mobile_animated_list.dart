import 'package:flutter/material.dart';
import '../constants/app_animations.dart';

class MobileAnimatedList extends StatefulWidget {
  final List<Widget> children;
  final Function(int)? onRemove;
  final Function(int, int)? onReorder;
  final bool enableReorder;
  final EdgeInsets padding;
  final ScrollPhysics? physics;

  const MobileAnimatedList({
    super.key,
    required this.children,
    this.onRemove,
    this.onReorder,
    this.enableReorder = false,
    this.padding = EdgeInsets.zero,
    this.physics,
  });

  @override
  State<MobileAnimatedList> createState() => _MobileAnimatedListState();
}

class _MobileAnimatedListState extends State<MobileAnimatedList>
    with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<Widget> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.children);
  }

  @override
  void didUpdateWidget(MobileAnimatedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length > _items.length) {
      // Nuevos items añadidos
      final newItems = widget.children.sublist(_items.length);
      for (var i = 0; i < newItems.length; i++) {
        _items.add(newItems[i]);
        _listKey.currentState?.insertItem(
          _items.length - 1,
          duration: AppAnimations.normal,
        );
      }
    } else if (widget.children.length < _items.length) {
      // Items eliminados
      while (_items.length > widget.children.length) {
        final index = _items.length - 1;
        final removedItem = _items[index];
        _listKey.currentState?.removeItem(
          index,
          (context, animation) => _buildRemovedItem(removedItem, animation),
          duration: AppAnimations.normal,
        );
        _items.removeLast();
      }
    }
  }

  Widget _buildRemovedItem(Widget item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: const Offset(-0.5, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: AppAnimations.smoothCurve)),
          ),
          child: item,
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: AppAnimations.smoothCurve)),
      ),
      child: FadeTransition(
        opacity: animation,
        child: widget.onRemove != null
            ? Dismissible(
                key: ValueKey(_items[index]),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => widget.onRemove?.call(index),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                child: _items[index],
              )
            : _items[index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enableReorder && widget.onReorder != null) {
      return ReorderableListView(
        padding: widget.padding,
        physics: widget.physics,
        onReorder: widget.onReorder!,
        children: _items
            .asMap()
            .map((index, child) => MapEntry(
                  index,
                  KeyedSubtree(
                    key: ValueKey(index),
                    child: child,
                  ),
                ))
            .values
            .toList(),
      );
    }

    return AnimatedList(
      key: _listKey,
      padding: widget.padding,
      physics: widget.physics,
      initialItemCount: _items.length,
      itemBuilder: _buildItem,
    );
  }
}
