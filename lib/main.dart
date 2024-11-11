import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (iconData) {
              return DockItem(iconData: iconData);
            },
          ),
        ),
      ),
    );
  }
}

/// Dock that provides draggable and reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {
  /// List of [T] items being manipulated.
  late final List<T> _items = widget.items.toList();
  int? draggingIndex;
  Offset dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black26,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_items.length, (index) {
          final isDragging = draggingIndex == index;
          return AnimatedPositioned(
            duration: isDragging ? Duration.zero : const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left: isDragging
                ? dragOffset.dx
                : index * 60.0, // Adjusts position based on index.
            child: LongPressDraggable<int>(
              data: index,
              onDragStarted: () {
                setState(() {
                  draggingIndex = index;
                });
              },
              onDragUpdate: (details) {
                setState(() {
                  dragOffset = details.localPosition;
                });
              },
              onDragEnd: (details) {
                setState(() {
                  draggingIndex = null;
                });
              },
              feedback: Opacity(
                opacity: 0.75,
                child: widget.builder(_items[index]),
              ),
              childWhenDragging: const SizedBox.shrink(),
              child: DragTarget<int>(
                onAccept: (fromIndex) {
                  setState(() {
                    final item = _items.removeAt(fromIndex);
                    _items.insert(index, item);
                  });
                },
                onWillAccept: (fromIndex) => fromIndex != index,
                builder: (context, candidateData, rejectedData) {
                  return widget.builder(_items[index]);
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// A single dock item widget that displays an icon.
class DockItem extends StatelessWidget {
  const DockItem({Key? key, required this.iconData}) : super(key: key);

  /// The icon data to be displayed in the dock item.
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      height: 48,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.primaries[iconData.hashCode % Colors.primaries.length],
      ),
      child: Center(
        child: Icon(
          iconData,
          color: Colors.white,
        ),
      ),
    );
  }
}
