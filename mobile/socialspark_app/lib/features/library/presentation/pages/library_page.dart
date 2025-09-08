import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socialspark_app/core/widgets/main_scaffold.dart';
import 'package:socialspark_app/features/library/data/datasources/library_local_ds.dart';
import 'package:socialspark_app/features/library/data/models/library_item.dart';
import 'package:socialspark_app/features/editor/domain/entities/content.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final LibraryLocalDataSource _libraryDs = LibraryLocalDataSource.instance;
  List<LibraryItem> _items = [];

  String _selectedPlatform = 'All';
  String _selectedContentType = 'All';

  final List<String> _platforms = ['All', 'instagram', 'tiktok'];
  final List<String> _contentTypes = ['All', 'Image', 'Video'];

  @override
  void initState() {
    super.initState();
    _libraryDs.addListener(_loadLibraryItems);
    _loadLibraryItems();
  }

  @override
  void dispose() {
    _libraryDs.removeListener(_loadLibraryItems);
    super.dispose();
  }

  Future<void> _loadLibraryItems() async {
    final items = await _libraryDs.getLibraryItems();
    if (mounted) setState(() => _items = items);
  }

  void _deleteItem(String id) => _libraryDs.deleteLibraryItem(id);

  @override
  Widget build(BuildContext context) {
    final filteredData = _items.where((item) {
      final platformMatch =
          _selectedPlatform == 'All' || item.platform == _selectedPlatform;
      final typeMatch = _selectedContentType == 'All' ||
          (_selectedContentType == 'Image' && item.type == MediaType.image) ||
          (_selectedContentType == 'Video' && item.type == MediaType.video);
      return platformMatch && typeMatch;
    }).toList();

    return MainScaffold(
      currentIndex: 1,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: const [
                Icon(Icons.auto_awesome_mosaic, color: Color(0xFF0F2137)),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Content Library',
                      style: TextStyle(
                        color: Color(0xFF0F2137),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Manage your created content',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: TextButton.icon(
                  onPressed: () => context.go('/create'),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Create New',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF0F2137),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
            floating: true,
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search your content...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 5),
                  DropdownButton<String>(
                    value: _selectedContentType,
                    onChanged: (v) => setState(() => _selectedContentType = v!),
                    items: _contentTypes
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selectedPlatform,
                    onChanged: (v) => setState(() => _selectedPlatform = v!),
                    items: _platforms
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          // One full-width post per row
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = filteredData[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _ContentCard(
                    item: item,
                    onDelete: () => _deleteItem(item.id),
                    onSchedule: () {
                      // Route through GoRouter to your typed scheduler
                      context.push('/scheduler', extra: {
                        'mediaUrl': item.mediaUrl,
                        'caption': item.caption,
                        'platform': item.platform,
                        'type': item.type == MediaType.video ? 'video' : 'image',
                        'hashtags': item.hashtags,
                      });
                    },
                    onEdit: () {
                      // Demo: open editor UI
                      context.push('/editor', extra: {'item': item});
                    },
                  ),
                );
              },
              childCount: filteredData.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

class _ContentCard extends StatefulWidget {
  final LibraryItem item;
  final VoidCallback onDelete;
  final VoidCallback onSchedule;
  final VoidCallback onEdit;

  const _ContentCard({
    required this.item,
    required this.onDelete,
    required this.onSchedule,
    required this.onEdit,
  });

  @override
  State<_ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<_ContentCard> {
  bool _isHovering = false;

  Widget _hoverBtn(IconData icon, String label, VoidCallback onPressed) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon, size: 28, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onPressed,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final tags = widget.item.hashtags;
    final visible = tags.take(2).toList();
    final extraCount = tags.length - visible.length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media
          GestureDetector(
            onTap: widget.onSchedule,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: widget.item.type == MediaType.video
                      ? Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              size: 56,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : Image.network(
                          widget.item.mediaUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.error_outline,
                                size: 56,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA500),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Draft',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
                // Hover overlay (desktop/web)
                MouseRegion(
                  onEnter: (_) => setState(() => _isHovering = true),
                  onExit: (_) => setState(() => _isHovering = false),
                  child: AnimatedOpacity(
                    opacity: _isHovering ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      color: Colors.black.withOpacity(0.55),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _hoverBtn(Icons.schedule, 'Schedule', widget.onSchedule),
                          const SizedBox(width: 20),
                          _hoverBtn(Icons.edit, 'Edit', widget.onEdit),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    ...visible.map(
                      (tag) => Chip(
                        label: Text(
                          '#$tag',
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 0,
                        ),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    if (extraCount > 0)
                      Chip(
                        label: Text(
                          '+$extraCount more',
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 0,
                        ),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.item.createdAt.toIso8601String().substring(0, 10),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _IconBtn(icon: Icons.schedule, onTap: widget.onSchedule),
                    _IconBtn(icon: Icons.edit, onTap: widget.onEdit),
                    _IconBtn(icon: Icons.download_outlined, onTap: () {}),
                    _IconBtn(icon: Icons.share_outlined, onTap: () {}),
                    _IconBtn(icon: Icons.delete_outline, onTap: widget.onDelete),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.grey, size: 22),
      onPressed: onTap,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
