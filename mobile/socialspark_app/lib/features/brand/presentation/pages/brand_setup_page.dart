import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/session_store.dart';
import '../controller/brand_setup_controller.dart';

class BrandSetupPage extends StatefulWidget {
  const BrandSetupPage({super.key});
  @override
  State<BrandSetupPage> createState() => _BrandSetupPageState();
}

class _BrandSetupPageState extends State<BrandSetupPage> {
  final _name = TextEditingController(text: 'Addis Coffee House');
  final _desc = TextEditingController(text: 'Premium Ethiopian coffee experience in the heart of Addis Ababa');
  final _hashtag = TextEditingController();

  String _type = 'Cafe/Restaurant';
  String _voice = 'Friendly & Casual';
  String _audience = 'Coffee Enthusiasts';

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<BrandSetupController>();
    final draft = ctrl.draft;

    return Scaffold(
      appBar: AppBar(title: const Text('Set up your brand')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Business Info
          const Text('Business Information', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Business Name', border: OutlineInputBorder()),
            onChanged: ctrl.setBusinessName,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _type,
            items: const [
              DropdownMenuItem(value: 'Cafe/Restaurant', child: Text('Cafe/Restaurant')),
              DropdownMenuItem(value: 'Fashion/Retail', child: Text('Fashion/Retail')),
              DropdownMenuItem(value: 'Services', child: Text('Services')),
            ],
            onChanged: (v) => setState(() { _type = v!; ctrl.setBusinessType(_type); }),
            decoration: const InputDecoration(labelText: 'Business Type', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Business Description', border: OutlineInputBorder()),
            onChanged: ctrl.setDescription,
          ),
          const SizedBox(height: 24),

          // Colors & Logo
          const Text('Brand Colors', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _colorBox('Primary', draft.primary)),
              const SizedBox(width: 8),
              Expanded(child: _colorBox('Secondary', draft.secondary)),
              const SizedBox(width: 8),
              Expanded(child: _colorBox('Accent', draft.accent)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Brand Logo', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
            ),
            child: const Center(child: Text('Upload logo placeholder')),
          ),
          const SizedBox(height: 24),

          // Hashtags
          const Text('Default Hashtags', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _hashtag,
            onSubmitted: (v) {
              ctrl.addHashtag(v);
              _hashtag.clear();
            },
            decoration: const InputDecoration(hintText: 'Add hashtag', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: draft.defaultHashtags.map((h) => Chip(
              label: Text('#$h'),
              deleteIcon: const Icon(Icons.close),
              onDeleted: () => ctrl.removeHashtag(h),
            )).toList(),
          ),
          const SizedBox(height: 24),

          // Voice & Audience
          const Text('Brand Voice & Audience', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _voice,
            items: const [
              DropdownMenuItem(value: 'Friendly & Casual', child: Text('Friendly & Casual')),
              DropdownMenuItem(value: 'Bold & Energetic', child: Text('Bold & Energetic')),
              DropdownMenuItem(value: 'Professional & Helpful', child: Text('Professional & Helpful')),
            ],
            onChanged: (v) => setState(() { _voice = v!; ctrl.setVoice(_voice); }),
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Brand Voice'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _audience,
            items: const [
              DropdownMenuItem(value: 'Coffee Enthusiasts', child: Text('Coffee Enthusiasts')),
              DropdownMenuItem(value: 'Fashion Shoppers', child: Text('Fashion Shoppers')),
              DropdownMenuItem(value: 'Foodies', child: Text('Foodies')),
            ],
            onChanged: (v) => setState(() { _audience = v!; ctrl.setAudience(_audience); }),
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Target Audience'),
          ),
          const SizedBox(height: 24),

          FilledButton(
            onPressed: () async {
              await context.read<SessionStore>().completeBrandSetup();
              if (mounted) context.go('/dashboard');
            },
            child: const Text('Continue'),
          )
        ],
      ),
    );
  }

  Widget _colorBox(String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        Container(height: 36, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8))),
      ],
    );
  }
}
