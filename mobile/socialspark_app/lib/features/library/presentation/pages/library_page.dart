import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socialspark_app/core/widgets/main_scaffold.dart';
import 'package:socialspark_app/features/scheduling/presentation/pages/scheduler_page.dart';
import 'package:socialspark_app/features/library/data/datasources/library_local_ds.dart';
import 'package:socialspark_app/features/library/data/models/library_item.dart';

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
    if (mounted) {
      setState(() => _items = items);
    }
  }

  void _deleteItem(String id) {
    _libraryDs.deleteLibraryItem(id);
  }

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
              children: [
                const Icon(Icons.auto_awesome_mosaic, color: Color(0xFF0F2137)),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Content Library',
                        style: TextStyle(
                            color: Color(0xFF0F2137),
                            fontWeight: FontWeight.bold)),
                    Text('Manage your created content',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                  label: const Text('Create New',
                      style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF0F2137),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search your content...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          const Icon(Icons.filter_list),
                          const SizedBox(width: 5),
                          DropdownButton<String>(
                            value: _selectedContentType,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedContentType = newValue!;
                              });
                            },
                            items: _contentTypes
                                .map<DropdownMenuItem<String>>(
                                    (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            value: _selectedPlatform,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedPlatform = newValue!;
                              });
                            },
                            items: _platforms
                                .map<DropdownMenuItem<String>>(
                                    (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.52, // Adjusted for more height
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = filteredData[index];
                  return _ContentCard(
                    item: item,
                    onDelete: () => _deleteItem(item.id),
                    onSchedule: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SchedulerPage(
                            item: item,
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: filteredData.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentCard extends StatefulWidget {
  final LibraryItem item;
  final VoidCallback onDelete;
  final VoidCallback onSchedule;

  const _ContentCard({
    required this.item,
    required this.onDelete,
    required this.onSchedule,
  });

  @override
  State<_ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<_ContentCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: widget.onSchedule,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: (widget.item.type == MediaType.video)
                      ? Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              size: 50,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : Image.network(
                          widget.item.mediaUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  size: 50,
                                  color: Colors.black54,
                                ),
                              ),
                            );
                          },
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
                MouseRegion(
                  onEnter: (_) => setState(() => _isHovering = true),
                  onExit: (_) => setState(() => _isHovering = false),
                  child: AnimatedOpacity(
                    opacity: _isHovering ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.schedule, size: 40, color: Colors.white),
                              onPressed: widget.onSchedule,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Schedule Post',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.caption,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: widget.item.hashtags
                      .map((tag) => Chip(
                            label: Text('#$tag',
                                style: const TextStyle(fontSize: 10)),
                            backgroundColor: Colors.grey[200],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 0),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.item.createdAt.toIso8601String().substring(0, 10),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ActionButton(
                        icon: Icons.schedule, onPressed: widget.onSchedule),
                    _ActionButton(
                        icon: Icons.download_outlined, onPressed: () {}),
                    _ActionButton(
                        icon: Icons.share_outlined, onPressed: () {}),
                    _ActionButton(
                        icon: Icons.delete_outline, onPressed: widget.onDelete),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.grey, size: 20),
      onPressed: onPressed,
      constraints: const BoxConstraints(),
      padding: EdgeInsets.zero,
    );
  }
}
