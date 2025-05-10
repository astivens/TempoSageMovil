import 'package:flutter/material.dart';
import '../constants/app_animations.dart';
import '../constants/app_colors.dart';
import 'animated_list_item.dart';

/// Lista animada para interfaces móviles con soporte para:
/// - Animaciones de entrada/salida
/// - Eliminación mediante deslizamiento (swipe-to-dismiss)
/// - Reordenamiento de elementos
///
/// Este componente utiliza el AnimatedList de Flutter internamente y
/// proporciona una API simplificada para animaciones de interfaz de usuario.
class MobileAnimatedList extends StatefulWidget {
  /// Elementos a mostrar en la lista
  final List<Widget> children;

  /// Callback cuando un elemento es eliminado (con su índice)
  final Function(int)? onRemove;

  /// Callback cuando un elemento es reordenado (con índice original y nuevo)
  final Function(int, int)? onReorder;

  /// Activar funcionalidad de reordenamiento
  final bool enableReorder;

  /// Relleno alrededor de la lista
  final EdgeInsets padding;

  /// Física de desplazamiento personalizada
  final ScrollPhysics? physics;

  /// Duración de las animaciones
  final Duration animationDuration;

  /// Controlador de desplazamiento personalizado
  final ScrollController? scrollController;

  const MobileAnimatedList({
    super.key,
    required this.children,
    this.onRemove,
    this.onReorder,
    this.enableReorder = false,
    this.padding = EdgeInsets.zero,
    this.physics,
    this.animationDuration = const Duration(milliseconds: 350),
    this.scrollController,
  });

  @override
  State<MobileAnimatedList> createState() => _MobileAnimatedListState();
}

class _MobileAnimatedListState extends State<MobileAnimatedList>
    with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<Widget> _items;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.children);
    _isInitialized = true;
  }

  @override
  void didUpdateWidget(MobileAnimatedList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Sólo manejar cambios después de la inicialización
    if (!_isInitialized) return;

    // Optimización: no hacer cambios si los elementos son los mismos
    if (_itemsAreEqual(widget.children, _items)) return;

    _updateItems();
  }

  /// Verifica si dos listas de widgets son iguales usando sus keys
  bool _itemsAreEqual(List<Widget> items1, List<Widget> items2) {
    if (items1.length != items2.length) return false;

    for (var i = 0; i < items1.length; i++) {
      if (items1[i].key != items2[i].key) return false;
    }

    return true;
  }

  /// Actualiza los elementos mostrados con animaciones
  void _updateItems() {
    if (widget.children.length > _items.length) {
      // Nuevos elementos añadidos
      final newItems = widget.children.sublist(_items.length);
      for (var i = 0; i < newItems.length; i++) {
        _items.add(newItems[i]);
        _listKey.currentState?.insertItem(
          _items.length - 1,
          duration: widget.animationDuration,
        );
      }
    } else if (widget.children.length < _items.length) {
      // Elementos eliminados
      while (_items.length > widget.children.length) {
        final index = _items.length - 1;
        final removedItem = _items[index];
        _listKey.currentState?.removeItem(
          index,
          (context, animation) => _buildRemovedItem(removedItem, animation),
          duration: widget.animationDuration,
        );
        _items.removeLast();
      }
    } else {
      // Misma cantidad pero posibles diferentes elementos
      setState(() {
        _items = List.from(widget.children);
      });
    }
  }

  /// Construye la animación para un elemento removido
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

  /// Construye un elemento con animación
  Widget _buildItem(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    // Usar AnimatedListItem para animaciones consistentes
    final child = AnimatedListItem(
      index: index,
      animation: animation,
      animateOnInit: false,
      child: _items[index],
    );

    // Agregar comportamiento de deslizamiento si se especifica onRemove
    if (widget.onRemove != null) {
      return Dismissible(
        key: ValueKey('dismissible_${_items[index].hashCode}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => widget.onRemove?.call(index),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.mocha.red
              : AppColors.latte.red,
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        child: child,
      );
    }

    return child;
  }

  @override
  Widget build(BuildContext context) {
    // Usar ReorderableListView si se activa reordenamiento
    if (widget.enableReorder && widget.onReorder != null) {
      return ReorderableListView(
        padding: widget.padding,
        physics: widget.physics,
        scrollController: widget.scrollController,
        onReorder: widget.onReorder!,
        children: _items
            .asMap()
            .map((index, child) => MapEntry(
                  index,
                  KeyedSubtree(
                    key: ValueKey('reorderable_$index'),
                    child: child,
                  ),
                ))
            .values
            .toList(),
      );
    }

    // Usar AnimatedList para los demás casos
    return AnimatedList(
      key: _listKey,
      padding: widget.padding,
      physics: widget.physics,
      controller: widget.scrollController,
      initialItemCount: _items.length,
      itemBuilder: _buildItem,
    );
  }
}
