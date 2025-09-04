import 'package:flutter/material.dart';
import 'package:socialspark_app/core/widgets/main_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:socialspark_app/features/library/data/library_data_service.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String _selectedPlatform = 'All';
  String _selectedContentType = 'All';

  final List<String> _platforms = ['All', 'Instagram', 'TikTok'];
  final List<String> _contentTypes = ['All', 'Image', 'Video'];

  final List<Map<String, dynamic>> _dummyData = LibraryDataService.getData();

  void _deleteItem(int index) {
    setState(() {
      LibraryDataService.deleteItem(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _dummyData.where((item) {
      final platformMatch =
          _selectedPlatform == 'All' || item['platform'] == _selectedPlatform;
      final typeMatch = _selectedContentType == 'All' ||
          item['type'] == _selectedContentType;
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
                const Icon(Icons.auto_awesome_mosaic,
                    color: Color(0xFF0F2137)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
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
                  onPressed: () {},
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
                  // Search and filter options
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
                      // Filter and view options
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
                childAspectRatio:
                    0.55, // Adjust aspect ratio for more image space
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = filteredData[index];
                  return _ContentCard(
                    status: item['status']!,
                    image: item['image']!,
                    title: item['title']!,
                    description: item['description']!,
                    tags: item['tags'] as List<String>,
                    date: item['date']!,
                    platform: item['platform']!,
                    type: item['type']!,
                    onDelete: () => _deleteItem(index),
                    onSchedule: () {
                      context.go('/scheduler', extra: {
                        'item': item,
                        'index': _dummyData.indexOf(item),
                      });
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
  final String status;
  final String image;
  final String title;
  final String description;
  final List<String> tags;
  final String date;
  final String platform;
  final String type;
  final VoidCallback onDelete;
  final VoidCallback onSchedule;

  const _ContentCard({
    required this.status,
    required this.image,
    required this.title,
    required this.description,
    required this.tags,
    required this.date,
    required this.platform,
    required this.type,
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
          // Image with status badge and hover effect
          MouseRegion(
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) => setState(() => _isHovering = false),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.asset(
                    widget.image,
                    height: 180, // Increased image height
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.status == 'published'
                          ? const Color(0xFF0F2137)
                          : widget.status == 'scheduled'
                              ? Colors.blue
                              : const Color(0xFFFFA500),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.status,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
                if (_isHovering)
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _HoverButton(
                            icon: Icons.schedule,
                            onPressed: widget.onSchedule,
                          ),
                          const SizedBox(width: 16),
                          _HoverButton(icon: Icons.edit, onPressed: () {}),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Content details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: widget.tags
                      .map((tag) => Chip(
                            label:
                                Text(tag, style: const TextStyle(fontSize: 10)),
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
                  widget.date,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const SizedBox(height: 8),
                // Action buttons
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
                        icon: Icons.delete_outline,
                        onPressed: widget.onDelete),
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

class _HoverButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _HoverButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFA500).withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
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
