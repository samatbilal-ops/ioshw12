import 'package:flutter/material.dart';

import '../../widgets/product_image.dart';

/// Swipeable gallery: PageView.builder + counter "1 / 3" + animated dots.
class PhotoCarousel extends StatefulWidget {
  final List<String> images;
  final String heroTag;

  const PhotoCarousel({super.key, required this.images, required this.heroTag});

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose(); // free the controller
    super.dispose();
  }

  void _goTo(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    final primary = Theme.of(context).colorScheme.primary;

    return AspectRatio(
      aspectRatio: 1.1,
      child: Stack(
        children: [
          // Lazy: only the visible page (and its neighbour) is built.
          PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) {
              final photo = Container(
                color: Colors.white,
                padding: const EdgeInsets.all(28),
                child: ProductImage(path: images[i], fit: BoxFit.contain),
              );
              // Hero only on the first page (the one that flew from the list)
              return i == 0 ? Hero(tag: widget.heroTag, child: photo) : photo;
            },
          ),

          // Counter "1 / 3"
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_page + 1} / ${images.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),

          // Arrows (handy with a mouse in Chrome)
          if (images.length > 1) ...[
            Positioned(
              left: 4,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  tooltip: 'Previous photo',
                  onPressed: _page > 0 ? () => _goTo(_page - 1) : null,
                  icon: const Icon(Icons.chevron_left),
                ),
              ),
            ),
            Positioned(
              right: 4,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  tooltip: 'Next photo',
                  onPressed:
                      _page < images.length - 1 ? () => _goTo(_page + 1) : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ),
            ),
          ],

          // Animated dots: the active one stretches into a pill.
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < images.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page ? primary : Colors.black26,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
